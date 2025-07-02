# 🛠️ Comandos Útiles para la Práctica de Jenkins

## 🔧 Gestión de Jenkins

### Instalación y Estado
```bash
# Verificar estado de Jenkins
sudo systemctl status jenkins

# Iniciar Jenkins
sudo systemctl start jenkins

# Detener Jenkins
sudo systemctl stop jenkins

# Reiniciar Jenkins
sudo systemctl restart jenkins

# Habilitar inicio automático
sudo systemctl enable jenkins

# Ver logs de Jenkins
sudo journalctl -u jenkins -f

# Ver logs de Jenkins (archivo)
sudo tail -f /var/log/jenkins/jenkins.log

# Verificar puerto de Jenkins
sudo netstat -tlnp | grep :8080
```

### Configuración de Jenkins
```bash
# Ubicación de archivos de configuración
ls -la /var/lib/jenkins/

# Ver contraseña inicial
sudo cat /var/lib/jenkins/secrets/initialAdminPassword

# Backup de configuración de Jenkins
sudo tar -czf jenkins-backup-$(date +%Y%m%d).tar.gz -C /var/lib jenkins/

# Restaurar backup
sudo tar -xzf jenkins-backup-YYYYMMDD.tar.gz -C /var/lib

# Cambiar puerto de Jenkins
sudo nano /etc/default/jenkins
# Modificar: HTTP_PORT=8080
sudo systemctl restart jenkins
```

---

## 🌐 Gestión de Nginx

### Control del Servicio
```bash
# Estado de Nginx
sudo systemctl status nginx

# Iniciar Nginx
sudo systemctl start nginx

# Detener Nginx
sudo systemctl stop nginx

# Reiniciar Nginx
sudo systemctl restart nginx

# Recargar configuración (sin detener)
sudo systemctl reload nginx

# Verificar configuración
sudo nginx -t

# Ver procesos de Nginx
ps aux | grep nginx
```

### Configuración y Logs
```bash
# Editar configuración principal
sudo nano /etc/nginx/nginx.conf

# Editar configuración del sitio
sudo nano /etc/nginx/sites-available/portfolio

# Habilitar sitio
sudo ln -s /etc/nginx/sites-available/portfolio /etc/nginx/sites-enabled/

# Deshabilitar sitio
sudo rm /etc/nginx/sites-enabled/portfolio

# Ver logs de acceso
sudo tail -f /var/log/nginx/access.log

# Ver logs de error
sudo tail -f /var/log/nginx/error.log

# Ver logs específicos del portfolio
sudo tail -f /var/log/nginx/portfolio.access.log
sudo tail -f /var/log/nginx/portfolio.error.log

# Limpiar logs
sudo truncate -s 0 /var/log/nginx/*.log
```

---

## 📁 Gestión de Archivos y Permisos

### Directorio del Portfolio
```bash
# Ver contenido del portfolio
ls -la /var/www/portfolio/

# Cambiar propietario
sudo chown -R www-data:www-data /var/www/portfolio

# Configurar permisos correctos
sudo chmod -R 755 /var/www/portfolio
sudo find /var/www/portfolio -type f -exec chmod 644 {} \;

# Backup manual del sitio
sudo tar -czf portfolio-backup-$(date +%Y%m%d_%H%M%S).tar.gz -C /var/www portfolio/

# Restaurar desde backup
sudo tar -xzf portfolio-backup-YYYYMMDD_HHMMSS.tar.gz -C /var/www/

# Sincronizar archivos desde repositorio
rsync -av --delete site/ /var/www/portfolio/
```

### Permisos de Jenkins
```bash
# Verificar permisos de Jenkins
sudo -u jenkins test -w /var/www/portfolio && echo "OK" || echo "NO WRITE PERMISSION"

# Agregar Jenkins a grupo www-data
sudo usermod -a -G www-data jenkins

# Ver grupos de Jenkins
groups jenkins

# Verificar configuración sudo
sudo cat /etc/sudoers.d/jenkins

# Probar comando sudo como Jenkins
sudo -u jenkins sudo nginx -t
```

---

## 🔍 Diagnóstico y Troubleshooting

### Verificación de Red
```bash
# Verificar conectividad local
curl -I http://localhost
curl -I http://localhost:8080

# Verificar desde IP externa
curl -I http://$(hostname -I | awk '{print $1}')

# Verificar puertos abiertos
sudo netstat -tlnp | grep -E ":(80|8080|443)"

# Verificar firewall
sudo ufw status

# Verificar DNS
nslookup $(hostname)

# Test de velocidad de respuesta
curl -w "@curl-format.txt" -o /dev/null -s http://localhost
```

### Monitoreo de Recursos
```bash
# Uso de CPU y memoria
htop

# Uso de disco
df -h

# Espacio usado por Jenkins
sudo du -sh /var/lib/jenkins/

# Espacio usado por logs
sudo du -sh /var/log/

# Procesos que más consumen
ps aux --sort=-%cpu | head -10
ps aux --sort=-%mem | head -10

# Información del sistema
uname -a
lsb_release -a
```

### Logs y Debugging
```bash
# Ver todos los logs del sistema
sudo journalctl -f

# Logs específicos de servicios
sudo journalctl -u jenkins -f
sudo journalctl -u nginx -f

# Logs de último boot
sudo journalctl -b

# Buscar errores en logs
sudo grep -i error /var/log/jenkins/jenkins.log
sudo grep -i error /var/log/nginx/error.log

# Monitorear archivos de log en tiempo real
sudo multitail /var/log/jenkins/jenkins.log /var/log/nginx/error.log
```

---

## 🔄 Git y Repositorios

### Comandos Git Básicos
```bash
# Clonar repositorio
git clone <URL>

# Ver estado
git status

# Agregar cambios
git add .

# Hacer commit
git commit -m "Mensaje del commit"

# Enviar cambios
git push origin main

# Actualizar desde remoto
git pull origin main

# Ver historial
git log --oneline

# Ver diferencias
git diff

# Crear branch
git checkout -b nueva-funcionalidad

# Cambiar branch
git checkout main
```

### Integración con Jenkins
```bash
# Configurar credenciales Git (si es necesario)
git config --global user.name "Tu Nombre"
git config --global user.email "tu-email@ejemplo.com"

# Verificar configuración
git config --list

# Crear clave SSH (si es necesario)
ssh-keygen -t rsa -b 4096 -C "tu-email@ejemplo.com"

# Ver clave pública
cat ~/.ssh/id_rsa.pub

# Probar conexión SSH
ssh -T git@github.com
```

---

## 🧪 Testing y Validación

### Tests de Funcionamiento
```bash
# Test básico HTTP
curl -s -o /dev/null -w "%{http_code}\n" http://localhost

# Test con headers detallados
curl -I http://localhost

# Test de rendimiento básico
time curl -s http://localhost > /dev/null

# Test de carga (requiere apache2-utils)
sudo apt install apache2-utils
ab -n 100 -c 10 http://localhost/

# Verificar SSL (si está configurado)
curl -I https://localhost

# Test de DNS
dig $(hostname)
```

### Validación de Configuración
```bash
# Validar Jenkinsfile (desde el directorio del proyecto)
jenkins-cli declarative-linter < Jenkinsfile

# Validar HTML
which tidy > /dev/null && find /var/www/portfolio -name "*.html" -exec tidy -errors {} \;

# Validar CSS
which csslint > /dev/null && find /var/www/portfolio -name "*.css" -exec csslint {} \;

# Verificar enlaces rotos
which linkchecker > /dev/null && linkchecker http://localhost
```

---

## 🚀 Automatización y Scripts

### Scripts Personalizados
```bash
# Script de despliegue rápido
echo '#!/bin/bash
git pull origin main
sudo cp -r site/* /var/www/portfolio/
sudo systemctl reload nginx
echo "✅ Despliegue completado"' | sudo tee /usr/local/bin/quick-deploy
sudo chmod +x /usr/local/bin/quick-deploy

# Script de backup automático
echo '#!/bin/bash
BACKUP_DIR="/var/backups/jenkins-portfolio"
DATE=$(date +%Y%m%d_%H%M%S)
mkdir -p $BACKUP_DIR
tar -czf $BACKUP_DIR/jenkins-$DATE.tar.gz -C /var/lib jenkins/
tar -czf $BACKUP_DIR/portfolio-$DATE.tar.gz -C /var/www portfolio/
echo "✅ Backup creado: $DATE"' | sudo tee /usr/local/bin/daily-backup
sudo chmod +x /usr/local/bin/daily-backup

# Programar backup diario (crontab)
echo "0 2 * * * /usr/local/bin/daily-backup" | sudo crontab -
```

### Monitoreo Automático
```bash
# Script de health check
echo '#!/bin/bash
echo "🏥 Health Check - $(date)"
echo "========================"

# Jenkins
if systemctl is-active --quiet jenkins; then
    echo "✅ Jenkins: Running"
else
    echo "❌ Jenkins: Not running"
fi

# Nginx
if systemctl is-active --quiet nginx; then
    echo "✅ Nginx: Running"
else
    echo "❌ Nginx: Not running"
fi

# Web response
if curl -s -o /dev/null http://localhost; then
    echo "✅ Website: Responding"
else
    echo "❌ Website: Not responding"
fi

# Disk space
DISK_USAGE=$(df / | awk "NR==2 {print \$5}" | sed "s/%//")
if [ $DISK_USAGE -lt 80 ]; then
    echo "✅ Disk: ${DISK_USAGE}% used"
else
    echo "⚠️ Disk: ${DISK_USAGE}% used (Warning)"
fi' | sudo tee /usr/local/bin/health-check
sudo chmod +x /usr/local/bin/health-check
```

---

## 🛡️ Seguridad

### Configuración de Seguridad Básica
```bash
# Actualizar sistema
sudo apt update && sudo apt upgrade -y

# Configurar firewall básico
sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw allow ssh
sudo ufw allow 80
sudo ufw allow 8080
sudo ufw enable

# Verificar servicios activos
sudo netstat -tlnp

# Cambiar contraseña de Jenkins (desde la UI)
# Jenkins > Manage Jenkins > Manage Users

# Deshabilitar usuario root SSH (opcional)
sudo nano /etc/ssh/sshd_config
# PermitRootLogin no
sudo systemctl restart ssh
```

### Logs de Seguridad
```bash
# Ver intentos de login SSH
sudo grep "Failed password" /var/log/auth.log

# Ver accesos exitosos SSH
sudo grep "Accepted" /var/log/auth.log

# Monitorear accesos a Jenkins
sudo grep "login" /var/log/jenkins/jenkins.log

# Ver intentos de acceso web
sudo grep "401\|403\|404" /var/log/nginx/access.log
```

---

## 📊 Métricas y Reporting

### Estadísticas de Jenkins
```bash
# Número total de builds
find /var/lib/jenkins/jobs -name "nextBuildNumber" -exec cat {} \; | awk '{sum+=$1} END {print "Total builds: " sum}'

# Builds por día (últimos 7 días)
find /var/lib/jenkins/jobs -name "build.xml" -newermt "7 days ago" | wc -l

# Tamaño del workspace de Jenkins
sudo du -sh /var/lib/jenkins/workspace/
```

### Estadísticas Web
```bash
# Requests por hora (última hora)
sudo awk -v date="$(date -d '1 hour ago' '+%d/%b/%Y:%H')" '$4 ~ date' /var/log/nginx/access.log | wc -l

# IPs más frecuentes
sudo awk '{print $1}' /var/log/nginx/access.log | sort | uniq -c | sort -nr | head -10

# Páginas más visitadas
sudo awk '{print $7}' /var/log/nginx/access.log | sort | uniq -c | sort -nr | head -10

# Códigos de respuesta
sudo awk '{print $9}' /var/log/nginx/access.log | sort | uniq -c | sort -nr
```

---

## 🔧 Comandos de Emergencia

### Recuperación Rápida
```bash
# Reiniciar todos los servicios
sudo systemctl restart jenkins nginx

# Limpiar espacio en disco
sudo apt autoremove -y
sudo apt autoclean
sudo journalctl --vacuum-time=7d

# Restaurar configuración por defecto de Nginx
sudo cp /etc/nginx/nginx.conf.bak /etc/nginx/nginx.conf 2>/dev/null || echo "No backup found"

# Resetear permisos
sudo chown -R jenkins:jenkins /var/lib/jenkins
sudo chown -R www-data:www-data /var/www/portfolio
sudo chmod -R 755 /var/www/portfolio

# Verificar integridad del sistema
sudo fsck -f /dev/sda1  # ¡CUIDADO! Solo en emergencia
```

### Rollback de Emergencia
```bash
# Rollback usando backup más reciente
LATEST_BACKUP=$(ls -t /var/backups/portfolio/portfolio_backup_*.tar.gz 2>/dev/null | head -1)
if [ -n "$LATEST_BACKUP" ]; then
    sudo rm -rf /var/www/portfolio/*
    sudo tar -xzf "$LATEST_BACKUP" -C /var/www/
    sudo systemctl reload nginx
    echo "✅ Rollback completado desde: $LATEST_BACKUP"
else
    echo "❌ No se encontró backup para rollback"
fi
```

---

> **💡 Consejo**: Guarda estos comandos en un archivo de referencia y personalízalos según tu entorno específico. Siempre haz backup antes de ejecutar comandos de modificación en producción.

---

<div align="center">

**🛠️ Happy DevOps! 🚀**

</div>
