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
sudo journalctl -u jenkins --no-pager -n 10 2>/dev/null || echo "No se pueden leer los logs"

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
echo "🔄 Reiniciar Jenkins:"
echo "   sudo systemctl restart jenkins"
echo ""
echo "📝 Ver logs en tiempo real:"
echo "   sudo journalctl -u jenkins -f"
echo ""
echo "🔍 Ver estado detallado:"
echo "   sudo systemctl status jenkins"
echo ""
echo "🔧 Si Jenkins no inicia, verificar configuración:"
echo "   sudo nano /etc/default/jenkins"
echo ""
echo "💥 Reinstalar Jenkins completamente:"
echo "   sudo apt remove --purge jenkins"
echo "   sudo ./instalar.sh"
echo ""

# URLs específicas para Cloud Shell
if [[ -n "$CLOUD_SHELL" ]]; then
    echo "🌐 URLs PARA GOOGLE CLOUD SHELL:"
    echo "================================="
    EXTERNAL_IP=$(curl -s ifconfig.me 2>/dev/null || echo "unknown")
    SAFE_IP=$(echo $EXTERNAL_IP | tr '.' '-')
    echo "Jenkins: https://8080-${SAFE_IP}-8080.googleusercontent.com"
    echo "O usa: Web Preview → Preview on port 8080"
    echo ""
fi

echo "✅ Diagnóstico completado"
