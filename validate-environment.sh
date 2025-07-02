#!/bin/bash

# 🧪 Script de Validación para la Práctica de Jenkins
# Verifica que toda la configuración esté correcta antes de comenzar
# Autor: RoxsRoss DevOps Community

set -e

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m'

# Contadores
TOTAL_TESTS=0
PASSED_TESTS=0
FAILED_TESTS=0
WARNING_TESTS=0

print_header() {
    echo -e "\n${PURPLE}=================================================="
    echo -e "$1"
    echo -e "==================================================${NC}\n"
}

print_test() {
    TOTAL_TESTS=$((TOTAL_TESTS + 1))
    echo -e "${BLUE}🧪 Test $TOTAL_TESTS: $1${NC}"
}

print_success() {
    PASSED_TESTS=$((PASSED_TESTS + 1))
    echo -e "${GREEN}✅ $1${NC}"
}

print_failure() {
    FAILED_TESTS=$((FAILED_TESTS + 1))
    echo -e "${RED}❌ $1${NC}"
}

print_warning() {
    WARNING_TESTS=$((WARNING_TESTS + 1))
    echo -e "${YELLOW}⚠️  $1${NC}"
}

print_info() {
    echo -e "${CYAN}ℹ️  $1${NC}"
}

# Función para verificar si un comando existe
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Función para verificar si un puerto está abierto
port_open() {
    nc -z localhost "$1" 2>/dev/null
}

# Función para verificar HTTP response
check_http() {
    local url="$1"
    local expected_code="${2:-200}"
    local response
    response=$(curl -s -o /dev/null -w "%{http_code}" "$url" 2>/dev/null || echo "000")
    
    if [ "$response" = "$expected_code" ]; then
        return 0
    else
        return 1
    fi
}

print_header "🧪 VALIDACIÓN DEL ENTORNO JENKINS CI/CD"

# Test 1: Verificar sistema operativo
print_test "Verificando sistema operativo"
if [ -f /etc/os-release ]; then
    . /etc/os-release
    if [[ "$ID" =~ ^(ubuntu|debian)$ ]]; then
        print_success "Sistema soportado: $PRETTY_NAME"
    else
        print_warning "Sistema no oficialmente soportado: $PRETTY_NAME"
    fi
else
    print_failure "No se pudo determinar el sistema operativo"
fi

# Test 2: Verificar permisos de usuario
print_test "Verificando permisos de usuario"
if [[ $EUID -eq 0 ]]; then
    print_success "Ejecutando como root"
elif sudo -n true 2>/dev/null; then
    print_success "Usuario tiene permisos sudo"
else
    print_failure "Se requieren permisos sudo para continuar"
fi

# Test 3: Verificar conectividad a internet
print_test "Verificando conectividad a internet"
if ping -c 1 google.com >/dev/null 2>&1; then
    print_success "Conectividad a internet disponible"
else
    print_failure "Sin conectividad a internet"
fi

# Test 4: Verificar espacio en disco
print_test "Verificando espacio en disco"
disk_usage=$(df / | awk 'NR==2 {print $5}' | sed 's/%//')
if [ "$disk_usage" -lt 80 ]; then
    print_success "Espacio en disco suficiente (${disk_usage}% usado)"
elif [ "$disk_usage" -lt 90 ]; then
    print_warning "Espacio en disco limitado (${disk_usage}% usado)"
else
    print_failure "Espacio en disco insuficiente (${disk_usage}% usado)"
fi

# Test 5: Verificar memoria RAM
print_test "Verificando memoria RAM"
total_mem=$(free -m | awk 'NR==2{print $2}')
if [ "$total_mem" -gt 2048 ]; then
    print_success "Memoria RAM suficiente (${total_mem}MB)"
elif [ "$total_mem" -gt 1024 ]; then
    print_warning "Memoria RAM limitada (${total_mem}MB) - recomendado 2GB+"
else
    print_failure "Memoria RAM insuficiente (${total_mem}MB) - mínimo 1GB"
fi

print_header "☕ VERIFICACIÓN DE JAVA"

# Test 6: Verificar Java
print_test "Verificando instalación de Java"
if command_exists java; then
    java_version=$(java -version 2>&1 | head -n 1 | cut -d '"' -f 2)
    major_version=$(echo "$java_version" | cut -d '.' -f 1)
    
    if [ "$major_version" -ge 11 ]; then
        print_success "Java instalado: $java_version"
    else
        print_failure "Versión de Java no soportada: $java_version (se requiere Java 11+)"
    fi
else
    print_failure "Java no está instalado"
    print_info "Ejecutar: sudo apt install openjdk-11-jdk"
fi

# Test 7: Verificar JAVA_HOME
print_test "Verificando JAVA_HOME"
if [ -n "$JAVA_HOME" ] && [ -d "$JAVA_HOME" ]; then
    print_success "JAVA_HOME configurado: $JAVA_HOME"
else
    print_warning "JAVA_HOME no configurado (se puede configurar automáticamente)"
fi

print_header "🔧 VERIFICACIÓN DE JENKINS"

# Test 8: Verificar instalación de Jenkins
print_test "Verificando instalación de Jenkins"
if command_exists jenkins; then
    print_success "Jenkins está instalado"
elif [ -f /etc/init.d/jenkins ] || [ -f /lib/systemd/system/jenkins.service ]; then
    print_success "Jenkins está instalado (servicio detectado)"
else
    print_failure "Jenkins no está instalado"
    print_info "Ejecutar: sudo ./install-jenkins.sh"
fi

# Test 9: Verificar servicio Jenkins
print_test "Verificando servicio Jenkins"
if systemctl is-active --quiet jenkins 2>/dev/null; then
    print_success "Servicio Jenkins está corriendo"
elif systemctl is-enabled --quiet jenkins 2>/dev/null; then
    print_warning "Servicio Jenkins configurado pero no corriendo"
    print_info "Ejecutar: sudo systemctl start jenkins"
else
    print_failure "Servicio Jenkins no configurado"
fi

# Test 10: Verificar puerto Jenkins
print_test "Verificando puerto Jenkins (8080)"
if port_open 8080; then
    print_success "Puerto 8080 está abierto"
else
    print_failure "Puerto 8080 no está disponible"
    print_info "Verificar firewall y estado del servicio"
fi

# Test 11: Verificar acceso web a Jenkins
print_test "Verificando acceso web a Jenkins"
if check_http "http://localhost:8080"; then
    print_success "Jenkins web UI accesible"
elif check_http "http://localhost:8080" 403; then
    print_warning "Jenkins web UI responde pero puede requerir configuración"
else
    print_failure "Jenkins web UI no accesible"
fi

# Test 12: Verificar archivo de contraseña inicial
print_test "Verificando contraseña inicial de Jenkins"
if [ -f /var/lib/jenkins/secrets/initialAdminPassword ]; then
    print_success "Archivo de contraseña inicial encontrado"
    initial_pass=$(sudo cat /var/lib/jenkins/secrets/initialAdminPassword 2>/dev/null || echo "No acceso")
    print_info "Contraseña inicial: $initial_pass"
else
    print_warning "Archivo de contraseña inicial no encontrado"
    print_info "Jenkins puede estar ya configurado o no inicializado"
fi

print_header "🌐 VERIFICACIÓN DE NGINX"

# Test 13: Verificar instalación de Nginx
print_test "Verificando instalación de Nginx"
if command_exists nginx; then
    nginx_version=$(nginx -v 2>&1 | cut -d '/' -f 2)
    print_success "Nginx instalado: $nginx_version"
else
    print_failure "Nginx no está instalado"
    print_info "Ejecutar: sudo apt install nginx"
fi

# Test 14: Verificar servicio Nginx
print_test "Verificando servicio Nginx"
if systemctl is-active --quiet nginx 2>/dev/null; then
    print_success "Servicio Nginx está corriendo"
else
    print_failure "Servicio Nginx no está corriendo"
    print_info "Ejecutar: sudo systemctl start nginx"
fi

# Test 15: Verificar puerto HTTP
print_test "Verificando puerto HTTP (80)"
if port_open 80; then
    print_success "Puerto 80 está abierto"
else
    print_failure "Puerto 80 no está disponible"
fi

# Test 16: Verificar acceso web
print_test "Verificando acceso web básico"
if check_http "http://localhost"; then
    print_success "Servidor web responde correctamente"
else
    print_failure "Servidor web no responde"
fi

print_header "📁 VERIFICACIÓN DE DIRECTORIOS"

# Test 17: Verificar directorio del portafolio
print_test "Verificando directorio del portafolio"
if [ -d "/var/www/portfolio" ]; then
    print_success "Directorio /var/www/portfolio existe"
    
    # Verificar permisos
    owner=$(stat -c '%U:%G' /var/www/portfolio 2>/dev/null || echo "unknown")
    perms=$(stat -c '%a' /var/www/portfolio 2>/dev/null || echo "unknown")
    print_info "Propietario: $owner, Permisos: $perms"
else
    print_warning "Directorio /var/www/portfolio no existe"
    print_info "Se creará automáticamente durante el setup"
fi

# Test 18: Verificar directorio de Jenkins
print_test "Verificando directorio de Jenkins"
if [ -d "/var/lib/jenkins" ]; then
    print_success "Directorio /var/lib/jenkins existe"
    
    jenkins_size=$(sudo du -sh /var/lib/jenkins 2>/dev/null | cut -f1 || echo "unknown")
    print_info "Tamaño del directorio Jenkins: $jenkins_size"
else
    print_failure "Directorio /var/lib/jenkins no existe"
fi

print_header "🔐 VERIFICACIÓN DE PERMISOS"

# Test 19: Verificar usuario Jenkins
print_test "Verificando usuario Jenkins"
if id jenkins >/dev/null 2>&1; then
    print_success "Usuario jenkins existe"
    
    # Verificar grupos
    jenkins_groups=$(groups jenkins 2>/dev/null || echo "unknown")
    print_info "Grupos: $jenkins_groups"
else
    print_failure "Usuario jenkins no existe"
fi

# Test 20: Verificar configuración sudo
print_test "Verificando configuración sudo para Jenkins"
if [ -f /etc/sudoers.d/jenkins ]; then
    print_success "Configuración sudo para Jenkins encontrada"
else
    print_warning "Configuración sudo para Jenkins no encontrada"
    print_info "Se configurará durante el setup del entorno"
fi

print_header "🛠️ VERIFICACIÓN DE HERRAMIENTAS"

# Test 21: Verificar Git
print_test "Verificando Git"
if command_exists git; then
    git_version=$(git --version | cut -d ' ' -f 3)
    print_success "Git instalado: $git_version"
else
    print_failure "Git no está instalado"
    print_info "Ejecutar: sudo apt install git"
fi

# Test 22: Verificar Curl
print_test "Verificando Curl"
if command_exists curl; then
    print_success "Curl disponible"
else
    print_failure "Curl no está instalado"
    print_info "Ejecutar: sudo apt install curl"
fi

# Test 23: Verificar herramientas de red
print_test "Verificando herramientas de red"
missing_tools=""
for tool in netstat ss nc; do
    if ! command_exists "$tool"; then
        missing_tools="$missing_tools $tool"
    fi
done

if [ -z "$missing_tools" ]; then
    print_success "Todas las herramientas de red están disponibles"
else
    print_warning "Herramientas faltantes:$missing_tools"
    print_info "Ejecutar: sudo apt install net-tools netcat-openbsd"
fi

print_header "🔥 VERIFICACIÓN DE FIREWALL"

# Test 24: Verificar UFW
print_test "Verificando configuración de firewall"
if command_exists ufw; then
    ufw_status=$(sudo ufw status 2>/dev/null | head -1 | cut -d ' ' -f 2)
    
    if [ "$ufw_status" = "active" ]; then
        print_success "UFW está activo"
        
        # Verificar reglas importantes
        if sudo ufw status | grep -q "8080"; then
            print_success "Puerto 8080 (Jenkins) permitido en firewall"
        else
            print_warning "Puerto 8080 no permitido en firewall"
            print_info "Ejecutar: sudo ufw allow 8080"
        fi
        
        if sudo ufw status | grep -q "80"; then
            print_success "Puerto 80 (HTTP) permitido en firewall"
        else
            print_warning "Puerto 80 no permitido en firewall"
            print_info "Ejecutar: sudo ufw allow 80"
        fi
    else
        print_warning "UFW está inactivo"
        print_info "El firewall se puede configurar opcionalmente"
    fi
else
    print_warning "UFW no está instalado"
    print_info "Ejecutar: sudo apt install ufw"
fi

print_header "📊 RESUMEN DE VALIDACIÓN"

# Calcular porcentaje de éxito
if [ $TOTAL_TESTS -gt 0 ]; then
    success_percentage=$(( (PASSED_TESTS * 100) / TOTAL_TESTS ))
else
    success_percentage=0
fi

echo -e "${BLUE}📊 Estadísticas de las pruebas:${NC}"
echo -e "   Total de pruebas: $TOTAL_TESTS"
echo -e "   ${GREEN}Exitosas: $PASSED_TESTS${NC}"
echo -e "   ${RED}Fallidas: $FAILED_TESTS${NC}"
echo -e "   ${YELLOW}Advertencias: $WARNING_TESTS${NC}"
echo -e "   Porcentaje de éxito: $success_percentage%"

echo ""

# Determinar estado general
if [ $FAILED_TESTS -eq 0 ] && [ $WARNING_TESTS -le 3 ]; then
    echo -e "${GREEN}🎉 ¡EXCELENTE! El sistema está listo para la práctica de Jenkins${NC}"
    echo -e "${GREEN}✅ Puedes proceder con confianza${NC}"
    exit_code=0
elif [ $FAILED_TESTS -le 2 ] && [ $WARNING_TESTS -le 5 ]; then
    echo -e "${YELLOW}⚠️  BUENO: El sistema está mayormente listo${NC}"
    echo -e "${YELLOW}🔧 Resuelve las advertencias antes de continuar${NC}"
    exit_code=1
else
    echo -e "${RED}❌ PROBLEMAS DETECTADOS: Se requiere configuración adicional${NC}"
    echo -e "${RED}🛠️  Resuelve los errores críticos antes de continuar${NC}"
    exit_code=2
fi

echo ""
print_header "🚀 PRÓXIMOS PASOS"

if [ $exit_code -eq 0 ]; then
    echo -e "${GREEN}1. ✅ Iniciar la práctica siguiendo GUIA-PASO-A-PASO.md${NC}"
    echo -e "${GREEN}2. ✅ Ejecutar install-jenkins.sh si Jenkins no está instalado${NC}"
    echo -e "${GREEN}3. ✅ Ejecutar setup-environment.sh para configurar el entorno${NC}"
elif [ $exit_code -eq 1 ]; then
    echo -e "${YELLOW}1. 🔧 Revisar y resolver advertencias mostradas arriba${NC}"
    echo -e "${YELLOW}2. 🔧 Ejecutar install-jenkins.sh si es necesario${NC}"
    echo -e "${YELLOW}3. 🔧 Volver a ejecutar este script de validación${NC}"
else
    echo -e "${RED}1. 🛠️  Revisar y resolver errores críticos${NC}"
    echo -e "${RED}2. 🛠️  Consultar TROUBLESHOOTING.md para soluciones${NC}"
    echo -e "${RED}3. 🛠️  Volver a ejecutar este script después de las correcciones${NC}"
fi

echo ""
echo -e "${CYAN}📚 Recursos útiles:${NC}"
echo -e "   • GUIA-PASO-A-PASO.md - Tutorial completo"
echo -e "   • TROUBLESHOOTING.md - Solución de problemas"
echo -e "   • COMANDOS-UTILES.md - Comandos de referencia"
echo -e "   • ./install-jenkins.sh - Instalación automatizada"
echo -e "   • ./setup-environment.sh - Configuración del entorno"

echo ""
echo -e "${PURPLE}🎯 ¡Buena suerte con tu práctica de Jenkins CI/CD!${NC}"

exit $exit_code
