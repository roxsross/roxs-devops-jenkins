#!/bin/bash

# 🚀 Script para iniciar solo Jenkins

echo "🚀 Iniciando Jenkins"
echo "==================="
echo ""

# Verificar Docker
if ! command -v docker &> /dev/null; then
    echo "❌ Docker no está instalado"
    exit 1
fi

if ! command -v docker-compose &> /dev/null; then
    echo "❌ Docker Compose no está instalado"
    exit 1
fi

echo "✅ Docker está disponible"

# Verificar que el directorio portafolio-web existe
if [ ! -d "portafolio-web" ]; then
    echo "⚠️ Directorio portafolio-web no encontrado"
    echo "💡 Creando directorio de ejemplo..."
    mkdir -p portafolio-web
    
    cat > portafolio-web/index.html << 'EOF'
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>🚀 Mi Portafolio</title>
    <style>
        body {
            font-family: Arial, sans-serif;
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
        }
    </style>
</head>
<body>
    <div class="container">
        <h1>🚀 Mi Portafolio</h1>
        <p>¡Desplegado con Jenkins!</p>
        <p>Edita los archivos en portafolio-web/ y ejecuta el pipeline</p>
    </div>
</body>
</html>
EOF
    echo "✅ Archivo de ejemplo creado"
fi

# Iniciar Jenkins
echo ""
echo "🚀 Iniciando Jenkins..."
docker-compose up -d

# Esperar a que Jenkins esté listo
echo ""
echo "⏳ Esperando a que Jenkins esté listo..."
sleep 15

# Verificar estado
if curl -s --connect-timeout 10 http://localhost:8080 >/dev/null 2>&1; then
    echo "✅ Jenkins está funcionando"
else
    echo "⚠️ Jenkins puede estar iniciando... espera 1-2 minutos más"
fi

# Mostrar contraseña
echo ""
echo "🔑 Obteniendo contraseña de Jenkins..."
sleep 5
JENKINS_PASSWORD=$(docker-compose exec -T jenkins cat /var/jenkins_home/secrets/initialAdminPassword 2>/dev/null || echo "No disponible aún")

if [ "$JENKINS_PASSWORD" != "No disponible aún" ]; then
    echo "Contraseña de Jenkins: $JENKINS_PASSWORD"
else
    echo "⏳ Contraseña no disponible aún. Ejecuta:"
    echo "   docker-compose exec jenkins cat /var/jenkins_home/secrets/initialAdminPassword"
fi

echo ""
echo "🎉 Jenkins iniciado correctamente"
echo ""
echo "🌐 Acceso:"
echo "• Jenkins: Web Preview → Preview on port 8080"
echo "• Contraseña: $JENKINS_PASSWORD"
echo ""
echo "🚀 Próximos pasos:"
echo "1. Configura Jenkins con la contraseña"
echo "2. Crea un pipeline que use este repositorio"
echo "3. El pipeline desplegará tu portafolio automáticamente"