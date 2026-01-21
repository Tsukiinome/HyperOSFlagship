#!/system/bin/sh

# Este script se ejecuta durante la instalación del módulo
MODPATH=${0%/*}

# Establecer permisos de ejecución para los scripts
ui_print "- Configurando permisos..."
set_perm_recursive $MODPATH 0 0 0755 0644
set_perm $MODPATH/service.sh 0 0 0755

ui_print "- Módulo instalado correctamente"
ui_print "- Reinicia tu dispositivo para aplicar los cambios"
ui_print "- La descripción se actualizará con ✓ cuando se apliquen los cambios"