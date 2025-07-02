#!/bin/bash

# Script de prueba para verificar detección del sistema de init

echo "🔍 Probando detección de sistema de init..."
echo ""

echo "Método 1: command -v systemctl"
if command -v systemctl &> /dev/null; then
    echo "✅ systemctl comando encontrado"
else
    echo "❌ systemctl comando NO encontrado"
fi

echo ""
echo "Método 2: systemctl --version"
if systemctl --version &>/dev/null; then
    echo "✅ systemctl responde a --version"
else
    echo "❌ systemctl NO responde a --version"
fi

echo ""
echo "Método 3: Directorio /run/systemd/system"
if [ -d /run/systemd/system ]; then
    echo "✅ Directorio /run/systemd/system existe"
else
    echo "❌ Directorio /run/systemd/system NO existe"
fi

echo ""
echo "Método 4: Proceso systemd como PID 1"
if [ "$(ps -p 1 -o comm= 2>/dev/null)" = "systemd" ]; then
    echo "✅ systemd es el proceso PID 1"
else
    echo "❌ systemd NO es el proceso PID 1"
    echo "Proceso PID 1: $(ps -p 1 -o comm= 2>/dev/null || echo 'desconocido')"
fi

echo ""
echo "🎯 DETECCIÓN FINAL:"
if systemctl --version &>/dev/null && [ -d /run/systemd/system ]; then
    echo "✅ Sistema usa SYSTEMD"
else
    echo "✅ Sistema usa SYSV INIT"
fi

echo ""
echo "Información adicional:"
echo "- Distribución: $(lsb_release -d 2>/dev/null | cut -f2 || echo 'Desconocida')"
echo "- Kernel: $(uname -r)"
echo "- Sistema operativo: $(uname -o 2>/dev/null || uname -s)"

if [[ -n "$CLOUD_SHELL" ]]; then
    echo "- Entorno: Google Cloud Shell"
else
    echo "- Entorno: Sistema local/VM"
fi
