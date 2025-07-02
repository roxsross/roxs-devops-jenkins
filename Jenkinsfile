#!/usr/bin/env groovy

/*
 * Jenkinsfile para Despliegue de Portafolio
 * Práctica de Jenkins - DevOps
 * Autor: RoxsRoss DevOps Community
 */

pipeline {
    agent any
    
    // Variables de entorno
    environment {
        DEPLOY_PATH = '/var/www/portfolio'
        NGINX_CONFIG = '/etc/nginx/sites-available/portfolio'
        BACKUP_PATH = '/var/backups/portfolio'
        BUILD_TIMESTAMP = sh(script: 'date +%Y%m%d_%H%M%S', returnStdout: true).trim()
    }
    
    // Opciones del pipeline
    options {
        // Mantener solo los últimos 10 builds
        buildDiscarder(logRotator(numToKeepStr: '10'))
        
        // Timeout de 10 minutos para todo el pipeline
        timeout(time: 10, unit: 'MINUTES')
        
        // Evitar builds concurrentes
        disableConcurrentBuilds()
    }
    
    // Triggers automáticos
    triggers {
        // Polling cada 5 minutos para cambios en SCM
        pollSCM('H/5 * * * *')
    }
    
    stages {
        stage('🧹 Cleanup Workspace') {
            steps {
                echo '=================================================='
                echo '🧹 FASE 1: Limpiando espacio de trabajo'
                echo '=================================================='
                
                // Limpiar workspace anterior
                cleanWs()
                
                echo '✅ Workspace limpio y listo para usar'
            }
        }
        
        stage('📥 Checkout Code') {
            steps {
                echo '=================================================='
                echo '📥 FASE 2: Descargando código fuente'
                echo '=================================================='
                
                // Checkout del código fuente
                checkout scm
                
                // Mostrar información del commit
                script {
                    env.GIT_COMMIT_SHORT = sh(
                        script: 'git rev-parse --short HEAD',
                        returnStdout: true
                    ).trim()
                    
                    env.GIT_AUTHOR = sh(
                        script: 'git log -1 --pretty=format:"%an"',
                        returnStdout: true
                    ).trim()
                    
                    env.GIT_MESSAGE = sh(
                        script: 'git log -1 --pretty=format:"%s"',
                        returnStdout: true
                    ).trim()
                }
                
                echo "📋 Commit: ${env.GIT_COMMIT_SHORT}"
                echo "👤 Autor: ${env.GIT_AUTHOR}"
                echo "💬 Mensaje: ${env.GIT_MESSAGE}"
                echo "⏰ Build: ${env.BUILD_TIMESTAMP}"
            }
        }
        
        stage('🔍 Code Analysis') {
            steps {
                echo '=================================================='
                echo '🔍 FASE 3: Análisis de código'
                echo '=================================================='
                
                script {
                    // Contar archivos HTML
                    def htmlFiles = sh(
                        script: 'find . -name "*.html" | wc -l',
                        returnStdout: true
                    ).trim()
                    
                    // Contar archivos CSS
                    def cssFiles = sh(
                        script: 'find . -name "*.css" | wc -l',
                        returnStdout: true
                    ).trim()
                    
                    // Contar archivos JS
                    def jsFiles = sh(
                        script: 'find . -name "*.js" | wc -l',
                        returnStdout: true
                    ).trim()
                    
                    echo "📄 Archivos HTML encontrados: ${htmlFiles}"
                    echo "🎨 Archivos CSS encontrados: ${cssFiles}"
                    echo "⚡ Archivos JS encontrados: ${jsFiles}"
                    
                    // Verificar que tenemos al menos un archivo HTML
                    if (htmlFiles.toInteger() == 0) {
                        error("❌ No se encontraron archivos HTML en el proyecto")
                    }
                }
                
                // Validar HTML (básico)
                sh '''
                    echo "🔍 Validando estructura de archivos HTML..."
                    for html_file in $(find . -name "*.html"); do
                        echo "Validando: $html_file"
                        # Verificar que el archivo tenga las etiquetas básicas
                        if ! grep -q "<html" "$html_file"; then
                            echo "⚠️  Advertencia: $html_file no tiene etiqueta <html>"
                        fi
                        if ! grep -q "<head" "$html_file"; then
                            echo "⚠️  Advertencia: $html_file no tiene etiqueta <head>"
                        fi
                        if ! grep -q "<body" "$html_file"; then
                            echo "⚠️  Advertencia: $html_file no tiene etiqueta <body>"
                        fi
                    done
                '''
                
                echo '✅ Análisis de código completado'
            }
        }
        
        stage('🔧 Prepare Deployment') {
            steps {
                echo '=================================================='
                echo '🔧 FASE 4: Preparando despliegue'
                echo '=================================================='
                
                script {
                    // Crear directorio de backup si no existe
                    sh "sudo mkdir -p ${env.BACKUP_PATH}"
                    
                    // Hacer backup del sitio actual si existe
                    sh '''
                        if [ -d "/var/www/portfolio" ]; then
                            echo "📦 Creando backup del sitio actual..."
                            sudo tar -czf ${BACKUP_PATH}/portfolio_backup_${BUILD_TIMESTAMP}.tar.gz -C /var/www portfolio/ || true
                            echo "✅ Backup creado: ${BACKUP_PATH}/portfolio_backup_${BUILD_TIMESTAMP}.tar.gz"
                        else
                            echo "ℹ️  No hay sitio anterior para respaldar"
                        fi
                    '''
                    
                    // Crear directorio de despliegue
                    sh "sudo mkdir -p ${env.DEPLOY_PATH}"
                    
                    // Asegurar permisos correctos
                    sh "sudo chown -R jenkins:www-data ${env.DEPLOY_PATH}"
                    sh "sudo chmod -R 755 ${env.DEPLOY_PATH}"
                }
                
                echo '✅ Preparación completada'
            }
        }
        
        stage('🚀 Deploy Application') {
            steps {
                echo '=================================================='
                echo '🚀 FASE 5: Desplegando aplicación'
                echo '=================================================='
                
                script {
                    // Copiar archivos al directorio de despliegue
                    sh """
                        echo "📁 Copiando archivos de la aplicación..."
                        sudo cp -r site/* ${env.DEPLOY_PATH}/
                        
                        echo "🔐 Configurando permisos..."
                        sudo chown -R www-data:www-data ${env.DEPLOY_PATH}
                        sudo chmod -R 644 ${env.DEPLOY_PATH}/*
                        sudo find ${env.DEPLOY_PATH} -type d -exec chmod 755 {} \\;
                        
                        echo "📝 Creando archivo de información del build..."
                        sudo tee ${env.DEPLOY_PATH}/build-info.html > /dev/null << EOF
<!DOCTYPE html>
<html>
<head>
    <title>Build Information</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 40px; }
        .info-box { background: #f0f8ff; padding: 20px; border-radius: 8px; }
        .success { color: #28a745; }
    </style>
</head>
<body>
    <div class="info-box">
        <h2 class="success">🚀 Despliegue Exitoso</h2>
        <p><strong>Build #:</strong> ${env.BUILD_NUMBER}</p>
        <p><strong>Timestamp:</strong> ${env.BUILD_TIMESTAMP}</p>
        <p><strong>Commit:</strong> ${env.GIT_COMMIT_SHORT}</p>
        <p><strong>Autor:</strong> ${env.GIT_AUTHOR}</p>
        <p><strong>Mensaje:</strong> ${env.GIT_MESSAGE}</p>
        <p><strong>Jenkins Job:</strong> ${env.JOB_NAME}</p>
    </div>
</body>
</html>
EOF
                    """
                }
                
                echo '✅ Aplicación desplegada exitosamente'
            }
        }
        
        stage('🌐 Configure Nginx') {
            steps {
                echo '=================================================='
                echo '🌐 FASE 6: Configurando servidor web'
                echo '=================================================='
                
                script {
                    // Verificar si Nginx está instalado
                    def nginxInstalled = sh(
                        script: 'which nginx',
                        returnStatus: true
                    )
                    
                    if (nginxInstalled != 0) {
                        echo "📦 Instalando Nginx..."
                        sh 'sudo apt update && sudo apt install -y nginx'
                    }
                    
                    // Configurar sitio en Nginx
                    sh '''
                        echo "⚙️  Configurando virtual host de Nginx..."
                        sudo tee /etc/nginx/sites-available/portfolio > /dev/null << 'EOF'
server {
    listen 80;
    server_name _;
    
    root /var/www/portfolio;
    index gaming-hub.html index.html index.htm;
    
    # Logs
    access_log /var/log/nginx/portfolio.access.log;
    error_log /var/log/nginx/portfolio.error.log;
    
    # Configuración principal
    location / {
        try_files $uri $uri/ =404;
        
        # Headers de seguridad
        add_header X-Frame-Options "SAMEORIGIN" always;
        add_header X-XSS-Protection "1; mode=block" always;
        add_header X-Content-Type-Options "nosniff" always;
    }
    
    # Cache para archivos estáticos
    location ~* \\.(css|js|png|jpg|jpeg|gif|ico|svg)$ {
        expires 1y;
        add_header Cache-Control "public, immutable";
    }
    
    # Información del build
    location /build-info {
        try_files /build-info.html =404;
    }
    
    # Status page
    location /status {
        return 200 "Portfolio is running! Build: ${BUILD_NUMBER}\\n";
        add_header Content-Type text/plain;
    }
}
EOF
                        
                        echo "🔗 Habilitando sitio..."
                        sudo ln -sf /etc/nginx/sites-available/portfolio /etc/nginx/sites-enabled/
                        
                        echo "🧪 Verificando configuración de Nginx..."
                        sudo nginx -t
                        
                        echo "🔄 Recargando Nginx..."
                        sudo systemctl reload nginx
                    '''
                }
                
                echo '✅ Nginx configurado correctamente'
            }
        }
        
        stage('🧪 Testing') {
            steps {
                echo '=================================================='
                echo '🧪 FASE 7: Ejecutando pruebas'
                echo '=================================================='
                
                script {
                    // Test 1: Verificar que Nginx esté corriendo
                    echo "🔍 Test 1: Verificando estado de Nginx..."
                    sh 'sudo systemctl is-active nginx'
                    
                    // Test 2: Verificar que el sitio responde
                    echo "🔍 Test 2: Verificando respuesta HTTP..."
                    sh '''
                        response=$(curl -s -o /dev/null -w "%{http_code}" http://localhost)
                        if [ "$response" = "200" ]; then
                            echo "✅ Sitio responde correctamente (HTTP $response)"
                        else
                            echo "❌ Error: Sitio no responde correctamente (HTTP $response)"
                            exit 1
                        fi
                    '''
                    
                    // Test 3: Verificar archivos desplegados
                    echo "🔍 Test 3: Verificando archivos desplegados..."
                    sh '''
                        if [ -f "${DEPLOY_PATH}/gaming-hub.html" ]; then
                            echo "✅ Archivo principal encontrado"
                        else
                            echo "❌ Error: Archivo principal no encontrado"
                            exit 1
                        fi
                    '''
                    
                    // Test 4: Verificar página de build info
                    echo "🔍 Test 4: Verificando página de build info..."
                    sh '''
                        response=$(curl -s -o /dev/null -w "%{http_code}" http://localhost/build-info)
                        if [ "$response" = "200" ]; then
                            echo "✅ Página de build info accesible"
                        else
                            echo "⚠️  Advertencia: Página de build info no accesible"
                        fi
                    '''
                    
                    // Test 5: Status endpoint
                    echo "🔍 Test 5: Verificando endpoint de status..."
                    sh 'curl -s http://localhost/status'
                }
                
                echo '✅ Todas las pruebas completadas exitosamente'
            }
        }
    }
    
    // Acciones post-build
    post {
        always {
            echo '=================================================='
            echo '📊 RESUMEN FINAL DEL PIPELINE'
            echo '=================================================='
            
            script {
                def duration = currentBuild.durationString.replace(' and counting', '')
                echo "⏱️  Duración total: ${duration}"
                echo "🏗️  Build número: ${env.BUILD_NUMBER}"
                echo "📅 Timestamp: ${env.BUILD_TIMESTAMP}"
                
                // Limpiar archivos temporales pero conservar logs importantes
                echo "🧹 Limpiando archivos temporales..."
                
                // Mostrar información del sitio desplegado
                echo "🌐 Sitio desplegado en: http://localhost"
                echo "📊 Build info: http://localhost/build-info"
                echo "🔍 Status: http://localhost/status"
            }
        }
        
        success {
            echo '🎉 ¡DESPLIEGUE EXITOSO!'
            echo '✅ El portafolio ha sido desplegado correctamente'
            echo '🌍 Tu sitio está ahora disponible en línea'
            
            // Aquí podrías agregar notificaciones de éxito
            // slackSend channel: '#deployments', 
            //           color: 'good', 
            //           message: "✅ Despliegue exitoso de ${env.JOB_NAME} #${env.BUILD_NUMBER}"
        }
        
        failure {
            echo '❌ DESPLIEGUE FALLIDO'
            echo '🔍 Revisa los logs para identificar el problema'
            echo '💡 Posibles soluciones:'
            echo '   - Verificar permisos de archivos'
            echo '   - Comprobar configuración de Nginx'
            echo '   - Revisar logs de sistema'
            
            // Rollback automático en caso de fallo
            script {
                echo "🔄 Intentando rollback automático..."
                sh '''
                    latest_backup=$(ls -t ${BACKUP_PATH}/portfolio_backup_*.tar.gz 2>/dev/null | head -1)
                    if [ -n "$latest_backup" ]; then
                        echo "📦 Restaurando desde: $latest_backup"
                        sudo rm -rf ${DEPLOY_PATH}/*
                        sudo tar -xzf "$latest_backup" -C /var/www/
                        echo "✅ Rollback completado"
                    else
                        echo "⚠️  No hay backups disponibles para rollback"
                    fi
                '''
            }
            
            // Aquí podrías agregar notificaciones de fallo
            // slackSend channel: '#deployments', 
            //           color: 'danger', 
            //           message: "❌ Fallo en despliegue de ${env.JOB_NAME} #${env.BUILD_NUMBER}"
        }
        
        unstable {
            echo '⚠️  BUILD INESTABLE'
            echo '🔍 Algunas pruebas fallaron pero el despliegue continuó'
        }
        
        changed {
            echo '🔄 ESTADO DEL BUILD HA CAMBIADO'
            echo "Anterior: ${currentBuild.previousBuild?.result}"
            echo "Actual: ${currentBuild.result}"
        }
    }
}
