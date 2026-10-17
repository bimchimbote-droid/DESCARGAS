# Actualización: pestañas y tamaño de texto

Proyecto: bimchimbote-droid/MYG.Presupuestos, rama main.
Versión base de los archivos: 65dcad829a9601a52fac7588cd61adff6ec628da.
Entregas: bimchimbote-droid/DESCARGAS (público, sin cambiar su visibilidad).
No se hizo push ni commit en el repositorio del código.

## Comportamiento

Las pestañas de proyectos tienen un ancho máximo de 340 píxeles lógicos, ajustado al DPI de Windows. Los títulos cortos conservan su ancho natural; los largos muestran puntos suspensivos, el nombre completo al pasar el cursor y mantienen el cierre y la marca de cambios pendientes.

El botón «Texto 100 %» en Inicio y en la cinta del proyecto permite elegir Compacto 85 %, Normal 100 % o Grande 115 %. La preferencia se guarda por usuario en ese equipo. Prueba 85 % en la laptop y conserva 100 % en la PC de escritorio; puedes cambiarlo en cualquier momento. No se deduce el tamaño del texto a partir de las pulgadas del monitor.

Se ajustan las fuentes de los controles de interfaz. El tamaño y formato de documentos, especificaciones, hojas de metrado e impresión conservan sus propios controles de fuente y zoom.

## Aplicar sin sustituir el repositorio

1. Cierra MYG y guarda tu trabajo en Visual Studio. Haz un respaldo o commit local de tus cambios antes de aplicar esta actualización.
2. Extrae el ZIP en una carpeta temporal fuera del repositorio. No reemplaces la carpeta completa del proyecto ni borres o copies encima de `.git`.
3. Recomendado: abre PowerShell en tu checkout local (por ejemplo `D:\ADDIN\repos\MYG.Presupuestos_GITHUB`) y ejecuta, ajustando la ruta donde extrajiste el ZIP:

```powershell
git status --short
git apply --check 'C:\Ruta\Actualizacion\CAMBIOS.patch'
if ($LASTEXITCODE -ne 0) { throw 'Los archivos locales difieren: integra los cambios manualmente antes de continuar.' }
git apply 'C:\Ruta\Actualizacion\CAMBIOS.patch'
```

`--check` comprueba la compatibilidad antes de escribir. Si falla, no fuerces el parche: revisa las diferencias para conservar tus avances.

4. Alternativa manual: dentro de `ARCHIVOS` se entregan los archivos completos. CREA o REEMPLAZA solo las rutas de la tabla, conservando antes una copia de tus archivos. Si hiciste cambios locales en alguno, combínalos con el parche en lugar de sobrescribirlos. No hay cambios de dependencias, solución ni esquema de bases de datos.
5. Abre la solución en Visual Studio 2026 con SDK .NET 10, compila Release y ejecuta MYG.Desktop. Para compilar toda la solución sin Revit instalado puedes usar las referencias ya admitidas por el proyecto:

```powershell
dotnet build MYG.Presupuestos.sln -c Release -p:UseRevitReferencePackages=true -m:1 -nr:false
dotnet run --project MYG.Pruebas/MYG.Pruebas.csproj -c Release --no-build --no-restore
dotnet run --project MYG.PruebasUI/MYG.PruebasUI.csproj -c Release --no-build --no-restore
```

No hagas push a main como parte de copiar los archivos: revisa los cambios localmente y decide después cómo integrarlos en GitHub.

## Validación de esta entrega

Compilación completa Release: cero errores y cero advertencias. Pruebas de consola .NET/SQLite: 451 comprobaciones correctas. Se añadieron comprobaciones de interfaz para pestañas y texto; compilan, pero su ejecución visual necesita Windows y no se ejecutó en el entorno Linux. Las comprobaciones de Named Pipes y de muestras externas no suministradas conservan sus limitaciones documentadas.

## Archivos

| N.º | Ruta exacta del archivo | Acción requerida | Descripción |
|---|---|---|---|
| 1 | MYG.Desktop/EditorHerramientas.cs | REEMPLAZAR | Acceso al tamaño del texto dentro del proyecto. |
| 2 | MYG.Desktop/InicioForm.cs | REEMPLAZAR | Acceso al tamaño del texto en Inicio. |
| 3 | MYG.Desktop/PresupuestosResumenMenu.cs | REEMPLAZAR | Conserva el tamaño de autor al editar fuentes del resumen. |
| 4 | MYG.Desktop/ProyectosAbiertos.cs | REEMPLAZAR | Límite de ancho de las pestañas de proyecto. |
| 5 | MYG.Desktop/TamanoTextoUI.cs | CREAR | Preferencia local 85/100/115 y escala de fuentes de interfaz. |
| 6 | MYG.Desktop/Tema.cs | REEMPLAZAR | Integración de la escala en estilos de controles. |
| 7 | MYG.Desktop/TemaAplicacion.cs | REEMPLAZAR | Integración de fuentes nuevas y tablas sin alterar documentos. |
| 8 | MYG.Desktop/TemaPestanas.cs | REEMPLAZAR | Dibujo de etiquetas, puntos suspensivos y ajuste DPI. |
| 9 | MYG.PruebasUI/HerramientasEditorCheck.cs | REEMPLAZAR | Verifica el acceso de texto en la cinta del proyecto. |
| 10 | MYG.PruebasUI/Program.cs | REEMPLAZAR | Registra las pruebas de texto y revisa la cabecera de Inicio. |
| 11 | MYG.PruebasUI/ProyectosAbiertosCheck.cs | REEMPLAZAR | Verifica títulos largos, cierre y nombre completo. |
| 12 | MYG.PruebasUI/TamanoTextoUICheck.cs | CREAR | Comprueba escala sin acumulación y conservación de documentos. |


`MANIFIESTO_SHA256.json` identifica los archivos de base y entregados; el archivo `.zip.sha256` permite verificar la descarga.
