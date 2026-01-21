#!/system/bin/sh

MODPATH=${0%/*}

#####################################
# Funciones de selección de volumen
#####################################

chooseport() {
    while true; do
        getevent -lc 1 2>&1 | grep VOLUME | grep " DOWN" > $TMPDIR/events
        if $(cat $TMPDIR/events 2>/dev/null | grep -q VOLUME); then
            break
        fi
    done
    if $(cat $TMPDIR/events 2>/dev/null | grep -q VOLUMEUP); then
        return 0
    else
        return 1
    fi
}

chooseportold() {
    while true; do
        KEY_EVENT=$(getevent -qlc 1)
        KEY_EVENT=$(echo "$KEY_EVENT" | awk '{ print $3 }' | grep 'KEY_')
        if [ "$KEY_EVENT" = "KEY_VOLUMEUP" ]; then
            return 0
        elif [ "$KEY_EVENT" = "KEY_VOLUMEDOWN" ]; then
            return 1
        fi
    done
}

# Intentar método moderno primero, si falla usar el antiguo
chooseport_wrapper() {
    if timeout 3 chooseport; then
        return $?
    else
        chooseportold
        return $?
    fi
}

#####################################
# Banner y bienvenida
#####################################

ui_print " "
ui_print "╔════════════════════════════════════╗"
ui_print "║   Balanced Mid Range Installer     ║"
ui_print "║          v1.3 Interactive          ║"
ui_print "╚════════════════════════════════════╝"
ui_print " "
sleep 1

#####################################
# Selección de perfil
#####################################

ui_print "┌────────────────────────────────────┐"
ui_print "│    Selecciona tu perfil:           │"
ui_print "├────────────────────────────────────┤"
ui_print "│                                    │"
ui_print "│  Vol+ = Performance                │"
ui_print "│         (v:4, c:3, g:3)            │"
ui_print "│                                    │"
ui_print "│  Vol- = Balanced                   │"
ui_print "│         (v:3, c:2, g:2)            │"
ui_print "│                                    │"
ui_print "└────────────────────────────────────┘"
ui_print " "

if chooseport_wrapper; then
    DEVICE_LEVEL="v:4,c:3,g:3"
    PROFILE_NAME="Performance"
    ui_print "✓ Perfil seleccionado: Performance"
else
    DEVICE_LEVEL="v:3,c:2,g:2"
    PROFILE_NAME="Balanced"
    ui_print "✓ Perfil seleccionado: Balanced"
fi

ui_print " "
sleep 1

#####################################
# Configuración de animaciones
#####################################

ui_print "┌────────────────────────────────────┐"
ui_print "│    Configuración de animaciones:   │"
ui_print "├────────────────────────────────────┤"
ui_print "│                                    │"
ui_print "│  Vol+ = Medias (1x)          │"
ui_print "│         + animaciones/menor rendimiento          │"
ui_print "│                                    │"
ui_print "│  Vol- = Suaves (0.5x)              │"
ui_print "│         Balance velocidad/suavidad │"
ui_print "│                                    │"
ui_print "└────────────────────────────────────┘"
ui_print " "

if chooseport_wrapper; then
    ANIM_WINDOW=".05"
    ANIM_TRANSITION="0.5"
    ANIM_DURATION="0.5"
    ANIM_NAME="Medias"
    ui_print "✓ Animaciones: Medias (all 0.5)"
else
    ANIM_WINDOW="0.5"
    ANIM_TRANSITION="0.5"
    ANIM_DURATION="0.5"
    ANIM_NAME="Suaves"
    ui_print "✓ Animaciones: Suaves (0.5x)"
fi

ui_print " "
sleep 1

#####################################
# Backup de configuración original
#####################################

ui_print "┌────────────────────────────────────┐"
ui_print "│    ¿Crear backup de config?        │"
ui_print "├────────────────────────────────────┤"
ui_print "│                                    │"
ui_print "│  Vol+ = Sí (recomendado)          │"
ui_print "│  Vol- = No                         │"
ui_print "│                                    │"
ui_print "└────────────────────────────────────┘"
ui_print " "

if chooseport_wrapper; then
    CREATE_BACKUP="true"
    ui_print "✓ Se creará backup"
else
    CREATE_BACKUP="false"
    ui_print "✓ Sin backup"
fi

ui_print " "
sleep 1

#####################################
# Opciones avanzadas
#####################################

ui_print "┌────────────────────────────────────┐"
ui_print "│    ¿Habilitar logs detallados?     │"
ui_print "├────────────────────────────────────┤"
ui_print "│                                    │"
ui_print "│  Vol+ = Sí                         │"
ui_print "│  Vol- = No                         │"
ui_print "│                                    │"
ui_print "└────────────────────────────────────┘"
ui_print " "

if chooseport_wrapper; then
    ENABLE_LOGS="true"
    ui_print "✓ Logs habilitados"
else
    ENABLE_LOGS="false"
    ui_print "✓ Logs deshabilitados"
fi

ui_print " "
sleep 1

#####################################
# Guardar configuración
#####################################

ui_print "- Guardando configuración..."

# Crear archivo de configuración
cat > "$MODPATH/config.txt" << EOF
# Configuración del módulo
DEVICE_LEVEL=$DEVICE_LEVEL
PROFILE_NAME=$PROFILE_NAME
ANIM_WINDOW=$ANIM_WINDOW
ANIM_TRANSITION=$ANIM_TRANSITION
ANIM_DURATION=$ANIM_DURATION
ANIM_NAME=$ANIM_NAME
CREATE_BACKUP=$CREATE_BACKUP
ENABLE_LOGS=$ENABLE_LOGS
INSTALL_DATE=$(date '+%Y-%m-%d %H:%M:%S')
EOF

#####################################
# Establecer permisos
#####################################

ui_print "- Configurando permisos..."
set_perm_recursive $MODPATH 0 0 0755 0644
set_perm $MODPATH/service.sh 0 0 0755
set_perm $MODPATH/config.txt 0 0 0644

#####################################
# Resumen de instalación
#####################################

ui_print " "
ui_print "╔════════════════════════════════════╗"
ui_print "║      Instalación completada        ║"
ui_print "╚════════════════════════════════════╝"
ui_print " "
ui_print "Configuración aplicada:"
ui_print "  • Perfil: $PROFILE_NAME"
ui_print "  • Device Level: $DEVICE_LEVEL"
ui_print "  • Animaciones: $ANIM_NAME"
ui_print "  • Backup: $CREATE_BACKUP"
ui_print "  • Logs: $ENABLE_LOGS"
ui_print " "
ui_print "⚠️  REINICIA tu dispositivo para"
ui_print "    aplicar los cambios"
ui_print " "

sleep 2
