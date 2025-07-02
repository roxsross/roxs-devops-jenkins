#!/bin/bash

# 🚀 Script de Instalación Automatizada de Jenkins
# Práctica DevOps - RoxsRoss Community
# Autor: RoxsRoss DevOps Team

set -e  # Salir si cualquier comando falla

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Función para imprimir con colores
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

# Variables
JENKINS_USER="devops-admin"
JENKINS_PASS="DevOps2024!"
JENKINS_PORT=8080

print_header "🚀 INSTALACIÓN AUTOMATIZADA DE JENKINS"

# Verificar que el script se ejecute como root o con sudo
if [[ $EUID -eq 0 ]]; then
    print_info "Ejecutando como root"
else
    print_error "Este script debe ejecutarse como root o con sudo"
    exit 1
fi

# Función para verificar si un comando existe
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Función para verificar la distribución de Linux
check_distro() {
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        OS=$NAME
        VER=$VERSION_ID
    else
        print_error "No se pudo determinar la distribución de Linux"
        exit 1
    fi
    
    print_info "Distribución detectada: $OS $VER"
    
    if [[ ! "$OS" =~ Ubuntu|Debian ]]; then
        print_warning "Este script está optimizado para Ubuntu/Debian"
        read -p "¿Deseas continuar? (y/N): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            exit 1
        fi
    fi
}

# Función para actualizar el sistema
update_system() {
    print_header "📦 ACTUALIZANDO SISTEMA"
    
    apt update -y
    print_success "Lista de paquetes actualizada"
    
    apt upgrade -y
    print_success "Sistema actualizado"
    
    # Instalar paquetes básicos necesarios
    apt install -y curl wget gnupg2 software-properties-common apt-transport-https ca-certificates lsb-release
    print_success "Paquetes básicos instalados"
}

# Función para instalar Java
install_java() {
    print_header "☕ INSTALANDO JAVA"
    
    if command_exists java; then
        java_version=$(java -version 2>&1 | head -n 1 | cut -d '"' -f 2)
        print_info "Java ya está instalado: $java_version"
        
        # Verificar si es Java 11 o superior
        major_version=$(echo $java_version | cut -d '.' -f 1)
        if [ "$major_version" -ge 11 ]; then
            print_success "Versión de Java compatible"
            return 0
        else
            print_warning "Se requiere Java 11 o superior. Instalando OpenJDK 11..."
        fi
    fi
    
    apt install -y openjdk-11-jdk
    print_success "OpenJDK 11 instalado"
    
    # Configurar JAVA_HOME
    java_home=$(readlink -f /usr/bin/java | sed "s:bin/java::")
    echo "export JAVA_HOME=$java_home" >> /etc/environment
    source /etc/environment
    
    print_info "JAVA_HOME configurado: $java_home"
    
    # Verificar instalación
    java -version
    javac -version
    print_success "Java instalado y configurado correctamente"
}

# Función para instalar Jenkins
install_jenkins() {
    print_header "🔧 INSTALANDO JENKINS"
    
    # Agregar clave GPG de Jenkins
    print_info "Agregando clave GPG de Jenkins..."
    wget -q -O - https://pkg.jenkins.io/debian-stable/jenkins.io.key | apt-key add -
    
    # Agregar repositorio de Jenkins
    print_info "Agregando repositorio de Jenkins..."
    sh -c 'echo deb https://pkg.jenkins.io/debian-stable binary/ > /etc/apt/sources.list.d/jenkins.list'
    
    # Actualizar lista de paquetes
    apt update -y
    
    # Instalar Jenkins
    print_info "Instalando Jenkins..."
    apt install -y jenkins
    
    print_success "Jenkins instalado"
    
    # Habilitar y iniciar Jenkins
    systemctl daemon-reload
    systemctl enable jenkins
    systemctl start jenkins
    
    print_success "Servicio Jenkins habilitado e iniciado"
    
    # Esperar a que Jenkins inicie completamente
    print_info "Esperando a que Jenkins inicie completamente..."
    timeout=60
    counter=0
    
    while [ $counter -lt $timeout ]; do
        if systemctl is-active --quiet jenkins && [ -f /var/lib/jenkins/secrets/initialAdminPassword ]; then
            break
        fi
        sleep 2
        counter=$((counter + 2))
        echo -n "."
    done
    echo
    
    if [ $counter -ge $timeout ]; then
        print_error "Jenkins tardó demasiado en iniciar"
        exit 1
    fi
    
    print_success "Jenkins iniciado correctamente"
}

# Función para instalar herramientas adicionales
install_additional_tools() {
    print_header "🛠️  INSTALANDO HERRAMIENTAS ADICIONALES"
    
    # Git
    if ! command_exists git; then
        apt install -y git
        print_success "Git instalado"
    else
        print_info "Git ya está instalado"
    fi
    
    # Nginx
    if ! command_exists nginx; then
        apt install -y nginx
        systemctl enable nginx
        systemctl start nginx
        print_success "Nginx instalado y configurado"
    else
        print_info "Nginx ya está instalado"
    fi
    
    # Curl y herramientas de red
    apt install -y curl wget net-tools htop tree
    print_success "Herramientas de red instaladas"
    
    # Docker (opcional, comentado por el requerimiento)
    # print_info "¿Deseas instalar Docker? (y/N):"
    # read -r install_docker
    # if [[ $install_docker =~ ^[Yy]$ ]]; then
    #     curl -fsSL https://get.docker.com -o get-docker.sh
    #     sh get-docker.sh
    #     usermod -aG docker jenkins
    #     print_success "Docker instalado"
    # fi
}

# Función para configurar firewall
configure_firewall() {
    print_header "🔥 CONFIGURANDO FIREWALL"
    
    if command_exists ufw; then
        # Habilitar SSH
        ufw allow ssh
        print_success "Puerto SSH habilitado"
        
        # Habilitar Jenkins
        ufw allow $JENKINS_PORT
        print_success "Puerto Jenkins ($JENKINS_PORT) habilitado"
        
        # Habilitar HTTP y HTTPS
        ufw allow 80
        ufw allow 443
        print_success "Puertos HTTP (80) y HTTPS (443) habilitados"
        
        # Activar UFW si no está activo
        if ! ufw status | grep -q "Status: active"; then
            print_warning "UFW no está activo. ¿Deseas activarlo? (y/N):"
            read -r activate_ufw
            if [[ $activate_ufw =~ ^[Yy]$ ]]; then
                ufw --force enable
                print_success "UFW activado"
            fi
        fi
        
        ufw status
    else
        print_warning "UFW no está instalado. Instalando..."
        apt install -y ufw
        configure_firewall
    fi
}

# Función para obtener información de acceso a Jenkins
get_jenkins_info() {
    print_header "🔑 INFORMACIÓN DE ACCESO A JENKINS"
    
    # Obtener IP del servidor
    server_ip=$(hostname -I | awk '{print $1}')
    
    # Obtener contraseña inicial
    initial_password=$(cat /var/lib/jenkins/secrets/initialAdminPassword)
    
    print_info "URL de Jenkins: http://$server_ip:$JENKINS_PORT"
    print_info "Contraseña inicial: $initial_password"
    
    # Crear archivo con información
    cat > /root/jenkins-info.txt << EOF
🚀 INFORMACIÓN DE ACCESO A JENKINS
======================================

URL de acceso: http://$server_ip:$JENKINS_PORT
Contraseña inicial: $initial_password

Usuario sugerido: $JENKINS_USER
Contraseña sugerida: $JENKINS_PASS

Archivos importantes:
- Configuración: /var/lib/jenkins/
- Logs: /var/log/jenkins/jenkins.log
- Servicio: systemctl status jenkins

Comandos útiles:
- Reiniciar Jenkins: sudo systemctl restart jenkins
- Ver logs: sudo tail -f /var/log/jenkins/jenkins.log
- Estado del servicio: sudo systemctl status jenkins

¡Jenkins instalado exitosamente! 🎉
EOF
    
    print_success "Información guardada en /root/jenkins-info.txt"
}

# Función para crear scripts útiles
create_helper_scripts() {
    print_header "📝 CREANDO SCRIPTS DE AYUDA"
    
    # Script para ver logs de Jenkins
    cat > /usr/local/bin/jenkins-logs << 'EOF'
#!/bin/bash
echo "📋 Logs de Jenkins en tiempo real (Ctrl+C para salir):"
echo "======================================================"
sudo tail -f /var/log/jenkins/jenkins.log
EOF
    chmod +x /usr/local/bin/jenkins-logs
    print_success "Script jenkins-logs creado"
    
    # Script para estado de Jenkins
    cat > /usr/local/bin/jenkins-status << 'EOF'
#!/bin/bash
echo "📊 Estado de Jenkins:"
echo "===================="
sudo systemctl status jenkins --no-pager
echo ""
echo "🌐 URLs de acceso:"
server_ip=$(hostname -I | awk '{print $1}')
echo "http://$server_ip:8080"
echo "http://localhost:8080"
EOF
    chmod +x /usr/local/bin/jenkins-status
    print_success "Script jenkins-status creado"
    
    # Script para reiniciar Jenkins
    cat > /usr/local/bin/jenkins-restart << 'EOF'
#!/bin/bash
echo "🔄 Reiniciando Jenkins..."
sudo systemctl restart jenkins
echo "⏳ Esperando que Jenkins inicie..."
sleep 10
sudo systemctl status jenkins --no-pager
echo "✅ Jenkins reiniciado"
EOF
    chmod +x /usr/local/bin/jenkins-restart
    print_success "Script jenkins-restart creado"
}

# Función para verificar instalación
verify_installation() {
    print_header "🧪 VERIFICANDO INSTALACIÓN"
    
    # Verificar Java
    if command_exists java; then
        java_version=$(java -version 2>&1 | head -n 1)
        print_success "Java: $java_version"
    else
        print_error "Java no encontrado"
        return 1
    fi
    
    # Verificar Jenkins
    if systemctl is-active --quiet jenkins; then
        print_success "Jenkins: Servicio activo"
    else
        print_error "Jenkins: Servicio no activo"
        return 1
    fi
    
    # Verificar puerto Jenkins
    if netstat -tlnp | grep -q ":$JENKINS_PORT"; then
        print_success "Jenkins: Puerto $JENKINS_PORT activo"
    else
        print_error "Jenkins: Puerto $JENKINS_PORT no disponible"
        return 1
    fi
    
    # Verificar Nginx
    if systemctl is-active --quiet nginx; then
        print_success "Nginx: Servicio activo"
    else
        print_warning "Nginx: Servicio no activo"
    fi
    
    # Verificar Git
    if command_exists git; then
        git_version=$(git --version)
        print_success "Git: $git_version"
    else
        print_error "Git no encontrado"
    fi
    
    print_success "Verificación completada"
}

# Función para mostrar resumen final
show_final_summary() {
    server_ip=$(hostname -I | awk '{print $1}')
    
    print_header "🎉 INSTALACIÓN COMPLETADA EXITOSAMENTE"
    
    echo -e "${GREEN}"
    cat << EOF
┌─────────────────────────────────────────────────────────────┐
│                    ✅ JENKINS INSTALADO                     │
└─────────────────────────────────────────────────────────────┘

🌐 ACCESO A JENKINS:
   URL: http://$server_ip:$JENKINS_PORT
   URL local: http://localhost:$JENKINS_PORT

🔑 CREDENCIALES INICIALES:
   Contraseña: $(cat /var/lib/jenkins/secrets/initialAdminPassword 2>/dev/null || echo "Ver /var/lib/jenkins/secrets/initialAdminPassword")

👤 USUARIO SUGERIDO:
   Username: $JENKINS_USER
   Password: $JENKINS_PASS

📁 ARCHIVOS IMPORTANTES:
   • Configuración: /var/lib/jenkins/
   • Logs: /var/log/jenkins/jenkins.log
   • Info completa: /root/jenkins-info.txt

⚡ COMANDOS ÚTILES:
   • jenkins-status  : Ver estado de Jenkins
   • jenkins-logs    : Ver logs en tiempo real
   • jenkins-restart : Reiniciar Jenkins

🚀 PRÓXIMOS PASOS:
   1. Accede a Jenkins en tu navegador
   2. Usa la contraseña inicial mostrada arriba
   3. Instala los plugins sugeridos
   4. Crea tu usuario administrador
   5. ¡Comienza a crear pipelines!

EOF
    echo -e "${NC}"
    
    print_success "¡Instalación de Jenkins completada!"
    print_info "Revisa el archivo /root/jenkins-info.txt para más detalles"
}

# Función principal
main() {
    # Verificaciones previas
    check_distro
    
    # Proceso de instalación
    update_system
    install_java
    install_jenkins
    install_additional_tools
    configure_firewall
    create_helper_scripts
    
    # Verificaciones finales
    verify_installation
    get_jenkins_info
    show_final_summary
    
    print_success "🎉 ¡Instalación completada exitosamente!"
    print_info "Jenkins está listo para usar en http://$(hostname -I | awk '{print $1}'):$JENKINS_PORT"
}

# Manejar interrupciones
trap 'print_error "Instalación interrumpida"; exit 1' INT TERM

# Ejecutar función principal
main "$@"
