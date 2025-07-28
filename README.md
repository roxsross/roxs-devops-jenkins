# 🚀 Jenkins para Principiantes

¡Aprende Jenkins creando tu primer pipeline automático!

## ✨ ¿Qué vas a hacer?

✅ Instalar Jenkins en 5 minutos  
✅ Crear tu primer pipeline  
✅ Desplegar una página web automáticamente  
✅ Ver tu sitio funcionando  

---

## 🚀 ¡Empezar ahora!

### ☁️ Opción 1: Docker Compose (Recomendado - Sin problemas de permisos):

[![Open in Cloud Shell](https://gstatic.com/cloudssh/images/open-btn.svg)](https://shell.cloud.google.com/cloudshell/editor?cloudshell_git_repo=https://github.com/roxsross/roxs-devops-jenkins.git&cloudshell_tutorial=tutorial.md)

```bash
git clone https://github.com/roxsross/roxs-devops-jenkins.git
cd roxs-devops-jenkins
./docker-start.sh  # ¡Todo en contenedores!
```

**🐳 Ventajas de Docker:**
- ✅ Sin problemas de permisos
- ✅ Instalación más rápida
- ✅ Entorno aislado y limpio
- ✅ Fácil de reiniciar y limpiar
- ✅ Usa tu directorio `portafolio-web` automáticamente

### ☁️ Opción 2: Instalación tradicional:

```bash
git clone https://github.com/roxsross/roxs-devops-jenkins.git
cd roxs-devops-jenkins
sudo ./instalar.sh
./cloud-shell-helper.sh  # URLs y configuración específica
```

**🎯 Características específicas para Cloud Shell:**
- ✅ Detección automática de Cloud Shell
- ✅ Timeouts optimizados para el entorno
- ✅ URLs automáticas con Web Preview
- ✅ Configuración de permisos específica
- ✅ Scripts de diagnóstico adaptados

### 🖥️ En tu computadora local:

```bash
git clone https://github.com/roxsross/roxs-devops-jenkins.git
cd roxs-devops-jenkins
# Opción Docker (recomendada)
./docker-start.sh
# O instalación tradicional
sudo ./instalar.sh
```

---

## 📚 ¿Qué incluye?

- **📖 Tutorial simple** - Paso a paso para principiantes
- **🐳 Docker Compose** - Instalación sin problemas de permisos
- **🔧 Script de instalación** - Todo automático y optimizado para Cloud Shell
- **☁️ Helper de Cloud Shell** - URLs y configuración específica  
- **🔍 Script de diagnóstico** - Resuelve problemas comunes
- **📁 Gaming Hub interactivo** - Sitio web de ejemplo divertido
- **⚙️ Pipeline básico** - Listo para usar con tu `portafolio-web`

### 🛠️ Scripts útiles (optimizados para Cloud Shell):
```bash
# DOCKER (Recomendado)
./docker-start.sh           # Iniciar todo con Docker Compose
docker-compose logs -f      # Ver logs en tiempo real
docker-compose restart      # Reiniciar servicios
docker-compose down         # Detener todo

# URLs de acceso:
# Jenkins: Web Preview → Preview on port 8080
# Tu aplicación: Web Preview → Preview on port 8088

# INSTALACIÓN TRADICIONAL
./post-install-check.sh     # Verificación post-instalación
./cloud-shell-helper.sh     # URLs y configuración específica
./test-init.sh              # Inicialización rápida
./verificar.sh              # Verificación completa
sudo ./arreglar-permisos.sh # Si el pipeline falla por permisos
./diagnostico.sh            # Diagnóstico detallado
```

### 🔧 Compatibilidad total:
✅ **Google Cloud Shell** - 100% optimizado y probado  
✅ **Docker** - Sin problemas de permisos  
✅ **Ubuntu/Debian** - Con systemd o SysV  
✅ **Contenedores Docker** - Sin systemd  
✅ **VMs en la nube** - AWS, Azure, GCP  

*Los scripts detectan automáticamente tu sistema y usan los comandos correctos*

### ⚡ Solución rápida si el pipeline falla:
**Con Docker:** No deberías tener problemas de permisos  
**Sin Docker:** Si tu primer pipeline falla por permisos (normal), simplemente ejecuta:
```bash
sudo ./arreglar-permisos.sh
```
Y vuelve a ejecutar el pipeline. ¡Solo necesitas hacerlo una vez!

---

## 🎯 ¿Qué aprenderás?

- ✅ Qué es Jenkins y para qué sirve
- ✅ Cómo crear pipelines automáticos  
- ✅ Despliegue automático de sitios web
- ✅ Conceptos básicos de DevOps
- ✅ Docker y contenedores (opción Docker)

---

## 🤝 Comunidad

- 📺 [YouTube](https://youtube.com/@295devops)
- 🐦 [Twitter](https://twitter.com/roxsross)
- 💼 [LinkedIn](https://www.linkedin.com/in/roxsross/)

---

<div align="center">

**🚀 ¡Tu primer paso en DevOps!**  
*Por [RoxsRoss](https://github.com/roxsross)*

</div>