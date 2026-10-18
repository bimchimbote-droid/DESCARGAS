# Corrección: parámetros dentro de Opciones

Proyecto: bimchimbote-droid/MYG.Presupuestos. Fecha: 17/10/2026 19:31 (Lima).

El botón **Parámetros predeterminados** aparece como la última opción del panel derecho, inmediatamente debajo de **Crear otra base**, con el mismo estilo y tamaño que las demás opciones. Se retira el botón superior. Nombre y logo de empresa se conservan cuando estén configurados.

Al abrir o crear una base SQLite, Inicio muestra el panel Opciones con el botón. Los campos, el guardado y las preferencias existentes conservan su funcionamiento.

## Aplicar sobre la entrega anterior

Esta es una corrección incremental para la entrega de parámetros ya instalada. La entrega anterior completa está en:
https://github.com/bimchimbote-droid/DESCARGAS/tree/3d31b282da37a298fc96087b70bcf3f4f7737f8c/ENTREGAS/2026-10-17_PARAMETROS_192313

1. Guarde sus cambios y haga una copia de seguridad de los cuatro archivos que va a sustituir. Las rutas parten de la carpeta donde está MYG.Presupuestos.sln; use su carpeta local real.
2. Copie los archivos completos del ZIP siguiendo la tabla. Si tiene cambios locales más recientes en ellos, combínelos antes de reemplazarlos. No sustituya el repositorio completo ni su .git.
3. Como alternativa a copiar archivos, desde la raíz de la solución ejecute `git apply --check "RUTA_EXTRAIDA/CAMBIOS.patch"`. Sólo si pasa, ejecute `git apply "RUTA_EXTRAIDA/CAMBIOS.patch"`. Si no pasa, revise las diferencias y no fuerce la aplicación. Utilice copia o parche, una sola vez.
4. Compile la solución y abra una base SQLite. El nuevo botón está al final de Opciones y el panel permite desplazarse si la ventana tiene poca altura.

## Validación

Compilación completa Release con .NET SDK 10.0.100: **0 errores y 0 advertencias**. El parche se aplicó sobre copias de la entrega anterior y se verificó que reproduce exactamente los archivos entregados. La comprobación de interfaz actualizada compiló; su ejecución visual requiere Windows y no se realizó en Linux.

```powershell
dotnet build MYG.Presupuestos.sln -c Release -p:UseRevitReferencePackages=true -m:1 -nr:false
dotnet run --project MYG.PruebasUI/MYG.PruebasUI.csproj -c Release -- --parametros
```

El ZIP contiene código fuente. No modifica datos de proyectos ni el archivo de preferencias. La publicación se realiza en una carpeta nueva de DESCARGAS; no se hace push al repositorio del código ni se sustituyen entregas anteriores.

## Archivos

| N.º | Ruta exacta del archivo | Acción requerida | Descripción |
|---|---|---|---|
| 1 | MYG.Desktop/InicioForm.cs | REEMPLAZAR | Añadir Parámetros predeterminados al final de Opciones. |
| 2 | MYG.Desktop/InicioParametros.cs | REEMPLAZAR | Dar al botón el mismo tamaño y estilo que las demás opciones. |
| 3 | MYG.Desktop/ProyectosAbiertos.cs | REEMPLAZAR | Retirar la barra superior y conservar la identidad de empresa. |
| 4 | MYG.PruebasUI/ParametrosDialogoUICheck.cs | REEMPLAZAR | Comprobar ubicación, orden y ausencia del botón superior. |
| 5 | REUBICAR_PARAMETROS.md | CREAR | Instrucciones de esta corrección. |
