#!/bin/bash

# 🐳 Script de inicio para Jenkins con Docker Compose
# Optimizado para Google Cloud Shell

echo "🐳 Iniciando Jenkins con Docker Compose"
echo "========================================"
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
if ! command -v docker &> /dev/null; then
    echo "❌ Docker no está instalado"
    if [ "$IS_CLOUD_SHELL" = true ]; then
        echo "💡 En Cloud Shell, Docker debería estar disponible por defecto"
        echo "🔧 Intenta: sudo apt update && sudo apt install -y docker.io docker-compose"
    else
        echo "💡 Instala Docker desde: https://docs.docker.com/get-docker/"
    fi
    exit 1
fi

if ! command -v docker-compose &> /dev/null; then
    echo "❌ Docker Compose no está instalado"
    if [ "$IS_CLOUD_SHELL" = true ]; then
        echo "🔧 Instalando Docker Compose..."
        sudo apt update && sudo apt install -y docker-compose
    else
        echo "💡 Instala Docker Compose desde: https://docs.docker.com/compose/install/"
        exit 1
    fi
fi

echo "✅ Docker está disponible"
docker --version
docker-compose --version

# Verificar que el directorio portafolio-web existe
echo ""
echo "📁 Verificando archivos del portafolio..."
if [ -d "portafolio-web" ]; then
    echo "✅ Directorio portafolio-web encontrado"
    echo "📁 Archivos en portafolio-web:"
    ls -la portafolio-web/ | head -5
else
    echo "⚠️ Directorio portafolio-web no encontrado"
    echo "💡 Creando directorio con contenido de ejemplo..."
    mkdir -p portafolio-web
    
    # Copiar desde site si existe
    if [ -d "site" ]; then
        cp -r site/* portafolio-web/
        echo "✅ Contenido copiado desde directorio 'site'"
    else
        # Crear contenido de ejemplo
        cat > portafolio-web/index.html << 'EOF'
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>🚀 Jenkins DevOps - Docker</title>
    <style>
        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            min-height: 100vh;
            margin: 0;
            display: flex;
            align-items: center;
            justify-content: center;
            color: white;
        }
        .container {
            text-align: center;
            padding: 40px;
            background: rgba(255, 255, 255, 0.1);
            border-radius: 20px;
            backdrop-filter: blur(10px);
            box-shadow: 0 20px 40px rgba(0,0,0,0.2);
        }
        h1 {
            font-size: 3em;
            margin-bottom: 20px;
            text-shadow: 2px 2px 4px rgba(0,0,0,0.3);
        }
        .status {
            background: #4CAF50;
            color: white;
            padding: 15px 30px;
            border-radius: 25px;
            display: inline-block;
            font-weight: bold;
            margin: 20px 0;
        }
    </style>
</head>
<body>
    <div class="container">
        <h1>🐳 Jenkins + Docker</h1>
        <div class="status">✅ Funcionando con Docker Compose</div>
        <p>Tu pipeline Jenkins está desplegando con Docker</p>
        <p style="margin-top: 40px; opacity: 0.7;">
            🚀 Google Cloud Shell + Docker + Jenkins<br>
            Por RoxsRoss DevOps Academy
        </p>
    </div>
</body>
</html>
EOF
        echo "✅ Contenido de ejemplo creado"
    fi
fi

# Detener contenedores existentes si los hay
echo ""
echo "🛑 Deteniendo contenedores existentes..."
docker-compose down 2>/dev/null || echo "No hay contenedores previos"

# Iniciar servicios
echo ""
echo "🚀 Iniciando servicios con Docker Compose..."
docker-compose up -d

# Esperar a que los servicios estén listos
echo ""
echo "⏳ Esperando a que los servicios estén listos..."
sleep 10

# Verificar estado
echo ""
echo "📊 Estado de los contenedores:"
docker-compose ps

# Verificar conectividad
echo ""
echo "🌐 Verificando conectividad..."
if curl -s --connect-timeout 10 http://localhost:8080 >/dev/null 2>&1; then
    echo "✅ Jenkins está respondiendo en puerto 8080"
else
    echo "⚠️ Jenkins puede estar iniciando... espera 1-2 minutos más"
fi

if curl -s --connect-timeout 5 http://localhost:8088 >/dev/null 2>&1; then
    echo "✅ Aplicación está respondiendo en puerto 8088"
else
    echo "⚠️ Aplicación puede estar iniciando..."
fi

# Mostrar contraseña de Jenkins
echo ""
echo "🔑 Obteniendo contraseña inicial de Jenkins..."
sleep 5
JENKINS_PASSWORD=$(docker-compose exec -T jenkins cat /var/jenkins_home/secrets/initialAdminPassword 2>/dev/null || echo "No disponible aún")
if [ "$JENKINS_PASSWORD" != "No disponible aún" ]; then
    echo "Contraseña de Jenkins: $JENKINS_PASSWORD"
else
    echo "⏳ Contraseña no disponible aún. Ejecuta este comando en unos minutos:"
    echo "   docker-compose exec jenkins cat /var/jenkins_home/secrets/initialAdminPassword"
fi

# Información final
echo ""
echo "🎉 ¡Docker Compose iniciado correctamente!"
echo ""
if [ "$IS_CLOUD_SHELL" = true ]; then
    echo "☁️ URLs para Google Cloud Shell:"
    echo "• Jenkins: Web Preview → Preview on port 8080"
    echo "• Tu aplicación: Web Preview → Preview on port 8088"
else
    echo "🌐 URLs locales:"
    echo "• Jenkins: http://localhost:8080"
    echo "• Tu aplicación: http://localhost:8088"
fi

echo ""
echo "🐳 Comandos útiles:"
echo "• Ver logs: docker-compose logs -f"
echo "• Reiniciar: docker-compose restart"
echo "• Detener: docker-compose down"
echo "• Estado: docker-compose ps"

echo ""
echo "🚀 Próximos pasos:"
echo "1. Abre Jenkins y configúralo con la contraseña mostrada"
echo "2. Crea tu pipeline usando el Jenkinsfile incluido"
echo "3. ¡Ejecuta el pipeline y ve tu sitio desplegado!"