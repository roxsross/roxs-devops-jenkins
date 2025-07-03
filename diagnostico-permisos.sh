#!/bin/bash

# 🔍 Diagnóstico Completo de Permisos Jenkins
# Este script verifica todos los aspectos de permisos de Jenkins

echo "🔍 DIAGNÓSTICO COMPLETO DE PERMISOS JENKINS"
echo "============================================="

# Verificar usuario jenkins
echo ""
echo "👤 Verificando usuario jenkins..."
if id jenkins &>/dev/null; then
    echo "✅ Usuario jenkins existe"
    echo "   UID: $(id -u jenkins)"
    echo "   GID: $(id -g jenkins)"
    echo "   Grupos: $(groups jenkins)"
else
    echo "❌ Usuario jenkins NO existe"
    exit 1
fi

# Verificar archivo sudoers para jenkins
echo ""
echo "🔐 Verificando configuración sudo..."
if [ -f /etc/sudoers.d/jenkins ]; then
    echo "✅ Archivo /etc/sudoers.d/jenkins existe"
    echo "   Contenido:"
    sudo cat /etc/sudoers.d/jenkins | sed 's/^/   /'
    
    # Verificar sintaxis
    if sudo visudo -c -f /etc/sudoers.d/jenkins &>/dev/null; then
        echo "✅ Sintaxis del archivo sudoers es válida"
    else
        echo "❌ Error en sintaxis del archivo sudoers"
    fi
else
    echo "❌ Archivo /etc/sudoers.d/jenkins NO existe"
    echo "💡 Necesitas ejecutar: sudo ./arreglar-permisos.sh"
fi

# Probar permisos sudo como jenkins
echo ""
echo "🧪 Probando permisos sudo como jenkins..."
if sudo -u jenkins sudo -n true 2>/dev/null; then
    echo "✅ Jenkins puede ejecutar sudo sin contraseña"
else
    echo "❌ Jenkins NO puede ejecutar sudo sin contraseña"
fi

# Probar comandos específicos
echo ""
echo "🧪 Probando comandos específicos..."
commands=("/bin/cp" "/bin/chown" "/bin/mkdir")
for cmd in "${commands[@]}"; do
    if sudo -u jenkins sudo -n $cmd --help &>/dev/null; then
        echo "✅ Jenkins puede ejecutar: $cmd"
    else
        echo "❌ Jenkins NO puede ejecutar: $cmd"
    fi
done

# Verificar directorio de despliegue
echo ""
echo "📁 Verificando directorio de despliegue..."
if [ -d /var/www/portfolio ]; then
    echo "✅ Directorio /var/www/portfolio existe"
    echo "   Propietario: $(stat -c '%U:%G' /var/www/portfolio)"
    echo "   Permisos: $(stat -c '%a' /var/www/portfolio)"
else
    echo "❌ Directorio /var/www/portfolio NO existe"
    echo "💡 Creando directorio..."
    sudo mkdir -p /var/www/portfolio
    sudo chown -R www-data:www-data /var/www/portfolio
    echo "✅ Directorio creado y configurado"
fi

# Verificar proceso Jenkins
echo ""
echo "🔧 Verificando proceso Jenkins..."
if pgrep -f jenkins > /dev/null; then
    echo "✅ Proceso Jenkins está corriendo"
    echo "   PID: $(pgrep -f jenkins)"
    echo "   Usuario: $(ps -o user= -p $(pgrep -f jenkins))"
else
    echo "❌ Proceso Jenkins NO está corriendo"
fi

echo ""
echo "🔧 SOLUCIÓN AUTOMÁTICA"
echo "======================"
echo ""
echo "Si hay problemas, ejecuta estos comandos:"
echo ""
echo "1. Configurar permisos:"
echo "   sudo ./arreglar-permisos.sh"
echo ""
echo "2. Reiniciar Jenkins:"
echo "   sudo service jenkins restart"
echo ""
echo "3. Verificar otra vez:"
echo "   ./diagnostico-permisos.sh"
