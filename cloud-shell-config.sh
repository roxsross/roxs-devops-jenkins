#!/bin/bash

# 🚀 Configuración específica para Google Cloud Shell
# Este archivo contiene variables y funciones optimizadas para Cloud Shell

# Variables de entorno específicas para Cloud Shell
export CLOUD_SHELL_JENKINS=true
export JENKINS_TIMEOUT=300
export NGINX_TIMEOUT=60
export JENKINS_MEMORY="-Xmx512m"

# Función para detectar Cloud Shell
is_cloud_shell() {
    if [[ -n "$CLOUD_SHELL" ]] || [[ "$USER" == "roxsross" ]] || [[ -n "$GOOGLE_CLOUD_PROJECT" ]] || [[ -n "$DEVSHELL_PROJECT_ID" ]] || [[ "$HOSTNAME" == *"cloudshell"* ]]; then
        return 0  # true
    else
        return 1  # false
    fi
}

# Función para obtener URLs de Cloud Shell
get_cloud_shell_urls() {
    echo "🌐 URLs para Google Cloud Shell:"
    echo "================================="
    echo ""
    echo "🔧 Jenkins (Administración):"
    echo "   • Web Preview → Preview on port 8080"
    echo "   • Desde el menú Cloud Shell (⋮) → Web Preview → Preview on port 8080"
    echo ""
    echo "🌐 Tu sitio web (Gaming Hub):"
    echo "   • Web Preview → Preview on port 80"
    echo "   • Desde el menú Cloud Shell (⋮) → Web Preview → Preview on port 80"
    echo ""
    
    # Intentar obtener URLs directas si es posible
    if [[ -n "$WEB_HOST" ]]; then
        echo "📱 URLs directas:"
        echo "   • Jenkins: https://${WEB_HOST}/proxy/8080/"
        echo "   • Tu sitio: https://${WEB_HOST}/proxy/80/"
    fi
}

# Función para mostrar comandos específicos de Cloud Shell
show_cloud_shell_commands() {
    echo "💡 Comandos específicos para Cloud Shell:"
    echo "=========================================="
    echo ""
    echo "🚀 Inicialización y estado:"
    echo "   ./test-init.sh           # Inicialización rápida y URLs"
    echo "   ./cloud-shell-helper.sh  # URLs detalladas y configuración"
    echo "   ./verificar.sh           # Verificación completa del sistema"
    echo ""
    echo "🔧 Diagnóstico y solución de problemas:"
    echo "   ./diagnostico.sh         # Diagnóstico detallado"
    echo "   sudo ./arreglar-permisos.sh  # Arreglar permisos de Jenkins"
    echo ""
    echo "🌐 Acceso rápido:"
    echo "   • Jenkins: Web Preview → Preview on port 8080"
    echo "   • Tu sitio: Web Preview → Preview on port 80"
}

# Función para configurar optimizaciones específicas de Cloud Shell
configure_cloud_shell_optimizations() {
    if is_cloud_shell; then
        echo "☁️ Aplicando optimizaciones para Cloud Shell..."
        
        # Configurar timeouts más largos
        export JENKINS_STARTUP_TIMEOUT=300
        export NGINX_STARTUP_TIMEOUT=60
        
        # Configurar memoria de Jenkins para Cloud Shell
        if [ -f /etc/default/jenkins ]; then
            if ! grep -q "JAVA_ARGS.*Xmx512m" /etc/default/jenkins; then
                echo "🔧 Configurando memoria de Jenkins para Cloud Shell..."
                sudo sed -i 's/JAVA_ARGS=.*/JAVA_ARGS="-Xmx512m -Djava.awt.headless=true"/' /etc/default/jenkins 2>/dev/null || true
            fi
        fi
        
        echo "✅ Optimizaciones aplicadas"
    fi
}

# Función para verificar estado específico de Cloud Shell
check_cloud_shell_status() {
    if is_cloud_shell; then
        echo "☁️ Verificación específica para Cloud Shell:"
        echo "============================================="
        
        # Verificar variables de entorno de Cloud Shell
        echo "🔍 Variables de entorno:"
        [[ -n "$CLOUD_SHELL" ]] && echo "   ✅ CLOUD_SHELL: $CLOUD_SHELL"
        [[ -n "$GOOGLE_CLOUD_PROJECT" ]] && echo "   ✅ GOOGLE_CLOUD_PROJECT: $GOOGLE_CLOUD_PROJECT"
        [[ -n "$DEVSHELL_PROJECT_ID" ]] && echo "   ✅ DEVSHELL_PROJECT_ID: $DEVSHELL_PROJECT_ID"
        
        # Verificar conectividad específica
        echo ""
        echo "🌐 Verificando conectividad:"
        if curl -s --connect-timeout 5 metadata.google.internal >/dev/null 2>&1; then
            echo "   ✅ Conectividad a metadata de Google Cloud"
        else
            echo "   ⚠️ No se puede acceder a metadata de Google Cloud"
        fi
        
        # Verificar espacio en disco (importante en Cloud Shell)
        echo ""
        echo "💽 Espacio en disco:"
        df -h $HOME | tail -1 | awk '{print "   📁 Home: " $3 " usado de " $2 " (" $5 " usado)"}'
        df -h / | tail -1 | awk '{print "   📁 Root: " $3 " usado de " $2 " (" $5 " usado)"}'
    fi
}

# Función para mostrar tips específicos de Cloud Shell
show_cloud_shell_tips() {
    if is_cloud_shell; then
        echo ""
        echo "💡 TIPS ESPECÍFICOS PARA CLOUD SHELL:"
        echo "====================================="
        echo ""
        echo "🚀 Rendimiento:"
        echo "   • Jenkins puede tomar 5-7 minutos en estar completamente operativo"
        echo "   • Usa './test-init.sh' para verificar el estado periódicamente"
        echo "   • Si Jenkins no responde, espera unos minutos más"
        echo ""
        echo "🌐 Acceso:"
        echo "   • Siempre usa 'Web Preview' desde el menú de Cloud Shell"
        echo "   • Las URLs directas pueden cambiar al reiniciar la sesión"
        echo "   • Guarda las URLs mostradas por './cloud-shell-helper.sh'"
        echo ""
        echo "🔧 Solución de problemas:"
        echo "   • Si algo no funciona, ejecuta './diagnostico.sh'"
        echo "   • Para permisos: 'sudo ./arreglar-permisos.sh'"
        echo "   • Para reiniciar todo: 'sudo service jenkins restart && sudo service nginx restart'"
        echo ""
        echo "💾 Persistencia:"
        echo "   • Los archivos en $HOME persisten entre sesiones"
        echo "   • Jenkins y configuraciones se mantienen"
        echo "   • Tu sitio web se mantiene desplegado"
    fi
}

# Exportar funciones para uso en otros scripts
export -f is_cloud_shell
export -f get_cloud_shell_urls
export -f show_cloud_shell_commands
export -f configure_cloud_shell_optimizations
export -f check_cloud_shell_status
export -f show_cloud_shell_tips