# 🔧 Guía de Troubleshooting - Jenkins CI/CD

## 🚨 Problemas Comunes y Soluciones

---

## 📋 Tabla de Contenidos

1. [Problemas de Instalación](#problemas-de-instalación)
2. [Problemas de Jenkins](#problemas-de-jenkins)
3. [Problemas de Pipeline](#problemas-de-pipeline)
4. [Problemas de Nginx](#problemas-de-nginx)
5. [Problemas de Permisos](#problemas-de-permisos)
6. [Problemas de Red](#problemas-de-red)
7. [Problemas de Performance](#problemas-de-performance)
8. [Comandos de Diagnóstico](#comandos-de-diagnóstico)

---

## 🔧 Problemas de Instalación

### ❌ Error: "Package jenkins has no installation candidate"

**Síntomas:**
```
E: Package 'jenkins' has no installation candidate
```

**Causa:** Repositorio de Jenkins no agregado correctamente.

**Solución:**
```bash
# Limpiar repositorios anteriores
sudo rm -f /etc/apt/sources.list.d/jenkins.list

# Agregar clave GPG actualizada
curl -fsSL https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key | sudo tee \
  /usr/share/keyrings/jenkins-keyring.asc > /dev/null

# Agregar repositorio con clave
echo deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] \
  https://pkg.jenkins.io/debian-stable binary/ | sudo tee \
  /etc/apt/sources.list.d/jenkins.list > /dev/null

# Actualizar e instalar
sudo apt update
sudo apt install jenkins
```

### ❌ Error: "Java not found"

**Síntomas:**
```
jenkins: command not found
```

**Causa:** Java no instalado o versión incorrecta.

**Solución:**
```bash
# Verificar Java
java -version

# Instalar Java 11 (recomendado)
sudo apt install openjdk-11-jdk -y

# Configurar JAVA_HOME
echo 'export JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64' | sudo tee -a /etc/environment
source /etc/environment

# Verificar instalación
java -version
javac -version
```

### ❌ Error: "Port 8080 already in use"

**Síntomas:**
```
Address already in use
```

**Causa:** Otro servicio usando el puerto 8080.

**Solución:**
```bash
# Identificar proceso usando el puerto
sudo netstat -tlnp | grep :8080
sudo lsof -i :8080

# Opción 1: Terminar proceso conflictivo
sudo kill -9 <PID>

# Opción 2: Cambiar puerto de Jenkins
sudo nano /etc/default/jenkins
# Cambiar: HTTP_PORT=8080 por HTTP_PORT=8081
sudo systemctl restart jenkins

# Verificar nuevo puerto
sudo netstat -tlnp | grep :8081
```

---

## 🔧 Problemas de Jenkins

### ❌ Jenkins no inicia

**Síntomas:**
```
● jenkins.service - LSB: Start Jenkins at boot time
   Active: failed (Result: exit-code)
```

**Diagnóstico:**
```bash
# Ver logs detallados
sudo journalctl -u jenkins -f
sudo systemctl status jenkins -l

# Ver logs de Jenkins
sudo tail -f /var/log/jenkins/jenkins.log
```

**Soluciones comunes:**

1. **Permisos incorrectos:**
```bash
sudo chown -R jenkins:jenkins /var/lib/jenkins
sudo chmod -R 755 /var/lib/jenkins
```

2. **Memoria insuficiente:**
```bash
# Editar configuración Java
sudo nano /etc/default/jenkins
# Agregar o modificar:
JAVA_ARGS="-Xmx512m -Djava.awt.headless=true"
```

3. **Conflicto de plugins:**
```bash
# Mover plugins problemáticos
sudo mv /var/lib/jenkins/plugins /var/lib/jenkins/plugins.bak
sudo mkdir /var/lib/jenkins/plugins
sudo systemctl restart jenkins
```

### ❌ "Jenkins is getting ready to work"

**Síntomas:** Jenkins se queda en pantalla de "Getting ready".

**Causa:** Proceso de inicialización lento o bloqueado.

**Solución:**
```bash
# Esperar más tiempo (hasta 10 minutos)
# Si persiste, verificar logs:
sudo tail -f /var/log/jenkins/jenkins.log

# Reiniciar con limpieza
sudo systemctl stop jenkins
sudo rm -f /var/lib/jenkins/jenkins.pid
sudo systemctl start jenkins
```

### ❌ Error de autenticación inicial

**Síntomas:** No se puede acceder con la contraseña inicial.

**Solución:**
```bash
# Obtener contraseña actual
sudo cat /var/lib/jenkins/secrets/initialAdminPassword

# Si el archivo no existe, reinicializar:
sudo systemctl stop jenkins
sudo rm -f /var/lib/jenkins/secrets/initialAdminPassword
sudo systemctl start jenkins

# Esperar y obtener nueva contraseña
sleep 30
sudo cat /var/lib/jenkins/secrets/initialAdminPassword
```

---

## 🔧 Problemas de Pipeline

### ❌ Error: "Permission denied" en Pipeline

**Síntomas:**
```
+ sudo cp -r site/* /var/www/portfolio/
sudo: no tty present and no askpass program specified
```

**Causa:** Jenkins no puede ejecutar comandos sudo.

**Solución:**
```bash
# Configurar sudoers para Jenkins
sudo nano /etc/sudoers.d/jenkins

# Agregar líneas:
jenkins ALL=(ALL) NOPASSWD: /bin/cp, /bin/mv, /bin/rm, /bin/mkdir
jenkins ALL=(ALL) NOPASSWD: /bin/chown, /bin/chmod
jenkins ALL=(ALL) NOPASSWD: /usr/sbin/nginx, /bin/systemctl reload nginx
jenkins ALL=(ALL) NOPASSWD: /usr/bin/tee

# Verificar sintaxis
sudo visudo -c
```

### ❌ Error: "Workspace not found"

**Síntomas:**
```
ERROR: Workspace not available
```

**Causa:** Directorio de workspace corrupto o permisos incorrectos.

**Solución:**
```bash
# Verificar workspace
sudo ls -la /var/lib/jenkins/workspace/

# Recrear workspace
sudo rm -rf /var/lib/jenkins/workspace/portfolio-deployment
sudo mkdir -p /var/lib/jenkins/workspace/portfolio-deployment
sudo chown jenkins:jenkins /var/lib/jenkins/workspace/portfolio-deployment

# Ejecutar build nuevamente
```

### ❌ Error: "Git command failed"

**Síntomas:**
```
stderr: fatal: could not read Username for 'https://github.com'
```

**Causa:** Credenciales de Git incorrectas o faltantes.

**Solución:**

1. **Para repositorios públicos:**
```bash
# Verificar URL del repositorio (debe ser HTTPS público)
# En Jenkins: Repository URL = https://github.com/usuario/repo.git
```

2. **Para repositorios privados:**
```bash
# En Jenkins > Manage Jenkins > Manage Credentials
# Agregar credenciales tipo "Username with password" o SSH
```

3. **Configurar Git globalmente:**
```bash
sudo -u jenkins git config --global user.name "Jenkins"
sudo -u jenkins git config --global user.email "jenkins@localhost"
```

### ❌ Error: "Nginx configuration test failed"

**Síntomas:**
```
nginx: [emerg] unexpected end of file
nginx: configuration file /etc/nginx/nginx.conf test is failed
```

**Causa:** Configuración de Nginx corrupta.

**Solución:**
```bash
# Verificar sintaxis específica
sudo nginx -t

# Restaurar configuración por defecto
sudo cp /etc/nginx/nginx.conf /etc/nginx/nginx.conf.backup
sudo apt install --reinstall nginx-common

# Verificar configuración del sitio
sudo nginx -t -c /etc/nginx/sites-available/portfolio
```

---

## 🔧 Problemas de Nginx

### ❌ Error 403 Forbidden

**Síntomas:** El sitio devuelve error 403.

**Causas y soluciones:**

1. **Permisos de archivos:**
```bash
sudo chown -R www-data:www-data /var/www/portfolio
sudo chmod -R 755 /var/www/portfolio
sudo find /var/www/portfolio -type f -exec chmod 644 {} \;
```

2. **Archivo index faltante:**
```bash
# Verificar que existe gaming-hub.html o index.html
ls -la /var/www/portfolio/

# Crear symlink si es necesario
sudo ln -sf /var/www/portfolio/gaming-hub.html /var/www/portfolio/index.html
```

3. **Configuración incorrecta:**
```bash
# Verificar configuración
sudo nano /etc/nginx/sites-available/portfolio

# Verificar que la directiva index incluye tu archivo:
index gaming-hub.html index.html index.htm;
```

### ❌ Error 502 Bad Gateway

**Síntomas:** El sitio devuelve error 502.

**Causa:** Nginx no puede servir archivos estáticos (configuración incorrecta).

**Solución:**
```bash
# Verificar configuración del sitio
sudo nginx -t

# Verificar logs de error
sudo tail -f /var/log/nginx/error.log

# Verificar que no hay upstream configurado incorrectamente
sudo grep -i upstream /etc/nginx/sites-available/portfolio

# Para sitios estáticos, NO debe haber configuración upstream
```

### ❌ Error 404 Not Found

**Síntomas:** Páginas específicas no se encuentran.

**Solución:**
```bash
# Verificar estructura de archivos
ls -la /var/www/portfolio/

# Verificar configuración try_files
sudo grep try_files /etc/nginx/sites-available/portfolio

# Debería ser algo como:
try_files $uri $uri/ =404;

# Verificar logs de acceso
sudo tail -f /var/log/nginx/access.log
```

---

## 🔧 Problemas de Permisos

### ❌ "Permission denied" al escribir archivos

**Síntomas:**
```
cp: cannot create regular file '/var/www/portfolio/index.html': Permission denied
```

**Diagnóstico:**
```bash
# Verificar permisos actuales
ls -la /var/www/portfolio/
ls -ld /var/www/portfolio/

# Verificar propietario
stat /var/www/portfolio/
```

**Solución:**
```bash
# Configurar permisos correctos
sudo chown -R www-data:www-data /var/www/portfolio
sudo chmod -R 755 /var/www/portfolio

# Agregar Jenkins al grupo www-data
sudo usermod -a -G www-data jenkins

# Verificar grupos de Jenkins
groups jenkins

# Configurar permisos de grupo
sudo chmod -R g+w /var/www/portfolio
sudo chmod g+s /var/www/portfolio
```

### ❌ Jenkins no puede ejecutar sudo

**Síntomas:**
```
sudo: no tty present and no askpass program specified
```

**Solución completa:**
```bash
# Crear archivo sudoers específico
sudo tee /etc/sudoers.d/jenkins << 'EOF'
# Jenkins CI/CD permissions
jenkins ALL=(ALL) NOPASSWD: ALL

# Más restrictivo (recomendado):
# jenkins ALL=(ALL) NOPASSWD: /bin/cp, /bin/mv, /bin/rm, /bin/mkdir, /bin/chown, /bin/chmod
# jenkins ALL=(ALL) NOPASSWD: /usr/sbin/nginx, /bin/systemctl reload nginx, /bin/systemctl restart nginx
# jenkins ALL=(ALL) NOPASSWD: /usr/bin/tee, /bin/tar
EOF

# Verificar sintaxis
sudo visudo -c

# Probar como usuario jenkins
sudo -u jenkins sudo whoami
```

---

## 🔧 Problemas de Red

### ❌ No se puede acceder desde el navegador

**Diagnóstico:**
```bash
# Verificar que Jenkins está corriendo
sudo systemctl status jenkins

# Verificar puerto
sudo netstat -tlnp | grep :8080

# Verificar desde local
curl -I http://localhost:8080

# Verificar firewall
sudo ufw status
```

**Soluciones:**

1. **Configurar firewall:**
```bash
sudo ufw allow 8080
sudo ufw allow 80
sudo ufw reload
```

2. **Verificar bind address:**
```bash
sudo nano /etc/default/jenkins
# Verificar: HTTP_HOST=0.0.0.0 (no 127.0.0.1)
```

3. **Reiniciar servicios:**
```bash
sudo systemctl restart jenkins
sudo systemctl restart nginx
```

### ❌ Error de conexión intermitente

**Causa:** Recursos insuficientes del servidor.

**Solución:**
```bash
# Verificar recursos
free -h
df -h
iostat 1 5

# Optimizar Jenkins
sudo nano /etc/default/jenkins
# Ajustar memoria:
JAVA_ARGS="-Xmx1024m -Xms512m"

# Limpiar builds antiguos
# En Jenkins UI: Manage Jenkins > System Configuration
```

---

## 🔧 Problemas de Performance

### ❌ Jenkins muy lento

**Causas comunes:**
- Memoria insuficiente
- Disco lleno
- Muchos plugins instalados
- Builds antiguos acumulados

**Soluciones:**

1. **Optimizar memoria:**
```bash
sudo nano /etc/default/jenkins
# Aumentar memoria:
JAVA_ARGS="-Xmx2048m -Xms1024m -XX:+AlwaysPreTouch"
```

2. **Limpiar disco:**
```bash
# Limpiar logs antiguos
sudo journalctl --vacuum-time=7d

# Limpiar builds antiguos
find /var/lib/jenkins/jobs -name "builds" -type d -exec sudo rm -rf {}/* \;

# Limpiar workspace
sudo rm -rf /var/lib/jenkins/workspace/*
```

3. **Optimizar plugins:**
```bash
# En Jenkins UI: Manage Jenkins > Manage Plugins
# Desinstalar plugins no utilizados
```

### ❌ Builds muy lentos

**Optimizaciones:**

1. **Pipeline paralelo:**
```groovy
stage('Tests') {
    parallel {
        stage('Unit Tests') {
            steps { /* tests */ }
        }
        stage('Integration Tests') {
            steps { /* tests */ }
        }
    }
}
```

2. **Cache de dependencias:**
```groovy
// En Jenkinsfile, usar directorios cache
dir('/tmp/cache') {
    // Download dependencies
}
```

3. **Workspace limpio:**
```groovy
options {
    skipDefaultCheckout(true)
}
steps {
    cleanWs()
    checkout scm
}
```

---

## 🔧 Comandos de Diagnóstico

### 🔍 Diagnóstico General
```bash
#!/bin/bash
echo "🔍 DIAGNÓSTICO GENERAL DEL SISTEMA"
echo "=================================="

echo "📅 Fecha y hora:"
date

echo "💻 Información del sistema:"
uname -a
lsb_release -a

echo "💾 Uso de memoria:"
free -h

echo "💿 Uso de disco:"
df -h

echo "⚡ Procesos más pesados:"
ps aux --sort=-%cpu | head -5

echo "🌐 Puertos en uso:"
sudo netstat -tlnp | grep -E ":(80|8080|443)"

echo "🔥 Estado del firewall:"
sudo ufw status

echo "📋 Servicios principales:"
for service in jenkins nginx; do
    if systemctl is-active --quiet $service; then
        echo "✅ $service: Running"
    else
        echo "❌ $service: Not running"
    fi
done

echo "🌐 Conectividad web:"
for url in "http://localhost" "http://localhost:8080"; do
    if curl -s -o /dev/null $url; then
        echo "✅ $url: OK"
    else
        echo "❌ $url: Failed"
    fi
done
```

### 🔍 Diagnóstico de Jenkins
```bash
#!/bin/bash
echo "🔍 DIAGNÓSTICO DE JENKINS"
echo "========================="

echo "📊 Estado del servicio:"
sudo systemctl status jenkins --no-pager

echo "📁 Archivos importantes:"
ls -la /var/lib/jenkins/secrets/ 2>/dev/null || echo "❌ No access to secrets"
ls -la /var/lib/jenkins/config.xml 2>/dev/null || echo "❌ No access to config"

echo "📋 Últimas líneas del log:"
sudo tail -10 /var/log/jenkins/jenkins.log 2>/dev/null || echo "❌ No access to logs"

echo "🔌 Plugins instalados:"
ls /var/lib/jenkins/plugins/*.jpi 2>/dev/null | wc -l || echo "0 plugins found"

echo "💼 Trabajos configurados:"
ls /var/lib/jenkins/jobs/ 2>/dev/null || echo "❌ No access to jobs"

echo "🏠 Espacio del workspace:"
sudo du -sh /var/lib/jenkins/workspace/ 2>/dev/null || echo "❌ No access to workspace"
```

### 🔍 Diagnóstico de Red
```bash
#!/bin/bash
echo "🔍 DIAGNÓSTICO DE RED"
echo "===================="

echo "🌐 Interfaces de red:"
ip addr show

echo "🔍 Puertos abiertos:"
sudo ss -tlnp | grep -E ":(80|8080|443)"

echo "🔥 Reglas de firewall:"
sudo ufw status numbered

echo "📡 Conectividad externa:"
ping -c 3 google.com

echo "🌍 Resolución DNS:"
nslookup github.com

echo "📊 Estadísticas de red:"
cat /proc/net/dev
```

---

## 🆘 Script de Emergencia

### 🚨 Reset Completo (¡USAR CON PRECAUCIÓN!)
```bash
#!/bin/bash
echo "🚨 RESET DE EMERGENCIA - ¿Estás seguro? (y/N)"
read -r confirm
if [[ ! $confirm =~ ^[Yy]$ ]]; then
    echo "❌ Operación cancelada"
    exit 1
fi

echo "🔄 Deteniendo servicios..."
sudo systemctl stop jenkins nginx

echo "🧹 Limpiando configuraciones..."
sudo rm -rf /var/lib/jenkins/workspace/*
sudo rm -f /etc/nginx/sites-enabled/portfolio

echo "🔧 Restaurando configuraciones por defecto..."
sudo systemctl restart jenkins nginx

echo "⏳ Esperando servicios..."
sleep 30

echo "✅ Reset completado. Verifica:"
echo "   - http://localhost:8080 (Jenkins)"
echo "   - http://localhost (Nginx)"
```

---

## 📞 ¿Necesitas Más Ayuda?

Si ninguna de estas soluciones funciona:

1. **Revisa los logs detallados:**
   ```bash
   sudo journalctl -u jenkins -f
   sudo tail -f /var/log/jenkins/jenkins.log
   ```

2. **Busca en la documentación oficial:**
   - [Jenkins Troubleshooting](https://www.jenkins.io/doc/book/system-administration/troubleshooting/)
   - [Nginx Troubleshooting](http://nginx.org/en/docs/debugging_log.html)

3. **Comunidad:**
   - [Jenkins Community](https://www.jenkins.io/participate/)
   - [Stack Overflow](https://stackoverflow.com/questions/tagged/jenkins)

4. **Contacta al instructor o equipo de soporte**

---

<div align="center">

**🔧 ¡No te rindas! Cada error es una oportunidad de aprender 🚀**

</div>
