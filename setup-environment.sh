#!/bin/bash

# 🎯 Script de Configuración del Entorno Jenkins
# Para la práctica completa de Jenkins con despliegue de portafolio
# Autor: RoxsRoss DevOps Community

set -e

# Colores
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m'

# Variables globales
PORTFOLIO_DIR="/var/www/portfolio"
NGINX_SITE="portfolio"
BACKUP_DIR="/var/backups/portfolio"
JENKINS_USER="jenkins"

print_header() {
    echo -e "\n${PURPLE}=================================================="
    echo -e "$1"
    echo -e "==================================================${NC}\n"
}

print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

print_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

# Función para verificar permisos
check_permissions() {
    if [[ $EUID -ne 0 ]]; then
        print_error "Este script debe ejecutarse como root o con sudo"
        exit 1
    fi
}

# Función para configurar directorios
setup_directories() {
    print_header "📁 CONFIGURANDO DIRECTORIOS"
    
    # Crear directorio del portafolio
    mkdir -p $PORTFOLIO_DIR
    print_success "Directorio del portafolio creado: $PORTFOLIO_DIR"
    
    # Crear directorio de backups
    mkdir -p $BACKUP_DIR
    print_success "Directorio de backups creado: $BACKUP_DIR"
    
    # Configurar permisos
    chown -R $JENKINS_USER:www-data $PORTFOLIO_DIR
    chmod -R 755 $PORTFOLIO_DIR
    print_success "Permisos configurados para el directorio del portafolio"
    
    chown -R $JENKINS_USER:$JENKINS_USER $BACKUP_DIR
    chmod -R 755 $BACKUP_DIR
    print_success "Permisos configurados para el directorio de backups"
}

# Función para configurar Nginx
setup_nginx() {
    print_header "🌐 CONFIGURANDO NGINX"
    
    # Verificar si Nginx está instalado
    if ! command -v nginx &> /dev/null; then
        print_info "Instalando Nginx..."
        apt update
        apt install -y nginx
        systemctl enable nginx
        systemctl start nginx
        print_success "Nginx instalado y iniciado"
    else
        print_info "Nginx ya está instalado"
    fi
    
    # Copiar configuración del sitio
    if [ -f "nginx-portfolio.conf" ]; then
        cp nginx-portfolio.conf /etc/nginx/sites-available/$NGINX_SITE
        print_success "Configuración del sitio copiada"
    else
        print_warning "Archivo nginx-portfolio.conf no encontrado, creando configuración básica..."
        create_basic_nginx_config
    fi
    
    # Habilitar el sitio
    ln -sf /etc/nginx/sites-available/$NGINX_SITE /etc/nginx/sites-enabled/
    print_success "Sitio habilitado"
    
    # Deshabilitar sitio por defecto de Nginx
    if [ -f /etc/nginx/sites-enabled/default ]; then
        rm -f /etc/nginx/sites-enabled/default
        print_success "Sitio por defecto deshabilitado"
    fi
    
    # Verificar configuración
    nginx -t
    print_success "Configuración de Nginx verificada"
    
    # Recargar Nginx
    systemctl reload nginx
    print_success "Nginx recargado"
}

# Función para crear configuración básica de Nginx
create_basic_nginx_config() {
    cat > /etc/nginx/sites-available/$NGINX_SITE << 'EOF'
server {
    listen 80;
    server_name _;
    
    root /var/www/portfolio;
    index gaming-hub.html index.html index.htm;
    
    access_log /var/log/nginx/portfolio.access.log;
    error_log /var/log/nginx/portfolio.error.log;
    
    location / {
        try_files $uri $uri/ =404;
        add_header X-Served-By "Jenkins-Pipeline" always;
    }
    
    location /status {
        return 200 "Portfolio is running!\n";
        add_header Content-Type text/plain;
    }
    
    location /build-info {
        try_files /build-info.html =404;
    }
}
EOF
    print_success "Configuración básica de Nginx creada"
}

# Función para configurar permisos de Jenkins
setup_jenkins_permissions() {
    print_header "🔐 CONFIGURANDO PERMISOS DE JENKINS"
    
    # Agregar jenkins al grupo www-data
    usermod -a -G www-data $JENKINS_USER
    print_success "Usuario jenkins agregado al grupo www-data"
    
    # Configurar sudoers para Jenkins
    cat > /etc/sudoers.d/jenkins << 'EOF'
# Permitir a jenkins ejecutar comandos específicos sin contraseña
jenkins ALL=(ALL) NOPASSWD: /bin/cp, /bin/mv, /bin/rm, /bin/mkdir, /bin/chown, /bin/chmod
jenkins ALL=(ALL) NOPASSWD: /usr/sbin/nginx, /bin/systemctl reload nginx, /bin/systemctl restart nginx
jenkins ALL=(ALL) NOPASSWD: /usr/bin/tee
jenkins ALL=(ALL) NOPASSWD: /bin/tar
EOF
    print_success "Permisos sudo configurados para Jenkins"
    
    # Configurar permisos para logs
    touch /var/log/nginx/portfolio.access.log
    touch /var/log/nginx/portfolio.error.log
    chown www-data:adm /var/log/nginx/portfolio.*
    print_success "Permisos de logs configurados"
}

# Función para crear página de ejemplo
create_sample_portfolio() {
    print_header "🎨 CREANDO PORTAFOLIO DE EJEMPLO"
    
    if [ -d "site" ] && [ -f "site/gaming-hub.html" ]; then
        cp -r site/* $PORTFOLIO_DIR/
        print_success "Portafolio copiado desde directorio site/"
    else
        print_info "Creando portafolio de ejemplo..."
        create_default_portfolio
    fi
    
    # Crear página de error 404
    cat > $PORTFOLIO_DIR/404.html << 'EOF'
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>404 - Página no encontrada</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            text-align: center;
            padding: 50px;
            min-height: 100vh;
            margin: 0;
        }
        .error-container {
            max-width: 600px;
            margin: 0 auto;
            padding: 40px;
            background: rgba(255,255,255,0.1);
            border-radius: 10px;
        }
        h1 { font-size: 3em; margin-bottom: 20px; }
        p { font-size: 1.2em; margin-bottom: 30px; }
        a {
            background: #4CAF50;
            color: white;
            padding: 15px 30px;
            text-decoration: none;
            border-radius: 5px;
            font-weight: bold;
        }
        a:hover { background: #45a049; }
    </style>
</head>
<body>
    <div class="error-container">
        <h1>🤖 404</h1>
        <p>¡Oops! La página que buscas no existe.</p>
        <p>Puede que haya sido movida o eliminada durante el último despliegue.</p>
        <a href="/">🏠 Volver al inicio</a>
    </div>
</body>
</html>
EOF
    
    # Configurar permisos finales
    chown -R www-data:www-data $PORTFOLIO_DIR
    find $PORTFOLIO_DIR -type f -exec chmod 644 {} \;
    find $PORTFOLIO_DIR -type d -exec chmod 755 {} \;
    
    print_success "Portafolio de ejemplo creado y configurado"
}

# Función para crear portafolio por defecto
create_default_portfolio() {
    cat > $PORTFOLIO_DIR/index.html << 'EOF'
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>🚀 Portfolio DevOps - Jenkins CI/CD</title>
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            min-height: 100vh;
            padding: 20px;
        }
        .container {
            max-width: 800px;
            margin: 0 auto;
            text-align: center;
            padding: 40px;
        }
        h1 {
            font-size: 3em;
            margin-bottom: 20px;
            text-shadow: 2px 2px 4px rgba(0,0,0,0.3);
        }
        .status-card {
            background: rgba(255,255,255,0.1);
            padding: 30px;
            border-radius: 15px;
            margin: 20px 0;
            backdrop-filter: blur(10px);
        }
        .success { border-left: 5px solid #4CAF50; }
        .info { border-left: 5px solid #2196F3; }
        .links {
            display: flex;
            justify-content: center;
            gap: 20px;
            margin-top: 30px;
            flex-wrap: wrap;
        }
        .link-btn {
            background: #4CAF50;
            color: white;
            padding: 15px 25px;
            text-decoration: none;
            border-radius: 8px;
            font-weight: bold;
            transition: background 0.3s;
        }
        .link-btn:hover { background: #45a049; }
        .footer {
            margin-top: 50px;
            opacity: 0.8;
            font-size: 0.9em;
        }
    </style>
</head>
<body>
    <div class="container">
        <h1>🚀 Portfolio DevOps</h1>
        <p style="font-size: 1.3em; margin-bottom: 30px;">
            Desplegado automáticamente con Jenkins CI/CD
        </p>
        
        <div class="status-card success">
            <h2>✅ Despliegue Exitoso</h2>
            <p>Tu aplicación está funcionando correctamente</p>
        </div>
        
        <div class="status-card info">
            <h2>🔧 Tecnologías Utilizadas</h2>
            <p>Jenkins • Nginx • Linux • Git • CI/CD Pipeline</p>
        </div>
        
        <div class="links">
            <a href="/status" class="link-btn">📊 Status</a>
            <a href="/build-info" class="link-btn">🔧 Build Info</a>
            <a href="/health" class="link-btn">❤️ Health</a>
        </div>
        
        <div class="footer">
            <p>🎯 Práctica de Jenkins - RoxsRoss DevOps Community</p>
            <p>Automatización • Integración Continua • Despliegue Continuo</p>
        </div>
    </div>
</body>
</html>
EOF
    
    # Crear symlink para gaming-hub.html
    ln -sf index.html $PORTFOLIO_DIR/gaming-hub.html
    
    print_success "Portafolio por defecto creado"
}

# Función para verificar la configuración
verify_setup() {
    print_header "🧪 VERIFICANDO CONFIGURACIÓN"
    
    # Verificar directorios
    if [ -d "$PORTFOLIO_DIR" ]; then
        print_success "Directorio del portafolio existe"
    else
        print_error "Directorio del portafolio no existe"
        return 1
    fi
    
    # Verificar Nginx
    if systemctl is-active --quiet nginx; then
        print_success "Nginx está activo"
    else
        print_error "Nginx no está activo"
        return 1
    fi
    
    # Verificar configuración del sitio
    if [ -f "/etc/nginx/sites-enabled/$NGINX_SITE" ]; then
        print_success "Sitio de Nginx configurado"
    else
        print_error "Sitio de Nginx no configurado"
        return 1
    fi
    
    # Verificar respuesta HTTP
    if curl -s -o /dev/null -w "%{http_code}" http://localhost | grep -q "200"; then
        print_success "Sitio web responde correctamente"
    else
        print_warning "Sitio web no responde (puede ser normal si no hay contenido)"
    fi
    
    # Verificar permisos de Jenkins
    if sudo -u jenkins test -w "$PORTFOLIO_DIR"; then
        print_success "Jenkins tiene permisos de escritura"
    else
        print_error "Jenkins no tiene permisos de escritura"
        return 1
    fi
    
    print_success "Verificación completada"
}

# Función para mostrar información del entorno
show_environment_info() {
    print_header "📋 INFORMACIÓN DEL ENTORNO"
    
    server_ip=$(hostname -I | awk '{print $1}')
    
    cat << EOF
🌐 URLs del portafolio:
   • http://$server_ip
   • http://localhost
   • http://$server_ip/status
   • http://$server_ip/build-info

📁 Directorios importantes:
   • Portafolio: $PORTFOLIO_DIR
   • Backups: $BACKUP_DIR
   • Nginx config: /etc/nginx/sites-available/$NGINX_SITE
   • Nginx logs: /var/log/nginx/portfolio.*

🔧 Comandos útiles:
   • Ver logs de Nginx: sudo tail -f /var/log/nginx/portfolio.access.log
   • Recargar Nginx: sudo systemctl reload nginx
   • Verificar sintaxis Nginx: sudo nginx -t
   • Estado de Nginx: sudo systemctl status nginx

📝 Archivos de configuración:
   • Jenkinsfile: Para el pipeline de CI/CD
   • nginx-portfolio.conf: Configuración del servidor web
   • Permisos sudo: /etc/sudoers.d/jenkins

EOF
}

# Función para crear scripts de ayuda
create_helper_scripts() {
    print_header "📝 CREANDO SCRIPTS DE AYUDA"
    
    # Script para desplegar manualmente
    cat > /usr/local/bin/deploy-portfolio << EOF
#!/bin/bash
# Script para despliegue manual del portafolio
echo "🚀 Desplegando portafolio manualmente..."

if [ -d "site" ]; then
    sudo cp -r site/* $PORTFOLIO_DIR/
    sudo chown -R www-data:www-data $PORTFOLIO_DIR
    sudo chmod -R 644 $PORTFOLIO_DIR/*
    sudo find $PORTFOLIO_DIR -type d -exec chmod 755 {} \\;
    echo "✅ Portafolio desplegado desde directorio 'site/'"
else
    echo "❌ Directorio 'site/' no encontrado"
    exit 1
fi

# Verificar despliegue
if curl -s http://localhost > /dev/null; then
    echo "✅ Sitio web funcionando correctamente"
else
    echo "⚠️  Advertencia: No se pudo verificar el sitio web"
fi
EOF
    chmod +x /usr/local/bin/deploy-portfolio
    print_success "Script deploy-portfolio creado"
    
    # Script para ver logs del portafolio
    cat > /usr/local/bin/portfolio-logs << 'EOF'
#!/bin/bash
echo "📋 Logs del portafolio (Ctrl+C para salir):"
echo "============================================"
sudo tail -f /var/log/nginx/portfolio.access.log
EOF
    chmod +x /usr/local/bin/portfolio-logs
    print_success "Script portfolio-logs creado"
    
    # Script de estado del portafolio
    cat > /usr/local/bin/portfolio-status << EOF
#!/bin/bash
echo "📊 Estado del Portafolio"
echo "========================"
echo ""
echo "🌐 URLs:"
server_ip=\$(hostname -I | awk '{print \$1}')
echo "   http://\$server_ip"
echo "   http://localhost"
echo ""
echo "🔧 Servicios:"
echo -n "   Nginx: "
if systemctl is-active --quiet nginx; then
    echo "✅ Activo"
else
    echo "❌ Inactivo"
fi
echo ""
echo "📁 Archivos en $PORTFOLIO_DIR:"
ls -la $PORTFOLIO_DIR 2>/dev/null || echo "   Directorio vacío o no accesible"
echo ""
echo "🌐 Respuesta HTTP:"
response=\$(curl -s -o /dev/null -w "%{http_code}" http://localhost)
if [ "\$response" = "200" ]; then
    echo "   ✅ 200 OK"
else
    echo "   ❌ \$response"
fi
EOF
    chmod +x /usr/local/bin/portfolio-status
    print_success "Script portfolio-status creado"
}

# Función principal
main() {
    check_permissions
    setup_directories
    setup_nginx
    setup_jenkins_permissions
    create_sample_portfolio
    create_helper_scripts
    verify_setup
    show_environment_info
    
    print_header "🎉 CONFIGURACIÓN COMPLETADA"
    print_success "El entorno está listo para Jenkins!"
    print_info "Ahora puedes crear tu pipeline en Jenkins usando el Jenkinsfile incluido"
    print_info "Scripts disponibles: deploy-portfolio, portfolio-logs, portfolio-status"
}

# Ejecutar función principal
main "$@"
