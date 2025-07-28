pipeline {
    agent any
    
    stages {
        stage('📥 Obtener Código') {
            steps {
                echo '📥 Obteniendo código del repositorio...'
                checkout scm
            }
        }
        
        stage('🔍 Verificar Portafolio') {
            steps {
                echo '🔍 Verificando directorio portafolio-web...'
                sh '''
                    if [ -d "portafolio-web" ]; then
                        echo "✅ Directorio portafolio-web encontrado"
                        echo "📁 Archivos del portafolio:"
                        ls -la portafolio-web/ | head -10
                    else
                        echo "❌ Directorio portafolio-web no encontrado"
                        echo "📁 Archivos disponibles:"
                        ls -la
                        exit 1
                    fi
                '''
            }
        }
        
        stage('🚀 Desplegar Aplicación') {
            steps {
                echo '🚀 Desplegando aplicación web...'
                sh '''
                    echo "🐳 Desplegando con Docker Compose..."
                    
                    # Reiniciar contenedor de la aplicación
                    docker-compose restart web
                    
                    # Esperar a que esté lista
                    echo "⏳ Esperando a que la aplicación esté lista..."
                    sleep 5
                    
                    # Verificar que está funcionando
                    if curl -f http://localhost:8088/health > /dev/null 2>&1; then
                        echo "✅ Aplicación desplegada y funcionando en puerto 8088"
                    else
                        echo "⚠️ Aplicación puede tardar en estar lista"
                        docker-compose logs web --tail 10
                    fi
                '''
            }
        }
    }
    
    post {
        success {
            echo '🎉 ¡Portafolio desplegado exitosamente!'
            echo ''
            echo '🌐 Ver tu aplicación:'
            echo '   • Cloud Shell: Web Preview → Preview on port 8088'
            echo '   • Local: http://localhost:8088'
            echo ''
            echo '🔍 Verificar estado:'
            echo '   • Health check: http://localhost:8088/health'
            echo '   • Logs: docker-compose logs web'
        }
        failure {
            echo '❌ Error en el despliegue'
            echo ''
            echo '🔧 Diagnóstico:'
            sh '''
                echo "📊 Estado de contenedores:"
                docker ps -a
                echo ""
                echo "📋 Logs de la aplicación:"
                docker-compose logs web --tail 20 || echo "No hay logs disponibles"
            '''
            echo ''
            echo '💡 Verificaciones:'
            echo '   • ¿Existe el directorio portafolio-web?'
            echo '   • ¿Está Docker funcionando?'
        }
    }
}