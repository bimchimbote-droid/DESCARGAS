# Corrección de inicio: Error al crear identificador de ventana

Proyecto: bimchimbote-droid/MYG.Presupuestos, rama main.
Esta corrección se aplica DESPUÉS de la entrega de pestañas y texto de 17/10/2026 (carpeta entrega-20261017-151603-pestanas-texto). Conserva los demás archivos de esa entrega.

Se detectó que el ajuste de Padding de TabControl podía recrear su ventana dentro de HandleCreated si las medidas iniciales o el DPI diferían. Ahora ese ajuste se programa para después de la creación nativa, agrupa las solicitudes pendientes y descarta las de identificadores destruidos. Los ajustes repetidos no vuelven a asignar las mismas medidas.

## Aplicación en Visual Studio

1. Pulsa Detener depuración y cierra las instancias de MYG.
2. Extrae este ZIP fuera del checkout y respalda los dos archivos de la tabla.
3. Copia los archivos completos de ARCHIVOS a las mismas rutas de tu proyecto, reemplazando solo esos dos. No sustituyas la carpeta del repositorio ni .git.
4. Si tienes cambios propios en esos archivos, usa el parche incluido: desde el checkout ejecuta primero git apply --check C:\Ruta\CAMBIOS.patch y, solo si termina correctamente, git apply C:\Ruta\CAMBIOS.patch. El parche tiene como base la entrega anterior, no la versión original de main.
5. En Visual Studio selecciona Compilar > Recompilar solución y ejecuta MYG.Desktop otra vez.

| N.º | Ruta exacta del archivo | Acción requerida | Descripción |
|---|---|---|---|
| 1 | MYG.Desktop/TemaPestanas.cs | REEMPLAZAR | Evita recrear la ventana de pestañas mientras se inicializa. |
| 2 | MYG.PruebasUI/DisenoProfesionalCheck.cs | REEMPLAZAR | Añade comprobación de creación y recreación con medidas iniciales distintas. |

## Validación

Solución completa Release compilada en .NET 10: cero errores y cero advertencias. El parche se comprobó contra los archivos de la entrega anterior y contra los entregados.

La prueba nueva de WinForms cubre pestañas superiores/inferiores, un desfase inicial de medidas, la ausencia de destrucción del identificador durante CreateHandle y la conservación de páginas, selección, texto y RTF. Compila, pero no se ejecutó en Linux: la comprobación del inicio de sesión y de esa prueba requiere Windows.

En Windows, después de recompilar:

```powershell
dotnet run --project MYG.PruebasUI/MYG.PruebasUI.csproj -c Release --no-build --no-restore
```

No se modificaron credenciales, servicio de licencia, dependencias ni bases de datos. No se hizo commit ni push al repositorio del código. El ZIP se publica como entrega nueva en bimchimbote-droid/DESCARGAS, conservando las anteriores.
