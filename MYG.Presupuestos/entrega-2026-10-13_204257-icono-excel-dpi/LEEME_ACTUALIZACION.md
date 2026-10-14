# Corrección: icono de metrado Excel al actualizar

Repositorio de código: bimchimbote-droid/MYG.Presupuestos, referencia seleccionada main.
Entrega pública independiente: bimchimbote-droid/DESCARGAS.
Entorno: Visual Studio 2026, C#, .NET 10 y Windows.

Esta corrección se aplica después de la entrega de iconos y especificaciones de esta conversación.

## Causa y corrección

La columna del icono Excel se creaba con 26 píxeles, pero el icono y sus márgenes se ampliaban con el DPI de Windows. Al arrancar con escala superior al 100 %, el espacio podía quedar demasiado estrecho y el código omitía el icono, aunque el metrado ya se hubiera actualizado.

El ancho y su mínimo ahora se ajustan desde la creación y el inicio de la vista, además de los cambios de escala. A 125 % dispone de 33 píxeles; a 150 %, 39; a 200 %, 52. La prueba nueva contempla también 250 %.

El icono permanece después de Cantidad/Unidad, antes de Precio. La corrección conserva las reglas de presencia de contenido y el comportamiento de las especificaciones.

## Aplicación manual

1. Cierra MYG y guarda una copia de estos dos archivos en tu carpeta local (por ejemplo, D:\ADDIN\repos\MYG.Presupuestos_GITHUB).
2. Extrae el ZIP y copia el contenido de `archivos` a la raíz del checkout, reemplazando los archivos de la tabla.
3. Abre MYG.Presupuestos.sln, compila Release y ejecuta el resultado actualizado.
4. Revisa una partida con metrado Excel, pulsa Actualizar y comprueba el icono entre Unidad y Precio.

El ZIP incluye únicamente los dos archivos completos, el parche, las huellas y la evidencia de compilación. Mantén tu carpeta .git y la configuración de GitHub.

Alternativa sobre la entrega anterior: ejecuta `git apply --check RUTA\CORRECCION.patch` y después `git apply RUTA\CORRECCION.patch` desde la raíz de tu checkout. Usa el parche o la copia de archivos, no ambos.

| N.º | Ruta exacta del archivo | Acción requerida | Descripción |
|---|---|---|---|
| 1 | MYG.Desktop/PresupuestosIndicadoresContenido.cs | REEMPLAZAR | Ajusta desde el arranque el ancho del icono Excel según la escala de Windows. |
| 2 | MYG.PruebasUI/IndicadoresContenidoCheck.cs | REEMPLAZAR | Agrega regresión de inicio, Actualizar y pintura con distintos DPI. |

## Validación

Compilación Release de toda la solución correcta con .NET 10.0.100: cero errores y advertencias. El metrado B3=1 y el total G16=1 se verificaron con el detector real antes y después de Actualizar: fuente Excel y cantidad 1.

Las pruebas visuales nuevas están compiladas, pero requieren Windows para ejecutarse. No se ejecutó la interfaz WinForms en Linux.

```powershell
dotnet build MYG.Presupuestos.sln -c Release -p:UseRevitReferencePackages=true -m:2 -nr:false
dotnet run --project MYG.PruebasUI/MYG.PruebasUI.csproj -c Release
```

La publicación se realiza en una carpeta nueva de DESCARGAS, conservando la entrega anterior.
