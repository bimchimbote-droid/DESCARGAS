# MYG Presupuestos: nube compacta y colaboración

Descargue `MYG_Actualizacion_Nube_Compacta.zip` y extraiga todo su contenido.
Incluye aplicación Windows x64 con .NET, código editable y dos migraciones SQL.

1. Conserve una copia del SQLite y de su instalación actual.
2. Aplique `20261022_paquete_compacto.sql` y después `20261023_sincronizacion_incremental.sql` en el editor SQL de su proyecto Supabase. Requieren las actualizaciones anteriores de permisos y contenido grande; si falta un requisito, la migración se cancela sin alterar datos.
3. Cierre MYG y use la carpeta `MYG` del ZIP completa. Conserve su conexión local y, si corresponde, copie `nube-myg.json` desde su instalación anterior. Todos los colaboradores deben actualizarse para abrir publicaciones compactas.
4. Revise primero Mis proyectos. Si el intento anterior no se publicó, use Retirar y conservar copia en Publicaciones pendientes y cree una publicación nueva desde el SQLite. Un reintento conserva los bytes y el identificador de la solicitud anterior.

Los detalles están en `INSTRUCCIONES.md` dentro del ZIP. El código editable está en `Codigo.zip`.
Esta entrega actualiza el escritorio; no es un instalador de Revit.

Se verificaron la compilación, pruebas de datos y colaboración, migraciones PostgreSQL y HTTP real local. No se modificó Supabase del usuario ni se ejecutó la interfaz Windows. El tamaño de su base particular debe medirse con la publicación nueva.

Puede comprobar la integridad del ZIP con SHA256SUMS.txt. VALIDACION.json contiene el resumen de las comprobaciones.
