#!/bin/bash

# 🚀 Helper específico para Google Cloud Shell
# Este script optimiza Jenkins para Cloud Shell y proporciona URLs directas

echo "☁️ Cloud Shell Helper - Configuración optimizada para Jenkins"
echo ""

# Verificar que estamos en Cloud Shell
if [[ -z "$CLOUD_SHELL" ]] && [[ "$USER" != "naranjax" ]] && [[ -z "$GOOGLE_CLOUD_PROJECT" ]]; then
    echo "⚠️ Este script está optimizado para Google Cloud Shell"
    echo "💡 Puedes usarlo en otros sistemas, pero puede no ser necesario"
    echo ""
fi

# Verificar estado de Jenkins
echo "🔍 Verificando estado de Jenkins..."
if curl -s http://localhost:8080 > /dev/null 2>&1; then
    echo "✅ Jenkins está funcionando"
else
    echo "❌ Jenkins no está respondiendo"
    echo "🔧 Intentando reiniciar Jenkins..."
    sudo service jenkins restart || sudo systemctl restart jenkins
    echo "⏳ Esperando 30 segundos..."
    sleep 30
fi

# Verificar estado de Nginx
echo ""
echo "🔍 Verificando estado de Nginx..."
if curl -s http://localhost > /dev/null 2>&1; then
    echo "✅ Nginx está funcionando"
else
    echo "❌ Nginx no está respondiendo"
    echo "🔧 Intentando reiniciar Nginx..."
    sudo service nginx restart || sudo systemctl restart nginx
    echo "⏳ Esperando 10 segundos..."
    sleep 10
fi

# Mostrar URLs para Cloud Shell
echo ""
echo "🌐 URLs para acceder desde Cloud Shell:"
echo ""

# Jenkins
echo "🔧 JENKINS:"
echo "   • Método recomendado: Web Preview → Preview on port 8080"
echo "   • Desde el menú de Cloud Shell (⋮) → Web Preview → Preview on port 8080"

# Sitio web
echo ""
echo "🌐 TU SITIO WEB:"
echo "   • Método recomendado: Web Preview → Preview on port 80"
echo "   • Desde el menú de Cloud Shell (⋮) → Web Preview → Preview on port 80"

# URLs directas si es posible
echo ""
echo "📱 URLs directas (experimentales):"
if [[ -n "$WEB_HOST" ]]; then
    echo "   • Jenkins: https://${WEB_HOST}/proxy/8080/"
    echo "   • Tu sitio: https://${WEB_HOST}/proxy/80/"
elif [[ -n "$CLOUD_SHELL_IP" ]]; then
    echo "   • Jenkins: https://8080-${CLOUD_SHELL_IP}.googleusercontent.com"
    echo "   • Tu sitio: https://80-${CLOUD_SHELL_IP}.googleusercontent.com"
else
    echo "   • Jenkins: https://8080-{tu-ip}.googleusercontent.com"
    echo "   • Tu sitio: https://80-{tu-ip}.googleusercontent.com"
    echo "   (Reemplaza {tu-ip} con tu IP externa de Cloud Shell)"
fi

# Mostrar contraseña de Jenkins si está disponible
echo ""
echo "🔑 Contraseña inicial de Jenkins:"
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
    echo "   💡 Jenkins puede estar iniciando... espera 2-3 minutos"
fi

# Información sobre puertos
echo ""
echo "🔌 Información de puertos:"
echo "   • Puerto 8080: Jenkins (interfaz de administración)"
echo "   • Puerto 80: Tu sitio web desplegado"
echo ""
echo "🔧 Si los puertos no están accesibles:"
echo "   1. Verifica que los servicios estén corriendo:"
echo "      sudo service jenkins status"
echo "      sudo service nginx status"
echo ""
echo "   2. En Cloud Shell, usa siempre 'Web Preview' desde el menú"
echo "      (el botón con icono de cuadrado y flecha)"
echo ""
echo "   3. Si hay problemas, ejecuta: ./diagnostico.sh"

# Configuración adicional para Cloud Shell
echo ""
echo "⚙️ Configuración adicional para Cloud Shell..."

# Verificar que el firewall interno no bloquee
echo "🔥 Configurando acceso de red..."
sudo ufw allow 8080 2>/dev/null || echo "💡 UFW no activo (normal en Cloud Shell)"
sudo ufw allow 80 2>/dev/null || echo "💡 UFW no activo (normal en Cloud Shell)"

# Verificar permisos de archivos
echo ""
echo "📁 Verificando permisos de archivos..."
if [ -d /var/www/portfolio ]; then
    sudo chown -R www-data:www-data /var/www/portfolio
    echo "✅ Permisos de /var/www/portfolio actualizados"
else
    echo "⚠️ Directorio /var/www/portfolio no existe"
    echo "💡 Se creará automáticamente al ejecutar el pipeline"
fi

echo ""
echo "🎉 ¡Cloud Shell Helper completado!"
echo ""
echo "🚀 Próximos pasos:"
echo "   1. Abre Jenkins usando Web Preview → Preview on port 8080"
echo "   2. Configura Jenkins con la contraseña mostrada arriba"
echo "   3. Crea y ejecuta tu primer pipeline"
echo "   4. Ve el resultado en Web Preview → Preview on port 80"
echo ""
echo "💡 Guarda esta terminal abierta para consultar las URLs y contraseña"
