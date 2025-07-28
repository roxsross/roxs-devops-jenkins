#!/bin/bash

echo "🚀 Iniciando Jenkins con Docker para Cloud Shell"
echo "================================================"

# Iniciar Nginx en background
sudo service nginx start

# Configurar sitio web inicial si no existe
if [ ! -f /var/www/portfolio/index.html ]; then
    echo "🎨 Configurando sitio web inicial..."
    cat > /var/www/portfolio/index.html << 'EOF'
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>🚀 Jenkins DevOps - Sitio Desplegado</title>
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
        p {
            font-size: 1.2em;
            margin-bottom: 30px;
            opacity: 0.9;
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
        .links {
            margin-top: 30px;
        }
        .links a {
            color: #ffd700;
            text-decoration: none;
            margin: 0 15px;
            font-size: 1.1em;
        }
        .links a:hover {
            text-decoration: underline;
        }
    </style>
</head>
<body>
    <div class="container">
        <h1>🎉 ¡Felicitaciones!</h1>
        <p>Tu pipeline de Jenkins está funcionando correctamente</p>
        <div class="status">✅ Sitio Desplegado Exitosamente</div>
        <p>Este sitio se actualizará automáticamente cada vez que ejecutes tu pipeline</p>
        <div class="links">
            <a href="#" onclick="location.reload()">🔄 Recargar</a>
            <a href="javascript:alert('¡Tu pipeline Jenkins está funcionando!')">ℹ️ Info</a>
        </div>
        <p style="margin-top: 40px; opacity: 0.7; font-size: 0.9em;">
            🚀 Creado con Jenkins + Docker en Google Cloud Shell<br>
            Por RoxsRoss DevOps Academy
        </p>
    </div>
</body>
</html>
EOF
    echo "✅ Sitio web inicial configurado"
fi

# Mostrar información útil
echo ""
echo "🌐 URLs de acceso en Cloud Shell:"
echo "• Jenkins: Web Preview → Preview on port 8080"
echo "• Tu sitio: Web Preview → Preview on port 80"
echo ""
echo "🔑 Contraseña de Jenkins se mostrará en los logs..."
echo ""

# Iniciar Jenkins
exec /usr/local/bin/jenkins.sh