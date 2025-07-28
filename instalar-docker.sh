#!/bin/bash

# 🐳 Jenkins con Docker para Google Cloud Shell
# Instalación súper simple sin problemas de permisos

echo "🐳 Instalando Jenkins con Docker para Cloud Shell"
echo "================================================="
echo ""

# Verificar que estamos en Cloud Shell
if [[ -n "$CLOUD_SHELL" ]] || [[ "$USER" == "roxsross" ]] || [[ -n "$GOOGLE_CLOUD_PROJECT" ]] || [[ -n "$DEVSHELL_PROJECT_ID" ]]; then
    echo "☁️ Google Cloud Shell detectado ✅"
    IS_CLOUD_SHELL=true
else
    echo "💻 Sistema local detectado"
    IS_CLOUD_SHELL=false
fi

# Verificar Docker
echo ""
echo "🔍 Verificando Docker..."
if command -v docker &> /dev/null; then
    echo "✅ Docker está instalado"
    
    # Verificar que Docker esté corriendo
    if docker info &> /dev/null; then
        echo "✅ Docker está corriendo"
    else
        echo "🚀 Iniciando Docker..."
        if [ "$IS_CLOUD_SHELL" = true ]; then
            # En Cloud Shell, Docker debería estar disponible
            echo "💡 En Cloud Shell, Docker debería estar disponible automáticamente"
        else
            sudo systemctl start docker 2>/dev/null || sudo service docker start 2>/dev/null || echo "⚠️ No se pudo iniciar Docker automáticamente"
        fi
    fi
else
    echo "❌ Docker no está instalado"
    if [ "$IS_CLOUD_SHELL" = true ]; then
        echo "⚠️ Docker debería estar disponible en Cloud Shell"
        echo "💡 Intenta reiniciar tu sesión de Cloud Shell"
        exit 1
    else
        echo "📥 Instalando Docker..."
        curl -fsSL https://get.docker.com -o get-docker.sh
        sudo sh get-docker.sh
        sudo usermod -aG docker $USER
        echo "✅ Docker instalado. Puede que necesites reiniciar tu sesión"
    fi
fi

# Verificar Docker Compose
echo ""
echo "🔍 Verificando Docker Compose..."
if command -v docker-compose &> /dev/null || docker compose version &> /dev/null; then
    echo "✅ Docker Compose está disponible"
else
    echo "📥 Instalando Docker Compose..."
    if [ "$IS_CLOUD_SHELL" = true ]; then
        # En Cloud Shell, usar la versión plugin
        echo "💡 Usando docker compose (plugin) en Cloud Shell"
    else
        sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
        sudo chmod +x /usr/local/bin/docker-compose
    fi
fi

# Construir y ejecutar Jenkins
echo ""
echo "🏗️ Construyendo imagen de Jenkins..."
docker build -t jenkins-devops . || {
    echo "❌ Error construyendo la imagen"
    echo "💡 Verifica que Docker esté funcionando correctamente"
    exit 1
}

echo ""
echo "🚀 Iniciando Jenkins con Docker..."

# Detener contenedor existente si existe
docker stop jenkins-devops 2>/dev/null || true
docker rm jenkins-devops 2>/dev/null || true

# Iniciar nuevo contenedor
docker run -d \
    --name jenkins-devops \
    -p 8080:8080 \
    -p 80:80 \
    -v jenkins_home:/var/jenkins_home \
    -v "$(pwd)/site:/tmp/site:ro" \
    --restart unless-stopped \
    jenkins-devops

if [ $? -eq 0 ]; then
    echo "✅ Jenkins iniciado correctamente con Docker"
else
    echo "❌ Error iniciando Jenkins"
    exit 1
fi

# Esperar a que Jenkins esté listo
echo ""
echo "⏳ Esperando a que Jenkins esté listo..."
echo "💡 Esto puede tomar 2-3 minutos..."

max_attempts=60
attempt=1

while [ $attempt -le $max_attempts ]; do
    if curl -s http://localhost:8080 > /dev/null 2>&1; then
        echo "✅ Jenkins está listo y respondiendo"
        break
    else
        if [ $((attempt % 10)) -eq 0 ]; then
            echo "⏳ Intento $attempt/$max_attempts - Jenkins iniciando..."
        fi
        sleep 5
        attempt=$((attempt + 1))
    fi
done

if [ $attempt -gt $max_attempts ]; then
    echo "❌ Jenkins no respondió en el tiempo esperado"
    echo "🔍 Verificando logs..."
    docker logs jenkins-devops --tail 20
    exit 1
fi

# Obtener contraseña inicial
echo ""
echo "🔑 Obteniendo contraseña inicial de Jenkins..."
sleep 5  # Dar tiempo para que se genere la contraseña

JENKINS_PASSWORD=$(docker exec jenkins-devops cat /var/jenkins_home/secrets/initialAdminPassword 2>/dev/null)

if [ -n "$JENKINS_PASSWORD" ]; then
    echo "✅ Contraseña obtenida: $JENKINS_PASSWORD"
else
    echo "⏳ Contraseña aún no disponible, espera 1-2 minutos más y ejecuta:"
    echo "   docker exec jenkins-devops cat /var/jenkins_home/secrets/initialAdminPassword"
fi

# Verificar Nginx
echo ""
echo "🌐 Verificando sitio web..."
if curl -s http://localhost > /dev/null 2>&1; then
    echo "✅ Sitio web está funcionando"
else
    echo "⚠️ Sitio web puede tardar en estar disponible"
fi

echo ""
echo "🎉 ¡INSTALACIÓN COMPLETADA CON DOCKER!"
echo ""

if [ "$IS_CLOUD_SHELL" = true ]; then
    echo "☁️ ACCESO EN CLOUD SHELL:"
    echo "========================="
    echo ""
    echo "🔧 Jenkins:"
    echo "   • Web Preview → Preview on port 8080"
    echo "   • Contraseña: $JENKINS_PASSWORD"
    echo ""
    echo "🌐 Tu sitio web:"
    echo "   • Web Preview → Preview on port 80"
    echo ""
else
    echo "🌐 ACCESO LOCAL:"
    echo "==============="
    echo ""
    echo "🔧 Jenkins: http://localhost:8080"
    echo "🌐 Tu sitio: http://localhost"
    echo "🔑 Contraseña: $JENKINS_PASSWORD"
    echo ""
fi

echo "💡 COMANDOS ÚTILES:"
echo "=================="
echo "• docker logs jenkins-devops -f    # Ver logs en tiempo real"
echo "• docker restart jenkins-devops    # Reiniciar Jenkins"
echo "• docker stop jenkins-devops       # Detener Jenkins"
echo "• docker start jenkins-devops      # Iniciar Jenkins"
echo ""
echo "🚀 ¡Ahora crea tu pipeline sin problemas de permisos!"
echo "💡 Usa el archivo 'Jenkinsfile.docker' para tu pipeline"