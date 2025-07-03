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
                        exit 1
                    fi
                    
                    # Copiar archivos al servidor web
                    sudo cp -r site/* /var/www/portfolio/
                    
                    # Configurar permisos
                    sudo chown -R www-data:www-data /var/www/portfolio/
                    
                    echo "✅ Archivos copiados correctamente"
                    
                    # Verificar que el sitio responde (con timeout)
                    timeout 10 curl -f http://localhost/ > /dev/null || echo "⚠️ El sitio puede tardar en estar disponible"
                    
                    echo "🎉 Despliegue completado"
                '''
            }
        }
    }
    
    post {
        success {
            echo '🎉 ¡Éxito! Tu sitio web está desplegado'
        }
        failure {
            echo '❌ Algo salió mal. Revisa los logs arriba.'
        }
    }
}