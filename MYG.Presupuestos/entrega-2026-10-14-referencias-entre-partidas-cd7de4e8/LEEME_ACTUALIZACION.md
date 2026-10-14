# Referenciar el metrado de otra partida

Proyecto: bimchimbote-droid/MYG.Presupuestos, rama main.
Entrega pública independiente: bimchimbote-droid/DESCARGAS.
Desarrollo: Visual Studio, C#, .NET 10, SQLite y Windows; Revit cuando corresponda.

## Cómo usarlo

1. En Metrado Xls de la partida de destino, selecciona la celda de destino y pulsa **Referenciar otra partida**. Opcionalmente puedes empezar o continuar una fórmula antes de pulsar el botón; no necesitas escribir `=` para iniciar la selección.
2. En el selector, elige el presupuesto y la partida de origen del proyecto abierto. El programa abre su pestaña real **Metrado Xls**.
3. Haz clic en la celda de origen para elegirla o usa el teclado y confirma con **Enter**. Regresas al metrado de destino con la referencia añadida a la fórmula pendiente.
4. Puedes completar operaciones y otras referencias. Confirma la fórmula con **Enter** o **✓** para guardar el vínculo.
5. **Cancelar** o **Esc** durante la elección vuelve al destino y conserva la fórmula anterior. Cancelar la edición no guarda los vínculos pendientes.

Las referencias funcionan entre partidas y presupuestos del mismo proyecto abierto. Al cambiar el origen, las fórmulas vinculadas se recalculan; **Actualizar** aplica el total de la hoja a la cantidad y al importe de la partida.

Los vínculos y sus anclas se guardan en JSON y SQLite. Renumerar o renombrar partidas conserva sus identidades; insertar filas o columnas mantiene el vínculo con la celda original. Si se elimina la partida o la celda de origen, se muestra un error de referencia. Los ciclos y las referencias inválidas impiden confirmar fórmulas inválidas; no se reemplaza el error por cero. Las copias y plantillas mantienen sus vínculos internos sin compartir datos con el original.

Al exportar a XLSX, las celdas con la función `METRADO` se guardan como una instantánea de su valor o error. Las fórmulas locales, por ejemplo `=I20*2`, se conservan como fórmulas de Excel. El proyecto MYG conserva sus vínculos editables.

## Aplicación manual

Prerequisito: tener aplicadas, en orden, las tres entregas de esta conversación: iconos y especificaciones, corrección del icono Excel según la escala de Windows, e indicador Excel según el origen activo de la cantidad. Esas correcciones ya entregadas no se vuelven a incluir en este ZIP.

1. Cierra MYG y respalda los archivos indicados en la tabla, en tu carpeta habitual: `D:\ADDIN\repos\MYG.Presupuestos_GITHUB`.
2. Extrae el ZIP y copia el contenido de `archivos` a la raíz del proyecto. **CREAR** añade un archivo nuevo; **REEMPLAZAR** sustituye el archivo completo.
3. Conserva la carpeta `.git`, la conexión con GitHub y tus demás archivos. Si tienes cambios propios posteriores en alguno de los archivos, integra el parche antes de sustituirlo.
4. Abre `MYG.Presupuestos.sln` en Visual Studio y compila Release.
5. En Windows, prueba la selección de una celda de otra partida, su retorno a la fórmula, la confirmación y la cancelación. Guarda y reabre el proyecto y comprueba el recálculo al modificar el origen.

Como alternativa a copiar archivos, aplica el parche sobre la última entrega: desde la raíz del checkout ejecuta `git apply --check RUTA\CAMBIOS.patch` y después `git apply RUTA\CAMBIOS.patch`. Elige el parche o la copia de archivos, no ambos. El parche se validó sobre la combinación exacta de las tres entregas anteriores y el código base; no se debe aplicar directamente a una versión que no las tenga.

| N.º | Ruta exacta del archivo | Acción requerida | Descripción |
|---|---|---|---|
| 1 | MYG.Core/EdicionHojaMetrado.cs | REEMPLAZAR | Conserva y desplaza anclas de referencia al editar filas y columnas. |
| 2 | MYG.Core/FuncionesExcel.cs | REEMPLAZAR | Añade METRADO al catálogo de funciones y al autocompletado. |
| 3 | MYG.Core/HojaMetrado.cs | REEMPLAZAR | Integra cálculo, metadatos de vínculos y exportación XLSX. |
| 4 | MYG.Core/MotorFormulaExcel.cs | REEMPLAZAR | Evalúa referencias entre hojas y detecta errores y ciclos. |
| 5 | MYG.Core/ProyectoBim.cs | REEMPLAZAR | Recupera vínculos al abrir, copiar y guardar proyectos. |
| 6 | MYG.Core/ReferenciasMetradoPartidas.cs | CREAR | Resuelve partidas y celdas por identidades persistentes, con confirmación atómica. |
| 7 | MYG.Desktop/PresupuestosEstructuraPanel.cs | REEMPLAZAR | Actualiza el contexto de vínculos tras cambios en la estructura del presupuesto. |
| 8 | MYG.Desktop/PresupuestosExcelEditor.cs | REEMPLAZAR | Integra referencias elegidas en la fórmula pendiente y su confirmación. |
| 9 | MYG.Desktop/PresupuestosExcelElegirReferencias.cs | REEMPLAZAR | Coordina la selección de referencias locales y entre partidas. |
| 10 | MYG.Desktop/PresupuestosExcelPanel.cs | REEMPLAZAR | Mantiene el estado y la ayuda de la navegación a otra hoja de metrado. |
| 11 | MYG.Desktop/PresupuestosExcelPlantillas.cs | REEMPLAZAR | Conserva y adapta vínculos al usar plantillas de metrado. |
| 12 | MYG.Desktop/PresupuestosExcelReferenciasPartidas.cs | CREAR | Navega al metrado real del origen y devuelve la celda a la fórmula pendiente. |
| 13 | MYG.Desktop/PresupuestosExcelSeleccion.cs | REEMPLAZAR | Sincroniza los vínculos después de arrastrar celdas. |
| 14 | MYG.Desktop/PresupuestosExcelSelectorReferencia.cs | CREAR | Añade el selector de presupuesto y partida de origen. |
| 15 | MYG.Desktop/PresupuestosPanel.cs | REEMPLAZAR | Conecta el proyecto abierto y restaura la partida de destino al terminar. |
| 16 | MYG.Pruebas/Program.cs | REEMPLAZAR | Incluye las comprobaciones nuevas en la suite del núcleo. |
| 17 | MYG.Pruebas/ReferenciasMetradoPartidasCheck.cs | CREAR | Comprueba recálculo, persistencia, anclas, ciclos, cancelación y exportación. |
| 18 | MYG.PruebasUI/Program.cs | REEMPLAZAR | Incluye la comprobación del flujo visual en Windows. |
| 19 | MYG.PruebasUI/ReferenciasPartidasUICheck.cs | CREAR | Comprueba selector, navegación al metrado, elección de celda, retorno y cancelación. |

## Validación

La solución completa se compiló en Release con .NET 10.0.100: cero errores y cero advertencias. La suite del núcleo terminó con **293 comprobaciones**, incluidas doce nuevas sobre referencias entre partidas, recálculo, anclas, persistencia JSON/SQLite, errores, ciclos, confirmación atómica, plantillas y exportación XLSX.

Las pruebas de interfaz están compiladas; **no se ejecutaron en Linux**. Su ejecución requiere Windows. La comprobación de Named Pipes de Windows se omite explícitamente en Linux. Revit no se ejecutó en este entorno.

```powershell
dotnet build MYG.Presupuestos.sln -c Release -p:UseRevitReferencePackages=true -m:2 -nr:false
dotnet run --project MYG.Pruebas/MYG.Pruebas.csproj -c Release --no-build --no-restore
dotnet run --project MYG.PruebasUI/MYG.PruebasUI.csproj -c Release
```

Contenido: diecinueve archivos completos, `CAMBIOS.patch` verificado, `SHA256SUMS.txt` y registros de compilación y pruebas. La publicación usa una carpeta nueva de DESCARGAS y conserva todas las entregas anteriores.
