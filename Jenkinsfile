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
                sh 'ls -la'
                sh 'ls -la site/'
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
                    if ! sudo -n true 2>/dev/null; then
                        echo "❌ Jenkins no tiene permisos sudo configurados"
                        echo "💡 Ejecuta en el servidor: sudo ./arreglar-permisos.sh"
                        echo "💡 O manualmente: echo 'jenkins ALL=(ALL) NOPASSWD: /bin/cp, /bin/chown' | sudo tee /etc/sudoers.d/jenkins"
                        exit 1
                    fi
                    
                    echo "✅ Permisos sudo verificados"
                    
                    # Copiar archivos al servidor web
                    echo "📁 Copiando archivos..."
                    sudo cp -r site/* /var/www/portfolio/
                    
                    # Configurar permisos
                    echo "🔐 Configurando permisos..."
                    sudo chown -R www-data:www-data /var/www/portfolio/
                    
                    echo "✅ Archivos copiados correctamente"
                    
                    # Verificar que el sitio responde (con timeout)
                    echo "🌐 Verificando sitio web..."
                    if timeout 10 curl -f http://localhost/ > /dev/null 2>&1; then
                        echo "✅ Sitio web responde correctamente"
                    else
                        echo "⚠️ El sitio puede tardar en estar disponible"
                    fi
                    
                    echo "🎉 Despliegue completado"
                '''
            }
        }
    }
    
    post {
        success {
            echo '🎉 ¡Éxito! Tu sitio web está desplegado'
            echo '🌐 Visita: http://localhost para ver tu sitio'
        }
        failure {
            echo '❌ Pipeline falló. Posibles soluciones:'
            echo '💡 Si fue error de permisos sudo: ejecuta "./arreglar-permisos.sh"'
            echo '💡 Para diagnóstico completo: ejecuta "./diagnostico.sh"'
            echo '💡 Verifica que Jenkins esté corriendo: sudo service jenkins status'
        }
    }
}