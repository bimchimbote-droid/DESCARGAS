# Actualización de compatibilidad con Delphin

Repositorio de código: bimchimbote-droid/MYG.Presupuestos. Base: `df4ebe41f57386838564666820564a2e29d14fea` (main al iniciar el trabajo). Entrega independiente: bimchimbote-droid/DESCARGAS. Esta entrega no hace commit, push ni merge en el repositorio del código.

## Aplicar al código sin perder avances

1. Cierra Visual Studio y MYG y conserva una copia de seguridad de tu carpeta de trabajo y tus bases. Extrae este ZIP fuera del repositorio. `CODIGO` contiene los archivos completos; no contiene `.git`.
2. En PowerShell, cambia a la carpeta real del repositorio (por ejemplo, `D:\ADDIN\repos\MYG.Presupuestos_GITHUB`). Revisa `git status --short`.
3. Comprueba el parche usando su ruta real: `git apply --check "C:\CarpetaEntrega\CAMBIOS.patch"`.
4. Si la comprobación termina correctamente, aplica `git apply "C:\CarpetaEntrega\CAMBIOS.patch"`. Si encuentra conflictos, conserva tus archivos y combina los cambios manualmente; no uses reset/clean ni sustituyas avances a ciegas. La tabla siguiente identifica exactamente los archivos completos entregados.
5. Abre la solución en Visual Studio con SDK .NET 10. El parche conserva la carpeta `.git`, los remotos y la rama actual. No realiza operaciones remotas.

## Ejecutable para probar en Windows

`APLICACION_WINDOWS` contiene la aplicación x64 compilada. Ejecuta `MYG.Presupuestos.exe` desde esa carpeta completa; requiere Windows y .NET Desktop Runtime 10 x64. No copies únicamente el EXE, pues necesita las DLL incluidas. Descarga oficial del runtime: https://dotnet.microsoft.com/es-es/download/dotnet/10.0.

Abre una copia de la SQLite original de Delphin. Si antes guardaste una importación con la versión antigua de MYG, vuelve a abrir la original: esta entrega no repara automáticamente un JSON de importación antiguo que ya perdió filas del pie o precisión. Para esta muestra debe aparecer «PIE RESUMEN ÚNICO POR PROYECTO». Guardar como conserva la hoja completa, incluidos otros proyectos que contenga.

## Resultados comprobados

- Compilación de solución Release: cero errores y cero advertencias.
- Suite actual completada: **452 comprobaciones**; incluye muestra externa y pruebas sintéticas. La prueba de Named Pipes Windows se omite en Linux.
- Comparación independiente de los seis PDF aportados: **391 filas de insumos** coinciden en cantidades (4 decimales), precios e importes (2 decimales) con el PDF Delphin. Los precios unitarios de los 304 ACU del presupuesto exportado también coinciden, sin ajustes artificiales en el informe actual; no se certifica igualdad visual de la paginación.
- Conservadas 658 cantidades y 658 especificaciones RTF exactas. Esta muestra no trae filas ni archivos de desglose de metrado.
- Programación: 658 partidas, 659 tramos y 641 vínculos originales; 640 vínculos compatibles con el motor actual. El vínculo desde un resumen se conserva y se avisa.
- Guardar como y reabrir conserva todas las tablas nativas y no modifica la SQLite fuente. La copia incluye las tablas cuyo contenido aún no muestra MYG.
- El original conserva SHA-256 `efd8df3765e6c6dd88ee3460ebdfa8019af642b3df2e3cc612f08efdb0c513c6`.

| Pie del proyecto | Importe S/ |
|---|---:|
| Costo directo | 2,402,490.56 |
| Gastos generales | 400,685.85 |
| Utilidades | 240,249.06 |
| Sub total | 3,043,425.47 |
| IGV | 547,816.58 |
| Valor referencial | 3,591,242.05 |
| Gastos de supervisión | 262,565.96 |
| Expediente técnico | 5,598.29 |
| Costo total de ejecución | **3,859,406.30** |

| Incidencia | Importe S/ | Porcentaje visible |
|---|---:|---:|
| Mano de obra | 871,617.68 | 36.28 % |
| Materiales | 1,050,502.47 | 43.73 % |
| Equipo | 413,514.96 | 17.21 % |
| Subcontratos | 66,855.44 | 2.78 % |

## Alcance y límites

Se corrigieron los datos del presupuesto que MYG consulta y sus informes. Se conservan las tablas de fórmula polinómica, valorización contractual y administración, pero esos módulos todavía no tienen implementación equivalente en MYG. Conservar 195 tablas no certifica compatibilidad funcional de todos los módulos Delphin.

El pie nativo admite edición de porcentajes y formato de fuente. Sus fórmulas/filas se protegen en la interfaz para evitar conversiones involuntarias al pie estándar. El cronograma conserva fechas nativas; modificar inicio, duración o modo activa el cálculo propio de MYG. No se certifica igualdad de ruta crítica ni cálculos intradiarios.

La interfaz gráfica de Windows, la impresión PDF en Windows, la licencia real y la carga dentro de Revit requieren comprobación en ese sistema. Aquí se verificaron datos, cálculos, informes del motor y compilación. La SQLite y los PDF adjuntos no se publican en esta entrega.

## Repetir la validación

Desde la raíz del código:

```powershell
dotnet build MYG.Presupuestos.sln -c Release -p:UseRevitReferencePackages=true -m:1 -nr:false
# Opcional: ruta a la muestra original, fuera del repositorio
$env:MYG_QA_LLACUSBAMBA_SQLITE = 'D:\Datos\BASE_LLACUSBAMBA.sqlite'
dotnet run --project MYG.Pruebas/MYG.Pruebas.csproj -c Release --no-build --no-restore
Remove-Item Env:\MYG_QA_LLACUSBAMBA_SQLITE
```

Sin la variable opcional se ejecutan las pruebas sintéticas y se omiten los casos que requieren esa muestra externa. Para comprobar la interfaz en Windows: `dotnet run --project MYG.PruebasUI/MYG.PruebasUI.csproj -c Release`.

## Archivos completos para aplicar

Las rutas son relativas a la raíz del repositorio del código. REEMPLAZAR identifica archivos existentes completos; CREAR identifica archivos nuevos. `CAMBIOS.patch` aplica ambas clases en conjunto.

| N.º | Ruta exacta del archivo | Acción requerida | Descripción |
|---|---|---|---|
| 1 | `MYG.Core/BaseDatosMYG.cs` | REEMPLAZAR | Guardar como copia la hoja completa de SQLite antes de aplicar los cambios propios. |
| 2 | `MYG.Core/CalculoPresupuestoMYG.cs` | REEMPLAZAR | Respeta parciales nativos, factores, herramientas porcentuales y pie Delphin. |
| 3 | `MYG.Core/CalendarioCronogramaMYG.cs` | REEMPLAZAR | Conserva feriados anuales del calendario importado. |
| 4 | `MYG.Core/CronogramaMYG.cs` | REEMPLAZAR | Conserva fechas, tramos y dependencias originales con avisos de límites. |
| 5 | `MYG.Core/DelphinCronogramaMYG.cs` | CREAR | Lee calendario, programación y vínculos Delphin. |
| 6 | `MYG.Core/DelphinFormatoMYG.cs` | REEMPLAZAR | Sincroniza el pie nativo y el total global sin duplicar identidades. |
| 7 | `MYG.Core/DelphinImportacionMYG.cs` | REEMPLAZAR | Importa precisión, recursos, códigos, proveedores, índices y adaptadores nativos. |
| 8 | `MYG.Core/DelphinPieMYG.cs` | CREAR | Lee y evalúa filas, fórmulas y porcentajes nativos del resumen. |
| 9 | `MYG.Core/InsumosContextoMYG.cs` | REEMPLAZAR | Consolida insumos y herramientas con el criterio de Delphin. |
| 10 | `MYG.Core/MotorPresupuestos.cs` | REEMPLAZAR | Valida el modelo nativo y sus firmas de conservación. |
| 11 | `MYG.Core/PiePresupuestoMYG.cs` | REEMPLAZAR | Evalúa el resumen nativo y su alcance único por proyecto. |
| 12 | `MYG.Core/PresupuestosModelos.cs` | REEMPLAZAR | Guarda parciales por recurso y las filas del pie nativo. |
| 13 | `MYG.Core/ReportesCronogramaMYG.cs` | REEMPLAZAR | Distribuye costo y adquisiciones por tramos separados. |
| 14 | `MYG.Core/ReportesProyectoMYG.cs` | REEMPLAZAR | Imprime el pie global una vez y conserva códigos e índices en ACU. |
| 15 | `MYG.Desktop/CronogramaGanttControl.cs` | REEMPLAZAR | Dibuja los tramos separados del Gantt. |
| 16 | `MYG.Desktop/PresupuestosPiePanel.cs` | REEMPLAZAR | Muestra importes completos y permite porcentajes del pie nativo. |
| 17 | `MYG.Desktop/PresupuestosResumenMenu.cs` | REEMPLAZAR | Protege la estructura nativa y conserva identidades al copiar y pegar. |
| 18 | `MYG.Pruebas/DelphinContenidoLLacusbambaCheck.cs` | CREAR | Verifica cantidades y especificaciones de la muestra externa. |
| 19 | `MYG.Pruebas/DelphinCronogramaCheck.cs` | CREAR | Verifica tramos, calendario, vínculos y reparto de costos. |
| 20 | `MYG.Pruebas/DelphinPieCheck.cs` | CREAR | Verifica fórmulas, total global, edición y persistencia del resumen. |
| 21 | `MYG.Pruebas/DelphinRecursosCheck.cs` | CREAR | Verifica precisión, parciales, factores, proveedores y herramientas. |
| 22 | `MYG.Pruebas/GuardarComoDelphinCheck.cs` | CREAR | Verifica conservación integral de SQLite y recuperación ante fallos. |
| 23 | `MYG.Pruebas/Program.cs` | REEMPLAZAR | Registra las nuevas pruebas de compatibilidad. |
| 24 | `MYG.Pruebas/ReportesProyectoCheck.cs` | REEMPLAZAR | Prueba alcance del pie, numeración, códigos y recursos en informes. |
| 25 | `MYG.PruebasUI/PiePresupuestoSombreadoCheck.cs` | REEMPLAZAR | Prueba presentación y protección del pie nativo en Windows. |
