# 🚀 Tutorial Interactivo - Jenkins CI/CD

<div align="center">

![Jenkins](https://img.shields.io/badge/Jenkins-D24939?style=for-the-badge&logo=Jenkins&logoColor=white)
![Linux](https://img.shields.io/badge/Linux-FCC624?style=for-the-badge&logo=linux&logoColor=black)
![CI/CD](https://img.shields.io/badge/CI%2FCD-025E8C?style=for-the-badge&logo=gitlab&logoColor=white)

</div>

¡Bienvenid@ a la **Práctica Completa de Jenkins CI/CD**!

> 🎯 **Objetivo**: Instalar Jenkins, crear un pipeline de CI/CD y desplegar automáticamente un portafolio web

---

## 🚀 ¿Qué vas a lograr?

- ✅ **Instalar Jenkins** desde cero en Linux
- ✅ **Configurar** un pipeline de CI/CD completo
- ✅ **Automatizar** el despliegue de un portafolio web
- ✅ **Integrar Git** con Jenkins para deployments automáticos
- ✅ **Configurar Nginx** como servidor web
- ✅ **Monitorear** y troubleshoot pipelines

---

## 📋 Pre-requisitos

- ✅ Servidor Linux (Ubuntu 20.04+ recomendado)
- ✅ Acceso root/sudo al servidor
- ✅ 2GB RAM mínimo (4GB recomendado)
- ✅ Conexión a internet estable
- ✅ Navegador web para Jenkins UI

---

## ✅ Paso 1: Validar tu entorno

Antes de empezar, vamos a verificar que tu servidor esté listo.

```bash
# Ejecutar validación completa del sistema
./validate-environment.sh
```

**Este script verificará:**
- 🔍 Sistema operativo compatible
- 🔍 Permisos de usuario
- 🔍 Conectividad a internet
- 🔍 Recursos del sistema (RAM, disco)
- 🔍 Herramientas necesarias

### Salida esperada:

```
🧪 VALIDACIÓN DEL ENTORNO JENKINS CI/CD
==================================================

🧪 Test 1: Verificando sistema operativo
✅ Sistema soportado: Ubuntu 20.04.3 LTS

🧪 Test 2: Verificando permisos de usuario
✅ Usuario tiene permisos sudo

🧪 Test 3: Verificando conectividad a internet
✅ Conectividad a internet disponible

...

📊 Estadísticas de las pruebas:
   Total de pruebas: 24
   ✅ Exitosas: 22
   ❌ Fallidas: 0
   ⚠️ Advertencias: 2
   Porcentaje de éxito: 92%

🎉 ¡EXCELENTE! El sistema está listo para la práctica de Jenkins
```

> 💡 **Tip**: Si hay errores, consulta el archivo `TROUBLESHOOTING.md`

---

## ✅ Paso 2: Instalar Jenkins automáticamente 🪄

```bash
sudo ./install-jenkins.sh
```

### ¿Qué hace este script?

El script automatiza toda la instalación:

1. **☕ Instala Java 11** (OpenJDK)
2. **🔧 Instala Jenkins LTS** última versión
3. **🌐 Instala Nginx** para el portafolio
4. **� Configura firewall** (puertos 80, 8080)
5. **� Crea scripts** de administración
6. **✅ Verifica** que todo funcione

### Salida esperada:

```
🚀 INSTALACIÓN AUTOMATIZADA DE JENKINS
==================================================

� ACTUALIZANDO SISTEMA
✅ Lista de paquetes actualizada
✅ Sistema actualizado

☕ INSTALANDO JAVA
✅ OpenJDK 11 instalado
✅ Java instalado y configurado correctamente

� INSTALANDO JENKINS
✅ Jenkins instalado
✅ Servicio Jenkins habilitado e iniciado

🌐 CONFIGURANDO NGINX
✅ Nginx instalado y configurado

🔥 CONFIGURANDO FIREWALL
✅ Puerto Jenkins (8080) habilitado
✅ Puertos HTTP (80) y HTTPS (443) habilitados

🎉 INSTALACIÓN COMPLETADA EXITOSAMENTE
┌─────────────────────────────────────────────────────────────┐
│                    ✅ JENKINS INSTALADO                     │
└─────────────────────────────────────────────────────────────┘

🌐 ACCESO A JENKINS:
   URL: http://TU-IP-SERVIDOR:8080
```

**Tiempo estimado:** 15-20 minutos

---

## 🌐 Paso 3: Acceder a Jenkins por primera vez

### Obtener la contraseña inicial:

```bash
# Ver información completa de acceso
sudo cat /root/jenkins-info.txt

# O directamente la contraseña
sudo cat /var/lib/jenkins/secrets/initialAdminPassword
```

### Configurar Jenkins:

1. **Abre tu navegador** y ve a: `http://TU-IP-SERVIDOR:8080`
2. **Introduce la contraseña inicial** obtenida arriba
3. **Selecciona**: "Install suggested plugins"
4. **Espera** a que se instalen los plugins (5-10 minutos)
5. **Crea usuario administrador**:
   - Username: `devops-admin`
   - Password: `DevOps2024!`
   - Full name: `DevOps Administrator`
   - Email: `tu-email@ejemplo.com`
6. **Confirma la URL** de Jenkins
7. **Clic en "Start using Jenkins"**

---

## ✅ Paso 4: Configurar el entorno de despliegue

```bash
sudo ./setup-environment.sh
```

### ¿Qué configura este script?

1. **📁 Crea directorios** de despliegue y backup
2. **🔐 Configura permisos** de Jenkins
3. **🌐 Configura Nginx** con virtual host optimizado
4. **� Crea scripts** de ayuda y monitoreo
5. **✅ Verifica** toda la configuración

### Salida esperada:

```
📁 CONFIGURANDO DIRECTORIOS
✅ Directorio del portafolio creado: /var/www/portfolio
✅ Directorio de backups creado: /var/backups/portfolio

🌐 CONFIGURANDO NGINX
✅ Nginx ya está instalado
✅ Configuración del sitio copiada
✅ Sitio habilitado

🔐 CONFIGURANDO PERMISOS DE JENKINS
✅ Usuario jenkins agregado al grupo www-data
✅ Permisos sudo configurados para Jenkins

🎨 CREANDO PORTAFOLIO DE EJEMPLO
✅ Portafolio de ejemplo creado y configurado

🎉 CONFIGURACIÓN COMPLETADA
El entorno está listo para Jenkins!
```

---

## 🔄 Paso 5: Crear tu primer Pipeline

### En Jenkins UI:

1. **Clic en "Nueva tarea"**
2. **Nombre del item**: `portfolio-deployment`
3. **Seleccionar**: "Pipeline"
4. **Clic en "OK"**

### Configurar el Pipeline:

1. **Descripción**: `Pipeline para despliegue automático del portafolio`
2. En **"Pipeline"**:
   - **Definition**: `Pipeline script from SCM`
   - **SCM**: `Git`
   - **Repository URL**: `https://github.com/TU-USUARIO/roxs-devops-jenkins.git`
   - **Credentials**: `None` (si es público)
   - **Branch**: `*/main`
   - **Script Path**: `Jenkinsfile`
3. **Guardar**

---

## � Paso 6: ¡Ejecutar tu primer build!

### Ejecutar el Pipeline:

1. **En la página del job** `portfolio-deployment`
2. **Clic en "Construir ahora"**
3. **Monitorear la ejecución**:
   - Clic en el número del build (ej: #1)
   - Clic en "Console Output"

### Monitorear desde terminal:

```bash
# En otra terminal, ver logs de Jenkins
jenkins-logs

# Ver estado del portafolio
portfolio-status

# Ver logs de Nginx
portfolio-logs
```

### Salida esperada del Pipeline:

```
🧹 FASE 1: Limpiando espacio de trabajo
✅ Workspace limpio y listo para usar

📥 FASE 2: Descargando código fuente
✅ Código descargado exitosamente
📋 Commit: abc123d
👤 Autor: Tu Nombre
💬 Mensaje: Initial commit

🔍 FASE 3: Análisis de código
📄 Archivos HTML encontrados: 1
🎨 Archivos CSS encontrados: 0
⚡ Archivos JS encontrados: 0
✅ Análisis de código completado

🔧 FASE 4: Preparando despliegue
📦 Creando backup del sitio actual...
✅ Preparación completada

🚀 FASE 5: Desplegando aplicación
📁 Copiando archivos de la aplicación...
🔐 Configurando permisos...
✅ Aplicación desplegada exitosamente

🌐 FASE 6: Configurando servidor web
⚙️ Configurando virtual host de Nginx...
🔗 Habilitando sitio...
🔄 Recargando Nginx...
✅ Nginx configurado correctamente

🧪 FASE 7: Ejecutando pruebas
🔍 Test 1: Verificando estado de Nginx...
✅ Sitio responde correctamente (HTTP 200)
✅ Todas las pruebas completadas exitosamente

🎉 ¡DESPLIEGUE EXITOSO!
🌍 Tu sitio está ahora disponible en línea
```

---

## 🌐 Paso 7: Verificar tu sitio web

### URLs para verificar:

```bash
# URL principal de tu portafolio
echo "🌐 Portafolio: http://$(hostname -I | awk '{print $1}')"

# Información del build
echo "📊 Build Info: http://$(hostname -I | awk '{print $1}')/build-info"

# Status API
echo "🔍 Status: http://$(hostname -I | awk '{print $1}')/status"

# Health Check
echo "❤️ Health: http://$(hostname -I | awk '{print $1}')/health"
```

### Verificar desde terminal:

```bash
# Test básico
curl http://localhost

# Test de status
curl http://localhost/status

# Test de health
curl http://localhost/health
```

---

## 🛠️ Paso 8: Personalizar tu portafolio (Opcional)

¿Quieres personalizar el sitio? ¡Hazlo!

### Editar el contenido:

```bash
# Editar el archivo principal
nano site/gaming-hub.html

# Hacer commit de los cambios
git add .
git commit -m "Personalizar portafolio"
git push origin main

# Ejecutar pipeline nuevamente en Jenkins UI
# ¡Los cambios se desplegarán automáticamente!
```

---

## 🧪 Troubleshooting

### Problema: "Jenkins no inicia"

```bash
# Verificar estado del servicio
sudo systemctl status jenkins

# Ver logs detallados
sudo journalctl -u jenkins -f

# Reiniciar si es necesario
sudo systemctl restart jenkins
```

### Problema: "Pipeline falla en permisos"

```bash
# Verificar permisos de Jenkins
sudo ls -la /var/www/portfolio

# Reconfigurar permisos
sudo chown -R jenkins:www-data /var/www/portfolio
sudo chmod -R 755 /var/www/portfolio
```

### Problema: "Puerto 8080 ocupado"

```bash
# Ver qué está usando el puerto
sudo netstat -tlnp | grep :8080

# Parar proceso si es necesario
sudo systemctl stop jenkins
sudo systemctl start jenkins
```

### Problema: "Nginx no sirve el sitio"

```bash
# Verificar configuración de Nginx
sudo nginx -t

# Verificar estado
sudo systemctl status nginx

# Recargar configuración
sudo systemctl reload nginx
```

---

## 🏆 Desafíos Adicionales

### 🎯 Desafío 1: Modificar y redesplegar
1. Cambia el título del portafolio
2. Haz commit y push
3. Ejecuta el pipeline
4. Verifica que los cambios se apliquen

### � Desafío 2: Configurar webhook automático
1. Ve a GitHub → Settings → Webhooks
2. URL: `http://TU-IP:8080/github-webhook/`
3. Configura push events
4. Haz un cambio y verifica que se ejecute automáticamente

### 🎯 Desafío 3: Agregar notificaciones
1. Instala plugin de Email Extension
2. Configura SMTP
3. Agrega notificaciones al Jenkinsfile

---

## 📊 Monitoreo y Scripts Útiles

### Scripts de monitoreo:

```bash
# Ver estado general
jenkins-status
portfolio-status

# Monitorear logs en tiempo real
jenkins-logs
portfolio-logs

# Verificar health check
health-check

# Despliegue manual (emergencia)
deploy-portfolio
```

### Comandos útiles:

```bash
# Ver builds de Jenkins
ls /var/lib/jenkins/jobs/portfolio-deployment/builds/

# Ver logs específicos
sudo tail -f /var/log/nginx/portfolio.access.log

# Verificar espacio en disco
df -h

# Ver memoria disponible
free -h
```

---

## 📱 Comparte tu éxito

¡Muestra tu logro en redes sociales!

```
🎉 ¡Completé mi práctica de #Jenkins CI/CD! 
� Instalé Jenkins desde cero
🔄 Creé un pipeline automático 
🌐 Desplegué mi portafolio con Nginx
� Parte del programa #DevOps by @roxsross 

#Jenkins #CICD #DevOps #Automation #Learning
```

---

## 🤝 Comunidad y ayuda

- 📺 **YouTube**: [Canal de RoxsRoss](https://youtube.com/@295devops)
- 📚 **Blog**: [295devops.com](https://blog.295devops.com)
- 🐦 **Twitter**: [@roxsross](https://twitter.com/roxsross)
- 💼 **LinkedIn**: [RoxsRoss en LinkedIn](https://www.linkedin.com/in/roxsross/)

---

## 🎪 ¿Quieres más diversión?

### 🔍 Explorar configuraciones avanzadas:
```bash
# Ver configuración completa de Jenkins
sudo cat /var/lib/jenkins/config.xml

# Explorar plugins instalados
ls /var/lib/jenkins/plugins/

# Ver configuración de Nginx
sudo cat /etc/nginx/sites-available/portfolio
```

### 📚 Documentación adicional:
```bash
# Ver documentación completa
cat JENKINS-PRACTICE.md

# Guía paso a paso detallada
cat GUIA-PASO-A-PASO.md

# Comandos de referencia
cat COMANDOS-UTILES.md

# Solución de problemas
cat TROUBLESHOOTING.md
```

---

<div align="center">

## 🎉 ¡FELICITACIONES! 

Has completado exitosamente tu **práctica completa de Jenkins CI/CD**.

🏆 **¿Qué lograste?**
- ✅ Instalaste Jenkins desde cero
- ✅ Configuraste un pipeline completo
- ✅ Automatizaste el despliegue de una aplicación
- ✅ Integraste Git con Jenkins
- ✅ Configuraste un servidor web con Nginx
- ✅ Implementaste monitoreo y health checks

**¡Ahora tienes las habilidades fundamentales de DevOps!** 🚀

---

**Creado con ❤️ por [RoxsRoss](https://github.com/roxsross)**  
*Transformando desarrolladores en DevOps Engineers*

</div>
