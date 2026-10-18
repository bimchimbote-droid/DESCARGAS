# Actualización: plegado de presupuestos y regreso a Inicio

Proyecto: `bimchimbote-droid/MYG.Presupuestos`, rama de referencia `main`.
Base exacta del código: `18db5a4e3a2e48708a9fd7d20fc31b15fee3d57d`. Fecha: 17/10/2026 21:23 (Lima).
Entrega independiente: `bimchimbote-droid/DESCARGAS`; conserva su visibilidad pública y las entregas existentes.
Esta entrega no hace commit ni push ni modifica ramas del repositorio del código.

## Causa y corrección

Cada plegado reconstruía la tabla y recalculaba todo el proyecto, incluidos resúmenes, avisos y detalles. Ahora conserva las filas y los cálculos vigentes; inserta o retira las filas de las ramas y conserva selección y estado anidado. Una edición real invalida los cálculos y actualiza también las filas plegadas. La altura automática mide las filas mostradas en pantalla.

Inicio recargaba SQLite cada vez que se seleccionaba su pestaña. Ahora reutiliza su lista si la base y el WAL no han cambiado; los guardados del editor invalidan la lista explícitamente. Mantiene filtros y selección en la misma base, actualiza tras cambios guardados/externos y cambia la lista al volver desde otra base. El botón Ir inicio sincroniza el editor una sola vez.

## Aplicación manual sin perder avances

1. Cierre MYG, guarde sus avances y haga una copia de seguridad de su carpeta local. La carpeta de referencia es `D:\ADDIN\repos\MYG.Presupuestos_GITHUB`; use su ruta real.
2. Ejecute `git status --short` en esa carpeta y compruebe sus modificaciones locales. El ZIP contiene archivos completos; compare y combine cualquier cambio local más reciente antes de reemplazar. No sustituya la carpeta completa ni `.git`, bases SQLite, proyectos, bibliotecas o credenciales.
3. Copie los archivos de la tabla en sus rutas relativas a `MYG.Presupuestos.sln`. Cree los marcados CREAR y sustituya sólo los marcados REEMPLAZAR.
4. Como alternativa, desde la raíz del repositorio ejecute `git apply --check "RUTA_EXTRAIDA/CAMBIOS.patch"`. Si pasa, ejecute `git apply "RUTA_EXTRAIDA/CAMBIOS.patch"`. Si encuentra conflictos, conserve sus archivos y combine los cambios; no fuerce ni restablezca. Aplique por copia **o** por parche, una sola vez.
5. Los proyectos SDK incluyen automáticamente el nuevo archivo `.cs`. No cambian la solución, los `.csproj`, las dependencias ni los lockfiles. Compile la solución y ejecute su nueva compilación desde Visual Studio.

## Archivos

| N.º | Ruta exacta del archivo | Acción requerida | Descripción |
|---|---|---|---|
| 1 | `MYG.Desktop/EditorForm.cs` | REEMPLAZAR | Notifica el guardado para invalidar la lista de Inicio. |
| 2 | `MYG.Desktop/InicioForm.cs` | REEMPLAZAR | Actualiza proyectos sólo cuando corresponde y conserva la búsqueda en la misma base. |
| 3 | `MYG.Desktop/PresupuestosAlertasPartidas.cs` | REEMPLAZAR | Conserva los diagnósticos al retirar temporalmente filas plegadas. |
| 4 | `MYG.Desktop/PresupuestosEstructuraPanel.cs` | REEMPLAZAR | Pliega ramas reutilizando filas, selección, importes y estado anidado. |
| 5 | `MYG.Desktop/PresupuestosHerramientasPanel.cs` | REEMPLAZAR | Aplica la misma ruta ligera a Expandir todo y Contraer todo. |
| 6 | `MYG.Desktop/PresupuestosIndicadoresContenido.cs` | REEMPLAZAR | Actualiza indicadores también en las filas plegadas. |
| 7 | `MYG.Desktop/PresupuestosPanel.cs` | REEMPLAZAR | Reutiliza cálculos mientras no cambian los datos y mantiene vigente el resumen. |
| 8 | `MYG.Desktop/ProyectosAbiertos.cs` | REEMPLAZAR | Reutiliza el listado, detecta cambios SQLite/WAL y elimina la doble sincronización al volver. |
| 9 | `MYG.PruebasUI/PlegadoPresupuestosUICheck.cs` | CREAR | Regresiones de plegado, selección, edición pendiente y actualización de importes. |
| 10 | `MYG.PruebasUI/Program.cs` | REEMPLAZAR | Registra las regresiones y la opción --rendimiento-navegacion. |
| 11 | `MYG.PruebasUI/ProyectosAbiertosCheck.cs` | REEMPLAZAR | Regresiones de navegación, guardado, cambios en WAL y cambio de base. |
| 12 | `MYG.PruebasUI/README.md` | REEMPLAZAR | Documenta cómo ejecutar la comprobación específica en Windows. |

## Validación efectuada

- Compilación completa Release con .NET SDK 10.0.100 y `UseRevitReferencePackages=true`: 0 errores y 0 advertencias.
- Suite de datos `MYG.Pruebas`: 462 comprobaciones correctas, código de salida 0.
- `git diff --check` correcto.
- Parche completo aplicado sobre una copia de la base exacta y comparado byte por byte con todos los archivos entregados.
- ZIP comprobado y acompañado de SHA-256.
- Las nuevas pruebas UI compilan; su ejecución y los tiempos de respuesta reales no se verificaron en Linux. Named Pipes de Windows y muestras privadas opcionales no forman parte de las 462 comprobaciones aprobadas.

## Comprobar en Windows

Desde la raíz del proyecto, con SDK .NET 10:

```powershell
dotnet build .\MYG.Presupuestos.sln -c Release -p:UseRevitReferencePackages=true -m:1 -nr:false
dotnet run --project .\MYG.Pruebas\MYG.Pruebas.csproj -c Release --no-build --no-restore
dotnet run --project .\MYG.PruebasUI\MYG.PruebasUI.csproj -c Release --no-build --no-restore -- --rendimiento-navegacion
```

En la aplicación, pruebe con su base grande: pliegue y despliegue títulos anidados y presupuestos, además de Expandir/Contraer todo. Confirme que la selección, los totales y los colores se mantienen; si se oculta la partida seleccionada, debe quedar seleccionado su antecesor visible. Compruebe también el resumen al seleccionar otro presupuesto.

Edite una cantidad y despliegue su rama: debe aparecer el importe actualizado; una cantidad inválida debe impedir plegar hasta corregirla. Cambie el tema con una rama cerrada y vuelva a abrirla. Pulse el glifo de otra rama para comprobar que no recarga el detalle de una selección ajena.

Vuelva a Inicio varias veces por botón y pestaña sin modificar la base: debe conservarse la lista y no aparecer Actualizando proyectos. Tras guardar un cambio de nombre o un nuevo presupuesto debe actualizarse la lista; una segunda visita sin cambios debe reutilizarla. Cambiar de base debe mostrar los proyectos de esa base.
