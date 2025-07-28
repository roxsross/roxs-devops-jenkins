#!/bin/bash

# 🚀 Inicialización rápida para Google Cloud Shell
# Este script verifica y prepara el entorno de Cloud Shell para Jenkins

echo "🚀 Inicialización rápida para Google Cloud Shell"
echo "================================================"
echo ""

# Verificar que estamos en Cloud Shell
if [[ -n "$CLOUD_SHELL" ]] || [[ "$USER" == "roxsross" ]] || [[ -n "$GOOGLE_CLOUD_PROJECT" ]]; then
    echo "☁️ Google Cloud Shell detectado ✅"
else
    echo "⚠️ Este script está optimizado para Google Cloud Shell"
    echo "💡 Funciona en otros sistemas, pero puede no ser necesario"
fi

echo ""
echo "🔍 Verificando estado del sistema..."

# 1. Verificar si Jenkins ya está instalado
if [ -f /usr/share/jenkins/jenkins.war ] || command -v jenkins >/dev/null 2>&1; then
    echo "✅ Jenkins ya está instalado"
    JENKINS_INSTALLED=true
else
    echo "❌ Jenkins no está instalado"
    JENKINS_INSTALLED=false
fi

# 2. Verificar si los servicios están corriendo
if curl -s --connect-timeout 5 http://localhost:8080 >/dev/null 2>&1; then
    echo "✅ Jenkins está corriendo en puerto 8080"
    JENKINS_RUNNING=true
else
    echo "❌ Jenkins no está respondiendo en puerto 8080"
    JENKINS_RUNNING=false
fi

if curl -s --connect-timeout 5 http://localhost >/dev/null 2>&1; then
    echo "✅ Nginx está corriendo en puerto 80"
    NGINX_RUNNING=true
else
    echo "❌ Nginx no está respondiendo en puerto 80"
    NGINX_RUNNING=false
fi

echo ""

# Acciones basadas en el estado
if [ "$JENKINS_INSTALLED" = false ]; then
    echo "🔧 ACCIÓN REQUERIDA: Instalar Jenkins"
    echo "   Ejecuta: sudo ./instalar.sh"
    echo ""
elif [ "$JENKINS_RUNNING" = false ] || [ "$NGINX_RUNNING" = false ]; then
    echo "🔧 ACCIÓN REQUERIDA: Iniciar servicios"
    echo "   Ejecutando automáticamente..."
    
    if [ "$JENKINS_RUNNING" = false ]; then
        echo "🚀 Iniciando Jenkins..."
        sudo service jenkins start || sudo systemctl start jenkins
        echo "⏳ Esperando 30 segundos para que Jenkins inicie..."
        sleep 30
    fi
    
    if [ "$NGINX_RUNNING" = false ]; then
        echo "🌐 Iniciando Nginx..."
        sudo service nginx start || sudo systemctl start nginx
        sleep 5
    fi
    
    echo "✅ Servicios iniciados"
else
    echo "🎉 ¡Todo está funcionando correctamente!"
fi

echo ""
echo "🌐 URLs para Google Cloud Shell:"
echo "================================="
echo ""
echo "🔧 Jenkins (Administración):"
echo "   • Web Preview → Preview on port 8080"
echo "   • Desde el menú Cloud Shell (⋮) → Web Preview → Preview on port 8080"
echo ""
echo "🌐 Tu sitio web (Gaming Hub):"
echo "   • Web Preview → Preview on port 80"
echo "   • Desde el menú Cloud Shell (⋮) → Web Preview → Preview on port 80"

# Mostrar contraseña si está disponible
echo ""
echo "🔑 Contraseña de Jenkins:"
if [ -f /var/lib/jenkins/secrets/initialAdminPassword ]; then
    JENKINS_PASSWORD=$(sudo cat /var/lib/jenkins/secrets/initialAdminPassword 2>/dev/null)
    if [ -n "$JENKINS_PASSWORD" ]; then
        echo "   $JENKINS_PASSWORD"
        echo ""
        echo "💡 Copia esta contraseña para configurar Jenkins"
    else
        echo "   ⚠️ No se pudo leer la contraseña"
    fi
else
    echo "   ⚠️ Archivo de contraseña no encontrado"
    if [ "$JENKINS_INSTALLED" = true ]; then
        echo "   💡 Jenkins puede estar iniciando... espera 2-3 minutos"
    fi
fi

echo ""
echo "🚀 Próximos pasos:"
echo "=================="
echo "1. Abre Jenkins usando Web Preview → Preview on port 8080"
echo "2. Configura Jenkins con la contraseña mostrada arriba"
echo "3. Crea tu primer pipeline siguiendo tutorial.md"
echo "4. Ve el resultado en Web Preview → Preview on port 80"
echo ""
echo "💡 Comandos útiles:"
echo "   • ./cloud-shell-helper.sh - URLs y configuración específica"
echo "   • ./verificar.sh - Verificación completa del sistema"
echo "   • ./diagnostico.sh - Diagnóstico detallado si hay problemas"

echo ""
echo "✅ Inicialización completada"