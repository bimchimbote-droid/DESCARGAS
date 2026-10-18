# Actualización: parámetros predeterminados

Proyecto: bimchimbote-droid/MYG.Presupuestos, rama de referencia main.
Base del código: `8720072b07a79115494ce7c2122239360c73d435`. Fecha: 17/10/2026 19:23 (Lima).
Entrega independiente: bimchimbote-droid/DESCARGAS, público según la elección del usuario.
Esta entrega no publica commits ni modifica ramas del repositorio del código.

## Qué incorpora

En Inicio aparece **Parámetros predeterminados**, disponible antes de iniciar sesión. Sus pestañas son Presupuestos, Costos e Insumos, División política, Parámetros de Fierros y Aceros, Colores de Partidas y General.

Aceptar valida y guarda; Cerrar o Escape descarta. Los porcentajes, moneda, precisión, unidades, proveedor, jornada y rendimiento se aplican al crear presupuestos, partidas e insumos. Cambiar preferencias no reescribe sus datos anteriores ni importados. Las nuevas hojas de acero conservan pesos, ganchos, empalmes y desperdicio por diámetro, con resultados en kg o toneladas. Las preferencias posteriores no cambian esas hojas.

Las denominaciones geográficas se usan en Datos del proyecto. Los diez colores se muestran en los títulos de pantalla y de impresión. General muestra el nombre y logo en Inicio y propone el nombre como propietario al crear proyectos; el propietario se registra únicamente al aceptar sus datos. El logo se guarda dentro de la configuración, sin depender del archivo original.

Valores de referencia: gastos generales 12 %, utilidad 10 % e IGV 18 %. Las abreviaturas de gastos usan letras, números o guion bajo para poder emplearse en las fórmulas. La renta se calcula sobre utilidad; IGV y otros impuestos sobre costo directo + gastos generales + otros gastos + utilidad. Las tasas y conceptos se pueden editar posteriormente desde el panel Resumen del presupuesto.

La referencia visual se adaptó a los controles del software. El índice de fórmula polinómica del video no se incluyó: el proyecto no cuenta con ese cálculo. La denominación de moneda identifica la preferencia en este diálogo; el símbolo de moneda es el valor aplicado al presupuesto.

## Aplicación manual sin perder avances

1. Guarde sus cambios y haga una copia de seguridad de su carpeta local. La carpeta de referencia del documento recibido es `D:\ADDIN\repos\MYG.Presupuestos_GITHUB`; use su ruta real si es diferente.
2. Abra la solución `MYG.Presupuestos.sln`. Las rutas de la tabla parten de esa carpeta. El ZIP contiene los archivos completos: cree los marcados CREAR y sustituya los marcados REEMPLAZAR sólo después de comprobar que no tienen cambios locales más recientes. No sustituya la carpeta completa ni su `.git`, bases SQLite, configuración de licencias o proyectos de usuario.
3. Como alternativa para conservar modificaciones locales compatibles, desde la raíz del repositorio ejecute `git apply --check "RUTA_EXTRAIDA/CAMBIOS.patch"`. Si pasa, ejecute `git apply "RUTA_EXTRAIDA/CAMBIOS.patch"`. Si detecta conflictos, deténgase y combine los cambios; no fuerce ni restablezca archivos. Aplique por copia **o** parche, una sola vez.
4. Los proyectos SDK incluyen automáticamente los archivos .cs nuevos. No hace falta editar .csproj, dependencias o solución.
5. Compile y ejecute las comprobaciones indicadas abajo. Abra Inicio → Parámetros predeterminados. Configure, acepte y cree datos nuevos para comprobar los valores.

Las preferencias se guardan por usuario en `%LOCALAPPDATA%\MYG\Presupuestos\parametros-predeterminados.json`. Un archivo dañado se informa y conserva; no se sustituye silenciosamente.

## Validación

Compilación completa Release con .NET SDK 10.0.100: **0 errores, 0 advertencias**.
Suite de núcleo Release: **462 comprobaciones correctas**; incluye persistencia desde otro proceso, impuestos, totales de reportes y resumen conjunto, JSON/SQLite, aceros y detección de hojas vacías.

```powershell
dotnet restore MYG.Presupuestos.sln -p:UseRevitReferencePackages=true
dotnet build MYG.Presupuestos.sln -c Release --no-restore -p:UseRevitReferencePackages=true -m:1 -nr:false
dotnet run --project MYG.Pruebas/MYG.Pruebas.csproj -c Release --no-build --no-restore
```

Las pruebas WinForms nuevas compilaron; **su ejecución visual no se realizó en Linux**. Para ejecutarlas en Windows con .NET Desktop Runtime 10:

```powershell
dotnet run --project MYG.PruebasUI/MYG.PruebasUI.csproj -c Release -- --parametros
```

La suite omite Named Pipes de Windows y datos externos opcionales que no se proporcionaron. No se ejecutaron Revit, una licencia real ni el instalador de Windows. El ZIP contiene código fuente, no un instalador ni binarios.

## Archivos

| N.º | Ruta exacta del archivo | Acción requerida | Descripción |
|---|---|---|---|
| 1 | ACTUALIZACION_PARAMETROS.md | CREAR | Instrucciones, validación y tabla completa de archivos. |
| 2 | MYG.Core/ContenidoPartida.cs | REEMPLAZAR | Reconocer plantillas de acero vacías con parámetros propios. |
| 3 | MYG.Core/HojaMetrado.cs | REEMPLAZAR | Conservar los valores automáticos iniciales de cada hoja. |
| 4 | MYG.Core/MotorPresupuestos.cs | REEMPLAZAR | Conservar la firma de los presupuestos con total configurable. |
| 5 | MYG.Core/ParametrosPredeterminados.cs | CREAR | Modelos, validación, guardado por usuario y aplicación de parámetros. |
| 6 | MYG.Core/PiePresupuestoMYG.cs | REEMPLAZAR | Mostrar el Total sin duplicarlo en los cálculos. |
| 7 | MYG.Core/PresupuestosModelos.cs | REEMPLAZAR | Guardar la opción de total de los nuevos resúmenes. |
| 8 | MYG.Desktop/CatalogosForm.cs | REEMPLAZAR | Aplicar unidades y proveedor al crear en los catálogos. |
| 9 | MYG.Desktop/DatosProyectoForm.cs | REEMPLAZAR | Usar nombres geográficos y proponer la empresa en proyectos nuevos. |
| 10 | MYG.Desktop/EditorEstructura.cs | REEMPLAZAR | Aplicar preferencias a presupuestos y partidas nuevos. |
| 11 | MYG.Desktop/EditorForm.cs | REEMPLAZAR | Aplicar unidad y rendimiento en la creación de partidas. |
| 12 | MYG.Desktop/InicioParametros.cs | CREAR | Botón de parámetros e identidad de empresa en Inicio. |
| 13 | MYG.Desktop/InsumosForm.cs | REEMPLAZAR | Usar preferencias en nuevos insumos del ACU. |
| 14 | MYG.Desktop/ParametrosAplicacionUI.cs | CREAR | Actualizar empresa, logo, colores y nombres de ubicación. |
| 15 | MYG.Desktop/ParametrosPredeterminadosForm.cs | CREAR | Ventana de las seis pestañas, con Aceptar y Cerrar. |
| 16 | MYG.Desktop/PresupuestosExcelPlantillas.cs | REEMPLAZAR | Crear hojas de acero con los parámetros guardados. |
| 17 | MYG.Desktop/PresupuestosPanel.cs | REEMPLAZAR | Aplicar los valores iniciales al crear insumos. |
| 18 | MYG.Desktop/PresupuestosResumenMenu.cs | REEMPLAZAR | Conservar el total al copiar y pegar resúmenes. |
| 19 | MYG.Desktop/ProyectosAbiertos.cs | REEMPLAZAR | Incluir la barra de parámetros en la pestaña Inicio. |
| 20 | MYG.Desktop/Tema.cs | REEMPLAZAR | Aplicar los diez colores a pantalla e impresión. |
| 21 | MYG.Pruebas/ContenidoPartidaCheck.cs | REEMPLAZAR | Comprobar contenido real en hojas de acero configuradas. |
| 22 | MYG.Pruebas/ParametrosPredeterminadosCheck.cs | CREAR | Probar persistencia, importes, aceros e integridad de datos. |
| 23 | MYG.Pruebas/Program.cs | REEMPLAZAR | Ejecutar las comprobaciones nuevas del núcleo. |
| 24 | MYG.PruebasUI/ParametrosCreacionUICheck.cs | CREAR | Comprobar los vínculos de creación y conservación de datos. |
| 25 | MYG.PruebasUI/ParametrosDialogoUICheck.cs | CREAR | Comprobar pestañas, aceptación, cancelación y validación. |
| 26 | MYG.PruebasUI/ParametrosPresentacionUICheck.cs | CREAR | Comprobar empresa, logo, ubicación y colores. |
| 27 | MYG.PruebasUI/Program.cs | REEMPLAZAR | Incluir la suite de parámetros y su opción --parametros. |
