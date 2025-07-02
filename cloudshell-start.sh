#!/bin/bash

# ========================================
# Jenkins CI/CD - Cloud Shell Quick Start
# ========================================
# Script específico para Google Cloud Shell
# Configura y ejecuta toda la práctica automáticamente

set -e

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Función para logging
log() {
    echo -e "${CYAN}[$(date +'%H:%M:%S')]${NC} $1"
}

success() {
    echo -e "${GREEN}✅ $1${NC}"
}

warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

error() {
    echo -e "${RED}❌ $1${NC}"
}

info() {
    echo -e "${BLUE}💡 $1${NC}"
}

# Banner de bienvenida
show_banner() {
    echo -e "${PURPLE}"
    cat << 'EOF'
    ☁️  ========================================== ☁️
         JENKINS CI/CD EN GOOGLE CLOUD SHELL       
    ☁️  ========================================== ☁️
EOF
    echo -e "${NC}"
    echo -e "${CYAN}🚀 Configuración automática para Cloud Shell${NC}"
    echo -e "${CYAN}📚 Tutorial: tutorial.md${NC}"
    echo -e "${CYAN}⏱️  Tiempo estimado: 10-15 minutos${NC}"
    echo
}

# Verificar que estamos en Cloud Shell
verify_cloud_shell() {
    log "Verificando entorno Cloud Shell..."
    
    if [[ -n "$CLOUD_SHELL" ]]; then
        success "Ejecutando en Google Cloud Shell"
        info "Project ID: ${DEVSHELL_PROJECT_ID:-'No especificado'}"
        info "Usuario: $(whoami)"
        info "Directorio HOME persistente: $HOME"
    else
        warning "No se detectó Google Cloud Shell"
        info "Continuando como instalación en servidor Linux..."
    fi
    echo
}

# Mostrar recursos disponibles
show_resources() {
    log "Verificando recursos del sistema..."
    
    echo -e "${BLUE}💾 Memoria disponible:${NC}"
    free -h | grep Mem
    
    echo -e "${BLUE}💽 Espacio en disco:${NC}"
    df -h | grep -E "(cloudshell|/$)" | head -2
    
    echo -e "${BLUE}🌐 IP externa:${NC}"
    curl -s ifconfig.me
    echo
    echo
}

# Configurar persistencia en Cloud Shell
setup_cloudshell_persistence() {
    if [[ -n "$CLOUD_SHELL" ]]; then
        log "Configurando persistencia para Cloud Shell..."
        
        # Crear directorio persistente para Jenkins
        mkdir -p "$HOME/jenkins-data"
        mkdir -p "$HOME/nginx-sites"
        mkdir -p "$HOME/portfolio-backup"
        
        success "Directorios persistentes creados en $HOME"
        
        # Crear script de restauración
        cat > "$HOME/restore-jenkins.sh" << 'RESTORE_EOF'
#!/bin/bash
# Script para restaurar Jenkins después de reiniciar Cloud Shell

echo "🔄 Restaurando Jenkins en Cloud Shell..."

# Restaurar enlace simbólico a datos persistentes
if [ ! -L "/var/lib/jenkins" ]; then
    sudo mkdir -p /var/lib
    sudo ln -sf "$HOME/jenkins-data" /var/lib/jenkins
fi

# Iniciar servicios
sudo systemctl start jenkins 2>/dev/null || echo "Jenkins no instalado aún"
sudo systemctl start nginx 2>/dev/null || echo "Nginx no instalado aún"

echo "✅ Restauración completada"
RESTORE_EOF
        
        chmod +x "$HOME/restore-jenkins.sh"
        success "Script de restauración creado: $HOME/restore-jenkins.sh"
    fi
}

# Ejecutar validación del entorno
run_validation() {
    log "Ejecutando validación del entorno..."
    
    if [ -f "./validate-environment.sh" ]; then
        chmod +x ./validate-environment.sh
        ./validate-environment.sh
    else
        warning "Script de validación no encontrado, continuando..."
    fi
}

# Instalar Jenkins
install_jenkins() {
    log "Iniciando instalación de Jenkins..."
    
    if [ -f "./install-jenkins.sh" ]; then
        chmod +x ./install-jenkins.sh
        sudo ./install-jenkins.sh
        
        # En Cloud Shell, configurar persistencia
        if [[ -n "$CLOUD_SHELL" ]]; then
            log "Configurando persistencia de datos Jenkins..."
            sudo systemctl stop jenkins
            sudo mv /var/lib/jenkins/* "$HOME/jenkins-data/" 2>/dev/null || true
            sudo rmdir /var/lib/jenkins 2>/dev/null || sudo rm -rf /var/lib/jenkins
            sudo ln -sf "$HOME/jenkins-data" /var/lib/jenkins
            sudo systemctl start jenkins
            success "Jenkins configurado con persistencia en Cloud Shell"
        fi
    else
        error "Script de instalación no encontrado: install-jenkins.sh"
        exit 1
    fi
}

# Configurar entorno
setup_environment() {
    log "Configurando entorno de trabajo..."
    
    if [ -f "./setup-environment.sh" ]; then
        chmod +x ./setup-environment.sh
        ./setup-environment.sh
    else
        warning "Script de configuración no encontrado, creando configuración básica..."
        
        # Configuración mínima si no hay script
        sudo mkdir -p /var/www/portfolio
        sudo chown -R www-data:www-data /var/www/portfolio
        
        # Copiar sitio de ejemplo
        if [ -d "./site" ]; then
            sudo cp -r ./site/* /var/www/portfolio/
            success "Sitio de ejemplo copiado"
        fi
    fi
}

# Generar URLs para Cloud Shell
generate_cloud_shell_urls() {
    if [[ -n "$CLOUD_SHELL" ]]; then
        log "Generando URLs para Cloud Shell..."
        
        # Obtener IP externa
        EXTERNAL_IP=$(curl -s ifconfig.me)
        SAFE_IP=$(echo $EXTERNAL_IP | tr '.' '-')
        
        # Generar URLs
        JENKINS_URL="https://8080-${SAFE_IP}-8080.googleusercontent.com"
        PORTFOLIO_URL="https://80-${SAFE_IP}-80.googleusercontent.com"
        
        echo
        echo -e "${PURPLE}🌐 URLs DE ACCESO EN CLOUD SHELL:${NC}"
        echo -e "${GREEN}📊 Jenkins UI:${NC}    $JENKINS_URL"
        echo -e "${GREEN}🌐 Tu Portafolio:${NC} $PORTFOLIO_URL"
        echo
        echo -e "${CYAN}💡 También puedes usar Web Preview:${NC}"
        echo -e "   • Jenkins: Web Preview → Preview on port 8080"
        echo -e "   • Portafolio: Web Preview → Preview on port 80"
        echo
        
        # Guardar URLs en archivo
        cat > "$HOME/jenkins-urls.txt" << URL_EOF
# URLs generadas para esta sesión de Cloud Shell
Jenkins UI: $JENKINS_URL
Portafolio: $PORTFOLIO_URL

# Para nuevas sesiones, ejecuta:
echo "Jenkins: https://8080-\$(curl -s ifconfig.me | tr '.' '-')-8080.googleusercontent.com"
echo "Portafolio: https://80-\$(curl -s ifconfig.me | tr '.' '-')-80.googleusercontent.com"
URL_EOF
        
        success "URLs guardadas en: $HOME/jenkins-urls.txt"
    fi
}

# Mostrar contraseña de Jenkins
show_jenkins_password() {
    log "Obteniendo contraseña inicial de Jenkins..."
    
    # Esperar a que Jenkins esté listo
    local max_attempts=30
    local attempt=1
    
    while [ $attempt -le $max_attempts ]; do
        if sudo test -f /var/lib/jenkins/secrets/initialAdminPassword; then
            PASSWORD=$(sudo cat /var/lib/jenkins/secrets/initialAdminPassword)
            echo
            echo -e "${YELLOW}🔑 CONTRASEÑA INICIAL DE JENKINS:${NC}"
            echo -e "${RED}${PASSWORD}${NC}"
            echo
            success "Guarda esta contraseña para configurar Jenkins"
            return 0
        fi
        
        echo -n "."
        sleep 5
        ((attempt++))
    done
    
    warning "No se pudo obtener la contraseña automáticamente"
    info "Ejecuta: sudo cat /var/lib/jenkins/secrets/initialAdminPassword"
}

# Mostrar resumen final
show_summary() {
    echo
    echo -e "${PURPLE}🎉 ========================================== 🎉${NC}"
    echo -e "${PURPLE}     INSTALACIÓN COMPLETADA EXITOSAMENTE    ${NC}"
    echo -e "${PURPLE}🎉 ========================================== 🎉${NC}"
    echo
    
    echo -e "${GREEN}✅ Jenkins instalado y configurado${NC}"
    echo -e "${GREEN}✅ Nginx instalado y configurado${NC}"
    echo -e "${GREEN}✅ Portafolio web desplegado${NC}"
    echo -e "${GREEN}✅ Configuración optimizada para Cloud Shell${NC}"
    echo
    
    echo -e "${CYAN}📖 PRÓXIMOS PASOS:${NC}"
    echo -e "1. 🌐 Abre Jenkins en tu navegador (URLs mostradas arriba)"
    echo -e "2. 🔑 Usa la contraseña inicial para configurar Jenkins"
    echo -e "3. 📚 Sigue el tutorial completo en: tutorial.md"
    echo -e "4. 🏗️ Crea tu primer pipeline de CI/CD"
    echo
    
    if [[ -n "$CLOUD_SHELL" ]]; then
        echo -e "${YELLOW}💡 TIPS PARA CLOUD SHELL:${NC}"
        echo -e "• 🔄 Después de reiniciar: ejecuta ~/restore-jenkins.sh"
        echo -e "• 📁 Tus datos persisten en: $HOME/jenkins-data"
        echo -e "• 🌐 URLs actuales en: $HOME/jenkins-urls.txt"
        echo
    fi
    
    echo -e "${BLUE}🎪 ¿LISTO PARA CREAR TU PRIMER PIPELINE?${NC}"
    echo -e "Sigue el tutorial desde el Paso 5 en tutorial.md"
    echo
}

# Función principal
main() {
    show_banner
    verify_cloud_shell
    show_resources
    setup_cloudshell_persistence
    
    echo -e "${YELLOW}🚀 ¿Iniciar instalación completa? (y/N):${NC}"
    read -r response
    
    if [[ "$response" =~ ^[Yy]$ ]]; then
        run_validation
        install_jenkins
        setup_environment
        generate_cloud_shell_urls
        show_jenkins_password
        show_summary
    else
        info "Instalación cancelada. Puedes ejecutar pasos individuales:"
        echo "• ./validate-environment.sh"
        echo "• sudo ./install-jenkins.sh"
        echo "• ./setup-environment.sh"
    fi
}

# Verificar si se ejecuta desde el directorio correcto
if [ ! -f "tutorial.md" ]; then
    error "Por favor ejecuta este script desde el directorio del proyecto"
    error "Directorio actual: $(pwd)"
    exit 1
fi

# Ejecutar función principal
main "$@"
