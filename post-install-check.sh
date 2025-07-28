#!/bin/bash

# 🔍 Verificación post-instalación específica para Cloud Shell
# Este script verifica que todo esté listo para ejecutar pipelines

echo "🔍 Verificación post-instalación para Cloud Shell"
echo "================================================="
echo ""

# Verificar que estamos en Cloud Shell
if [[ -n "$CLOUD_SHELL" ]] || [[ "$USER" == "roxsross" ]] || [[ -n "$GOOGLE_CLOUD_PROJECT" ]] || [[ -n "$DEVSHELL_PROJECT_ID" ]]; then
    echo "☁️ Google Cloud Shell detectado ✅"
else
    echo "💻 Sistema local detectado"
fi

echo ""
echo "🔍 Verificando componentes principales..."

# 1. Jenkins instalado
if [ -f /usr/share/jenkins/jenkins.war ] || command -v jenkins >/dev/null 2>&1; then
    echo "✅ Jenkins está instalado"
    JENKINS_INSTALLED=true
else
    echo "❌ Jenkins NO está instalado"
    echo "💡 Ejecuta: sudo ./instalar.sh"
    JENKINS_INSTALLED=false
fi

# 2. Jenkins corriendo
if curl -s --connect-timeout 10 http://localhost:8080 >/dev/null 2>&1; then
    echo "✅ Jenkins está corriendo y responde"
    JENKINS_RUNNING=true
else
    echo "❌ Jenkins NO está respondiendo"
    echo "💡 Puede estar iniciando... espera 2-3 minutos"
    JENKINS_RUNNING=false
fi

# 3. Nginx corriendo
if curl -s --connect-timeout 5 http://localhost >/dev/null 2>&1; then
    echo "✅ Nginx está corriendo"
    NGINX_RUNNING=true
else
    echo "❌ Nginx NO está respondiendo"
    NGINX_RUNNING=false
fi

# 4. Permisos sudo para Jenkins
echo ""
echo "🔐 Verificando permisos sudo para Jenkins..."
if [ -f /etc/sudoers.d/jenkins ]; then
    if sudo visudo -c -f /etc/sudoers.d/jenkins >/dev/null 2>&1; then
        echo "✅ Permisos sudo configurados correctamente"
        SUDO_OK=true
    else
        echo "❌ Permisos sudo tienen errores"
        SUDO_OK=false
    fi
else
    echo "❌ Permisos sudo NO configurados"
    echo "💡 Ejecuta: sudo ./arreglar-permisos.sh"
    SUDO_OK=false
fi

# 5. Directorio web
if [ -d /var/www/portfolio ]; then
    echo "✅ Directorio web existe (/var/www/portfolio)"
    WEB_DIR_OK=true
else
    echo "❌ Directorio web NO existe"
    WEB_DIR_OK=false
fi

# 6. Contraseña de Jenkins
echo ""
echo "🔑 Verificando contraseña de Jenkins..."
if [ -f /var/lib/jenkins/secrets/initialAdminPassword ]; then
    JENKINS_PASSWORD=$(sudo cat /var/lib/jenkins/secrets/initialAdminPassword 2>/dev/null)
    if [ -n "$JENKINS_PASSWORD" ]; then
        echo "✅ Contraseña disponible: $JENKINS_PASSWORD"
        PASSWORD_OK=true
    else
        echo "⚠️ No se pudo leer la contraseña"
        PASSWORD_OK=false
    fi
else
    echo "❌ Archivo de contraseña no encontrado"
    PASSWORD_OK=false
fi

# Resumen y próximos pasos
echo ""
echo "📊 RESUMEN DE VERIFICACIÓN:"
echo "=========================="

if [ "$JENKINS_INSTALLED" = true ] && [ "$JENKINS_RUNNING" = true ] && [ "$NGINX_RUNNING" = true ] && [ "$SUDO_OK" = true ]; then
    echo "🎉 ¡TODO ESTÁ LISTO PARA USAR!"
    echo ""
    echo "🚀 PRÓXIMOS PASOS:"
    echo "1. Abre Jenkins: Web Preview → Preview on port 8080"
    echo "2. Configura Jenkins con la contraseña mostrada arriba"
    echo "3. Crea tu primer pipeline"
    echo "4. ¡Ejecuta el pipeline y ve tu sitio!"
    echo ""
    echo "🌐 URLs de acceso:"
    echo "• Jenkins: Web Preview → Preview on port 8080"
    echo "• Tu sitio (después del pipeline): Web Preview → Preview on port 80"
else
    echo "⚠️ ALGUNOS COMPONENTES NECESITAN ATENCIÓN:"
    echo ""
    
    if [ "$JENKINS_INSTALLED" = false ]; then
        echo "❌ Jenkins no instalado → Ejecuta: sudo ./instalar.sh"
    fi
    
    if [ "$JENKINS_RUNNING" = false ]; then
        echo "❌ Jenkins no responde → Espera 2-3 minutos o ejecuta: sudo service jenkins restart"
    fi
    
    if [ "$NGINX_RUNNING" = false ]; then
        echo "❌ Nginx no responde → Ejecuta: sudo service nginx restart"
    fi
    
    if [ "$SUDO_OK" = false ]; then
        echo "❌ Permisos sudo no configurados → Ejecuta: sudo ./arreglar-permisos.sh"
        echo "   ⚠️ IMPORTANTE: Sin esto, tu pipeline fallará"
    fi
    
    if [ "$WEB_DIR_OK" = false ]; then
        echo "❌ Directorio web no existe → Se creará automáticamente"
    fi
    
    echo ""
    echo "🔧 Para diagnóstico detallado: ./diagnostico.sh"
fi

echo ""
echo "💡 COMANDOS ÚTILES:"
echo "=================="
echo "• ./test-init.sh - Inicialización rápida"
echo "• ./verificar.sh - Verificación completa"
echo "• ./cloud-shell-helper.sh - URLs específicas"
echo "• ./diagnostico.sh - Diagnóstico detallado"
echo "• sudo ./arreglar-permisos.sh - Arreglar permisos"

echo ""
echo "✅ Verificación completada"