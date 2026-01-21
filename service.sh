#!/system/bin/sh
# Esperar a que el sistema esté completamente iniciado
until [ "$(getprop sys.boot_completed)" = "1" ]; do
    sleep 1
done

# Esperar 5 segundos adicionales para asegurar que los servicios estén listos
sleep 5

# Cambiar deviceLevelList
settings put system deviceLevelList v:3,c:2,g:2

# Configurar animaciones
settings put global window_animation_scale 0
settings put global transition_animation_scale 0
settings put global animator_duration_scale 0.5

# Obtener la ruta del módulo
MODDIR="/data/adb/modules/device_level_changer"

# Actualizar la descripción del módulo con check marks
cat > "$MODDIR/module.prop" << EOF
id=device_level_changer
name=Balanced Mid Range 
version=1.2
versionCode=120
author=@Tsukiinome
description=✅ deviceLevelList: v:3,c:2,g:2 | ✅ Animaciones configuradas | Última actualización: $(date '+%d/%m/%Y %H:%M')
EOF

# Log para verificar (opcional)
echo "Configuraciones aplicadas - $(date)" >> /data/local/tmp/device_level_log.txt
echo "deviceLevelList: v:3,c:2,g:2" >> /data/local/tmp/device_level_log.txt
echo "window_animation_scale: 0" >> /data/local/tmp/device_level_log.txt
echo "transition_animation_scale: 0" >> /data/local/tmp/device_level_log.txt
echo "animator_duration_scale: 0.5" >> /data/local/tmp/device_level_log.txt
echo "---" >> /data/local/tmp/device_level_log.txt