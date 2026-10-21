-- Formato portable compacto v2. Ejecutar después de 20261021_contenido_grande.sql.
-- Repetible: no convierte ni reescribe proyectos, historial u operaciones previos.
-- El paquete se almacena COMPACTO. La expansión existe únicamente para verificar
-- tipos y comparar los módulos protegidos con el guard ya probado de v1.
begin;

do $preflight$
declare v record; v_def text;
begin
    for v in select * from (values
        ('validar_contenido','jsonb','void'),
        ('exigir_modulos','jsonb,jsonb,jsonb','void')
    ) r(nombre,argumentos,resultado) loop
        if not exists(select 1 from pg_proc p where p.oid=to_regprocedure(
            'myg_nube_privado.'||v.nombre||'('||v.argumentos||')')
            and p.prorettype=to_regtype(v.resultado) and p.provolatile='i' and not p.prosecdef) then
            raise exception 'Migración cancelada: falta el auxiliar compatible %.',v.nombre;
        end if;
        if to_regprocedure('myg_nube_privado.'||v.nombre||'_v1('||v.argumentos||')') is null then
            select pg_get_functiondef(p.oid) into v_def from pg_proc p
            where p.oid=to_regprocedure('myg_nube_privado.'||v.nombre||'('||v.argumentos||')');
            if v.nombre='validar_contenido' and strpos(v_def,'MYG_CONTENIDO_INVALIDO_MAX_127_MIB')=0 then
                raise exception 'Migración cancelada: aplique primero 20261021_contenido_grande.sql.';
            end if;
            -- Copiar, en vez de renombrar, mantiene los OID originales. También
            -- las sesiones que ya ejecutaron los RPC reciben el nuevo validador.
            v_def:=replace(v_def,'FUNCTION myg_nube_privado.'||v.nombre||'(',
                'FUNCTION myg_nube_privado.'||v.nombre||'_v1(');
            execute v_def;
        elsif not exists(select 1 from pg_proc p where p.oid=to_regprocedure(
            'myg_nube_privado.'||v.nombre||'('||v.argumentos||')')
            and strpos(p.prosrc,'myg_nube_privado.expandir_paquete')>0) then
            raise exception 'Migración cancelada: el auxiliar % cambió después de guardar su versión anterior.',v.nombre;
        end if;
    end loop;
end $preflight$;

create or replace function myg_nube_privado.expandir_celda(p_celda jsonb,p_textos jsonb,p_documentos jsonb,p_tabla text,p_columna text,p_materializar boolean)
returns jsonb language plpgsql immutable set search_path=pg_catalog as $function$
declare v_tag text; v_valor text; v_indice numeric; v_real double precision; v_documento jsonb;
begin
    if p_celda='null'::jsonb then
        return case when p_materializar then '{"Tipo":"nulo","Valor":null}'::jsonb else null end;
    elsif jsonb_typeof(p_celda)='string' then
        return case when p_materializar then jsonb_build_object('Tipo','texto','Valor',p_celda) else null end;
    elsif jsonb_typeof(p_celda) is distinct from 'array' then
        raise exception using errcode='22023',message='MYG_CELDA_COMPACTA_INVALIDA';
    end if;
    if jsonb_array_length(p_celda)<>2 or jsonb_typeof(p_celda->0) is distinct from 'string' then
        raise exception using errcode='22023',message='MYG_CELDA_COMPACTA_INVALIDA';
    end if;
    v_tag:=p_celda->>0;
    if v_tag='s' then
        if jsonb_typeof(p_celda->1) is distinct from 'number'
            or (p_celda->>1)!~'^(0|[1-9][0-9]*)$' then
            raise exception using errcode='22023',message='MYG_REFERENCIA_COMPACTA_INVALIDA';
        end if;
        v_indice:=(p_celda->>1)::numeric;
        if v_indice>=jsonb_array_length(p_textos) then
            raise exception using errcode='22023',message='MYG_REFERENCIA_COMPACTA_INVALIDA';
        end if;
        return case when p_materializar then jsonb_build_object('Tipo','texto','Valor',p_textos->v_indice::integer) else null end;
    end if;
    if v_tag='d' then
        if p_tabla<>'myg_proyecto' or p_columna<>'json_documento'
            or jsonb_typeof(p_celda->1) is distinct from 'string' then
            raise exception using errcode='22023',message='MYG_REFERENCIA_DOCUMENTO_INVALIDA';
        end if;
        v_documento:=p_documentos->(p_celda->>1);
        if v_documento is null then
            raise exception using errcode='22023',message='MYG_REFERENCIA_DOCUMENTO_INVALIDA';
        end if;
        return case when p_materializar then jsonb_build_object('Tipo','texto','Valor',v_documento::text) else null end;
    end if;
    if v_tag not in ('i','r','b') or jsonb_typeof(p_celda->1) is distinct from 'string' then
        raise exception using errcode='22023',message='MYG_CELDA_COMPACTA_INVALIDA';
    end if;
    v_valor:=p_celda->>1;
    begin
        if v_tag='i' then
            if v_valor!~'^[+-]?[0-9]+$' then raise invalid_text_representation; end if;
            perform v_valor::bigint;
        elsif v_tag='r' then
            v_real:=v_valor::double precision;
            if v_real in ('NaN'::float8,'Infinity'::float8,'-Infinity'::float8) then
                raise invalid_text_representation;
            end if;
        else
            perform decode(v_valor,'base64');
        end if;
    exception when invalid_text_representation or numeric_value_out_of_range or invalid_parameter_value then
        raise exception using errcode='22023',message='MYG_CELDA_COMPACTA_VALOR_INVALIDO';
    end;
    if not p_materializar then return null; end if;
    return jsonb_build_object('Tipo',case v_tag when 'i' then 'entero' when 'r' then 'real' else 'blob' end,'Valor',v_valor);
end $function$;

create or replace function myg_nube_privado.expandir_paquete(p_contenido jsonb,p_materializar boolean)
returns jsonb language plpgsql immutable set search_path=pg_catalog as $function$
declare
    v_textos jsonb; v_tabla jsonb; v_tablas jsonb[]:=array[]::jsonb[];
    v_fila jsonb; v_celdas jsonb; v_nombre text;
    v_nombres text[]:=array[]::text[]; v_documentos jsonb; v_ids text[];
    v_documento jsonb; v_id text; v_total integer; v_documentos_mapa jsonb;
    v_bytes bigint; v_ref jsonb; v_textos_bytes bigint[]; v_documentos_bytes jsonb;
begin
    -- Los paquetes anteriores y los objetos de pruebas/baseline mantienen su
    -- contrato previo. No interpretar marcadores v2 con casing alternativo.
    if jsonb_typeof(p_contenido) is distinct from 'object'
        or p_contenido->>'formato' is distinct from 'MYG_COLABORACION' then return p_contenido; end if;
    if p_contenido->'version' is distinct from '2'::jsonb then
        if p_contenido->>'formato'='MYG_COLABORACION'
            and p_contenido ? 'version' and p_contenido->'version' is distinct from '1'::jsonb then
            raise exception using errcode='22023',message='MYG_PAQUETE_VERSION_NO_COMPATIBLE';
        end if;
        return p_contenido;
    end if;
    if p_contenido->>'formato' is distinct from 'MYG_COLABORACION'
        or p_contenido->>'version'<>'2'
        or not p_contenido ?& array['formato','version','alcance','documento','documentos','tablas','recursos','textos']
        or p_contenido-array['formato','version','alcance','documento','documentos','tablas','recursos','textos','avisos','exclusiones']<>'{}'::jsonb
        or p_contenido->>'alcance' is null or p_contenido->>'alcance' not in ('obra','base')
        or jsonb_typeof(p_contenido->'documento') is distinct from 'object'
        or jsonb_typeof(p_contenido->'documentos') is distinct from 'array'
        or jsonb_typeof(p_contenido->'tablas') is distinct from 'array'
        or jsonb_typeof(p_contenido->'recursos') is distinct from 'array' then
        raise exception using errcode='22023',message='MYG_PAQUETE_COMPACTO_INVALIDO';
    end if;
    v_textos:=p_contenido->'textos';
    if jsonb_typeof(v_textos) is distinct from 'array'
        or exists(select 1 from jsonb_array_elements(v_textos) where jsonb_typeof(value)<>'string')
        or (select count(*)<>count(distinct value) from jsonb_array_elements(v_textos)) then
        raise exception using errcode='22023',message='MYG_TEXTOS_COMPACTOS_INVALIDOS';
    end if;
    v_id:=p_contenido#>>'{documento,Id}';
    if jsonb_typeof(p_contenido#>'{documento,Id}') is distinct from 'string' or nullif(btrim(v_id),'') is null
        or (select count(*)<>count(distinct lower(key)) from jsonb_object_keys(p_contenido->'documento') k(key)) then
        raise exception using errcode='22023',message='MYG_DOCUMENTOS_COMPACTOS_INVALIDOS';
    end if;
    v_ids:=array[upper(v_id)];
    v_documentos_mapa:=jsonb_build_object(v_id,p_contenido->'documento');
    for v_documento in select value from jsonb_array_elements(p_contenido->'documentos') loop
        v_id:=v_documento->>'Id';
        if jsonb_typeof(v_documento) is distinct from 'object'
            or jsonb_typeof(v_documento->'Id') is distinct from 'string'
            or nullif(btrim(v_id),'') is null or upper(v_id)=any(v_ids)
            or (select count(*)<>count(distinct lower(key)) from jsonb_object_keys(v_documento) k(key)) then
            raise exception using errcode='22023',message='MYG_DOCUMENTOS_COMPACTOS_INVALIDOS';
        end if;
        v_ids:=array_append(v_ids,upper(v_id));
        v_documentos_mapa:=v_documentos_mapa||jsonb_build_object(v_id,v_documento);
    end loop;
    v_documentos:=(p_contenido->'documentos')||jsonb_build_array(p_contenido->'documento');
    select coalesce(array_agg(octet_length(value::text)::bigint order by ord),array[]::bigint[])
        into v_textos_bytes from jsonb_array_elements(v_textos) with ordinality d(value,ord);
    select coalesce(jsonb_object_agg(key,octet_length(to_jsonb(value::text)::text)),'{}'::jsonb)
        into v_documentos_bytes from jsonb_each(v_documentos_mapa);
    -- Estimar referencias ANTES de materializar sus valores. Un diccionario
    -- pequeño no debe permitir expandir varios GiB en memoria del servidor.
    v_bytes:=octet_length(p_contenido::text)+octet_length((p_contenido->'documento')::text);
    for v_tabla in select value from jsonb_array_elements(p_contenido->'tablas') loop
        v_nombre:=v_tabla->>'Nombre';
        if jsonb_typeof(v_tabla) is distinct from 'object'
            or not v_tabla ?& array['Nombre','Columnas','Filas']
            or v_tabla-array['Nombre','Columnas','Filas']<>'{}'::jsonb
            or jsonb_typeof(v_tabla->'Nombre') is distinct from 'string'
            or nullif(btrim(v_nombre),'') is null or lower(v_nombre)=any(v_nombres)
            or jsonb_typeof(v_tabla->'Columnas') is distinct from 'array'
            or jsonb_typeof(v_tabla->'Filas') is distinct from 'array' then
            raise exception using errcode='22023',message='MYG_TABLAS_COMPACTAS_INVALIDAS';
        end if;
        v_nombres:=array_append(v_nombres,lower(v_nombre));
        v_total:=jsonb_array_length(v_tabla->'Columnas');
        if exists(select 1 from jsonb_array_elements(v_tabla->'Columnas') where jsonb_typeof(value)<>'string' or nullif(btrim(value#>>'{}'),'') is null)
            or (select count(*)<>count(distinct lower(value#>>'{}')) from jsonb_array_elements(v_tabla->'Columnas')) then
            raise exception using errcode='22023',message='MYG_COLUMNAS_COMPACTAS_INVALIDAS';
        end if;
        for v_fila in select value from jsonb_array_elements(v_tabla->'Filas') loop
            if jsonb_typeof(v_fila) is distinct from 'array' or jsonb_array_length(v_fila)<>v_total then
                raise exception using errcode='22023',message='MYG_FILA_COMPACTA_INVALIDA';
            end if;
            for v_ref in select value from jsonb_array_elements(v_fila) loop
                v_bytes:=v_bytes+64;
                if jsonb_typeof(v_ref)='array' and v_ref->>0='s'
                    and jsonb_typeof(v_ref->1)='number' and (v_ref->>1)~'^(0|[1-9][0-9]*)$'
                    and (v_ref->>1)::numeric<jsonb_array_length(v_textos) then
                    v_bytes:=v_bytes+v_textos_bytes[(v_ref->>1)::integer+1];
                elsif jsonb_typeof(v_ref)='array' and v_ref->>0='d'
                    and jsonb_typeof(v_ref->1)='string' and v_documentos_mapa ? (v_ref->>1) then
                    v_bytes:=v_bytes+(v_documentos_bytes->>(v_ref->>1))::bigint;
                end if;
                if v_bytes>536870912 then
                    raise exception using errcode='22023',message='MYG_PAQUETE_EXPANDIDO_MAX_512_MIB';
                end if;
            end loop;
        end loop;
    end loop;
    -- Tras la estimación completa se validan todas las celdas. La comprobación
    -- previa al guardado no materializa otra copia expandida del paquete.
    for v_tabla in select value from jsonb_array_elements(p_contenido->'tablas') loop
        if not p_materializar then
            perform myg_nube_privado.expandir_celda(c.value,v_textos,v_documentos_mapa,
                v_tabla->>'Nombre',v_tabla->'Columnas'->>(c.ord-1)::integer,false)
            from jsonb_array_elements(v_tabla->'Filas') f(value)
            cross join lateral jsonb_array_elements(f.value) with ordinality c(value,ord);
        else
            select coalesce(jsonb_agg((select coalesce(jsonb_agg(
                myg_nube_privado.expandir_celda(c.value,v_textos,v_documentos_mapa,
                    v_tabla->>'Nombre',v_tabla->'Columnas'->>(c.ord-1)::integer,true) order by c.ord),'[]'::jsonb)
                from jsonb_array_elements(f.value) with ordinality c(value,ord)) order by f.ord),'[]'::jsonb)
                into v_celdas from jsonb_array_elements(v_tabla->'Filas') with ordinality f(value,ord);
            v_tablas:=array_append(v_tablas,jsonb_set(v_tabla,'{Filas}',v_celdas));
        end if;
    end loop;
    if not p_materializar then return p_contenido; end if;
    return (p_contenido-'textos')||jsonb_build_object('version',1,'documentos',v_documentos,'tablas',to_jsonb(v_tablas));
end $function$;

create or replace function myg_nube_privado.expandir_paquete(p_contenido jsonb)
returns jsonb language sql immutable set search_path=pg_catalog as $function$
    select myg_nube_privado.expandir_paquete(p_contenido,true);
$function$;

create or replace function myg_nube_privado.validar_contenido(p_contenido jsonb)
returns void language plpgsql immutable set search_path=pg_catalog as $function$
begin
    -- Aplicar tamaño a lo que se almacena, nunca a una representación expandida.
    perform myg_nube_privado.validar_contenido_v1(p_contenido);
    perform myg_nube_privado.expandir_paquete(p_contenido,false);
end $function$;

-- Comprueba exclusivamente las columnas de navegación que el guard v1 ya
-- excluye de TODOS los módulos. Mantiene encabezados, orden, IDs y todas las
-- demás celdas, incluidas las referencias d o los JSON literales.
create or replace function myg_nube_privado.tablas_solo_metadatos(p_anterior jsonb,p_nuevo jsonb)
returns boolean language plpgsql immutable set search_path=pg_catalog as $function$
declare v_antes jsonb; v_despues jsonb; v_fila jsonb; v_otra jsonb;
    v_nombre text; v_columnas jsonb; v_permitidas text[]; t integer; f integer; c integer;
begin
    if jsonb_typeof(p_anterior) is distinct from 'array' or jsonb_typeof(p_nuevo) is distinct from 'array'
        or jsonb_array_length(p_anterior)<>jsonb_array_length(p_nuevo) then return false; end if;
    for t in 0..jsonb_array_length(p_anterior)-1 loop
        v_antes:=p_anterior->t; v_despues:=p_nuevo->t;
        if v_antes=v_despues then continue; end if;
        if v_antes-'Filas'<>v_despues-'Filas' then return false; end if;
        v_nombre:=v_antes->>'Nombre';
        v_permitidas:=case v_nombre when 'myg_proyecto' then array['nombre','modificado_utc']
            when 'proyecto' then array['nombre_proyecto'] else null end;
        if v_permitidas is null or jsonb_typeof(v_antes->'Filas') is distinct from 'array'
            or jsonb_typeof(v_despues->'Filas') is distinct from 'array'
            or jsonb_array_length(v_antes->'Filas')<>jsonb_array_length(v_despues->'Filas') then return false; end if;
        v_columnas:=v_antes->'Columnas';
        for f in 0..jsonb_array_length(v_antes->'Filas')-1 loop
            v_fila:=v_antes->'Filas'->f; v_otra:=v_despues->'Filas'->f;
            if v_fila=v_otra then continue; end if;
            if jsonb_typeof(v_fila) is distinct from 'array' or jsonb_typeof(v_otra) is distinct from 'array'
                or jsonb_array_length(v_fila)<>jsonb_array_length(v_otra)
                or jsonb_array_length(v_fila)<>jsonb_array_length(v_columnas) then return false; end if;
            for c in 0..jsonb_array_length(v_columnas)-1 loop
                if v_fila->c is distinct from v_otra->c and not (v_columnas->>c)=any(v_permitidas) then return false; end if;
            end loop;
        end loop;
    end loop;
    return true;
end $function$;

create or replace function myg_nube_privado.exigir_modulos(p_anterior jsonb,p_nuevo jsonb,p_permisos jsonb)
returns void language plpgsql immutable set search_path=pg_catalog as $function$
begin
    if p_permisos='{"acu":true,"especificaciones":true,"metrados_excel":true}'::jsonb then return; end if;
    -- Una referencia d solo puede apuntar a json_documento de un documento
    -- canónico. Si solo cambian los tres metadatos de navegación del principal
    -- y sus columnas nativas permitidas, no cambia ningún módulo al resolver
    -- esa referencia. No expandir dos veces una base grande para renombrarla.
    -- Las RPC validan íntegramente p_nuevo antes de llamar a este guard.
    if myg_nube_privado.permisos_modulos_validos(p_permisos)
        and p_anterior->>'formato'='MYG_COLABORACION' and p_nuevo->>'formato'='MYG_COLABORACION'
        and p_anterior->'version'='2'::jsonb and p_nuevo->'version'='2'::jsonb
        and jsonb_typeof(p_anterior->'documento')='object'
        and jsonb_typeof(p_nuevo->'documento')='object'
        and p_anterior-array['documento','tablas']=p_nuevo-array['documento','tablas']
        and (p_anterior->'documento')-array['Nombre','ModificadoUtc','PresupuestoActivoId'] =
            (p_nuevo->'documento')-array['Nombre','ModificadoUtc','PresupuestoActivoId']
        and myg_nube_privado.tablas_solo_metadatos(p_anterior->'tablas',p_nuevo->'tablas') then
        return;
    end if;

    -- El guard v1 inspecciona TODAS las representaciones, también los textos
    -- referenciados, antes de autorizar. Un diccionario no oculta datos protegidos.
    perform myg_nube_privado.exigir_modulos_v1(
        myg_nube_privado.expandir_paquete(p_anterior),
        myg_nube_privado.expandir_paquete(p_nuevo),p_permisos);
end $function$;

create or replace function public.myg_nube_capacidades()
returns jsonb language plpgsql stable security definer set search_path=pg_catalog as $function$
begin
    perform myg_nube_privado.identidad();
    return '{"paquete_compacto":2}'::jsonb;
end $function$;

revoke all on function myg_nube_privado.validar_contenido_v1(jsonb) from public,anon,authenticated,service_role;
revoke all on function myg_nube_privado.exigir_modulos_v1(jsonb,jsonb,jsonb) from public,anon,authenticated,service_role;
revoke all on function myg_nube_privado.expandir_celda(jsonb,jsonb,jsonb,text,text,boolean) from public,anon,authenticated,service_role;
revoke all on function myg_nube_privado.expandir_paquete(jsonb,boolean) from public,anon,authenticated,service_role;
revoke all on function myg_nube_privado.expandir_paquete(jsonb) from public,anon,authenticated,service_role;
revoke all on function myg_nube_privado.validar_contenido(jsonb) from public,anon,authenticated,service_role;
revoke all on function myg_nube_privado.tablas_solo_metadatos(jsonb,jsonb) from public,anon,authenticated,service_role;
revoke all on function myg_nube_privado.exigir_modulos(jsonb,jsonb,jsonb) from public,anon,authenticated,service_role;
revoke all on function public.myg_nube_capacidades() from public,anon;
grant execute on function public.myg_nube_capacidades() to authenticated,service_role;

notify pgrst,'reload schema';
commit;
