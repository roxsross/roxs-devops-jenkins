# 🚀 Práctica Completa de Jenkins CI/CD - Despliegue de Portafolio

<div align="center">

![Jenkins Practice](https://img.shields.io/badge/Jenkins-D24939?style=for-the-badge&logo=Jenkins&logoColor=white)
![Linux](https://img.shields.io/badge/Linux-FCC624?style=for-the-badge&logo=linux&logoColor=black)
![CI/CD](https://img.shields.io/badge/CI%2FCD-025E8C?style=for-the-badge&logo=gitlab&logoColor=white)
![Nginx](https://img.shields.io/badge/nginx-%23009639.svg?style=for-the-badge&logo=nginx&logoColor=white)

**Una experiencia completa de aprendizaje de Jenkins CI/CD**  
*Sin contenedores - Instalación nativa en Linux*

</div>

---

## 🎯 ¿Qué vas a lograr?

✅ **Instalar Jenkins** desde cero en un servidor Linux  
✅ **Configurar** pipelines de CI/CD declarativos  
✅ **Automatizar** el despliegue de un portafolio web  
✅ **Integrar** Git con Jenkins para deployments automáticos  
✅ **Configurar** Nginx como servidor web  
✅ **Implementar** mejores prácticas de DevOps  
✅ **Monitorear** y troubleshoot pipelines  

---

## 🚀 ¡Empezá ahora mismo!

### Opción 1: Validación y Setup Automático

```bash
# 1. Clonar repositorio
git clone <URL-del-repositorio>
cd roxs-devops-jenkins

# 2. Validar entorno
./validate-environment.sh

# 3. Instalar Jenkins
sudo ./install-jenkins.sh

# 4. Configurar entorno
sudo ./setup-environment.sh
```

### Opción 2: Setup Manual Paso a Paso

Sigue la **[Guía Paso a Paso](GUIA-PASO-A-PASO.md)** para una experiencia de aprendizaje completa.

---

## 📁 ¿Qué incluye este proyecto?

| Archivo | Descripción |
|---------|-------------|
| **📚 Documentación** | |
| `JENKINS-PRACTICE.md` | Descripción completa de la práctica |
| `GUIA-PASO-A-PASO.md` | Tutorial detallado paso a paso |
| `TROUBLESHOOTING.md` | Guía de solución de problemas |
| `COMANDOS-UTILES.md` | Comandos de referencia y administración |
| **🔧 Scripts de Instalación** | |
| `install-jenkins.sh` | Instalación automatizada de Jenkins |
| `setup-environment.sh` | Configuración del entorno completo |
| `validate-environment.sh` | Validación del sistema antes de comenzar |
| **⚙️ Configuración** | |
| `Jenkinsfile` | Pipeline completo de CI/CD |
| `nginx-portfolio.conf` | Configuración optimizada de Nginx |
| **🎨 Aplicación** | |
| `site/gaming-hub.html` | Portafolio web a desplegar |

---

## 📋 Requisitos Previos

- **Servidor Linux** (Ubuntu 20.04 LTS o superior recomendado)
- **Acceso root/sudo** al servidor
- **2GB RAM mínimo** (4GB recomendado)
- **10GB espacio libre** en disco
- **Conexión a internet** estable
- **Navegador web** para acceder a Jenkins UI

---

## 🏗️ Flujo de la Práctica

### 📝 Duración Estimada: 2-3 horas

| Fase | Actividad | Tiempo |
|------|-----------|--------|
| 1 | Validación y preparación | 15 min |
| 2 | Instalación de Jenkins | 30 min |
| 3 | Configuración inicial | 30 min |
| 4 | Creación del pipeline | 45 min |
| 5 | Configuración del despliegue | 45 min |
| 6 | Testing y troubleshooting | 30 min |

---

## 🛠️ Instalación Paso a Paso

### Paso 1: Validar el Entorno

```bash
# Ejecutar validación completa del sistema
./validate-environment.sh
```

Este script verificará:
- ✅ Sistema operativo compatible
- ✅ Permisos de usuario
- ✅ Conectividad a internet
- ✅ Recursos del sistema (RAM, disco)
- ✅ Herramientas necesarias

### Paso 2: Instalar Jenkins

```bash
# Instalación automatizada completa
sudo ./install-jenkins.sh
```

Incluye:
- ☕ **Java 11** (OpenJDK)
- 🔧 **Jenkins LTS** última versión
- 🌐 **Nginx** para el portafolio
- 🔥 **Configuración de firewall**
- 📝 **Scripts de administración**

### Paso 3: Configurar el Entorno

```bash
# Configurar directorios, permisos y Nginx
sudo ./setup-environment.sh
```

Configura:
- 📁 Directorios de despliegue
- 🔐 Permisos de Jenkins
- 🌐 Virtual host de Nginx
- 📦 Scripts de ayuda

### Paso 4: Acceder a Jenkins

```bash
# Obtener información de acceso
sudo cat /root/jenkins-info.txt
```

1. **Abrir navegador**: `http://TU-IP-SERVIDOR:8080`
2. **Contraseña inicial**: Se muestra en el archivo de info
3. **Seguir wizard** de configuración inicial

---

## 🔄 Pipeline de CI/CD

### 🏗️ Etapas del Pipeline

El `Jenkinsfile` incluido implementa un pipeline completo con:

```groovy
pipeline {
    stages {
        stage('🧹 Cleanup') { /* Limpieza del workspace */ }
        stage('📥 Checkout') { /* Descarga del código */ }
        stage('🔍 Analysis') { /* Análisis de código */ }
        stage('🔧 Prepare') { /* Preparación del despliegue */ }
        stage('🚀 Deploy') { /* Despliegue de la aplicación */ }
        stage('🌐 Configure') { /* Configuración de Nginx */ }
        stage('🧪 Testing') { /* Pruebas de funcionamiento */ }
    }
}
```

### 🎯 Características del Pipeline

- **🔄 Rollback automático** en caso de fallo
- **📊 Información detallada** de cada build
- **🧪 Tests automáticos** de funcionamiento
- **📈 Métricas** de despliegue
- **🔍 Logs detallados** para debugging

---

## 🎮 Aplicación de Ejemplo

El portafolio incluido (`site/gaming-hub.html`) es una aplicación web moderna con:

- **🎨 Diseño responsive** y atractivo
- **⚡ Carga rápida** y optimizada
- **🎮 Temática gaming** y DevOps
- **📱 Compatible** con móviles y desktop

### 🔧 Personalización

Puedes personalizar el portafolio:

1. **Editar** `site/gaming-hub.html`
2. **Hacer commit** y push a tu repositorio
3. **Ejecutar pipeline** en Jenkins
4. **Ver cambios** desplegados automáticamente

---

## 📊 Monitoreo y Administración

### 🔍 Scripts de Monitoreo

```bash
# Ver estado general
jenkins-status
portfolio-status

# Monitorear logs en tiempo real
jenkins-logs
portfolio-logs

# Verificar health check
health-check
```

### 📈 URLs de Monitoreo

- **Jenkins UI**: `http://tu-servidor:8080`
- **Portafolio**: `http://tu-servidor`
- **Build Info**: `http://tu-servidor/build-info`
- **Status API**: `http://tu-servidor/status`
- **Health Check**: `http://tu-servidor/health`

---

## 🏆 Desafíos Avanzados

### 🎯 Nivel Principiante
1. **Modificar el portafolio** y ver el despliegue automático
2. **Configurar notificaciones** por email
3. **Agregar más pruebas** al pipeline

### 🎯 Nivel Intermedio
4. **Configurar webhook** para builds automáticos
5. **Implementar múltiples entornos** (dev, staging, prod)
6. **Agregar análisis de código** estático

### 🎯 Nivel Avanzado
7. **Configurar HTTPS** con certificados SSL
8. **Implementar blue-green deployment**
9. **Configurar monitoreo** con Prometheus/Grafana

---

## 🆘 Solución de Problemas

### 🔧 Recursos de Ayuda

- **[📖 Troubleshooting Guide](TROUBLESHOOTING.md)**: Soluciones a problemas comunes
- **[⚡ Comandos Útiles](COMANDOS-UTILES.md)**: Comandos de administración
- **[📚 Guía Completa](GUIA-PASO-A-PASO.md)**: Tutorial paso a paso

### 🚨 Comandos de Emergencia

```bash
# Restart completo de servicios
sudo systemctl restart jenkins nginx

# Verificar estado del sistema
./validate-environment.sh

# Logs de debugging
sudo journalctl -u jenkins -f
```

---

## 🎓 Entregables de la Práctica

### 📋 Lista de Entregables

1. **📸 Screenshots** del Dashboard de Jenkins funcionando
2. **🌐 URL pública** del portafolio desplegado
3. **📄 Jenkinsfile comentado** explicando cada etapa
4. **📝 Documento de troubleshooting** con problemas y soluciones
5. **🎥 Video demo** de 5 minutos mostrando el flujo completo

### 🏅 Criterios de Evaluación

| Criterio | Peso | Descripción |
|----------|------|-------------|
| **Instalación** | 20% | Jenkins instalado y funcionando |
| **Configuración** | 20% | Usuario creado, plugins instalados |
| **Pipeline** | 30% | Jenkinsfile funcional, pipeline ejecuta sin errores |
| **Despliegue** | 20% | Sitio web accesible y actualizable |
| **Documentación** | 10% | Entregables completos y bien documentados |

**Bonus Points:**
- **Webhook automático**: +5%
- **Notificaciones**: +5%
- **Multi-stage pipeline**: +10%
- **Monitoreo avanzado**: +5%

---

## 🌟 ¿Por qué esta práctica es especial?

### 🎯 Enfoque Práctico
- **Sin contenedores**: Instalación nativa para aprender los fundamentos
- **Automatización completa**: Scripts para todo el proceso
- **Experiencia real**: Como se hace en entornos empresariales

### 📚 Aprendizaje Integral
- **Jenkins**: Desde instalación hasta pipelines avanzados
- **Linux**: Administración de servicios y permisos
- **Nginx**: Configuración de servidor web
- **Git**: Integración con sistemas de control de versiones
- **DevOps**: Mejores prácticas de CI/CD

### 🛠️ Herramientas Incluidas
- **Scripts automatizados** para todo el proceso
- **Documentación completa** con ejemplos
- **Troubleshooting guide** para problemas comunes
- **Validation scripts** para verificar configuración

---

## 💡 Próximos Pasos

Después de completar esta práctica, estarás listo para:

- **🚀 Implementar CI/CD** en proyectos reales
- **🔧 Administrar Jenkins** en entornos de producción
- **🌐 Configurar servidores web** avanzados
- **📊 Monitorear** y optimizar pipelines
- **🏗️ Diseñar arquitecturas** de despliegue

---

## 📞 Soporte y Comunidad

- **📧 Contacto**: Instructor o equipo de soporte
- **💬 Comunidad**: [Jenkins Community](https://www.jenkins.io/participate/)
- **📚 Docs**: [Documentación oficial](https://www.jenkins.io/doc/)
- **🐛 Issues**: Reportar problemas en el repositorio

---

<div align="center">

**🎉 ¡Felicidades por embarcarte en esta aventura DevOps! 🚀**

**¡Que disfrutes aprendiendo Jenkins CI/CD!**

---

**#DevOps #Jenkins #CICD #RoxsRoss #Automation #Learning**

**⭐ Si te gusta este proyecto, ¡dale una estrella! ⭐**

</div>
