-- Aplicar después de 20261022_paquete_compacto.sql. No modifica proyectos existentes.
-- Los cambios mantienen concurrencia por revisión de proyecto, permisos por módulo
-- y UUID idempotentes. No se combinan escrituras concurrentes silenciosamente.
begin;

do $precondiciones$
begin
    if to_regprocedure('myg_nube_privado.expandir_paquete(jsonb)') is null then
        raise exception 'Aplique primero 20261022_paquete_compacto.sql';
    end if;
end $precondiciones$;

create table if not exists myg_nube_privado.historial_cambios (
    proyecto_id uuid not null references public.myg_nube_proyectos(id) on delete cascade,
    revision bigint not null,
    revision_base bigint not null check(revision_base > 0 and revision = revision_base + 1),
    usuario_id uuid not null,
    operacion_id uuid not null,
    cambios jsonb not null,
    creado_en timestamptz not null default clock_timestamp(),
    primary key(proyecto_id, revision)
);
revoke all on myg_nube_privado.historial_cambios from public, anon, authenticated, service_role;

create or replace function myg_nube_privado.cambiar_coleccion(
    p_anterior jsonb, p_cambio jsonb, p_identidad text)
returns jsonb language plpgsql immutable set search_path to pg_catalog
as $func$
declare
    v_mapa jsonb; v_salida jsonb; v_ids text[]; v_bajas text[];
    v_id text; v_elemento jsonb; v_total integer;
begin
    if jsonb_typeof(p_anterior) is distinct from 'array'
       or jsonb_typeof(p_cambio) is distinct from 'object'
       or not p_cambio ?& array['poner','quitar','orden']
       or p_cambio - array['poner','quitar','orden'] <> '{}'::jsonb
       or jsonb_typeof(p_cambio->'poner') is distinct from 'array'
       or jsonb_typeof(p_cambio->'quitar') is distinct from 'array'
       or jsonb_typeof(p_cambio->'orden') is distinct from 'array' then
        raise exception using errcode='22023',message='MYG_CAMBIOS_INVALIDOS';
    end if;
    if exists(select 1 from jsonb_array_elements(p_anterior) e
        where jsonb_typeof(e) is distinct from 'object'
           or jsonb_typeof(e->p_identidad) is distinct from 'string'
           or btrim(e->>p_identidad)='') then
        raise exception using errcode='22023',message='MYG_COLECCION_INVALIDA';
    end if;
    select coalesce(jsonb_object_agg(e->>p_identidad,e),'{}'::jsonb), count(*)
      into v_mapa,v_total from jsonb_array_elements(p_anterior) e;
    if (select count(*) from jsonb_object_keys(v_mapa)) <> v_total then
        raise exception using errcode='22023',message='MYG_IDENTIDAD_REPETIDA';
    end if;
    v_bajas:=array[]::text[];
    for v_elemento in select value from jsonb_array_elements(p_cambio->'quitar') loop
        if jsonb_typeof(v_elemento) is distinct from 'string' then
            raise exception using errcode='22023',message='MYG_CAMBIOS_INVALIDOS';
        end if;
        v_id:=v_elemento#>>'{}';
        if v_id=any(v_bajas) or not v_mapa ? v_id then
            raise exception using errcode='22023',message='MYG_BAJA_INVALIDA';
        end if;
        v_bajas:=array_append(v_bajas,v_id); v_mapa:=v_mapa-v_id;
    end loop;
    v_ids:=array[]::text[];
    for v_elemento in select value from jsonb_array_elements(p_cambio->'poner') loop
        if jsonb_typeof(v_elemento) is distinct from 'object'
           or jsonb_typeof(v_elemento->p_identidad) is distinct from 'string'
           or btrim(v_elemento->>p_identidad)='' then
            raise exception using errcode='22023',message='MYG_CAMBIOS_INVALIDOS';
        end if;
        v_id:=v_elemento->>p_identidad;
        if v_id=any(v_ids) or v_id=any(v_bajas) then
            raise exception using errcode='22023',message='MYG_IDENTIDAD_REPETIDA';
        end if;
        v_ids:=array_append(v_ids,v_id);
        v_mapa:=v_mapa||jsonb_build_object(v_id,v_elemento);
    end loop;
    if exists(select 1 from jsonb_array_elements(p_cambio->'orden') e
        where jsonb_typeof(e) is distinct from 'string') then
        raise exception using errcode='22023',message='MYG_ORDEN_INVALIDO';
    end if;
    select coalesce(array_agg(value#>>'{}' order by ord),array[]::text[])
      into v_ids from jsonb_array_elements(p_cambio->'orden') with ordinality d(value,ord);
    if cardinality(v_ids) <> (select count(*) from jsonb_object_keys(v_mapa))
       or cardinality(v_ids) <> (select count(distinct x) from unnest(v_ids) x)
       or exists(select 1 from unnest(v_ids) x where not v_mapa ? x) then
        raise exception using errcode='22023',message='MYG_ORDEN_INVALIDO';
    end if;
    select coalesce(jsonb_agg(v_mapa->x order by ord),'[]'::jsonb)
      into v_salida from unnest(v_ids) with ordinality d(x,ord);
    return v_salida;
end $func$;

create or replace function myg_nube_privado.aplicar_rutas(p_anterior jsonb,p_cambios jsonb)
returns jsonb language plpgsql immutable set search_path to pg_catalog,myg_nube_privado
as $func$
declare
    v_resultado jsonb:=p_anterior; v_operacion jsonb; v_ruta text[]; v_padre jsonb;
    v_segmento text; v_indice integer; i integer; v_quitar boolean;
begin
    if jsonb_typeof(p_cambios) is distinct from 'object'
       or p_cambios->'version' is distinct from '2'::jsonb
       or p_cambios-array['version','operaciones'] <> '{}'::jsonb
       or jsonb_typeof(p_cambios->'operaciones') is distinct from 'array'
       or jsonb_array_length(p_cambios->'operaciones')>4096 then
        raise exception using errcode='22023',message='MYG_RUTAS_INVALIDAS';
    end if;
    for v_operacion in select value from jsonb_array_elements(p_cambios->'operaciones') loop
        if jsonb_typeof(v_operacion) is distinct from 'object'
           or (select count(*) from jsonb_object_keys(v_operacion))<>2
           or jsonb_typeof(v_operacion->'ruta') is distinct from 'array'
           or jsonb_array_length(v_operacion->'ruta') not between 1 and 126
           or exists(select 1 from jsonb_array_elements(v_operacion->'ruta') s where jsonb_typeof(s)<>'string') then
            raise exception using errcode='22023',message='MYG_RUTAS_INVALIDAS';
        end if;
        v_quitar:=v_operacion?'quitar';
        if (v_quitar and v_operacion->'quitar' is distinct from 'true'::jsonb)
           or (not v_quitar and not v_operacion?'valor') then
            raise exception using errcode='22023',message='MYG_RUTAS_INVALIDAS';
        end if;
        select array_agg(value#>>'{}' order by ord) into v_ruta
          from jsonb_array_elements(v_operacion->'ruta') with ordinality d(value,ord);
        if v_ruta[1] not in ('formato','version','alcance','documento','textos','avisos','exclusiones','documentos','tablas','recursos') then
            raise exception using errcode='22023',message='MYG_RUTAS_INVALIDAS';
        end if;
        v_padre:=v_resultado;
        for i in 1..cardinality(v_ruta) loop
            v_segmento:=v_ruta[i];
            if jsonb_typeof(v_padre)='array' then
                if v_segmento!~'^(0|[1-9][0-9]*)$' or length(v_segmento)>10 then
                    raise exception using errcode='22023',message='MYG_INDICE_INVALIDO';
                end if;
                if v_segmento::bigint>2147483647 then
                    raise exception using errcode='22023',message='MYG_INDICE_INVALIDO';
                end if;
                v_indice:=v_segmento::integer;
                if v_indice>=jsonb_array_length(v_padre) or (i=cardinality(v_ruta) and v_quitar) then
                    raise exception using errcode='22023',message='MYG_INDICE_INVALIDO';
                end if;
                if i<cardinality(v_ruta) then v_padre:=v_padre->v_indice; end if;
            elsif jsonb_typeof(v_padre)='object' then
                if (i<cardinality(v_ruta) or v_quitar) and not v_padre?v_segmento then
                    raise exception using errcode='22023',message='MYG_RUTA_INEXISTENTE';
                end if;
                if i<cardinality(v_ruta) then v_padre:=v_padre->v_segmento; end if;
            else
                raise exception using errcode='22023',message='MYG_RUTA_INEXISTENTE';
            end if;
        end loop;
        if v_quitar then v_resultado:=v_resultado#-v_ruta;
        else v_resultado:=jsonb_set(v_resultado,v_ruta,v_operacion->'valor',true); end if;
    end loop;
    return v_resultado;
end $func$;

create or replace function myg_nube_privado.aplicar_cambios(p_anterior jsonb,p_cambios jsonb)
returns jsonb language plpgsql immutable set search_path to pg_catalog,myg_nube_privado
as $func$
declare v_resultado jsonb; v_nombre text; v_identidad text;
begin
    if jsonb_typeof(p_anterior) is distinct from 'object'
       or p_anterior->>'formato' is distinct from 'MYG_COLABORACION'
       or p_anterior->'version' is distinct from '2'::jsonb then
        raise exception using errcode='22023',message='MYG_PAQUETE_COMPACTO_REQUERIDO';
    end if;
    if p_cambios->'version'='2'::jsonb then
        v_resultado:=myg_nube_privado.aplicar_rutas(p_anterior,p_cambios);
        if v_resultado->>'formato' is distinct from 'MYG_COLABORACION'
           or v_resultado->'version' is distinct from '2'::jsonb then
            raise exception using errcode='22023',message='MYG_PAQUETE_COMPACTO_REQUERIDO';
        end if;
        return v_resultado;
    end if;
    if jsonb_typeof(p_cambios) is distinct from 'object'
       or p_cambios->'version' is distinct from '1'::jsonb
       or jsonb_typeof(p_cambios->'campos') is distinct from 'object'
       or p_cambios-array['version','campos','documentos','tablas','recursos'] <> '{}'::jsonb
       or (p_cambios->'campos')-array['formato','version','alcance','documento','textos','avisos','exclusiones'] <> '{}'::jsonb then
        raise exception using errcode='22023',message='MYG_CAMBIOS_INVALIDOS';
    end if;
    v_resultado:=p_anterior||(p_cambios->'campos');
    foreach v_nombre in array array['documentos','tablas','recursos'] loop
        if p_cambios ? v_nombre then
            v_identidad:=case v_nombre when 'documentos' then 'Id' when 'tablas' then 'Nombre' else 'Referencia' end;
            v_resultado:=jsonb_set(v_resultado,array[v_nombre],
                myg_nube_privado.cambiar_coleccion(p_anterior->v_nombre,p_cambios->v_nombre,v_identidad));
        end if;
    end loop;
    if v_resultado->>'formato' is distinct from 'MYG_COLABORACION'
       or v_resultado->'version' is distinct from '2'::jsonb then
        raise exception using errcode='22023',message='MYG_PAQUETE_COMPACTO_REQUERIDO';
    end if;
    return v_resultado;
end $func$;

-- Recuperación interna sin copiar un snapshot completo por cada edición.
-- Las escrituras antiguas siguen dejando checkpoints en el historial existente.
create or replace function myg_nube_privado.reconstruir_revision(p_id uuid,p_revision bigint)
returns jsonb language plpgsql stable security definer
set search_path to pg_catalog,myg_nube_privado
as $func$
declare v_contenido jsonb; v_revision bigint; v_delta jsonb; v_checkpoint jsonb;
begin
    select revision,contenido into v_revision,v_contenido from public.myg_nube_historial
      where proyecto_id=p_id and revision<=p_revision order by revision desc limit 1;
    if v_revision is null then
        raise exception using errcode='22023',message='MYG_REVISION_NO_RECUPERABLE';
    end if;
    while v_revision<p_revision loop
        select contenido into v_checkpoint from public.myg_nube_historial
          where proyecto_id=p_id and revision=v_revision+1;
        if found then
            v_contenido:=v_checkpoint;
        else
            select cambios into v_delta from myg_nube_privado.historial_cambios
              where proyecto_id=p_id and revision_base=v_revision and revision=v_revision+1;
            if not found then
                raise exception using errcode='22023',message='MYG_REVISION_NO_RECUPERABLE';
            end if;
            v_contenido:=myg_nube_privado.aplicar_cambios(v_contenido,v_delta);
        end if;
        v_revision:=v_revision+1;
    end loop;
    return v_contenido;
end $func$;

create or replace function public.myg_nube_revision(p_id uuid)
returns jsonb language plpgsql stable security definer
set search_path to pg_catalog,myg_nube_privado
as $func$
declare v_usuario uuid:=myg_nube_privado.identidad(); v_resultado jsonb;
begin
    select jsonb_build_object('id',p.id,'codigo',p.codigo,'nombre',p.nombre,'rol',m.rol,
        'revision',p.revision,'alcance',p.alcance,'permisos_modulos',m.permisos_modulos)
      into v_resultado from public.myg_nube_proyectos p
      join public.myg_nube_miembros m on m.proyecto_id=p.id and m.usuario_id=v_usuario
      where p.id=p_id;
    if v_resultado is null then
        raise exception using errcode='42501',message='MYG_ACCESO_DENEGADO';
    end if;
    return v_resultado;
end $func$;

create or replace function public.myg_nube_guardar_cambios(
    p_id uuid,p_operacion uuid,p_revision bigint,p_cambios jsonb)
returns jsonb language plpgsql security definer
set search_path to pg_catalog,myg_nube_privado set statement_timeout to '60s'
as $func$
declare
    v_usuario uuid:=myg_nube_privado.identidad();
    v_proyecto public.myg_nube_proyectos%rowtype;
    v_anterior public.myg_nube_operaciones%rowtype;
    v_rol text; v_permisos jsonb; v_solicitud jsonb; v_respuesta jsonb; v_nuevo jsonb;
begin
    if p_operacion is null or p_operacion='00000000-0000-0000-0000-000000000000'::uuid
       or p_revision is null or p_revision<1 or p_revision=9223372036854775807
       or jsonb_typeof(p_cambios) is distinct from 'object'
       or p_cambios->'version' not in ('1'::jsonb,'2'::jsonb)
       or p_cambios->'version' is null
       or (p_cambios->'version'='1'::jsonb and jsonb_typeof(p_cambios->'campos') is distinct from 'object')
       or (p_cambios->'version'='2'::jsonb and jsonb_typeof(p_cambios->'operaciones') is distinct from 'array')
       or octet_length(p_cambios::text)>133169152 then
        raise exception using errcode='22023',message='MYG_CAMBIOS_INVALIDOS';
    end if;
    select * into v_proyecto from public.myg_nube_proyectos where id=p_id for update;
    select rol,permisos_modulos into v_rol,v_permisos from public.myg_nube_miembros
      where proyecto_id=p_id and usuario_id=v_usuario;
    -- Un reintento nunca recupera acceso revocado, ni siquiera si antes fue aplicado.
    if v_proyecto.id is null or v_rol is null or v_rol not in ('propietario','administrador','editor') then
        raise exception using errcode='42501',message='MYG_ACCESO_DENEGADO';
    end if;
    perform pg_advisory_xact_lock(hashtextextended('myg-nube-op:'||v_usuario::text||':'||p_operacion::text,0));
    v_solicitud:=jsonb_build_object('tipo','cambios','revision',p_revision,'cambios',p_cambios);
    select * into v_anterior from public.myg_nube_operaciones
      where usuario_id=v_usuario and operacion_id=p_operacion;
    if found then
        if v_anterior.proyecto_id<>p_id or v_anterior.solicitud<>v_solicitud then
            raise exception using errcode='22023',message='MYG_UUID_REUTILIZADO_CON_OTRO_CUERPO';
        end if;
        return v_anterior.respuesta;
    end if;
    if v_proyecto.revision<>p_revision then
        -- Los conflictos conservan la respuesta exacta, aunque cambie el estado posterior.
        v_respuesta:=jsonb_build_object('estado','conflicto','revision',v_proyecto.revision,
            'contenido',v_proyecto.contenido,'operacion_id',p_operacion);
    else
        v_nuevo:=myg_nube_privado.aplicar_cambios(v_proyecto.contenido,p_cambios);
        perform myg_nube_privado.validar_contenido(v_nuevo);
        if v_nuevo->>'alcance' is distinct from v_proyecto.alcance then
            raise exception using errcode='22023',message='MYG_ALCANCE_INVALIDO';
        end if;
        perform myg_nube_privado.exigir_modulos(v_proyecto.contenido,v_nuevo,v_permisos);
        -- Primer cambio incremental: asegurar una base de reconstrucción, sin alterar
        -- snapshots existentes. En adelante se guarda un checkpoint cada 20 revisiones.
        if not exists(select 1 from myg_nube_privado.historial_cambios where proyecto_id=p_id) then
            insert into public.myg_nube_historial(proyecto_id,revision,usuario_id,contenido)
              values(p_id,v_proyecto.revision,v_usuario,v_proyecto.contenido) on conflict(proyecto_id,revision) do nothing;
        end if;
        update public.myg_nube_proyectos set contenido=v_nuevo,revision=revision+1,
            actualizado_en=clock_timestamp() where id=p_id returning * into v_proyecto;
        insert into myg_nube_privado.historial_cambios(proyecto_id,revision,revision_base,usuario_id,operacion_id,cambios)
          values(p_id,v_proyecto.revision,p_revision,v_usuario,p_operacion,p_cambios);
        if mod(v_proyecto.revision,20)=0 then
            insert into public.myg_nube_historial(proyecto_id,revision,usuario_id,operacion_id,contenido)
              values(p_id,v_proyecto.revision,v_usuario,p_operacion,v_nuevo);
        end if;
        -- La solicitud ya contiene solo cambios; el ACK no duplica la base entera.
        v_respuesta:=jsonb_build_object('estado','aplicada','revision',v_proyecto.revision,'operacion_id',p_operacion);
    end if;
    insert into public.myg_nube_operaciones(usuario_id,operacion_id,proyecto_id,solicitud,respuesta)
      values(v_usuario,p_operacion,p_id,v_solicitud,v_respuesta);
    return v_respuesta;
end $func$;

create or replace function public.myg_nube_capacidades()
returns jsonb language plpgsql stable security definer
set search_path to pg_catalog,myg_nube_privado
as $func$
begin
    perform myg_nube_privado.identidad();
    return jsonb_build_object('paquete_compacto',2,'cambios',1,'historial_intervalo',20);
end $func$;

revoke all on function myg_nube_privado.cambiar_coleccion(jsonb,jsonb,text) from public,anon,authenticated,service_role;
revoke all on function myg_nube_privado.aplicar_rutas(jsonb,jsonb) from public,anon,authenticated,service_role;
revoke all on function myg_nube_privado.aplicar_cambios(jsonb,jsonb) from public,anon,authenticated,service_role;
revoke all on function myg_nube_privado.reconstruir_revision(uuid,bigint) from public,anon,authenticated,service_role;
revoke all on function public.myg_nube_revision(uuid) from public,anon;
revoke all on function public.myg_nube_guardar_cambios(uuid,uuid,bigint,jsonb) from public,anon;
revoke all on function public.myg_nube_capacidades() from public,anon;
grant execute on function public.myg_nube_revision(uuid) to authenticated,service_role;
grant execute on function public.myg_nube_guardar_cambios(uuid,uuid,bigint,jsonb) to authenticated,service_role;
grant execute on function public.myg_nube_capacidades() to authenticated,service_role;
notify pgrst,'reload schema';
commit;
