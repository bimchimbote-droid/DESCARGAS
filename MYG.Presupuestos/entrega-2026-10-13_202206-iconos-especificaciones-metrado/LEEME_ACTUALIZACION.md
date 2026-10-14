# Actualización MYG.Presupuestos: iconos y especificaciones iniciales

Cuenta y repositorio de código: bimchimbote-droid/MYG.Presupuestos.
Referencia seleccionada: main. Base de esta entrega: 439189fa92c3e4b66b5adedbaa3ee5b6956ad4f4.
Repositorio independiente de entregas: bimchimbote-droid/DESCARGAS.
Archivo: MYG_PRESUPUESTOS_ACTUALIZACION.zip.
Entorno: Visual Studio 2026, C#, .NET 10, SQLite y conector Revit 2027.

## Comportamiento

- Especificaciones a la izquierda, al final de Descripción; Excel a la derecha, después de Cantidad/Unidad y antes de Precio, según la imagen confirmada.
- Cada icono aparece únicamente si la partida tiene ese contenido. La plantilla de Excel vacía y sus fórmulas automáticas no activan el indicador.
- Una partida sin especificación muestra ítem, nombre, unidad de medida y DESCRIPCIÓN con el mismo formato del botón Insertar título.
- Ese título inicial no activa el icono. Las ediciones se conservan como borrador hasta pulsar Guardar en la sección de especificaciones (también Ctrl+S en el editor).
- Las especificaciones de documentos anteriores se reconocen como guardadas. Los títulos y las filas raíz del presupuesto no reciben indicadores.
- Los borradores se conservan en MYG sin presentarse como especificaciones guardadas en las columnas nativas de Delphin.

## Aplicación manual

1. Cierra MYG y abre tu checkout habitual de MYG.Presupuestos. Un ejemplo de ruta es D:\ADDIN\repos\MYG.Presupuestos_GITHUB.
2. Guarda una copia de los archivos que reemplazarás y revisa `git status`. Si tienen cambios locales posteriores a la base indicada, integra el parche antes de sustituirlos.
3. Extrae el ZIP en una carpeta temporal. Copia el contenido de `archivos` a la raíz de tu checkout, respetando las rutas de la tabla. Crea los archivos nuevos y reemplaza los existentes indicados.
4. Conserva la carpeta `.git`, la solución y tu configuración de GitHub. La entrega no incluye `.git`, bases de obras, credenciales ni archivos compilados.
5. Abre MYG.Presupuestos.sln en Visual Studio y compila Release. Sin Revit instalado, puedes compilar Desktop o usar los paquetes de referencia para la solución completa.

Alternativa si tu checkout coincide con la base: desde su raíz ejecuta `git apply --check RUTA\CAMBIOS.patch` y luego `git apply RUTA\CAMBIOS.patch`. Usa el parche o la copia de archivos, no ambos. Estos comandos no publican cambios ni modifican la conexión con GitHub.

## Archivos

| N.º | Ruta exacta del archivo | Acción requerida | Descripción |
|---|---|---|---|
| 1 | `MYG.Core/ContenidoPartida.cs` | CREAR | Detecta especificaciones guardadas y metrado real; omite plantillas vacías. |
| 2 | `MYG.Core/DelphinFormatoMYG.cs` | REEMPLAZAR | Evita exportar borradores como especificaciones guardadas en SQLite nativo. |
| 3 | `MYG.Core/PresupuestosModelos.cs` | REEMPLAZAR | Conserva el estado de borrador de la especificación. |
| 4 | `MYG.Desktop/EspecificacionesEditor.cs` | REEMPLAZAR | Prepara el mismo título de Insertar título y gestiona la confirmación explícita. |
| 5 | `MYG.Desktop/PresupuestosAlertasPartidas.cs` | REEMPLAZAR | Reserva el espacio de las alertas para que no se superpongan con la especificación. |
| 6 | `MYG.Desktop/PresupuestosEstructuraPanel.cs` | REEMPLAZAR | Activa los indicadores en la tabla del presupuesto. |
| 7 | `MYG.Desktop/PresupuestosIndicadoresContenido.cs` | CREAR | Dibuja los iconos de especificaciones y Excel en cada partida con contenido. |
| 8 | `MYG.Desktop/PresupuestosPanel.cs` | REEMPLAZAR | Carga el título inicial y confirma la especificación al guardar. |
| 9 | `MYG.Pruebas/ContenidoPartidaCheck.cs` | CREAR | Prueba presencia de contenido, plantillas y compatibilidad. |
| 10 | `MYG.Pruebas/EspecificacionBorradorPersistenciaCheck.cs` | CREAR | Prueba conservación del borrador y guardado en JSON, SQLite y catálogo. |
| 11 | `MYG.Pruebas/Program.cs` | REEMPLAZAR | Registra las pruebas nuevas del núcleo. |
| 12 | `MYG.PruebasUI/EspecificacionesBorradorCheck.cs` | CREAR | Comprueba plantilla, formato, edición y botón Guardar en Windows. |
| 13 | `MYG.PruebasUI/IndicadoresContenidoCheck.cs` | CREAR | Comprueba ubicación, pintura y actualización de los iconos en Windows. |
| 14 | `MYG.PruebasUI/Program.cs` | REEMPLAZAR | Registra las pruebas nuevas de interfaz. |

## Validación

SDK .NET 10.0.100. Compilación Release de la solución completa: 0 errores, 0 advertencias.
280 comprobaciones del núcleo completadas (272 existentes y 8 nuevas).
Named Pipes de Windows se omite explícitamente en Linux. Las pruebas UI se compilaron, pero su ejecución y la comprobación visual requieren Windows.

Comandos de la validación Linux:

```sh
dotnet build MYG.Presupuestos.sln -c Release -p:UseRevitReferencePackages=true -m:2 -nr:false
dotnet run --project MYG.Pruebas/MYG.Pruebas.csproj -c Release --no-build --no-restore
```

En Windows, desde la raíz del checkout:

```powershell
dotnet run --project MYG.PruebasUI/MYG.PruebasUI.csproj -c Release
```

`SHA256SUMS.txt` contiene la huella de los archivos de código entregados.
