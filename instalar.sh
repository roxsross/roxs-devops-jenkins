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
sudo apt install -y openjdk-11-jdk

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
echo "🎉 ¡INSTALACIÓN COMPLETADA!"
echo ""
echo "🌐 Jenkins: http://localhost:8080"
echo "🌐 Tu sitio: http://localhost"
echo ""
echo "🔑 Contraseña de Jenkins:"
sudo cat /var/lib/jenkins/secrets/initialAdminPassword
echo ""
echo "💡 ¡Sigue el tutorial.md para continuar!"
