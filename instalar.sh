#!/bin/bash

# 🚀 Jenkins - Instalación Simple para Principiantes
# Un solo script que hace todo automáticamente

echo "🚀 Instalando Jenkins para principiantes..."
echo "⏱️  Esto tomará unos minutos..."
echo ""

# Verificar que el sistema esté listo
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
echo "🔧 Instalando Jenkins..."
# Usar el método recomendado para agregar claves GPG
curl -fsSL https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key | sudo tee /usr/share/keyrings/jenkins-keyring.asc > /dev/null
echo deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] https://pkg.jenkins.io/debian-stable binary/ | sudo tee /etc/apt/sources.list.d/jenkins.list > /dev/null

echo "📦 Actualizando lista de paquetes..."
sudo apt update -qq

echo "📥 Descargando e instalando Jenkins..."
sudo apt install -y jenkins

# Instalar Nginx (servidor web)
echo ""
echo "🌐 Instalando servidor web Nginx..."
sudo apt install -y nginx

echo "✅ Nginx instalado correctamente"

# Iniciar servicios
echo ""
echo "🚀 Iniciando servicios..."
echo "🔧 Iniciando Jenkins..."
sudo systemctl start jenkins
sudo systemctl enable jenkins

echo "🌐 Iniciando Nginx..."
sudo systemctl start nginx
sudo systemctl enable nginx

echo "✅ Servicios iniciados y habilitados para inicio automático"

# Esperar a que Jenkins esté completamente iniciado
echo ""
echo "⏳ Esperando a que Jenkins esté listo..."
echo "💡 Jenkins puede tomar 2-5 minutos en estar completamente operativo..."
max_attempts=60
attempt=1

while [ $attempt -le $max_attempts ]; do
    if sudo systemctl is-active --quiet jenkins && curl -s http://localhost:8080 > /dev/null 2>&1; then
        echo "✅ Jenkins está corriendo y respondiendo en puerto 8080"
        break
    else
        echo "⏳ Intento $attempt/$max_attempts - Jenkins iniciando... ($(date '+%H:%M:%S'))"
        sleep 5
        attempt=$((attempt + 1))
    fi
done

if [ $attempt -gt $max_attempts ]; then
    echo "❌ Jenkins no inició correctamente después de 5 minutos"
    echo "🔍 Verificando logs de Jenkins..."
    sudo journalctl -u jenkins --no-pager -l | tail -20
    echo ""
    echo "🔧 Intentando reiniciar Jenkins una vez más..."
    sudo systemctl restart jenkins
    echo "⏳ Esperando 30 segundos adicionales..."
    sleep 30
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
    sudo systemctl reload nginx
    echo "✅ Nginx recargado con nueva configuración"
else
    echo "❌ Error en configuración de Nginx"
fi

# Mostrar información final
echo ""
echo "🔍 Verificando instalación..."

# Verificar Jenkins
if curl -s http://localhost:8080 > /dev/null 2>&1; then
    echo "✅ Jenkins está funcionando correctamente"
else
    echo "⚠️ Jenkins puede no estar completamente listo"
    echo "🔧 Verifica con: sudo systemctl status jenkins"
fi

# Verificar Nginx
if curl -s http://localhost > /dev/null 2>&1; then
    echo "✅ Nginx está funcionando correctamente"
else
    echo "⚠️ Nginx puede tener problemas"
    echo "🔧 Verifica con: sudo systemctl status nginx"
fi

echo ""
echo "🎉 ¡INSTALACIÓN COMPLETADA!"
echo ""

# Mostrar URLs con IP si estamos en Cloud Shell
if [[ -n "$CLOUD_SHELL" ]]; then
    EXTERNAL_IP=$(curl -s ifconfig.me 2>/dev/null || echo "localhost")
    SAFE_IP=$(echo $EXTERNAL_IP | tr '.' '-')
    echo "🌐 Jenkins (Cloud Shell): https://8080-${SAFE_IP}-8080.googleusercontent.com"
    echo "🌐 Tu sitio (Cloud Shell): https://80-${SAFE_IP}-80.googleusercontent.com"
    echo "💡 O usa Web Preview en Cloud Shell:"
    echo "   • Jenkins: Web Preview → Preview on port 8080"
    echo "   • Tu sitio: Web Preview → Preview on port 80"
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
    echo "� Espera 2-3 minutos y ejecuta:"
    echo "   sudo cat /var/lib/jenkins/secrets/initialAdminPassword"
fi
echo ""
echo "�💡 ¡Sigue el tutorial.md para continuar!"
echo ""
echo "🛠️ Comandos útiles:"
echo "   • Ver estado Jenkins: sudo systemctl status jenkins"
echo "   • Ver logs Jenkins: sudo journalctl -u jenkins -f"
echo "   • Reiniciar Jenkins: sudo systemctl restart jenkins"
