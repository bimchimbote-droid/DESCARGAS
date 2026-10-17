# Actualización: interacción de gráficos y etiquetas porcentuales

Repositorio: bimchimbote-droid/MYG.Presupuestos
Rama de referencia: main
Commit de base: 1acd6f1c8b59e22226fb3b3c6efac87599f7f599
Entrega: MYG_PRESUPUESTOS_GRAFICOS_20261017_164020.zip

Al mover el puntero por una barra, sector, anillo o punto del gráfico se muestra
el resaltado tramado, las guías y el recuadro con el importe, siguiendo el video.
En los gráficos cartesianos se muestran también referencias sobre los ejes.
Las etiquetas de datos muestran solo el porcentaje, incluso al abrir plantillas
antiguas que incluían nombre e importe. Se conservan los nombres de los ejes y
las leyendas. Las ayudas de pantalla no se incluyen en las exportaciones.

## Archivos completos que se entregan

| N.º | Ruta exacta del archivo | Acción requerida | Descripción |
|---|---|---|---|
| 1 | MYG.Desktop/GraficoIncidencia.cs | REEMPLAZAR | Etiquetas solo con porcentaje e interacción en todos los tipos de gráfico. |
| 2 | MYG.Desktop/GraficoIncidenciaInteraccion.cs | REEMPLAZAR | Tramado, guías y recuadro del importe al mover el puntero. |
| 3 | MYG.Desktop/GraficoIncidenciaHerramientas.cs | REEMPLAZAR | Opciones de etiquetas coherentes con el contenido porcentual. |
| 4 | MYG.PruebasUI/GraficoIncidenciaUICheck.cs | REEMPLAZAR | Pruebas de interacción y porcentajes para todos los tipos de gráfico. |

## Aplicación manual en Windows

1. Guarda tus cambios locales y haz una copia de seguridad de los cuatro archivos
   de la tabla. Si los has modificado después del commit de base, compara y combina
   esas modificaciones antes de sustituirlos.
2. Extrae este ZIP en una carpeta temporal, fuera de tu repositorio.
3. Abre tu carpeta local del proyecto; la ruta de referencia proporcionada es
   `D:\ADDIN\repos\MYG.Presupuestos_GITHUB`. Si usas otra, trabaja en esa carpeta.
4. Copia únicamente los cuatro archivos completos a sus rutas de la tabla.
   Combina las carpetas existentes; no reemplaces ni borres carpetas completas.
   El ZIP no contiene `.git`, proyectos, dependencias, bases de datos ni obras.
5. Abre MYG.Presupuestos.sln en Visual Studio con el SDK .NET 10.
6. Compila MYG.Desktop en Release. Para comprobar toda la solución sin una
   instalación local de Revit, usa en la raíz del proyecto:

```powershell
dotnet build MYG.Presupuestos.sln -c Release -p:UseRevitReferencePackages=true -m:1 -nr:false
dotnet run --project MYG.Pruebas/MYG.Pruebas.csproj -c Release --no-build --no-restore
dotnet run --project MYG.PruebasUI/MYG.PruebasUI.csproj -c Release --no-build --no-restore
```

Para compilar el conector contra la instalación local de Revit 2027, omite
`-p:UseRevitReferencePackages=true`.

Comprueba visualmente columnas, barras horizontales, líneas, áreas, tartas,
donas y radares: al pasar sobre sus datos deben verse el tramado, las guías
y el importe. Al salir, deben desaparecer. Las etiquetas deben mostrar, por
ejemplo, `43.73 %`. La opción Mostrar ayudas controla la interacción.

Puedes revisar lo aplicado con `git diff --stat` y `git diff`. La copia de los
archivos conserva la conexión GitHub existente. Esta entrega no hace commit,
push ni fusiones en el repositorio del código.

## Validación de esta entrega

- Solución completa compilada en Linux con .NET SDK 10.0.100: 0 errores y 0 advertencias.
- Pruebas de lógica: 451 completadas correctamente.
- `git diff --check`: correcto.
- Pruebas de interfaz ampliadas y compiladas; NO ejecutadas en Linux, requieren Windows.
- Named Pipes de Windows y muestra opcional LLACUSBAMBA: omitidas en las pruebas de Linux.
- No se validó una sesión real de Revit ni la interfaz ejecutándose en Windows.

Este paquete contiene código fuente para compilar; no es un instalador ni un EXE.
Los archivos `LEEME_ACTUALIZACION.md` y `SHA256SUMS.txt` documentan la entrega
y no es necesario copiarlos dentro del repositorio.
