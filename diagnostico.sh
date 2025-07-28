#!/bin/bash

# 🔧 Script de Diagnóstico de Jenkins
# Para resolver problemas comunes

echo "🔍 DIAGNÓSTICO DE JENKINS"
echo "========================"

# Verificar si Jenkins está instalado
echo ""
echo "📦 Verificando instalación de Jenkins..."
if command -v jenkins &> /dev/null || [ -f /usr/share/jenkins/jenkins.war ]; then
    echo "✅ Jenkins está instalado"
else
    echo "❌ Jenkins no está instalado"
    echo "💡 Ejecuta: sudo ./instalar.sh"
    exit 1
fi

# Verificar Java
echo ""
echo "☕ Verificando Java..."
if command -v java &> /dev/null; then
    java_version=$(java -version 2>&1 | head -1)
    echo "✅ Java disponible: $java_version"
else
    echo "❌ Java no está instalado"
    echo "💡 Instala Java con: sudo apt install -y openjdk-17-jdk"
fi

# Verificar estado del servicio
echo ""
echo "🔧 Verificando servicio Jenkins..."

# Detectar sistema de init
if systemctl --version &>/dev/null && [ -d /run/systemd/system ]; then
    INIT_SYSTEM="systemd"
    echo "Sistema de init: systemd"
else
    INIT_SYSTEM="sysv"
    echo "Sistema de init: SysV (común en Cloud Shell/contenedores)"
fi

if [ "$INIT_SYSTEM" = "systemd" ]; then
    jenkins_status=$(sudo systemctl is-active jenkins 2>/dev/null || echo "inactive")
    echo "Estado del servicio: $jenkins_status"
    
    if [ "$jenkins_status" = "active" ]; then
        echo "✅ Servicio Jenkins está activo"
    else
        echo "⚠️ Servicio Jenkins no está activo"
        echo "🔧 Intentando iniciar..."
        sudo systemctl start jenkins
        sleep 10
    fi
else
    if sudo service jenkins status 2>/dev/null | grep -q "is running\|started\|active"; then
        echo "✅ Servicio Jenkins está activo"
    else
        echo "⚠️ Servicio Jenkins no está activo"
        echo "🔧 Intentando iniciar..."
        sudo service jenkins start
        sleep 10
    fi
fi

# Verificar puerto 8080
echo ""
echo "🌐 Verificando puerto 8080..."
if sudo netstat -tlnp | grep :8080 > /dev/null; then
    process=$(sudo netstat -tlnp | grep :8080 | awk '{print $7}')
    echo "✅ Puerto 8080 está en uso por: $process"
else
    echo "❌ Puerto 8080 no está en uso"
    echo "⚠️ Jenkins puede no estar iniciado correctamente"
fi

# Verificar conectividad HTTP
echo ""
echo "📡 Verificando conectividad HTTP..."
if curl -s --connect-timeout 10 http://localhost:8080 > /dev/null; then
    echo "✅ Jenkins responde en http://localhost:8080"
else
    echo "❌ Jenkins no responde en http://localhost:8080"
fi

# Verificar logs de Jenkins
echo ""
echo "📝 Últimos logs de Jenkins:"
echo "----------------------------"
if [ "$INIT_SYSTEM" = "systemd" ]; then
    sudo journalctl -u jenkins --no-pager -n 10 2>/dev/null || echo "No se pueden leer los logs de systemd"
else
    if [ -f /var/log/jenkins/jenkins.log ]; then
        sudo tail -10 /var/log/jenkins/jenkins.log
    elif [ -f /var/log/jenkins.log ]; then
        sudo tail -10 /var/log/jenkins.log
    else
        echo "No se encontraron logs de Jenkins en ubicaciones comunes"
        echo "💡 Verifica el estado con: sudo service jenkins status"
    fi
fi

# Verificar archivo de contraseña
echo ""
echo "🔑 Verificando contraseña inicial..."
if [ -f /var/lib/jenkins/secrets/initialAdminPassword ]; then
    echo "✅ Archivo de contraseña existe"
    echo "Contraseña: $(sudo cat /var/lib/jenkins/secrets/initialAdminPassword)"
else
    echo "⚠️ Archivo de contraseña no existe"
    echo "Jenkins puede estar iniciando aún..."
fi

# Verificar espacio en disco
echo ""
echo "💽 Verificando espacio en disco..."
disk_usage=$(df -h / | tail -1 | awk '{print $5}' | sed 's/%//')
if [ "$disk_usage" -lt 90 ]; then
    echo "✅ Espacio en disco suficiente: ${disk_usage}% usado"
else
    echo "⚠️ Poco espacio en disco: ${disk_usage}% usado"
fi

# Verificar memoria
echo ""
echo "💾 Verificando memoria..."
mem_available=$(free -m | grep ^Mem | awk '{print $7}')
if [ "$mem_available" -gt 500 ]; then
    echo "✅ Memoria suficiente: ${mem_available}MB disponible"
else
    echo "⚠️ Poca memoria disponible: ${mem_available}MB"
fi

# Comandos de resolución
echo ""
echo "🛠️ COMANDOS ÚTILES PARA RESOLVER PROBLEMAS:"
echo "============================================="
echo ""
if [ "$INIT_SYSTEM" = "systemd" ]; then
    echo "🔄 Reiniciar Jenkins:"
    echo "   sudo systemctl restart jenkins"
    echo ""
    echo "📝 Ver logs en tiempo real:"
    echo "   sudo journalctl -u jenkins -f"
    echo ""
    echo "🔍 Ver estado detallado:"
    echo "   sudo systemctl status jenkins"
else
    echo "🔄 Reiniciar Jenkins:"
    echo "   sudo service jenkins restart"
    echo ""
    echo "📝 Ver logs:"
    echo "   sudo tail -f /var/log/jenkins/jenkins.log"
    echo ""
    echo "🔍 Ver estado detallado:"
    echo "   sudo service jenkins status"
fi
echo ""
echo "🔧 Si Jenkins no inicia, verificar configuración:"
echo "   sudo nano /etc/default/jenkins"
echo ""
echo "💥 Reinstalar Jenkins completamente:"
echo "   sudo apt remove --purge jenkins"
echo "   sudo ./instalar.sh"
echo ""

# URLs específicas para Cloud Shell
if [[ -n "$CLOUD_SHELL" ]] || [[ "$USER" == "roxsross" ]] || [[ -n "$GOOGLE_CLOUD_PROJECT" ]] || [[ -n "$DEVSHELL_PROJECT_ID" ]]; then
    echo "🌐 URLs PARA GOOGLE CLOUD SHELL:"
    echo "================================="
    echo "🔧 Jenkins:"
    echo "   • Método recomendado: Web Preview → Preview on port 8080"
    echo "   • Desde el menú Cloud Shell (⋮) → Web Preview → Preview on port 8080"
    echo ""
    echo "🌐 Tu sitio web:"
    echo "   • Método recomendado: Web Preview → Preview on port 80"
    echo "   • Desde el menú Cloud Shell (⋮) → Web Preview → Preview on port 80"
    echo ""
    echo "💡 Comandos específicos para Cloud Shell:"
    echo "   • ./test-init.sh - Inicialización rápida y URLs"
    echo "   • ./cloud-shell-helper.sh - URLs detalladas"
    echo ""
fi

echo "✅ Diagnóstico completado"
