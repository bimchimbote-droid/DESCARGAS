# Gráfico de incidencia: texto y seguimiento como en el video

Repositorio de código: bimchimbote-droid/MYG.Presupuestos, rama main.
Base: 6a31acfb9b55c10e66ef84f918c3dae2e76ebfde; README parte de la entrega anterior de ACU/Metrado Xls.

Esta entrega actualiza sólo los archivos del gráfico y su documentación. Mantenga las correcciones anteriores de los demás archivos.

El título, ejes, porcentajes y herramientas del gráfico siguen Texto 85 %, 100 % y 115 % de forma reversible. Las galerías ajustan sus muestras y fuentes. Las columnas clásicas usan título serif, degradados azul/rojo/verde/celeste, marco completo, números del eje sin abreviar, porcentajes centrados y categorías en dos renglones alternos.

Al mover el puntero por el área de datos aparece el seguimiento del video: tramado de la columna más cercana, guía vertical siguiendo el puntero, guía horizontal del importe, etiquetas negras en los ejes y recuadro de importe con muestra de color. Al salir desaparece. Los importes y porcentajes siempre proceden del presupuesto real, sin copiar los valores del video.

| N.º | Ruta exacta del archivo | Acción requerida | Descripción |
|---|---|---|---|
| 1 | MYG.Desktop/GraficoIncidencia.cs | REEMPLAZAR | Aplica el porcentaje de texto al gráfico y conecta el seguimiento del puntero. |
| 2 | MYG.Desktop/GraficoIncidenciaBarras.cs | REEMPLAZAR | Adapta las barras personalizadas al tamaño de lectura. |
| 3 | MYG.Desktop/GraficoIncidenciaHerramientas.cs | REEMPLAZAR | Escala herramientas y galerías conservando sus opciones. |
| 4 | MYG.Desktop/GraficoIncidenciaEscalaTexto.cs | CREAR | Gestiona medidas, fuentes y miniaturas sin acumular escala al cambiar porcentaje o DPI. |
| 5 | MYG.Desktop/GraficoIncidenciaInteraccion.cs | CREAR | Dibuja columnas, degradados, etiquetas, guías, tramado y recuadros de seguimiento. |
| 6 | MYG.PruebasUI/GraficoIncidenciaUICheck.cs | REEMPLAZAR | Comprueba escala, seguimiento, exportación limpia y liberación de recursos. |
| 7 | MYG.PruebasUI/README.md | REEMPLAZAR | Documenta las nuevas comprobaciones del gráfico. |

## Aplicación manual

1. Detenga MYG Presupuestos y la depuración en Visual Studio.
2. Extraiga el ZIP en una carpeta temporal fuera de su repositorio de código.
3. Revise `git status --short` y guarde una copia de los archivos que va a reemplazar. Si tienen avances locales posteriores, compare el parche incluido antes de sustituirlos.
4. Copie únicamente los siete archivos de la tabla a las mismas rutas relativas de su repositorio. Cree también los dos archivos .cs nuevos dentro de MYG.Desktop; el proyecto SDK los incluye automáticamente. Conserve los demás archivos y la carpeta .git.
5. Compile MYG.Desktop en Release / x64 en Visual Studio, o desde la carpeta que contiene MYG.Presupuestos.sln:

```powershell
dotnet build .\MYG.Desktop\MYG.Desktop.csproj -c Release
```

6. Abra su presupuesto y, en la barra del gráfico, pulse R (Restaurar presentación). Esto aplica las columnas clásicas y las etiquetas de porcentajes de la referencia si tenía otra presentación guardada; conserva sus datos del presupuesto y las preferencias de acceso a la barra.
7. Pruebe Texto 85 %, 100 % y 115 %. Recorra las columnas y los espacios entre ellas con el puntero y luego salga del gráfico. Abra las galerías y compruebe sus fuentes y muestras. Los otros tipos de gráfico continúan disponibles.
8. Para ejecutar la suite de interfaz en Windows con SDK .NET 10:

```powershell
dotnet run --project .\MYG.PruebasUI\MYG.PruebasUI.csproj -c Release
```

El porcentaje global es una preferencia de lectura de pantalla. La exportación e impresión conservan el tamaño de fuente configurado en la presentación y no incluyen guías, etiquetas flotantes ni tramado de selección.

## Alternativa: parche

El parche se preparó sobre los archivos del commit base y el README de la entrega anterior. Sustituya la ruta del ejemplo por la ubicación donde extrajo el ZIP:

```powershell
git apply --check 'C:\Temp\MYG_Incidencia\actualizar-grafico-incidencia.patch'
git apply 'C:\Temp\MYG_Incidencia\actualizar-grafico-incidencia.patch'
```

Si `--check` informa conflictos, compare los cambios; no fuerce la aplicación. Elija copiar los archivos o aplicar el parche, sin hacer ambas operaciones.

## Comprobaciones de esta entrega

- Solución completa compilada con .NET 10.0.100: 0 errores y 0 advertencias.
- 451 comprobaciones del núcleo correctas con datos sintéticos y SQLite real. Named Pipes de Windows y la muestra externa LLACUSBAMBA quedan omitidos en Linux.
- Las pruebas nuevas de escala, clon de fuente, seguimiento dentro/entre columnas, retirada al salir, exportación limpia y liberación de controles compilan. Su ejecución y la comparación visual final con el video requieren Windows y quedan pendientes; no se afirman como ejecutadas aquí.
- El parche se aplicó a copias de los archivos de partida y reprodujo exactamente los siete archivos entregados.
- SHA256SUMS.txt comprueba los archivos internos; el checksum externo comprueba el ZIP.

Se publica únicamente en una carpeta nueva de bimchimbote-droid/DESCARGAS, conservando las entregas anteriores.
