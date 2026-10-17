# Actualización de temas, cabecera y ventanas

Proyecto: bimchimbote-droid/MYG.Presupuestos (main).
Entrega: MYG_PRESUPUESTOS_TEMAS_VENTANAS_20261017_165841.zip. Código fuente para compilar en Visual Studio y .NET 10.

## Cambios

- Se retira de la cabecera el rótulo Presupuesto y su desplegable señalados.
  Para cambiar de presupuesto, selecciona su fila en la tabla de estructura.
  El nombre del proyecto aprovecha el ancho disponible.
- La franja de herramientas, sus botones y las vistas R/CPM utilizan los colores
  del tema claro o del tema oscuro, también al cambiar de tema con el editor abierto.
- Las ventanas y diálogos propios con barra de título ofrecen los botones nativos
  minimizar, maximizar/restaurar y cerrar. Conservan sus datos, acciones Aceptar/
  Cancelar, propiedad de ventana y estilo de borde.
- La barra de título adopta los colores de la paleta cuando Windows admite los
  atributos DWM correspondientes. Windows 11 admite los colores explícitos;
  versiones anteriores compatibles mantienen su marco nativo claro u oscuro.
- Los paneles incrustados, menús, avisos de carga y ventanas sin barra de título
  conservan su presentación. Los selectores y mensajes nativos de Windows siguen
  las reglas del sistema operativo.

## Archivos completos

| N.º | Ruta exacta del archivo | Acción requerida | Descripción |
|---|---|---|---|
| 1 | MYG.Desktop/EditorPresupuestos.cs | REEMPLAZAR | Retira el selector marcado y amplía el nombre del proyecto. |
| 2 | MYG.Desktop/EditorHerramientas.cs | REEMPLAZAR | Botones de la cinta con colores del tema activo. |
| 3 | MYG.Desktop/EditorCronograma.cs | REEMPLAZAR | Franjas y selector R/CPM adaptados a ambos temas. |
| 4 | MYG.Desktop/CronogramaPanel.cs | REEMPLAZAR | Herramientas de Cronograma con fondo y texto del tema. |
| 5 | MYG.Desktop/TemaAplicacion.cs | REEMPLAZAR | Integra el estilo común de las barras de título. |
| 6 | MYG.Desktop/TemaVentanas.cs | CREAR | Botones nativos y colores del título para ventanas y diálogos. |
| 7 | MYG.PruebasUI/Program.cs | REEMPLAZAR | Registra las pruebas y el comando --ventanas-tema. |
| 8 | MYG.PruebasUI/VentanasTemaUICheck.cs | CREAR | Pruebas específicas de ventanas, temas y selección del presupuesto. |

## Cómo aplicar manualmente

1. Guarda tu trabajo y respalda los archivos de la tabla. Si tienen cambios
   locales adicionales, compáralos y combina esos cambios antes de reemplazarlos.
2. Extrae este ZIP en una carpeta temporal fuera del repositorio.
3. Abre tu carpeta local del proyecto (ruta de referencia:
   `D:\ADDIN\repos\MYG.Presupuestos_GITHUB`).
4. Copia los ocho archivos completos a las rutas exactas de la tabla; crea los
   dos archivos marcados CREAR. Combina las carpetas, sin reemplazarlas enteras.
   Conserva `.git`, proyectos, bases de datos, obras y los demás archivos existentes.
5. Abre MYG.Presupuestos.sln en Visual Studio con .NET SDK 10.0.100 o compatible
   con global.json y compila en Release.

También puedes verificar desde PowerShell, en la raíz del repositorio:

```powershell
dotnet build MYG.Presupuestos.sln -c Release -p:UseRevitReferencePackages=true -m:1 -nr:false
dotnet run --project MYG.Pruebas/MYG.Pruebas.csproj -c Release --no-build --no-restore
dotnet run --project MYG.PruebasUI/MYG.PruebasUI.csproj -c Release --no-build --no-restore -- --ventanas-tema
```

La tercera orden ejecuta únicamente las comprobaciones nuevas de ventanas y
temas, en Windows. Para ejecutar toda la suite de interfaz, omite
`-- --ventanas-tema`. Para usar las DLL de una instalación local de Revit 2027,
omite `-p:UseRevitReferencePackages=true` de la compilación.

Comprueba manualmente:

- La cabecera principal ya no tiene el selector marcado y la selección por fila
  mantiene el presupuesto activo, sus insumos y sus comandos.
- Las cintas R y CPM cambian con los temas normal y oscuro.
- Las ventanas independientes con título tienen los tres botones de la imagen.
  Minimiza, restaura, maximiza y cierra un diálogo conservando sus campos y sin
  confirmar cambios al usar los botones de estado de ventana.

Esta entrega conserva los cambios anteriores de gráficos al aplicar solamente
los archivos de esta tabla. La conexión con GitHub se mantiene porque `.git`
permanece intacto. No se ha hecho push al repositorio del código.

## Validación

- Solución completa compilada con .NET 10.0.100: 0 errores y 0 advertencias.
- 451 pruebas de lógica completadas correctamente en Linux.
- `git diff --check` correcto.
- Pruebas específicas de interfaz añadidas y compiladas, pendientes de ejecución
  en Windows. No se afirma validación visual ni de comandos de ventana en Linux.
- Named Pipes de Windows y la muestra opcional LLACUSBAMBA no se ejecutan en Linux.

El ZIP contiene código fuente, no un instalador o EXE. LEEME_ACTUALIZACION.md y
SHA256SUMS.txt documentan la entrega y no hace falta copiarlos al proyecto.
