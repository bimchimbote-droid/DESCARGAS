# Correcciones del selector ACU y Metrado Xls con texto al 85 %

Repositorio de código: bimchimbote-droid/MYG.Presupuestos, rama main.
Base de esta entrega: 6a31acfb9b55c10e66ef84f918c3dae2e76ebfde.

Esta entrega es acumulativa e incluye también la corrección anterior del menú Texto.

El selector del ACU ya no registra todos los insumos antes de abrirse. Un conflicto en un insumo ajeno (por ejemplo 470010198, ALQUILER DE ALMACÉN, OFICINA Y GUARDIANÍA) no debe impedir consultar, cancelar o editar el recurso elegido. Sólo se registran los insumos nuevos aceptados y se mantiene la validación de códigos duplicados al crearlos. El mismo ajuste cubre insertar arriba y abajo.

La cinta de Metrado Xls tenía dos componentes que imponían márgenes distintos (12 y 20) a la misma barra de pestañas. Cambiar ese margen recrea su ventana nativa; los ajustes contrapuestos podían repetirse al abrirla o cambiar de tamaño. Ahora el tema administra un único margen de 20 para la cinta, adaptado al DPI, sin escribirlo desde HandleCreated.

| N.º | Ruta exacta del archivo | Acción requerida | Descripción |
|---|---|---|---|
| 1 | MYG.Desktop/PresupuestosExcelCinta.cs | REEMPLAZAR | La cinta deja al tema el margen nativo y no recrea la ventana desde HandleCreated. |
| 2 | MYG.Desktop/PresupuestosHerramientasPanel.cs | REEMPLAZAR | Insertar arriba/abajo abre el selector sin registrar insumos ajenos. |
| 3 | MYG.Desktop/PresupuestosPanel.cs | REEMPLAZAR | Abrir la flecha, agregar o editar no intenta registrar todos los insumos del presupuesto. |
| 4 | MYG.Desktop/TamanoTextoUI.cs | REEMPLAZAR | Conserva la corrección anterior del cierre del menú de tamaño de texto. |
| 5 | MYG.Desktop/TemaPestanas.cs | REEMPLAZAR | Unifica el margen por pestaña, adaptado al DPI, sin ajustes contrapuestos. |
| 6 | MYG.PruebasUI/MetradoExcelCheck.cs | REEMPLAZAR | Prueba apertura al 85 %, estabilidad de ventanas y conservación de fórmulas y formato. |
| 7 | MYG.PruebasUI/Program.cs | REEMPLAZAR | Prueba la flecha y las inserciones con un código ajeno en conflicto a 85 %, 100 % y 115 %. |
| 8 | MYG.PruebasUI/README.md | REEMPLAZAR | Describe las comprobaciones de regresión en Windows. |
| 9 | MYG.PruebasUI/TamanoTextoUICheck.cs | REEMPLAZAR | Conserva la prueba anterior del menú real de tamaños de texto. |

## Aplicación manual

1. Detenga la aplicación y la depuración de Visual Studio.
2. Extraiga el ZIP en una carpeta temporal fuera de su repositorio de código.
3. Abra la carpeta donde tiene MYG.Presupuestos.sln y revise `git status --short`. Guarde una copia de sus archivos actuales fuera del repositorio. Si contienen avances posteriores al commit base, compare el parche antes de reemplazarlos.
4. Copie únicamente los archivos de la tabla a sus mismas rutas relativas. Todos se entregan completos. Mantenga los demás archivos y su carpeta .git para conservar historial y conexión con GitHub.
5. Compile MYG.Desktop en Release / x64 desde Visual Studio, o desde la raíz:

```powershell
dotnet build .\MYG.Desktop\MYG.Desktop.csproj -c Release
```

6. Ejecute la aplicación con Texto 85 %. Abra una partida con ACU, pulse la flecha de un insumo, cancele y vuelva a abrirla. Compruebe que no aparece el conflicto de un insumo ajeno. Pruebe también Insertar insumo arriba/abajo.
7. Entre en Metrado Xls, recorra las pestañas de la cinta y vuelva al ACU. Repita con Texto 100 % y 115 %; las fórmulas, el formato y el contenido del proyecto deben conservarse.
8. Para ejecutar las pruebas de interfaz en Windows con SDK .NET 10:

```powershell
dotnet run --project .\MYG.PruebasUI\MYG.PruebasUI.csproj -c Release
```

No se requiere migrar ni editar las bases SQLite ni cambiar códigos de otros insumos para abrir el selector.

## Alternativa: aplicar el parche

El parche incluido es acumulativo respecto al commit base. Si ya aplicó la entrega anterior o conserva otros cambios, revise las diferencias antes de usarlo. Sustituya la ruta temporal del ejemplo:

```powershell
git apply --check 'C:\Temp\MYG_Actualizacion\correcciones-acu-metrado.patch'
git apply 'C:\Temp\MYG_Actualizacion\correcciones-acu-metrado.patch'
```

Si `--check` informa un conflicto, compare los archivos; no fuerce el parche. Elija reemplazar los archivos o aplicar el parche, sin hacer ambas operaciones.

## Validación y alcance

- Solución completa compilada con .NET 10.0.100: 0 errores y 0 advertencias.
- 451 comprobaciones del núcleo correctas, con datos sintéticos y SQLite real.
- Named Pipes de Windows y la muestra externa LLACUSBAMBA se omiten en Linux.
- Las pruebas nuevas de interfaz compilan; su ejecución está pendiente en Windows. No se afirma que se hayan ejecutado en Linux.
- El parche se aplicó a copias originales de los nueve archivos y reprodujo exactamente los archivos entregados.
- SHA256SUMS.txt y el checksum externo del ZIP permiten comprobar integridad.

Esta entrega se publica en una carpeta nueva de bimchimbote-droid/DESCARGAS. Se conservan las entregas anteriores. No se hace push al repositorio del código.
