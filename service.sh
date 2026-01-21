#!/system/bin/sh

#####################################
# Configuración del módulo
#####################################

MODDIR="/data/adb/modules/device_level_changer"
CONFIG_FILE="$MODDIR/config.txt"
LOG_FILE="/data/local/tmp/device_level_log.txt"
BACKUP_FILE="/data/local/tmp/device_level_backup.txt"

#####################################
# Esperar boot completo
#####################################

until [ "$(getprop sys.boot_completed)" = "1" ]; do
    sleep 1
done

# Esperar 5 segundos adicionales
sleep 5

#####################################
# Obtener información del dispositivo
#####################################

DEVICE_MODEL=$(getprop ro.product.model)
DEVICE_BRAND=$(getprop ro.product.brand)
ANDROID_VERSION=$(getprop ro.build.version.release)

# Si no se puede obtener el modelo, usar valores alternativos
if [ -z "$DEVICE_MODEL" ]; then
    DEVICE_MODEL=$(getprop ro.product.name)
fi

if [ -z "$DEVICE_BRAND" ]; then
    DEVICE_BRAND=$(getprop ro.product.manufacturer)
fi

# Información completa del dispositivo
DEVICE_INFO="$DEVICE_BRAND $DEVICE_MODEL (Android $ANDROID_VERSION)"

#####################################
# Cargar configuración
#####################################

if [ -f "$CONFIG_FILE" ]; then
    . "$CONFIG_FILE"
else
    # Valores por defecto si no existe config
    DEVICE_LEVEL="v:3,c:2,g:2"
    PROFILE_NAME="Balanced"
    ANIM_WINDOW="0"
    ANIM_TRANSITION="0"
    ANIM_DURATION="0.5"
    ANIM_NAME="Default"
    CREATE_BACKUP="false"
    ENABLE_LOGS="false"
fi

#####################################
# Función de logging
#####################################

log_message() {
    if [ "$ENABLE_LOGS" = "true" ]; then
        echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> "$LOG_FILE"
    fi
}

#####################################
# Crear backup de configuración original
#####################################

if [ "$CREATE_BACKUP" = "true" ] && [ ! -f "$BACKUP_FILE" ]; then
    log_message "Creando backup de configuración original..."
    
    echo "# Backup creado el $(date '+%Y-%m-%d %H:%M:%S')" > "$BACKUP_FILE"
    echo "ORIGINAL_DEVICE_LEVEL=$(settings get system deviceLevelList)" >> "$BACKUP_FILE"
    echo "ORIGINAL_WINDOW_ANIM=$(settings get global window_animation_scale)" >> "$BACKUP_FILE"
    echo "ORIGINAL_TRANSITION_ANIM=$(settings get global transition_animation_scale)" >> "$BACKUP_FILE"
    echo "ORIGINAL_DURATION_ANIM=$(settings get global animator_duration_scale)" >> "$BACKUP_FILE"
    
    log_message "✓ Backup creado en $BACKUP_FILE"
fi

#####################################
# Aplicar configuración
#####################################

log_message "=========================================="
log_message "Dispositivo: $DEVICE_INFO"
log_message "Aplicando configuración - Perfil: $PROFILE_NAME"

# Cambiar deviceLevelList
RESULT=$(settings put system deviceLevelList "$DEVICE_LEVEL" 2>&1)
if [ $? -eq 0 ]; then
    log_message "✓ deviceLevelList configurado: $DEVICE_LEVEL"
else
    log_message "✗ Error al configurar deviceLevelList: $RESULT"
fi

# Configurar animaciones
settings put global window_animation_scale "$ANIM_WINDOW"
log_message "✓ window_animation_scale: $ANIM_WINDOW"

settings put global transition_animation_scale "$ANIM_TRANSITION"
log_message "✓ transition_animation_scale: $ANIM_TRANSITION"

settings put global animator_duration_scale "$ANIM_DURATION"
log_message "✓ animator_duration_scale: $ANIM_DURATION"

#####################################
# Verificar aplicación
#####################################

CURRENT_DEVICE_LEVEL=$(settings get system deviceLevelList)
CURRENT_WINDOW=$(settings get global window_animation_scale)
CURRENT_TRANSITION=$(settings get global transition_animation_scale)
CURRENT_DURATION=$(settings get global animator_duration_scale)

if [ "$CURRENT_DEVICE_LEVEL" = "$DEVICE_LEVEL" ]; then
    STATUS_DEVICE="✅"
    log_message "✓ Verificación deviceLevelList: OK"
else
    STATUS_DEVICE="⚠️"
    log_message "⚠ Verificación deviceLevelList: FALLO"
    log_message "  Esperado: $DEVICE_LEVEL"
    log_message "  Actual: $CURRENT_DEVICE_LEVEL"
fi

if [ "$CURRENT_WINDOW" = "$ANIM_WINDOW" ] && [ "$CURRENT_TRANSITION" = "$ANIM_TRANSITION" ] && [ "$CURRENT_DURATION" = "$ANIM_DURATION" ]; then
    STATUS_ANIM="✅"
    log_message "✓ Verificación animaciones: OK"
else
    STATUS_ANIM="⚠️"
    log_message "⚠ Verificación animaciones: FALLO"
fi

#####################################
# Actualizar descripción del módulo
#####################################

# Descripción detallada en múltiples líneas
cat > "$MODDIR/module.prop" << EOF
id=device_level_changer
name=HyperOs Flagship
version=1.5
versionCode=150
author=@Tsukiinome
description=📱 Modelo: $DEVICE_INFO | $STATUS_DEVICE Perfil: $PROFILE_NAME | 🎮 deviceLevelList: $CURRENT_DEVICE_LEVEL | $STATUS_ANIM Animaciones: $ANIM_NAME (W:$CURRENT_WINDOW T:$CURRENT_TRANSITION D:$CURRENT_DURATION) | ⏱️ $(date '+%d/%m/%Y %H:%M')
EOF

log_message "✓ module.prop actualizado"
log_message "  Modelo: $DEVICE_INFO"
log_message "  deviceLevelList actual: $CURRENT_DEVICE_LEVEL"
log_message "  Animaciones actuales: W:$CURRENT_WINDOW T:$CURRENT_TRANSITION D:$CURRENT_DURATION"
log_message "=========================================="

#####################################
# Rotación de logs (mantener últimas 100 líneas)
#####################################

if [ "$ENABLE_LOGS" = "true" ] && [ -f "$LOG_FILE" ]; then
    LINE_COUNT=$(wc -l < "$LOG_FILE")
    if [ "$LINE_COUNT" -gt 100 ]; then
        tail -n 100 "$LOG_FILE" > "${LOG_FILE}.tmp"
        mv "${LOG_FILE}.tmp" "$LOG_FILE"
        log_message "✓ Log rotado (manteniendo últimas 100 líneas)"
    fi
fi
