# Corrección del tamaño de texto de MYG Presupuestos

Repositorio de código: bimchimbote-droid/MYG.Presupuestos (main).
Carpeta local indicada: D:\ADDIN\repos\MYG.Presupuestos_GITHUB.
Base de esta entrega: 6a31acfb9b55c10e66ef84f918c3dae2e76ebfde.

Se corrige la destrucción prematura del menú Texto de Inicio. El menú se reutiliza y solo se libera al destruir su botón, evitando ObjectDisposedException durante el cierre. Se conservan las opciones Compacto (85 %), Normal (100 %) y Grande (115 %).

| N.º | Ruta exacta del archivo | Acción requerida | Descripción |
|---|---|---|---|
| 1 | MYG.Desktop/TamanoTextoUI.cs | REEMPLAZAR | Corrige la vida del menú y actualiza la marca y el tema al reabrir. |
| 2 | MYG.PruebasUI/TamanoTextoUICheck.cs | REEMPLAZAR | Prueba la selección real de 85 %, 115 % y 100 %, reapertura, cancelación y cierre de Inicio. |
| 3 | MYG.PruebasUI/README.md | REEMPLAZAR | Documenta la prueba de regresión en Windows. |

## Aplicación manual

1. Detenga la aplicación y la depuración de Visual Studio.
2. Extraiga este ZIP en una carpeta temporal fuera del repositorio.
3. Abra su repositorio local y revise `git status --short`. Guarde una copia de los tres archivos actuales fuera del repositorio. Si tienen avances locales posteriores a esta base, compare los cambios antes de reemplazarlos.
4. Copie únicamente los tres archivos de la tabla a sus rutas homónimas. Se entregan completos. Conserve el resto de su solución y su carpeta .git para mantener el historial y la conexión con GitHub.
5. Abra MYG.Presupuestos.sln, seleccione Release / x64 y compile MYG.Desktop en Visual Studio. También puede ejecutar desde la raíz:

```powershell
dotnet build .\MYG.Desktop\MYG.Desktop.csproj -c Release
```

6. Ejecute la aplicación y pruebe Texto: 85 %, 115 % y 100 % repetidamente. Cancele el menú, vuelva a abrirlo y cierre Inicio con el menú abierto. El cambio debe aplicarse sin la excepción y la opción marcada debe coincidir con el porcentaje actual.
7. Para ejecutar la suite de interfaz en Windows con SDK .NET 10:

```powershell
dotnet run --project .\MYG.PruebasUI\MYG.PruebasUI.csproj -c Release
```

Esta actualización no requiere modificar bases SQLite, dependencias ni archivos de proyecto.

## Alternativa: aplicar el parche

Si prefiere conservar otros cambios de esos archivos, use el parche desde la raíz del repositorio. Sustituya la ruta de ejemplo por la carpeta donde extrajo el ZIP:

```powershell
git apply --check 'C:\Temp\MYG_Texto\cambio-tamano-texto.patch'
git apply 'C:\Temp\MYG_Texto\cambio-tamano-texto.patch'
```

Si `--check` informa un conflicto, no fuerce el parche; compare los cambios con sus archivos. Use una sola alternativa: reemplazar archivos o aplicar el parche.

## Validación de esta entrega

- Solución completa compilada en Linux con .NET 10.0.100: 0 errores y 0 advertencias.
- 451 comprobaciones del núcleo correctas; Named Pipes de Windows y la muestra externa LLACUSBAMBA se omiten en este entorno.
- La prueba de regresión de interfaz compila; su ejecución visual está pendiente en Windows. No se afirma que se haya ejecutado aquí.
- El parche se aplicó sobre copias de los archivos originales del commit base y reprodujo exactamente los archivos entregados.
- SHA256SUMS.txt permite comprobar la integridad de los archivos del paquete.

Los ZIP de entregas anteriores se conservan en DESCARGAS. Esta entrega no hace push al repositorio del código.
