#!/bin/bash

# 🚀 Jenkins - Instalación Simple para Principiantes
# Un solo script que hace todo automáticamente
# Optimizado para Google Cloud Shell y contenedores

echo "🚀 Instalando Jenkins para principiantes..."
echo "⏱️  Esto tomará unos minutos..."
echo ""

# Detectar si estamos en Cloud Shell (múltiples métodos de detección)
if [[ -n "$CLOUD_SHELL" ]] || [[ "$USER" == "roxsross" ]] || [[ -n "$GOOGLE_CLOUD_PROJECT" ]] || [[ -n "$DEVSHELL_PROJECT_ID" ]] || [[ "$HOSTNAME" == *"cloudshell"* ]]; then
    echo "☁️ Google Cloud Shell detectado - Usando configuración optimizada"
    IS_CLOUD_SHELL=true
    # Configurar variables específicas para Cloud Shell
    export CLOUD_SHELL_JENKINS=true
    export JENKINS_TIMEOUT=300
    export NGINX_TIMEOUT=60
else
    echo "🖥️ Sistema local/VM detectado"
    IS_CLOUD_SHELL=false
fi

# Verificar que el sistema esté listo
echo ""
echo "🔍 Verificando sistema..."
if ! command -v curl &> /dev/null; then
    echo "📥 Instalando curl..."
    sudo apt install -y curl
fi

# Verificar conectividad
if curl -s --connect-timeout 5 google.com > /dev/null; then
    echo "✅ Conectividad a internet verificada"
else
    echo "⚠️ Problemas de conectividad, pero continuando..."
fi

# Actualizar sistema
echo ""
echo "📦 Actualizando sistema..."
sudo apt update -qq

# Instalar Java (necesario para Jenkins)
echo ""
echo "☕ Instalando Java..."
echo "📥 Descargando OpenJDK 17 (esto puede tomar un momento)..."
sudo apt install -y openjdk-17-jdk

# Verificar instalación de Java
echo ""
echo "🔍 Verificando Java..."
java_version=$(java -version 2>&1 | head -1)
if [[ $java_version == *"openjdk"* ]]; then
    echo "✅ Java instalado correctamente: $java_version"
    export JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64
    echo "🎯 JAVA_HOME configurado: $JAVA_HOME"
else
    echo "❌ Error instalando Java"
    exit 1
fi

# Instalar Jenkins
echo ""
echo "🔧 Instalando Jenkins..."
# Usar el método recomendado para agregar claves GPG
curl -fsSL https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key | sudo tee /usr/share/keyrings/jenkins-keyring.asc > /dev/null
echo deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] https://pkg.jenkins.io/debian-stable binary/ | sudo tee /etc/apt/sources.list.d/jenkins.list > /dev/null

echo "📦 Actualizando lista de paquetes..."
sudo apt update -qq

echo "📥 Descargando e instalando Jenkins..."
sudo apt install -y jenkins

# Configurar permisos sudo para Jenkins (para pipelines)
echo ""
echo "🔐 Configurando permisos para Jenkins..."

# En Cloud Shell, configurar permisos específicos más restrictivos
if [ "$IS_CLOUD_SHELL" = true ]; then
    echo "☁️ Configurando permisos optimizados para Cloud Shell..."
    echo "jenkins ALL=(ALL) NOPASSWD: /bin/cp, /bin/chown, /usr/sbin/service, /bin/systemctl, /usr/sbin/nginx, /bin/mkdir, /bin/rm, /usr/bin/unzip, /bin/mv" | sudo tee /etc/sudoers.d/jenkins > /dev/null
else
    echo "jenkins ALL=(ALL) NOPASSWD: /bin/cp, /bin/chown, /usr/sbin/service, /bin/systemctl, /usr/sbin/nginx, /bin/mkdir, /bin/rm, /usr/bin/unzip, /bin/mv" | sudo tee /etc/sudoers.d/jenkins > /dev/null
fi

# Verificar que el archivo se creó correctamente
if [ -f /etc/sudoers.d/jenkins ]; then
    echo "✅ Archivo de permisos creado: /etc/sudoers.d/jenkins"
    
    # Verificar sintaxis del archivo sudoers
    if sudo visudo -c -f /etc/sudoers.d/jenkins &>/dev/null; then
        echo "✅ Configuración de sudoers válida"
        # En Cloud Shell, también agregar el usuario jenkins al grupo www-data para mejor compatibilidad
        if [ "$IS_CLOUD_SHELL" = true ]; then
            sudo usermod -a -G www-data jenkins 2>/dev/null || echo "💡 Grupo www-data configurado"
        fi
    else
        echo "❌ Error en configuración de sudoers, eliminando archivo..."
        sudo rm -f /etc/sudoers.d/jenkins
    fi
else
    echo "❌ No se pudo crear el archivo de permisos"
fi

echo "✅ Permisos configurados para que Jenkins pueda desplegar archivos"

# Instalar Nginx (servidor web)
echo ""
echo "🌐 Instalando servidor web Nginx..."
sudo apt install -y nginx

echo "✅ Nginx instalado correctamente"

# Detectar sistema de init
echo ""
echo "🔍 Detectando sistema de init..."
if systemctl --version &>/dev/null && [ -d /run/systemd/system ]; then
    echo "🔧 Sistema con systemd detectado"
    INIT_SYSTEM="systemd"
else
    echo "🔧 Sistema con SysV init detectado (común en Cloud Shell y contenedores)"
    INIT_SYSTEM="sysv"
fi

# Iniciar servicios
echo ""
echo "🚀 Iniciando servicios..."
echo "🔧 Iniciando Jenkins..."
if [ "$INIT_SYSTEM" = "systemd" ]; then
    sudo systemctl start jenkins
    sudo systemctl enable jenkins
else
    sudo service jenkins start
    sudo update-rc.d jenkins enable 2>/dev/null || echo "Jenkins habilitado para inicio automático"
fi

echo "🌐 Iniciando Nginx..."
if [ "$INIT_SYSTEM" = "systemd" ]; then
    sudo systemctl start nginx
    sudo systemctl enable nginx
else
    sudo service nginx start
    sudo update-rc.d nginx enable 2>/dev/null || echo "Nginx habilitado para inicio automático"
fi

echo "✅ Servicios iniciados y habilitados para inicio automático"

# Esperar a que Jenkins esté completamente iniciado
echo ""
echo "⏳ Esperando a que Jenkins esté listo..."
if [ "$IS_CLOUD_SHELL" = true ]; then
    echo "☁️ En Cloud Shell, Jenkins puede tomar 3-7 minutos en estar operativo..."
    max_attempts=84  # 7 minutos
else
    echo "💡 Jenkins puede tomar 2-5 minutos en estar completamente operativo..."
    max_attempts=60  # 5 minutos
fi

attempt=1

while [ $attempt -le $max_attempts ]; do
    # Verificar si Jenkins está activo según el sistema de init
    jenkins_running=false
    
    if [ "$INIT_SYSTEM" = "systemd" ]; then
        if sudo systemctl is-active --quiet jenkins 2>/dev/null; then
            jenkins_running=true
        fi
    else
        if sudo service jenkins status 2>/dev/null | grep -q "is running\|started\|active"; then
            jenkins_running=true
        fi
    fi
    
    # Verificar también que responda en el puerto 8080
    if [ "$jenkins_running" = true ] && curl -s http://localhost:8080 > /dev/null 2>&1; then
        echo "✅ Jenkins está corriendo y respondiendo en puerto 8080"
        break
    else
        # Mostrar progreso cada 15 segundos para Cloud Shell
        if [ "$IS_CLOUD_SHELL" = true ] && [ $((attempt % 3)) -eq 0 ]; then
            echo "⏳ Intento $attempt/$max_attempts - Jenkins iniciando... ($(date '+%H:%M:%S'))"
        elif [ "$IS_CLOUD_SHELL" = false ]; then
            echo "⏳ Intento $attempt/$max_attempts - Jenkins iniciando... ($(date '+%H:%M:%S'))"
        fi
        sleep 5
        attempt=$((attempt + 1))
    fi
done

if [ $attempt -gt $max_attempts ]; then
    echo "❌ Jenkins no inició correctamente después del tiempo esperado"
    echo "🔍 Verificando estado de Jenkins..."
    
    if [ "$INIT_SYSTEM" = "systemd" ]; then
        sudo journalctl -u jenkins --no-pager -l | tail -20 2>/dev/null || echo "No se pueden leer logs de systemd"
    else
        sudo service jenkins status || echo "No se puede verificar estado con service"
        [ -f /var/log/jenkins/jenkins.log ] && sudo tail -20 /var/log/jenkins/jenkins.log || echo "Log de Jenkins no encontrado"
    fi
    
    echo ""
    echo "🔧 Intentando reiniciar Jenkins una vez más..."
    if [ "$INIT_SYSTEM" = "systemd" ]; then
        sudo systemctl restart jenkins
    else
        sudo service jenkins restart
    fi
    
    if [ "$IS_CLOUD_SHELL" = true ]; then
        echo "⏳ Esperando 60 segundos adicionales (Cloud Shell)..."
        sleep 60
    else
        echo "⏳ Esperando 30 segundos adicionales..."
        sleep 30
    fi
fi

# Configurar firewall
echo ""
echo "🔥 Configurando accesos de red..."
sudo ufw allow 8080 2>/dev/null || echo "🔧 UFW no activo, continuando..."
sudo ufw allow 80 2>/dev/null || echo "🔧 UFW no activo, continuando..."
echo "✅ Puertos 8080 (Jenkins) y 80 (Web) configurados"

# Configurar sitio web
echo ""
echo "🎨 Configurando tu portafolio web..."
sudo mkdir -p /var/www/portfolio

# Verificar que existe el directorio site
if [ -d "site" ]; then
    sudo cp -r site/* /var/www/portfolio/
    echo "✅ Archivos del sitio copiados a /var/www/portfolio/"
else
    echo "⚠️ Directorio 'site' no encontrado, creando página de ejemplo..."
    echo "<h1>¡Hola! Tu sitio Jenkins está funcionando</h1>" | sudo tee /var/www/portfolio/index.html > /dev/null
fi

sudo chown -R www-data:www-data /var/www/portfolio
echo "✅ Permisos configurados correctamente"

# Configurar Nginx para el portafolio
echo ""
echo "⚙️ Configurando Nginx para servir tu portafolio..."
sudo tee /etc/nginx/sites-available/portfolio > /dev/null << 'EOF'
server {
    listen 80;
    server_name _;
    root /var/www/portfolio;
    index index.html gaming-hub.html;

    location / {
        try_files $uri $uri/ =404;
    }

    location /health {
        add_header Content-Type text/plain;
        return 200 "healthy";
    }
    
    # Cache para archivos estáticos
    location ~* \.(css|js|png|jpg|jpeg|gif|ico|svg)$ {
        expires 1y;
        add_header Cache-Control "public, immutable";
    }
}
EOF

echo "🔗 Habilitando sitio en Nginx..."
sudo ln -sf /etc/nginx/sites-available/portfolio /etc/nginx/sites-enabled/
sudo rm -f /etc/nginx/sites-enabled/default

echo "🔍 Verificando configuración de Nginx..."
if sudo nginx -t; then
    echo "✅ Configuración de Nginx válida"
    if [ "$INIT_SYSTEM" = "systemd" ]; then
        sudo systemctl reload nginx
    else
        sudo service nginx reload
    fi
    echo "✅ Nginx recargado con nueva configuración"
else
    echo "❌ Error en configuración de Nginx"
fi

# Mostrar información final
echo ""
echo "🔍 Verificando instalación..."

# Verificar Jenkins
if curl -s --connect-timeout 10 http://localhost:8080 > /dev/null 2>&1; then
    echo "✅ Jenkins está funcionando correctamente"
else
    echo "⚠️ Jenkins puede no estar completamente listo"
    if [ "$IS_CLOUD_SHELL" = true ]; then
        echo "☁️ En Cloud Shell, Jenkins puede tomar hasta 5-7 minutos en estar completamente operativo"
        echo "💡 Ejecuta './test-init.sh' en unos minutos para verificar el estado"
    fi
    if [ "$INIT_SYSTEM" = "systemd" ]; then
        echo "🔧 Verifica con: sudo systemctl status jenkins"
    else
        echo "🔧 Verifica con: sudo service jenkins status"
    fi
fi

# Verificar Nginx
if curl -s --connect-timeout 5 http://localhost > /dev/null 2>&1; then
    echo "✅ Nginx está funcionando correctamente"
else
    echo "⚠️ Nginx puede tener problemas"
    if [ "$INIT_SYSTEM" = "systemd" ]; then
        echo "🔧 Verifica con: sudo systemctl status nginx"
    else
        echo "🔧 Verifica con: sudo service nginx status"
    fi
fi

echo ""
echo "🎉 ¡INSTALACIÓN COMPLETADA!"
echo ""

# Mostrar URLs con IP si estamos en Cloud Shell
if [ "$IS_CLOUD_SHELL" = true ]; then
    echo "☁️ CLOUD SHELL - URLs de acceso:"
    echo ""
    echo "🌐 Jenkins:"
    echo "   • Web Preview → Preview on port 8080"
    echo "   • O abre el menú Cloud Shell y selecciona 'Web Preview' → 'Preview on port 8080'"
    echo ""
    echo "🌐 Tu sitio web:"
    echo "   • Web Preview → Preview on port 80"
    echo "   • O abre el menú Cloud Shell y selecciona 'Web Preview' → 'Preview on port 80'"
    echo ""
    echo "💡 También puedes usar estos enlaces directos (si están disponibles):"
    
    # Intentar obtener la URL de Cloud Shell
    if [[ -n "$WEB_HOST" ]]; then
        echo "   • Jenkins: https://${WEB_HOST}/proxy/8080/"
        echo "   • Tu sitio: https://${WEB_HOST}/proxy/80/"
    elif [[ -n "$CLOUD_SHELL_IP" ]]; then
        echo "   • Jenkins: https://8080-${CLOUD_SHELL_IP}-8080.googleusercontent.com"
        echo "   • Tu sitio: https://80-${CLOUD_SHELL_IP}-80.googleusercontent.com"
    else
        echo "   • Jenkins: https://8080-{tu-ip-cloud-shell}.googleusercontent.com"
        echo "   • Tu sitio: https://80-{tu-ip-cloud-shell}.googleusercontent.com"
        echo "   (Reemplaza {tu-ip-cloud-shell} con tu IP externa)"
    fi
else
    echo "🌐 Jenkins: http://localhost:8080"
    echo "🌐 Tu sitio: http://localhost"
fi

echo ""
echo "🔑 Contraseña de Jenkins:"
if [ -f /var/lib/jenkins/secrets/initialAdminPassword ]; then
    sudo cat /var/lib/jenkins/secrets/initialAdminPassword
else
    echo "⚠️ Archivo de contraseña no encontrado. Jenkins puede estar iniciando..."
    echo "💡 Espera 2-3 minutos y ejecuta:"
    echo "   sudo cat /var/lib/jenkins/secrets/initialAdminPassword"
fi

echo ""
echo "💡 ¡Sigue el tutorial.md para continuar!"
echo ""
if [ "$IS_CLOUD_SHELL" = true ]; then
    echo "☁️ Comandos específicos para Cloud Shell:"
    echo "   • Inicialización rápida: ./test-init.sh"
    echo "   • URLs y configuración: ./cloud-shell-helper.sh"
    echo "   • Verificación completa: ./verificar.sh"
    echo "   • Diagnóstico detallado: ./diagnostico.sh"
    echo ""
    echo "🌐 Acceso rápido:"
    echo "   • Jenkins: Web Preview → Preview on port 8080"
    echo "   • Tu sitio: Web Preview → Preview on port 80"
else
    echo "🛠️ Comandos útiles:"
    if [ "$INIT_SYSTEM" = "systemd" ]; then
        echo "   • Ver estado Jenkins: sudo systemctl status jenkins"
        echo "   • Ver logs Jenkins: sudo journalctl -u jenkins -f"
        echo "   • Reiniciar Jenkins: sudo systemctl restart jenkins"
        echo "   • Ver estado Nginx: sudo systemctl status nginx"
    else
        echo "   • Ver estado Jenkins: sudo service jenkins status"
        echo "   • Ver logs Jenkins: sudo tail -f /var/log/jenkins/jenkins.log"
        echo "   • Reiniciar Jenkins: sudo service jenkins restart"
        echo "   • Ver estado Nginx: sudo service nginx status"
    fi
    echo "   • Diagnóstico completo: ./diagnostico.sh"
fi
