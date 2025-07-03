#!/bin/bash

# 🧪 Script de verificación rápida para Jenkins
# Verifica que todo esté funcionando correctamente

echo "🧪 Verificación rápida de Jenkins y servicios..."
echo ""

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Función para mostrar estado
show_status() {
    if [ $1 -eq 0 ]; then
        echo -e "${GREEN}✅ $2${NC}"
    else
        echo -e "${RED}❌ $2${NC}"
    fi
}

# Verificar si estamos en Cloud Shell
if [[ -n "$CLOUD_SHELL" ]] || [[ "$USER" == "naranjax" ]] || [[ -n "$GOOGLE_CLOUD_PROJECT" ]]; then
    echo -e "${BLUE}☁️ Google Cloud Shell detectado${NC}"
    IS_CLOUD_SHELL=true
else
    echo -e "${BLUE}🖥️ Sistema local/VM detectado${NC}"
    IS_CLOUD_SHELL=false
fi

echo ""

# 1. Verificar Java
echo "1️⃣ Verificando Java..."
java -version >/dev/null 2>&1
show_status $? "Java está instalado"

# 2. Verificar Jenkins instalado
echo ""
echo "2️⃣ Verificando instalación de Jenkins..."
if [ -f /usr/share/jenkins/jenkins.war ] || command -v jenkins >/dev/null 2>&1; then
    show_status 0 "Jenkins está instalado"
else
    show_status 1 "Jenkins NO está instalado"
fi

# 3. Verificar servicios corriendo
echo ""
echo "3️⃣ Verificando servicios..."

# Jenkins
if curl -s http://localhost:8080 >/dev/null 2>&1; then
    show_status 0 "Jenkins está corriendo en puerto 8080"
else
    show_status 1 "Jenkins NO está respondiendo en puerto 8080"
fi

# Nginx
if curl -s http://localhost >/dev/null 2>&1; then
    show_status 0 "Nginx está corriendo en puerto 80"
else
    show_status 1 "Nginx NO está respondiendo en puerto 80"
fi

# 4. Verificar permisos sudo para Jenkins
echo ""
echo "4️⃣ Verificando permisos sudo..."
if [ -f /etc/sudoers.d/jenkins ]; then
    if sudo visudo -c -f /etc/sudoers.d/jenkins >/dev/null 2>&1; then
        show_status 0 "Permisos sudo de Jenkins configurados correctamente"
    else
        show_status 1 "Permisos sudo de Jenkins tienen errores de sintaxis"
    fi
else
    show_status 1 "Archivo de permisos sudo de Jenkins NO existe"
fi

# 5. Verificar directorio web
echo ""
echo "5️⃣ Verificando directorio web..."
if [ -d /var/www/portfolio ]; then
    show_status 0 "Directorio /var/www/portfolio existe"
    file_count=$(sudo find /var/www/portfolio -type f | wc -l)
    if [ $file_count -gt 0 ]; then
        show_status 0 "Directorio web contiene archivos ($file_count archivos)"
    else
        show_status 1 "Directorio web está vacío"
    fi
else
    show_status 1 "Directorio /var/www/portfolio NO existe"
fi

# 6. Verificar contraseña inicial de Jenkins
echo ""
echo "6️⃣ Verificando contraseña inicial..."
if [ -f /var/lib/jenkins/secrets/initialAdminPassword ]; then
    show_status 0 "Archivo de contraseña inicial existe"
    echo -e "${YELLOW}💡 Contraseña:${NC}"
    sudo cat /var/lib/jenkins/secrets/initialAdminPassword 2>/dev/null || echo "No se pudo leer"
else
    show_status 1 "Archivo de contraseña inicial NO existe"
fi

# 7. URLs de acceso
echo ""
echo "7️⃣ URLs de acceso:"
if [ "$IS_CLOUD_SHELL" = true ]; then
    echo -e "${BLUE}☁️ Cloud Shell URLs:${NC}"
    echo "   🔧 Jenkins: Web Preview → Preview on port 8080"
    echo "   🌐 Tu sitio: Web Preview → Preview on port 80"
    echo "   💡 Ejecuta './cloud-shell-helper.sh' para más opciones"
else
    echo -e "${BLUE}🖥️ URLs locales:${NC}"
    echo "   🔧 Jenkins: http://localhost:8080"
    echo "   🌐 Tu sitio: http://localhost"
fi

# Resumen final
echo ""
echo "📊 RESUMEN:"

jenkins_ok=true
nginx_ok=true
sudo_ok=true

if ! curl -s http://localhost:8080 >/dev/null 2>&1; then
    jenkins_ok=false
fi

if ! curl -s http://localhost >/dev/null 2>&1; then
    nginx_ok=false
fi

if [ ! -f /etc/sudoers.d/jenkins ]; then
    sudo_ok=false
fi

if [ "$jenkins_ok" = true ] && [ "$nginx_ok" = true ] && [ "$sudo_ok" = true ]; then
    echo -e "${GREEN}🎉 ¡Todo está funcionando perfectamente!${NC}"
    echo ""
    echo "🚀 Próximos pasos:"
    echo "   1. Abre Jenkins y configura tu usuario"
    echo "   2. Crea tu primer pipeline"
    echo "   3. ¡Despliega tu sitio web!"
else
    echo -e "${YELLOW}⚠️ Algunos servicios necesitan atención:${NC}"
    
    if [ "$jenkins_ok" = false ]; then
        echo "   • Jenkins no está respondiendo - prueba: sudo service jenkins restart"
    fi
    
    if [ "$nginx_ok" = false ]; then
        echo "   • Nginx no está respondiendo - prueba: sudo service nginx restart"
    fi
    
    if [ "$sudo_ok" = false ]; then
        echo "   • Permisos sudo no configurados - ejecuta: sudo ./arreglar-permisos.sh"
    fi
    
    echo ""
    echo "🔧 Para diagnóstico completo: ./diagnostico.sh"
fi

echo ""
echo "💡 Este script se puede ejecutar en cualquier momento para verificar el estado"
