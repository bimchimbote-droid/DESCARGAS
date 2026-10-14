# Corrección: icono Excel según el origen activo de la cantidad

Código: bimchimbote-droid/MYG.Presupuestos, referencia seleccionada main.
Entrega pública independiente: bimchimbote-droid/DESCARGAS.
Entorno: Visual Studio 2026, C#, .NET 10 y Windows.
Aplicar sobre las entregas de iconos y corrección de escala de esta conversación.

## Comportamiento

- El icono Excel aparece si la cantidad usa el metrado Excel y la hoja tiene contenido.
- Al confirmar una cantidad manual en la tabla, desaparece el icono y su ayuda. Esto también ocurre si escribes el mismo número que daba Excel.
- La hoja Excel conserva sus datos y formato. Los metrados manuales y BIM se conservan.
- Al volver a pulsar Actualizar en Metrado Xls, se usa otra vez el total de Excel y reaparece el icono.
- Elegir otra fuente de metrado también oculta el icono Excel.
- Se conserva el ajuste de escala de Windows y el comportamiento de las especificaciones.

## Aplicación manual

1. Cierra MYG y respalda estos cuatro archivos en tu checkout habitual, por ejemplo D:\ADDIN\repos\MYG.Presupuestos_GITHUB.
2. Extrae el ZIP y copia el contenido de `archivos` a la raíz del proyecto, reemplazando las rutas indicadas.
3. Abre MYG.Presupuestos.sln y compila Release.
4. Actualiza una partida desde Excel: debe verse su icono. Cambia Cantidad manualmente: debe desaparecer. Pulsa Actualizar desde Excel: debe volver y recuperar el total de la hoja.

Si alguno de estos archivos tiene cambios propios posteriores, integra el parche antes de reemplazarlo. Mantén la carpeta .git y tu configuración de GitHub.

Alternativa sobre la última entrega: desde la raíz del checkout ejecuta `git apply --check RUTA\CORRECCION.patch` y luego `git apply RUTA\CORRECCION.patch`. Usa el parche o la copia de archivos, no ambos.

| N.º | Ruta exacta del archivo | Acción requerida | Descripción |
|---|---|---|---|
| 1 | MYG.Core/ContenidoPartida.cs | REEMPLAZAR | Distingue contenido conservado y vínculo activo con Excel. |
| 2 | MYG.Desktop/PresupuestosIndicadoresContenido.cs | REEMPLAZAR | Muestra el icono y la ayuda sólo cuando Excel es el origen activo. |
| 3 | MYG.Pruebas/ContenidoPartidaCheck.cs | REEMPLAZAR | Comprueba edición manual, mismo valor y reconexión sin pérdida de metrados. |
| 4 | MYG.PruebasUI/IndicadoresContenidoCheck.cs | REEMPLAZAR | Comprueba celda Cantidad real, Actualizar y pintura a distintas escalas. |

## Validación

Compilación Release de toda la solución con .NET 10.0.100: cero errores y advertencias.
281 comprobaciones del núcleo completadas, incluida la transición Excel → cantidad manual → Excel mediante las operaciones reales del programa.
Named Pipes de Windows se omite explícitamente en Linux. Las pruebas visuales están compiladas; su ejecución requiere Windows y no se realizó en Linux.

```powershell
dotnet build MYG.Presupuestos.sln -c Release -p:UseRevitReferencePackages=true -m:2 -nr:false
dotnet run --project MYG.Pruebas/MYG.Pruebas.csproj -c Release --no-build --no-restore
dotnet run --project MYG.PruebasUI/MYG.PruebasUI.csproj -c Release
```

El ZIP incluye archivos completos, parche verificado, huellas SHA256 y resultados de compilación/pruebas. La publicación usa una carpeta nueva de DESCARGAS.
