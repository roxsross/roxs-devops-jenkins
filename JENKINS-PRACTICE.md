# 🚀 Práctica Completa de Jenkins - Despliegue de Portafolio

<div align="center">

![Jenkins Practice](https://img.shields.io/badge/Jenkins-D24939?style=for-the-badge&logo=Jenkins&logoColor=white)
![Linux](https://img.shields.io/badge/Linux-FCC624?style=for-the-badge&logo=linux&logoColor=black)
![CI/CD](https://img.shields.io/badge/CI%2FCD-025E8C?style=for-the-badge&logo=gitlab&logoColor=white)

</div>

## 📋 Objetivos de la Práctica

Al finalizar esta práctica, los estudiantes serán capaces de:

✅ **Instalar Jenkins** en un servidor Linux  
✅ **Configurar** Jenkins desde cero  
✅ **Crear pipelines** para automatizar despliegues  
✅ **Integrar Git** con Jenkins  
✅ **Desplegar** una aplicación web estática  
✅ **Monitorear** builds y logs  

---

## 🛠️ Requisitos Previos

- Servidor Linux (Ubuntu 20.04 LTS o superior)
- Acceso root o sudo
- Conexión a internet
- Git instalado
- Navegador web para acceder a Jenkins UI

---

## 📝 Duración Estimada: 2-3 horas

| Fase | Actividad | Tiempo |
|------|-----------|--------|
| 1 | Instalación de Jenkins | 30 min |
| 2 | Configuración inicial | 30 min |
| 3 | Creación del pipeline | 45 min |
| 4 | Configuración del despliegue | 45 min |
| 5 | Testing y troubleshooting | 30 min |

---

## 🎯 Fase 1: Instalación de Jenkins

### Paso 1.1: Preparación del Sistema

Antes de instalar Jenkins, actualizamos el sistema:

```bash
sudo apt update && sudo apt upgrade -y
```

### Paso 1.2: Instalación de Java

Jenkins requiere Java para funcionar:

```bash
sudo apt install openjdk-11-jdk -y
java -version
```

### Paso 1.3: Instalación de Jenkins

Agregamos el repositorio oficial de Jenkins:

```bash
wget -q -O - https://pkg.jenkins.io/debian-stable/jenkins.io.key | sudo apt-key add -
sudo sh -c 'echo deb https://pkg.jenkins.io/debian-stable binary/ > /etc/apt/sources.list.d/jenkins.list'
```

Actualizamos e instalamos Jenkins:

```bash
sudo apt update
sudo apt install jenkins -y
```

### Paso 1.4: Verificación del Servicio

```bash
sudo systemctl status jenkins
sudo systemctl enable jenkins
sudo systemctl start jenkins
```

### Paso 1.5: Configuración del Firewall

```bash
sudo ufw allow 8080
sudo ufw status
```

---

## 🔧 Fase 2: Configuración Inicial de Jenkins

### Paso 2.1: Acceso a Jenkins Web UI

1. Abre tu navegador y ve a: `http://tu-servidor-ip:8080`
2. Obten la contraseña inicial:

```bash
sudo cat /var/lib/jenkins/secrets/initialAdminPassword
```

### Paso 2.2: Configuración del Wizard

1. **Instala plugins sugeridos** - Esto instalará los plugins más comunes
2. **Crea tu usuario administrador**:
   - Username: `devops-admin`
   - Password: `DevOps2024!`
   - Nombre completo: `DevOps Administrator`
   - Email: `tu-email@ejemplo.com`

### Paso 2.3: Configuración de Jenkins URL

Configura la URL base de Jenkins: `http://tu-servidor-ip:8080`

---

## 🚀 Fase 3: Preparación del Proyecto

### Paso 3.1: Instalación de Herramientas Adicionales

```bash
# Instalar Git (si no está instalado)
sudo apt install git -y

# Instalar Nginx para servir nuestra aplicación
sudo apt install nginx -y
sudo systemctl enable nginx
sudo systemctl start nginx
```

### Paso 3.2: Configuración de Nginx

```bash
sudo nano /etc/nginx/sites-available/portfolio
```

Agrega la configuración del sitio (ver archivo nginx-portfolio.conf).

---

## 🔄 Fase 4: Creación del Pipeline de Jenkins

### Paso 4.1: Crear Nuevo Job

1. En Jenkins Dashboard, clic en "Nueva Tarea"
2. Nombre: `portfolio-deployment`
3. Tipo: "Pipeline"
4. Clic en "OK"

### Paso 4.2: Configuración del Pipeline

En la sección "Pipeline", selecciona "Pipeline script from SCM":

- **SCM**: Git
- **Repository URL**: `https://github.com/tu-usuario/tu-portfolio.git`
- **Credentials**: None (para repos públicos)
- **Branch**: `*/main`
- **Script Path**: `Jenkinsfile`

---

## 📋 Fase 5: Testing y Monitoreo

### Paso 5.1: Ejecutar el Pipeline

1. Ve a tu job `portfolio-deployment`
2. Clic en "Construir ahora"
3. Monitorea la ejecución en "Console Output"

### Paso 5.2: Verificación del Despliegue

```bash
# Verificar que Nginx está sirviendo tu sitio
curl http://localhost
curl http://tu-servidor-ip
```

### Paso 5.3: Logs y Troubleshooting

```bash
# Logs de Jenkins
sudo tail -f /var/log/jenkins/jenkins.log

# Logs de Nginx
sudo tail -f /var/log/nginx/access.log
sudo tail -f /var/log/nginx/error.log

# Estado de servicios
sudo systemctl status jenkins
sudo systemctl status nginx
```

---

## 🎮 Desafíos Adicionales

### Desafío 1: Webhook Automático
Configura un webhook en GitHub para que el pipeline se ejecute automáticamente en cada push.

### Desafío 2: Notificaciones
Configura notificaciones por email o Slack cuando el build falle o sea exitoso.

### Desafío 3: Multi-Stage Pipeline
Extiende el pipeline para incluir etapas de testing, staging y producción.

### Desafío 4: Backup Automático
Crea un job que haga backup automático de la configuración de Jenkins.

---

## 🐛 Solución de Problemas Comunes

### Error: "Jenkins no inicia"
```bash
sudo systemctl status jenkins
sudo journalctl -u jenkins -f
```

### Error: "Puerto 8080 ocupado"
```bash
sudo netstat -tlnp | grep :8080
sudo pkill -f jenkins
```

### Error: "Permisos de archivo"
```bash
sudo chown -R jenkins:jenkins /var/lib/jenkins
sudo chmod -R 755 /var/lib/jenkins
```

---

## 📚 Recursos Adicionales

- [Documentación Oficial de Jenkins](https://www.jenkins.io/doc/)
- [Pipeline Syntax Reference](https://www.jenkins.io/doc/book/pipeline/syntax/)
- [Plugin Index](https://plugins.jenkins.io/)

---

## 🏆 Entregables de la Práctica

Al completar la práctica, deberás entregar:

1. **Screenshot** del Dashboard de Jenkins funcionando
2. **URL pública** de tu portafolio desplegado
3. **Archivo Jenkinsfile** comentado
4. **Documento** con los desafíos que enfrentaste y cómo los resolviste
5. **Video de 5 minutos** demostrando todo el flujo funcionando

---

## 🎯 Criterios de Evaluación

| Criterio | Puntos | Descripción |
|----------|---------|-------------|
| Instalación correcta | 20% | Jenkins instalado y funcionando |
| Configuración | 20% | Usuario creado, plugins instalados |
| Pipeline funcional | 30% | Job ejecuta sin errores |
| Despliegue exitoso | 20% | Sitio web accesible |
| Documentación | 10% | Entregables completos |

---

<div align="center">

**¡Felicidades! 🎉**  
Has completado tu primera experiencia completa con Jenkins

**#DevOps #Jenkins #CI/CD #RoxsRoss**

</div>
