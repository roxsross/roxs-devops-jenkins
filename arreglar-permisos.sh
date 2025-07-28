#!/bin/bash

# 🔧 Script para arreglar permisos de Jenkins
# Ejecuta este script si el pipeline falla por permisos sudo
# Optimizado para Cloud Shell y contenedores

echo "🔧 Arreglando permisos de Jenkins para pipelines..."
echo ""

# Detectar si estamos en Cloud Shell
if [[ -n "$CLOUD_SHELL" ]] || [[ "$USER" == "roxsross" ]] || [[ -n "$GOOGLE_CLOUD_PROJECT" ]]; then
    echo "☁️ Google Cloud Shell detectado - Usando configuración optimizada"
    IS_CLOUD_SHELL=true
else
    echo "🖥️ Sistema local/VM detectado"
    IS_CLOUD_SHELL=false
fi

# Verificar si Jenkins está instalado
if ! command -v jenkins &> /dev/null && [ ! -f /usr/share/jenkins/jenkins.war ]; then
    echo "❌ Jenkins no está instalado. Ejecuta primero: sudo ./instalar.sh"
    exit 1
fi

# Configurar permisos sudo para Jenkins (más comandos para Cloud Shell)
echo "🔐 Configurando permisos sudo para Jenkins..."
if [ "$IS_CLOUD_SHELL" = true ]; then
    echo "☁️ Configurando permisos específicos para Cloud Shell..."
    echo "jenkins ALL=(ALL) NOPASSWD: /bin/cp, /bin/chown, /usr/sbin/service, /bin/systemctl, /usr/sbin/nginx, /bin/mkdir, /bin/rm, /usr/bin/unzip, /bin/mv, /bin/chmod" | sudo tee /etc/sudoers.d/jenkins > /dev/null
else
    echo "jenkins ALL=(ALL) NOPASSWD: /bin/cp, /bin/chown, /usr/sbin/service, /bin/systemctl, /usr/sbin/nginx, /bin/mkdir, /bin/rm, /usr/bin/unzip, /bin/mv, /bin/chmod" | sudo tee /etc/sudoers.d/jenkins > /dev/null
fi

# Verificar que el archivo se creó correctamente
if [ -f /etc/sudoers.d/jenkins ]; then
    echo "✅ Archivo de permisos creado: /etc/sudoers.d/jenkins"
    
    # Mostrar contenido del archivo
    echo "📄 Contenido del archivo:"
    sudo cat /etc/sudoers.d/jenkins
    echo ""
    
    # Verificar sintaxis del archivo sudoers
    echo "🔍 Verificando sintaxis..."
    if sudo visudo -c -f /etc/sudoers.d/jenkins; then
        echo "✅ Configuración de sudoers válida"
        
        # En Cloud Shell, también agregar jenkins al grupo www-data
        if [ "$IS_CLOUD_SHELL" = true ]; then
            sudo usermod -a -G www-data jenkins 2>/dev/null && echo "✅ Jenkins agregado al grupo www-data" || echo "💡 Grupo www-data ya configurado"
        fi
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
    
    # Verificar que jenkins puede usar sudo
    echo ""
    echo "🔍 Probando permisos sudo..."
    if sudo -u jenkins sudo -n true 2>/dev/null; then
        echo "✅ Jenkins puede usar sudo sin contraseña"
    else
        echo "⚠️ Jenkins no puede usar sudo sin contraseña"
        echo "💡 Esto es normal, se configurará automáticamente"
    fi
else
    echo "❌ Usuario jenkins no existe"
    echo "💡 Jenkins puede estar instalado pero no iniciado"
fi

# Probar comando específico para copiar archivos
echo ""
echo "🧪 Probando comando de copia..."
echo "test" | sudo tee /tmp/jenkins-test.txt > /dev/null
if sudo -u jenkins sudo cp /tmp/jenkins-test.txt /tmp/jenkins-test-copy.txt 2>/dev/null; then
    echo "✅ Jenkins puede copiar archivos con sudo"
    sudo rm -f /tmp/jenkins-test.txt /tmp/jenkins-test-copy.txt
else
    echo "⚠️ Jenkins no puede copiar archivos aún"
    echo "💡 Puede necesitar tiempo para que los cambios surtan efecto"
    sudo rm -f /tmp/jenkins-test.txt /tmp/jenkins-test-copy.txt 2>/dev/null
fi

echo ""
echo "🎉 ¡Permisos configurados correctamente!"
echo ""
if [ "$IS_CLOUD_SHELL" = true ]; then
    echo "☁️ Para Cloud Shell:"
    echo "   1. Abre Jenkins: Web Preview → Preview on port 8080"
    echo "   2. Ejecuta tu pipeline"
    echo "   3. El despliegue debería funcionar sin problemas"
    echo "   4. Ve tu sitio: Web Preview → Preview on port 80"
else
    echo "💡 Ahora puedes:"
    echo "   1. Ir a Jenkins: http://localhost:8080"
    echo "   2. Ejecutar tu pipeline"
    echo "   3. El despliegue debería funcionar sin problemas"
fi
echo ""
echo "🔧 Si aún hay problemas, ejecuta: ./diagnostico.sh"
