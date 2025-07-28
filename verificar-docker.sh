#!/bin/bash

# 🐳 Verificación de Jenkins con Docker

echo "🐳 Verificación de Jenkins con Docker"
echo "====================================="
echo ""

# Verificar que estamos en Cloud Shell
if [[ -n "$CLOUD_SHELL" ]] || [[ "$USER" == "roxsross" ]] || [[ -n "$GOOGLE_CLOUD_PROJECT" ]]; then
    echo "☁️ Google Cloud Shell detectado"
    IS_CLOUD_SHELL=true
else
    echo "💻 Sistema local detectado"
    IS_CLOUD_SHELL=false
fi

echo ""

# 1. Verificar Docker
echo "1️⃣ Verificando Docker..."
if command -v docker &> /dev/null; then
    echo "✅ Docker está instalado"
    
    if docker info &> /dev/null; then
        echo "✅ Docker está corriendo"
    else
        echo "❌ Docker no está corriendo"
        echo "💡 Intenta: sudo systemctl start docker"
    fi
else
    echo "❌ Docker no está instalado"
    echo "💡 Ejecuta: ./instalar-docker.sh"
fi

# 2. Verificar contenedor Jenkins
echo ""
echo "2️⃣ Verificando contenedor Jenkins..."
if docker ps | grep -q jenkins-devops; then
    echo "✅ Contenedor Jenkins está corriendo"
    
    # Mostrar información del contenedor
    echo "📊 Estado del contenedor:"
    docker ps --filter name=jenkins-devops --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"
else
    echo "❌ Contenedor Jenkins no está corriendo"
    
    # Verificar si existe pero está parado
    if docker ps -a | grep -q jenkins-devops; then
        echo "💡 Contenedor existe pero está parado. Iniciando..."
        docker start jenkins-devops
        sleep 10
    else
        echo "💡 Contenedor no existe. Ejecuta: ./instalar-docker.sh"
    fi
fi

# 3. Verificar conectividad
echo ""
echo "3️⃣ Verificando conectividad..."

# Jenkins
if curl -s --connect-timeout 10 http://localhost:8080 > /dev/null 2>&1; then
    echo "✅ Jenkins responde en puerto 8080"
else
    echo "❌ Jenkins no responde en puerto 8080"
    echo "💡 Puede estar iniciando... espera 2-3 minutos"
fi

# Sitio web
if curl -s --connect-timeout 5 http://localhost > /dev/null 2>&1; then
    echo "✅ Sitio web responde en puerto 80"
else
    echo "❌ Sitio web no responde en puerto 80"
fi

# 4. Verificar contraseña
echo ""
echo "4️⃣ Verificando contraseña de Jenkins..."
if docker ps | grep -q jenkins-devops; then
    JENKINS_PASSWORD=$(docker exec jenkins-devops cat /var/jenkins_home/secrets/initialAdminPassword 2>/dev/null)
    if [ -n "$JENKINS_PASSWORD" ]; then
        echo "✅ Contraseña disponible: $JENKINS_PASSWORD"
    else
        echo "⚠️ Contraseña aún no disponible"
        echo "💡 Jenkins puede estar iniciando... espera 2-3 minutos"
    fi
else
    echo "❌ No se puede obtener contraseña - contenedor no está corriendo"
fi

# 5. Verificar logs recientes
echo ""
echo "5️⃣ Logs recientes de Jenkins:"
echo "=============================="
if docker ps | grep -q jenkins-devops; then
    docker logs jenkins-devops --tail 10 2>/dev/null || echo "No se pueden obtener logs"
else
    echo "❌ Contenedor no está corriendo"
fi

# Resumen y URLs
echo ""
echo "📊 RESUMEN:"
echo "==========="

docker_ok=false
jenkins_ok=false
web_ok=false

if command -v docker &> /dev/null && docker info &> /dev/null; then
    docker_ok=true
fi

if curl -s --connect-timeout 5 http://localhost:8080 > /dev/null 2>&1; then
    jenkins_ok=true
fi

if curl -s --connect-timeout 5 http://localhost > /dev/null 2>&1; then
    web_ok=true
fi

if [ "$docker_ok" = true ] && [ "$jenkins_ok" = true ] && [ "$web_ok" = true ]; then
    echo "🎉 ¡Todo está funcionando perfectamente!"
    echo ""
    if [ "$IS_CLOUD_SHELL" = true ]; then
        echo "☁️ URLs para Cloud Shell:"
        echo "• Jenkins: Web Preview → Preview on port 8080"
        echo "• Tu sitio: Web Preview → Preview on port 80"
    else
        echo "🌐 URLs locales:"
        echo "• Jenkins: http://localhost:8080"
        echo "• Tu sitio: http://localhost"
    fi
    echo ""
    echo "🚀 ¡Listo para crear pipelines!"
else
    echo "⚠️ Algunos servicios necesitan atención:"
    
    if [ "$docker_ok" = false ]; then
        echo "• Docker no está funcionando"
    fi
    
    if [ "$jenkins_ok" = false ]; then
        echo "• Jenkins no está respondiendo"
    fi
    
    if [ "$web_ok" = false ]; then
        echo "• Sitio web no está respondiendo"
    fi
    
    echo ""
    echo "🔧 Para solucionar: ./instalar-docker.sh"
fi

echo ""
echo "💡 COMANDOS ÚTILES:"
echo "=================="
echo "• docker logs jenkins-devops -f    # Ver logs en tiempo real"
echo "• docker restart jenkins-devops    # Reiniciar Jenkins"
echo "• docker exec -it jenkins-devops bash  # Acceder al contenedor"
echo "• ./instalar-docker.sh             # Reinstalar si hay problemas"