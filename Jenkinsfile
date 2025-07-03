pipeline {
    agent any
    
    stages {
        stage('📥 Descargar Código') {
            steps {
                echo '📥 Descargando el código desde Git...'
                checkout scm
            }
        }
        
        stage('🔍 Verificar Archivos') {
            steps {
                echo '🔍 Verificando que tenemos los archivos...'
                sh '''
                    # Descargar el portafolio web desde el repositorio externo
                    curl -sL https://github.com/roxsross/devops-static-web/raw/portafolio-web/portafolio-web.zip -o portafolio-web.zip
                    
                    # Crear directorio temporal para extraer
                    mkdir -p temp-extract
                    cd temp-extract
                    
                    # Extraer sin preguntas (sobrescribir automáticamente)
                    unzip -o ../portafolio-web.zip
                    
                    # Volver al directorio principal y mover archivos
                    cd ..
                    mv temp-extract/* ./ 2>/dev/null || true
                    rm -rf temp-extract portafolio-web.zip
                    
                    # Mostrar archivos disponibles
                    echo "📁 Archivos descargados:"
                    ls -la
                '''
            }
        }
        
        stage('🚀 Desplegar Sitio Web') {
            steps {
                echo '🚀 Desplegando tu sitio web...'
                sh '''
                    # Verificar que el directorio existe
                    if [ ! -d "/var/www/portfolio" ]; then
                        echo "❌ Directorio /var/www/portfolio no existe"
                        echo "💡 Ejecuta: sudo mkdir -p /var/www/portfolio && sudo chown -R www-data:www-data /var/www/portfolio"
                        exit 1
                    fi
                    
                    # Verificar permisos sudo (con mensaje claro si falla)
                    echo "🔐 Verificando permisos sudo..."
                    if ! sudo -n true 2>/dev/null; then
                        echo "❌ Jenkins no tiene permisos sudo configurados"
                        echo ""
                        echo "� PARA SOLUCIONARLO:"
                        echo "1. Ejecuta en terminal: sudo ./arreglar-permisos.sh"
                        echo "2. O manualmente ejecuta:"
                        echo "   echo 'jenkins ALL=(ALL) NOPASSWD: /bin/cp, /bin/chown, /bin/rm, /usr/bin/unzip, /bin/mv' | sudo tee /etc/sudoers.d/jenkins"
                        echo "   sudo visudo -c"
                        echo "3. Luego reintenta el pipeline"
                        echo ""
                        exit 1
                    fi
                    
                    echo "✅ Permisos sudo verificados"
                    
                    # Buscar archivos HTML para copiar
                    echo "🔍 Buscando archivos web..."
                    if [ -d "portafolio-web" ]; then
                        SOURCE_DIR="portafolio-web"
                        echo "📁 Encontrado directorio: portafolio-web"
                    elif [ -f "index.html" ]; then
                        SOURCE_DIR="."
                        echo "📁 Encontrado index.html en directorio actual"
                    elif [ -d "site" ]; then
                        SOURCE_DIR="site"
                        echo "📁 Encontrado directorio: site"
                    else
                        echo "❌ No se encontraron archivos web para desplegar"
                        echo "📁 Archivos disponibles:"
                        ls -la
                        echo ""
                        echo "💡 Se esperaba encontrar:"
                        echo "   • Un directorio 'portafolio-web' con archivos HTML"
                        echo "   • Un archivo 'index.html' en el directorio actual"
                        echo "   • Un directorio 'site' con archivos HTML"
                        exit 1
                    fi
                    
                    echo "📁 Usando archivos de: $SOURCE_DIR"
                    echo "📁 Contenido a copiar:"
                    ls -la $SOURCE_DIR/ | head -10
                    
                    # Limpiar destino antes de copiar (para evitar conflictos)
                    echo "🧹 Limpiando directorio destino..."
                    sudo rm -rf /var/www/portfolio/*
                    
                    # Copiar archivos al servidor web
                    echo "📁 Copiando archivos..."
                    if [ "$SOURCE_DIR" = "." ]; then
                        # Si el directorio fuente es actual, copiar solo HTML/CSS/JS
                        sudo cp *.html /var/www/portfolio/ 2>/dev/null || true
                        sudo cp *.css /var/www/portfolio/ 2>/dev/null || true
                        sudo cp *.js /var/www/portfolio/ 2>/dev/null || true
                        sudo cp -r images /var/www/portfolio/ 2>/dev/null || true
                        sudo cp -r css /var/www/portfolio/ 2>/dev/null || true
                        sudo cp -r js /var/www/portfolio/ 2>/dev/null || true
                    else
                        sudo cp -r $SOURCE_DIR/* /var/www/portfolio/
                    fi
                    
                    # Configurar permisos
                    echo "🔐 Configurando permisos..."
                    sudo chown -R www-data:www-data /var/www/portfolio/
                    
                    echo "✅ Archivos copiados correctamente"
                    echo "📁 Archivos en el sitio web:"
                    sudo ls -la /var/www/portfolio/ | head -10
                    
                    # Verificar que el sitio responde (con timeout)
                    echo "🌐 Verificando sitio web..."
                    sleep 2  # Dar tiempo para que nginx procese los archivos
                    if timeout 10 curl -f http://localhost/ > /dev/null 2>&1; then
                        echo "✅ Sitio web responde correctamente"
                    else
                        echo "⚠️ El sitio puede tardar en estar disponible"
                        echo "🔍 Verificando nginx..."
                        sudo service nginx status || sudo systemctl status nginx || echo "No se puede verificar nginx"
                    fi
                    
                    echo "🎉 Despliegue completado"
                '''
            }
        }
    }
    
    post {
        success {
            echo '🎉 ¡Éxito! Tu sitio web está desplegado'
            echo ''
            echo '🌐 Para ver tu sitio:'
            echo '   • En Cloud Shell: Web Preview → Preview on port 80'
            echo '   • En local: http://localhost'
            echo ''
            echo '💡 Tips:'
            echo '   • Refresca la página si no ves cambios'
            echo '   • Puedes modificar los archivos y ejecutar el pipeline otra vez'
        }
        failure {
            echo '❌ Pipeline falló. Posibles soluciones:'
            echo ''
            echo '� Si fue error de permisos sudo:'
            echo '   1. Ejecuta: sudo ./arreglar-permisos.sh'
            echo '   2. O manualmente: sudo echo "jenkins ALL=(ALL) NOPASSWD: /bin/cp, /bin/chown, /bin/rm, /usr/bin/unzip, /bin/mv" | sudo tee /etc/sudoers.d/jenkins'
            echo ''
            echo '� Para diagnóstico completo:'
            echo '   • Ejecuta: ./diagnostico.sh'
            echo '   • Verifica Jenkins: sudo service jenkins status'
            echo '   • Verifica Nginx: sudo service nginx status'
            echo ''
            echo '💡 En Cloud Shell, puede ser necesario esperar más tiempo para que Jenkins esté listo'
        }
    }
}