#!/bin/bash

# 🚀 Quick Start - Práctica de Jenkins CI/CD
# Script de inicio rápido para estudiantes
# Autor: RoxsRoss DevOps Community

# Colores
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
PURPLE='\033[0;35m'
NC='\033[0m'

print_banner() {
    echo -e "${PURPLE}"
    cat << 'EOF'
╔══════════════════════════════════════════════════════════════╗
║                                                              ║
║     🚀 PRÁCTICA COMPLETA DE JENKINS CI/CD 🚀                ║
║                                                              ║
║     Bienvenido a tu experiencia de aprendizaje Jenkins       ║
║     Sin contenedores - Instalación nativa en Linux          ║
║                                                              ║
╚══════════════════════════════════════════════════════════════╝
EOF
    echo -e "${NC}"
}

print_header() {
    echo -e "\n${BLUE}▶ $1${NC}"
}

print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

# Verificar permisos
check_permissions() {
    if [[ $EUID -ne 0 ]]; then
        print_error "Este script debe ejecutarse como root o con sudo"
        echo ""
        echo "Ejecuta: sudo ./quick-start.sh"
        exit 1
    fi
}

# Mostrar menú de opciones
show_menu() {
    echo ""
    echo -e "${BLUE}¿Qué quieres hacer?${NC}"
    echo ""
    echo "1) 🔍 Validar entorno del sistema"
    echo "2) 🚀 Instalación completa automática (Jenkins + entorno)"
    echo "3) ☕ Solo instalar Jenkins"
    echo "4) 🌐 Solo configurar entorno de despliegue"
    echo "5) 📊 Ver estado actual del sistema"
    echo "6) 🆘 Ver ayuda y documentación"
    echo "7) 🔄 Reiniciar todos los servicios"
    echo "8) 🗑️  Limpiar y reset completo"
    echo "0) ❌ Salir"
    echo ""
}

# Función para validar entorno
validate_environment() {
    print_header "Validando entorno del sistema..."
    if [ -f "./validate-environment.sh" ]; then
        chmod +x ./validate-environment.sh
        ./validate-environment.sh
    else
        print_error "Script validate-environment.sh no encontrado"
        return 1
    fi
}

# Función para instalación completa
full_installation() {
    print_header "Iniciando instalación completa..."
    
    # Paso 1: Validar entorno
    echo -e "${BLUE}Paso 1/3: Validando entorno...${NC}"
    if ! validate_environment; then
        print_error "Validación falló. Revisa los errores antes de continuar."
        return 1
    fi
    
    # Paso 2: Instalar Jenkins
    echo -e "${BLUE}Paso 2/3: Instalando Jenkins...${NC}"
    if [ -f "./install-jenkins.sh" ]; then
        chmod +x ./install-jenkins.sh
        ./install-jenkins.sh
    else
        print_error "Script install-jenkins.sh no encontrado"
        return 1
    fi
    
    # Paso 3: Configurar entorno
    echo -e "${BLUE}Paso 3/3: Configurando entorno...${NC}"
    if [ -f "./setup-environment.sh" ]; then
        chmod +x ./setup-environment.sh
        ./setup-environment.sh
    else
        print_error "Script setup-environment.sh no encontrado"
        return 1
    fi
    
    print_success "¡Instalación completa terminada!"
    show_access_info
}

# Función para solo instalar Jenkins
install_jenkins_only() {
    print_header "Instalando solo Jenkins..."
    if [ -f "./install-jenkins.sh" ]; then
        chmod +x ./install-jenkins.sh
        ./install-jenkins.sh
        show_jenkins_info
    else
        print_error "Script install-jenkins.sh no encontrado"
    fi
}

# Función para solo configurar entorno
setup_environment_only() {
    print_header "Configurando solo entorno de despliegue..."
    if [ -f "./setup-environment.sh" ]; then
        chmod +x ./setup-environment.sh
        ./setup-environment.sh
    else
        print_error "Script setup-environment.sh no encontrado"
    fi
}

# Función para ver estado del sistema
show_system_status() {
    print_header "Estado actual del sistema"
    
    echo ""
    echo -e "${BLUE}🔧 Servicios:${NC}"
    
    # Jenkins
    if systemctl is-active --quiet jenkins; then
        print_success "Jenkins: Running"
        echo "   URL: http://$(hostname -I | awk '{print $1}'):8080"
    else
        print_warning "Jenkins: Not running"
    fi
    
    # Nginx
    if systemctl is-active --quiet nginx; then
        print_success "Nginx: Running"
        echo "   URL: http://$(hostname -I | awk '{print $1}')"
    else
        print_warning "Nginx: Not running"
    fi
    
    echo ""
    echo -e "${BLUE}💾 Recursos del sistema:${NC}"
    echo "   RAM: $(free -h | awk 'NR==2{printf "%.1f%%", $3*100/$2 }')"
    echo "   Disco: $(df / | awk 'NR==2{print $5}')"
    echo "   CPU Load: $(uptime | awk -F'load average:' '{ print $2 }')"
    
    echo ""
    echo -e "${BLUE}🌐 Conectividad:${NC}"
    if curl -s -o /dev/null http://localhost:8080; then
        print_success "Jenkins UI: Accesible"
    else
        print_warning "Jenkins UI: No accesible"
    fi
    
    if curl -s -o /dev/null http://localhost; then
        print_success "Sitio web: Accesible"
    else
        print_warning "Sitio web: No accesible"
    fi
}

# Función para mostrar ayuda
show_help() {
    print_header "Documentación y ayuda disponible"
    
    echo ""
    echo -e "${BLUE}📚 Documentos principales:${NC}"
    echo "   • tutorial.md                 - Tutorial interactivo (EMPEZAR AQUÍ)"
    echo "   • GUIA-PASO-A-PASO.md        - Guía detallada completa"
    echo "   • JENKINS-PRACTICE.md        - Descripción de la práctica"
    echo "   • README-JENKINS.md          - Información general del proyecto"
    
    echo ""
    echo -e "${BLUE}🔧 Scripts disponibles:${NC}"
    echo "   • ./validate-environment.sh   - Validar sistema"
    echo "   • ./install-jenkins.sh        - Instalar Jenkins"
    echo "   • ./setup-environment.sh      - Configurar entorno"
    echo "   • ./quick-start.sh            - Este script"
    
    echo ""
    echo -e "${BLUE}🆘 Solución de problemas:${NC}"
    echo "   • TROUBLESHOOTING.md          - Guía de troubleshooting"
    echo "   • COMANDOS-UTILES.md          - Comandos de referencia"
    
    echo ""
    echo -e "${BLUE}⚡ Comandos rápidos:${NC}"
    echo "   • jenkins-status              - Estado de Jenkins"
    echo "   • portfolio-status            - Estado del portafolio"
    echo "   • jenkins-logs                - Logs de Jenkins"
    echo "   • portfolio-logs              - Logs del sitio web"
    
    echo ""
    echo -e "${YELLOW}💡 Para empezar, abre y sigue: tutorial.md${NC}"
}

# Función para reiniciar servicios
restart_services() {
    print_header "Reiniciando todos los servicios..."
    
    echo "🔄 Reiniciando Jenkins..."
    systemctl restart jenkins
    sleep 5
    
    echo "🔄 Reiniciando Nginx..."
    systemctl restart nginx
    sleep 2
    
    echo "🔄 Verificando estado..."
    if systemctl is-active --quiet jenkins; then
        print_success "Jenkins reiniciado correctamente"
    else
        print_error "Error al reiniciar Jenkins"
    fi
    
    if systemctl is-active --quiet nginx; then
        print_success "Nginx reiniciado correctamente"
    else
        print_error "Error al reiniciar Nginx"
    fi
}

# Función para reset completo
reset_system() {
    print_header "⚠️  RESET COMPLETO DEL SISTEMA"
    echo ""
    print_warning "Esta acción eliminará:"
    echo "   • Configuración de Jenkins"
    echo "   • Configuración de Nginx"
    echo "   • Archivos de despliegue"
    echo "   • Logs y backups"
    echo ""
    
    read -p "¿Estás seguro? Escribe 'RESET' para confirmar: " confirm
    
    if [ "$confirm" = "RESET" ]; then
        echo ""
        print_header "Ejecutando reset completo..."
        
        # Detener servicios
        systemctl stop jenkins nginx 2>/dev/null || true
        
        # Eliminar configuraciones
        rm -rf /var/lib/jenkins/* 2>/dev/null || true
        rm -f /etc/nginx/sites-enabled/portfolio 2>/dev/null || true
        rm -f /etc/nginx/sites-available/portfolio 2>/dev/null || true
        rm -rf /var/www/portfolio/* 2>/dev/null || true
        rm -rf /var/backups/portfolio/* 2>/dev/null || true
        
        # Eliminar scripts de ayuda
        rm -f /usr/local/bin/jenkins-* 2>/dev/null || true
        rm -f /usr/local/bin/portfolio-* 2>/dev/null || true
        rm -f /usr/local/bin/health-check 2>/dev/null || true
        
        # Reiniciar servicios
        systemctl restart jenkins nginx 2>/dev/null || true
        
        print_success "Reset completado. El sistema está en estado inicial."
        print_warning "Ejecuta la instalación completa para configurar todo nuevamente."
    else
        print_warning "Reset cancelado."
    fi
}

# Función para mostrar información de acceso
show_access_info() {
    local server_ip=$(hostname -I | awk '{print $1}')
    
    echo ""
    echo -e "${GREEN}🎉 ¡TODO LISTO! Tu entorno Jenkins está configurado${NC}"
    echo ""
    echo -e "${BLUE}🌐 URLs de acceso:${NC}"
    echo "   • Jenkins UI:    http://$server_ip:8080"
    echo "   • Portafolio:    http://$server_ip"
    echo "   • Build Info:    http://$server_ip/build-info"
    echo "   • Status API:    http://$server_ip/status"
    echo ""
    echo -e "${BLUE}🔑 Credenciales de Jenkins:${NC}"
    echo "   • Usuario:       devops-admin"
    echo "   • Contraseña:    DevOps2024!"
    echo ""
    if [ -f /var/lib/jenkins/secrets/initialAdminPassword ]; then
        echo -e "${BLUE}🔐 Contraseña inicial (primera vez):${NC}"
        echo "   $(cat /var/lib/jenkins/secrets/initialAdminPassword)"
        echo ""
    fi
    echo -e "${YELLOW}📚 Próximo paso: Sigue el tutorial.md para crear tu primer pipeline${NC}"
}

# Función para mostrar solo info de Jenkins
show_jenkins_info() {
    local server_ip=$(hostname -I | awk '{print $1}')
    
    echo ""
    echo -e "${GREEN}✅ Jenkins instalado correctamente${NC}"
    echo ""
    echo -e "${BLUE}🌐 Acceso a Jenkins:${NC}"
    echo "   • URL: http://$server_ip:8080"
    echo ""
    if [ -f /var/lib/jenkins/secrets/initialAdminPassword ]; then
        echo -e "${BLUE}🔐 Contraseña inicial:${NC}"
        echo "   $(cat /var/lib/jenkins/secrets/initialAdminPassword)"
        echo ""
    fi
    echo -e "${YELLOW}📚 Próximo paso: Configura el entorno con la opción 4${NC}"
}

# Función principal
main() {
    print_banner
    
    # Verificar permisos solo si no es opción de ayuda
    if [[ $# -eq 0 ]]; then
        check_permissions
    fi
    
    # Si se pasa un argumento, ejecutar directamente
    if [[ $# -gt 0 ]]; then
        case $1 in
            "validate"|"1")
                validate_environment
                ;;
            "install"|"2")
                check_permissions
                full_installation
                ;;
            "jenkins"|"3")
                check_permissions
                install_jenkins_only
                ;;
            "setup"|"4")
                check_permissions
                setup_environment_only
                ;;
            "status"|"5")
                show_system_status
                ;;
            "help"|"6")
                show_help
                ;;
            "restart"|"7")
                check_permissions
                restart_services
                ;;
            "reset"|"8")
                check_permissions
                reset_system
                ;;
            *)
                echo "Opción no válida: $1"
                show_help
                ;;
        esac
        exit 0
    fi
    
    # Menú interactivo
    while true; do
        show_menu
        read -p "Selecciona una opción [0-8]: " choice
        echo ""
        
        case $choice in
            1)
                validate_environment
                ;;
            2)
                full_installation
                ;;
            3)
                install_jenkins_only
                ;;
            4)
                setup_environment_only
                ;;
            5)
                show_system_status
                ;;
            6)
                show_help
                ;;
            7)
                restart_services
                ;;
            8)
                reset_system
                ;;
            0)
                echo -e "${BLUE}¡Gracias por usar la práctica de Jenkins CI/CD!${NC}"
                echo -e "${YELLOW}🚀 ¡Que disfrutes aprendiendo DevOps!${NC}"
                exit 0
                ;;
            *)
                print_error "Opción no válida. Por favor selecciona 0-8."
                ;;
        esac
        
        echo ""
        read -p "Presiona Enter para continuar..."
    done
}

# Ejecutar función principal
main "$@"
