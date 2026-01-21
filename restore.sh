#!/system/bin/sh

#####################################
# Script de restauración
# Coloca este archivo en el módulo
# y ejecútalo con: sh /data/adb/modules/device_level_changer/restore.sh
#####################################

MODDIR="/data/adb/modules/device_level_changer"
BACKUP_FILE="/data/local/tmp/device_level_backup.txt"

echo "╔════════════════════════════════════╗"
echo "║   Restaurar Configuración Original ║"
echo "╚════════════════════════════════════╝"
echo ""

#####################################
# Verificar si existe backup
#####################################

if [ ! -f "$BACKUP_FILE" ]; then
    echo "✗ No se encontró archivo de backup"
    echo "  Ubicación esperada: $BACKUP_FILE"
    echo ""
    echo "No se puede restaurar sin backup."
    exit 1
fi

#####################################
# Cargar valores del backup
#####################################

echo "- Cargando backup..."
. "$BACKUP_FILE"

echo "✓ Backup encontrado"
echo ""
echo "Configuración original:"
echo "  • Device Level: $ORIGINAL_DEVICE_LEVEL"
echo "  • Window Animation: $ORIGINAL_WINDOW_ANIM"
echo "  • Transition Animation: $ORIGINAL_TRANSITION_ANIM"
echo "  • Duration Animation: $ORIGINAL_DURATION_ANIM"
echo ""

#####################################
# Confirmar restauración
#####################################

echo "⚠️  ¿Deseas restaurar la configuración original?"
echo "   Presiona Enter para continuar o Ctrl+C para cancelar..."
read

#####################################
# Restaurar configuración
#####################################

echo ""
echo "- Restaurando configuración..."

# Restaurar deviceLevelList
if [ -n "$ORIGINAL_DEVICE_LEVEL" ] && [ "$ORIGINAL_DEVICE_LEVEL" != "null" ]; then
    settings put system deviceLevelList "$ORIGINAL_DEVICE_LEVEL"
    echo "✓ deviceLevelList restaurado"
else
    echo "⚠ deviceLevelList no tenía valor original (estaba null)"
fi

# Restaurar animaciones
if [ -n "$ORIGINAL_WINDOW_ANIM" ] && [ "$ORIGINAL_WINDOW_ANIM" != "null" ]; then
    settings put global window_animation_scale "$ORIGINAL_WINDOW_ANIM"
    echo "✓ window_animation_scale restaurado"
fi

if [ -n "$ORIGINAL_TRANSITION_ANIM" ] && [ "$ORIGINAL_TRANSITION_ANIM" != "null" ]; then
    settings put global transition_animation_scale "$ORIGINAL_TRANSITION_ANIM"
    echo "✓ transition_animation_scale restaurado"
fi

if [ -n "$ORIGINAL_DURATION_ANIM" ] && [ "$ORIGINAL_DURATION_ANIM" != "null" ]; then
    settings put global animator_duration_scale "$ORIGINAL_DURATION_ANIM"
    echo "✓ animator_duration_scale restaurado"
fi

#####################################
# Actualizar module.prop
#####################################

cat > "$MODDIR/module.prop" << EOF
id=device_level_changer
name=Balanced Mid Range
version=1.3
versionCode=130
author=@Tsukiinome
description=⚠️ Configuración RESTAURADA a valores originales | $(date '+%d/%m/%Y %H:%M')
EOF

echo ""
echo "╔════════════════════════════════════╗"
echo "║    Restauración completada         ║"
echo "╚════════════════════════════════════╝"
echo ""
echo "✓ La configuración original ha sido restaurada"
echo "✓ Reinicia tu dispositivo para aplicar los cambios"
echo ""
echo "Nota: El backup se mantiene en $BACKUP_FILE"
echo "      por si necesitas restaurar nuevamente"
echo ""