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
                    # Copiar archivos al servidor web
                    sudo cp -r site/* /var/www/portfolio/
                    
                    # Configurar permisos
                    sudo chown -R www-data:www-data /var/www/portfolio/
                    
                    # Verificar que funcione
                    curl -f http://localhost/ || exit 1
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