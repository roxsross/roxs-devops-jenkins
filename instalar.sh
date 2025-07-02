#!/bin/bash

# 🚀 Jenkins - Instalación Simple para Principiantes
# Un solo script que hace todo automáticamente

echo "🚀 Instalando Jenkins para principiantes..."
echo "⏱️  Esto tomará unos minutos..."

# Actualizar sistema
echo "📦 Actualizando sistema..."
sudo apt update -qq

# Instalar Java (necesario para Jenkins)
echo "☕ Instalando Java..."
sudo apt install -y openjdk-17-jdk

# Verificar instalación de Java
echo "🔍 Verificando Java..."
java_version=$(java -version 2>&1 | head -1)
if [[ $java_version == *"openjdk"* ]]; then
    echo "✅ Java instalado correctamente: $java_version"
else
    echo "❌ Error instalando Java"
    exit 1
fi

# Instalar Jenkins
echo "🔧 Instalando Jenkins..."
wget -q -O - https://pkg.jenkins.io/debian-stable/jenkins.io.key | sudo apt-key add -
sudo sh -c 'echo deb https://pkg.jenkins.io/debian-stable binary/ > /etc/apt/sources.list.d/jenkins.list'
sudo apt update -qq
sudo apt install -y jenkins

# Instalar Nginx (servidor web)
echo "🌐 Instalando servidor web..."
sudo apt install -y nginx

# Iniciar servicios
echo "🚀 Iniciando servicios..."
sudo systemctl start jenkins
sudo systemctl start nginx
sudo systemctl enable jenkins
sudo systemctl enable nginx

# Esperar a que Jenkins esté completamente iniciado
echo "⏳ Esperando a que Jenkins esté listo..."
max_attempts=60
attempt=1

while [ $attempt -le $max_attempts ]; do
    if sudo systemctl is-active --quiet jenkins && curl -s http://localhost:8080 > /dev/null 2>&1; then
        echo "✅ Jenkins está corriendo y respondiendo"
        break
    else
        echo "⏳ Intento $attempt/$max_attempts - Jenkins iniciando..."
        sleep 5
        attempt=$((attempt + 1))
    fi
done

if [ $attempt -gt $max_attempts ]; then
    echo "❌ Jenkins no inició correctamente después de 5 minutos"
    echo "🔍 Verificando logs de Jenkins..."
    sudo journalctl -u jenkins --no-pager -l | tail -20
    echo ""
    echo "🔧 Intentando reiniciar Jenkins..."
    sudo systemctl restart jenkins
    sleep 30
fi

# Configurar firewall
echo "🔥 Configurando accesos..."
sudo ufw allow 8080 2>/dev/null || true
sudo ufw allow 80 2>/dev/null || true

# Configurar sitio web
echo "🎨 Configurando tu portafolio..."
sudo mkdir -p /var/www/portfolio
sudo cp -r site/* /var/www/portfolio/
sudo chown -R www-data:www-data /var/www/portfolio

# Configurar Nginx para el portafolio
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
}
EOF

sudo ln -sf /etc/nginx/sites-available/portfolio /etc/nginx/sites-enabled/
sudo rm -f /etc/nginx/sites-enabled/default
sudo systemctl reload nginx

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
