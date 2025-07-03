#!/bin/bash

# 🔧 Script para arreglar permisos de Jenkins
# Ejecuta este script si el pipeline falla por permisos sudo

echo "🔧 Arreglando permisos de Jenkins para pipelines..."
echo ""

# Verificar si Jenkins está instalado
if ! command -v jenkins &> /dev/null && [ ! -f /usr/share/jenkins/jenkins.war ]; then
    echo "❌ Jenkins no está instalado. Ejecuta primero: sudo ./instalar.sh"
    exit 1
fi

# Configurar permisos sudo para Jenkins
echo "🔐 Configurando permisos sudo para Jenkins..."
echo "jenkins ALL=(ALL) NOPASSWD: /bin/cp, /bin/chown, /usr/sbin/service, /bin/systemctl, /usr/sbin/nginx" | sudo tee /etc/sudoers.d/jenkins > /dev/null

# Verificar que el archivo se creó correctamente
if [ -f /etc/sudoers.d/jenkins ]; then
    echo "✅ Archivo de permisos creado: /etc/sudoers.d/jenkins"
    
    # Verificar sintaxis del archivo sudoers
    if sudo visudo -c -f /etc/sudoers.d/jenkins; then
        echo "✅ Configuración de sudoers válida"
    else
        echo "❌ Error en configuración de sudoers, eliminando archivo..."
        sudo rm -f /etc/sudoers.d/jenkins
        exit 1
    fi
else
    echo "❌ No se pudo crear el archivo de permisos"
    exit 1
fi

# Verificar que el directorio de despliegue existe
echo ""
echo "📁 Verificando directorio de despliegue..."
if [ ! -d /var/www/portfolio ]; then
    echo "📝 Creando directorio /var/www/portfolio..."
    sudo mkdir -p /var/www/portfolio
    sudo chown -R www-data:www-data /var/www/portfolio
    echo "✅ Directorio creado y permisos configurados"
else
    echo "✅ Directorio /var/www/portfolio existe"
fi

# Verificar permisos del usuario jenkins
echo ""
echo "👤 Verificando usuario jenkins..."
if id jenkins &>/dev/null; then
    echo "✅ Usuario jenkins existe"
    echo "Grupos del usuario jenkins: $(groups jenkins)"
else
    echo "❌ Usuario jenkins no existe"
    exit 1
fi

echo ""
echo "🎉 ¡Permisos configurados correctamente!"
echo ""
echo "💡 Ahora puedes:"
echo "   1. Ir a Jenkins: http://localhost:8080"
echo "   2. Ejecutar tu pipeline"
echo "   3. El despliegue debería funcionar sin problemas"
echo ""
echo "🔧 Si aún hay problemas, ejecuta: ./diagnostico.sh"
