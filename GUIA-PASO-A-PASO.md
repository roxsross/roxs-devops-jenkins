# 📚 Guía Paso a Paso - Práctica de Jenkins

## 🎯 Objetivo
Aprender a instalar, configurar y usar Jenkins para automatizar el despliegue de un portafolio web usando CI/CD.

---

## 📋 Pre-requisitos

✅ **Servidor Linux** (Ubuntu 20.04 LTS o superior)  
✅ **Acceso root/sudo** al servidor  
✅ **Conexión a internet** estable  
✅ **Navegador web** para acceder a Jenkins  
✅ **Terminal/SSH** para ejecutar comandos  

---

## 🚀 FASE 1: Preparación del Servidor

### Paso 1.1: Conectarse al servidor
```bash
# Si es un servidor remoto:
ssh usuario@ip-del-servidor

# Si es local, abrir terminal
```

### Paso 1.2: Actualizar el sistema
```bash
sudo apt update && sudo apt upgrade -y
```

### Paso 1.3: Clonar el repositorio de la práctica
```bash
git clone <URL-del-repositorio>
cd roxs-devops-jenkins
```

---

## 🔧 FASE 2: Instalación Automatizada

### Paso 2.1: Ejecutar script de instalación
```bash
# Hacer ejecutable el script
chmod +x install-jenkins.sh

# Ejecutar la instalación
sudo ./install-jenkins.sh
```

⏳ **Tiempo estimado**: 15-20 minutos

### Paso 2.2: Verificar la instalación
```bash
# Verificar estado de Jenkins
sudo systemctl status jenkins

# Verificar que el puerto esté abierto
sudo netstat -tlnp | grep :8080
```

### Paso 2.3: Obtener información de acceso
```bash
# Ver archivo con información completa
sudo cat /root/jenkins-info.txt

# O directamente la contraseña inicial
sudo cat /var/lib/jenkins/secrets/initialAdminPassword
```

---

## 🌐 FASE 3: Configuración Inicial de Jenkins

### Paso 3.1: Acceder a Jenkins Web UI
1. Abre tu navegador
2. Ve a: `http://TU-IP-SERVIDOR:8080`
3. Introduce la contraseña inicial obtenida en el paso anterior

### Paso 3.2: Configurar Jenkins
1. **Selecciona**: "Install suggested plugins"
2. **Espera** a que se instalen los plugins (5-10 minutos)
3. **Crea usuario administrador**:
   - Username: `devops-admin`
   - Password: `DevOps2024!`
   - Confirm password: `DevOps2024!`
   - Full name: `DevOps Administrator`
   - E-mail: `tu-email@ejemplo.com`

### Paso 3.3: Configurar URL de Jenkins
- Confirma la URL: `http://TU-IP-SERVIDOR:8080`
- Clic en "Save and Finish"
- Clic en "Start using Jenkins"

---

## 🏗️ FASE 4: Preparación del Entorno

### Paso 4.1: Configurar el entorno del portafolio
```bash
# Hacer ejecutable el script de configuración
chmod +x setup-environment.sh

# Ejecutar configuración del entorno
sudo ./setup-environment.sh
```

### Paso 4.2: Verificar la configuración
```bash
# Usar el script de estado
portfolio-status

# O verificar manualmente
curl http://localhost
```

---

## 🔄 FASE 5: Crear el Pipeline de Jenkins

### Paso 5.1: Crear nuevo Job
1. En Jenkins Dashboard, clic en **"Nueva tarea"**
2. Nombre del item: `portfolio-deployment`
3. Seleccionar: **"Pipeline"**
4. Clic en **"OK"**

### Paso 5.2: Configurar el Pipeline
1. **Descripción**: `Pipeline para despliegue automático del portafolio`
2. En la sección **"Pipeline"**:
   - Definition: `Pipeline script from SCM`
   - SCM: `Git`
   - Repository URL: `URL-de-tu-repositorio`
   - Credentials: `None` (si es público)
   - Branch Specifier: `*/main` o `*/master`
   - Script Path: `Jenkinsfile`

### Paso 5.3: Guardar configuración
- Clic en **"Guardar"**

---

## ▶️ FASE 6: Ejecutar el Pipeline

### Paso 6.1: Primera ejecución
1. En la página del job `portfolio-deployment`
2. Clic en **"Construir ahora"**
3. Observar la ejecución en tiempo real:
   - Clic en el número del build (ej: #1)
   - Clic en **"Console Output"**

### Paso 6.2: Monitorear la ejecución
```bash
# En otra terminal, monitorear logs
jenkins-logs

# Ver estado del portafolio
portfolio-status

# Ver logs de Nginx
portfolio-logs
```

### Paso 6.3: Verificar el resultado
1. **Verificar en navegador**: `http://TU-IP-SERVIDOR`
2. **Verificar build info**: `http://TU-IP-SERVIDOR/build-info`
3. **Verificar status**: `http://TU-IP-SERVIDOR/status`

---

## 🎮 FASE 7: Desafíos Prácticos

### Desafío 1: Modificar el Portafolio
1. Edita el archivo `site/gaming-hub.html`
2. Haz commit y push a tu repositorio
3. Ejecuta el pipeline nuevamente
4. Verifica que los cambios se desplieguen

### Desafío 2: Configurar Webhook Automático
1. En GitHub/GitLab, ve a Settings → Webhooks
2. URL: `http://TU-IP-SERVIDOR:8080/github-webhook/`
3. Content type: `application/json`
4. Events: `Just the push event`

### Desafío 3: Agregar Notificaciones
1. Instalar plugin de Slack o Email
2. Configurar notificaciones en el Jenkinsfile
3. Probar notificaciones de éxito y fallo

---

## 🔍 FASE 8: Troubleshooting

### Problemas Comunes y Soluciones

#### 🚨 Jenkins no inicia
```bash
# Verificar estado
sudo systemctl status jenkins

# Ver logs
sudo journalctl -u jenkins -f

# Reiniciar servicio
sudo systemctl restart jenkins
```

#### 🚨 Pipeline falla en permisos
```bash
# Verificar permisos de Jenkins
sudo ls -la /var/www/portfolio
sudo chown -R jenkins:www-data /var/www/portfolio

# Verificar sudoers
sudo cat /etc/sudoers.d/jenkins
```

#### 🚨 Nginx no sirve el sitio
```bash
# Verificar configuración
sudo nginx -t

# Verificar estado
sudo systemctl status nginx

# Recargar configuración
sudo systemctl reload nginx
```

#### 🚨 Puerto 8080 ocupado
```bash
# Ver qué usa el puerto
sudo netstat -tlnp | grep :8080

# Cambiar puerto de Jenkins (si es necesario)
sudo nano /etc/default/jenkins
# Modificar HTTP_PORT=8080 por otro puerto
sudo systemctl restart jenkins
```

---

## 📊 FASE 9: Monitoreo y Métricas

### Comandos útiles para monitoreo:
```bash
# Estado general
jenkins-status
portfolio-status

# Logs en tiempo real
jenkins-logs
portfolio-logs

# Verificar rendimiento
curl -w "@curl-format.txt" -o /dev/null -s http://localhost

# Verificar espacio en disco
df -h

# Verificar memoria
free -h
```

### Métricas importantes a monitorear:
- **Build success rate**: % de builds exitosos
- **Build duration**: Tiempo promedio de ejecución
- **Deployment frequency**: Frecuencia de despliegues
- **Mean time to recovery**: Tiempo promedio de recuperación

---

## 🏆 FASE 10: Entregables

### Documentos a entregar:

1. **Screenshot del Dashboard de Jenkins** funcionando
2. **URL pública del portafolio** desplegado
3. **Jenkinsfile comentado** explicando cada etapa
4. **Documento de troubleshooting** con problemas encontrados y soluciones
5. **Video demo de 5 minutos** mostrando:
   - Jenkins funcionando
   - Ejecución del pipeline
   - Sitio web desplegado
   - Modificación y redespliegue

### Formato del documento de troubleshooting:
```markdown
# Troubleshooting - Práctica Jenkins

## Problemas Encontrados

### Problema 1: [Descripción]
- **Error**: [Mensaje de error exacto]
- **Causa**: [Análisis de la causa]
- **Solución**: [Pasos para resolverlo]
- **Prevención**: [Cómo evitarlo en el futuro]

### Problema 2: [Descripción]
...
```

---

## 🎯 Criterios de Evaluación

| Criterio | Peso | Descripción |
|----------|------|-------------|
| **Instalación** | 20% | Jenkins instalado y funcionando correctamente |
| **Configuración** | 20% | Usuario creado, plugins instalados, seguridad configurada |
| **Pipeline** | 30% | Jenkinsfile funcional, pipeline ejecuta sin errores |
| **Despliegue** | 20% | Sitio web accesible y actualizable |
| **Documentación** | 10% | Entregables completos y bien documentados |

### Puntuación extra (Bonus):
- **Webhook automático**: +5%
- **Notificaciones**: +5%
- **Multi-stage pipeline**: +10%
- **Monitoreo avanzado**: +5%

---

## 📚 Recursos Adicionales

### Documentación oficial:
- [Jenkins User Documentation](https://www.jenkins.io/doc/)
- [Pipeline Syntax](https://www.jenkins.io/doc/book/pipeline/syntax/)
- [Plugin Index](https://plugins.jenkins.io/)

### Tutoriales recomendados:
- [Jenkins Pipeline Tutorial](https://www.jenkins.io/doc/tutorials/)
- [Best Practices](https://www.jenkins.io/doc/book/pipeline/best-practices/)

### Comunidad:
- [Jenkins Community](https://www.jenkins.io/participate/)
- [Stack Overflow - Jenkins](https://stackoverflow.com/questions/tagged/jenkins)

---

## 🎉 ¡Felicidades!

Si llegaste hasta aquí, has completado exitosamente tu primera experiencia completa con Jenkins CI/CD. 

**Has aprendido a**:
✅ Instalar y configurar Jenkins desde cero  
✅ Crear pipelines declarativos  
✅ Automatizar despliegues web  
✅ Integrar Git con Jenkins  
✅ Configurar servidores web (Nginx)  
✅ Monitorear y troubleshoot pipelines  
✅ Implementar mejores prácticas de DevOps  

**¡Ahora estás listo para proyectos más avanzados!** 🚀

---

<div align="center">

**#DevOps #Jenkins #CI/CD #RoxsRoss #Automation**

</div>
