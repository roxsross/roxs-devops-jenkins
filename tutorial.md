# 🚀 Jenkins para Principiantes - ¡Tu Primer Pipeline!

¡Bienvenid@ a Jenkins! Vamos a crear tu primer sistema de despliegue automático en **menos de 30 minutos**.

## 🎯 ¿Qué vamos a hacer?

✅ Instalar Jenkins con un solo comando  
✅ Crear tu primer "pipeline" (flujo automático)  
✅ Desplegar una página web automáticamente  
✅ ¡Ver tu sitio funcionando!  

---

## 🚀 Paso 1: Instalar todo (¡súper fácil!)

### ☁️ En Google Cloud Shell (100% Optimizado):

**Opción 1: Un solo clic (Recomendado)**
[![Open in Cloud Shell](https://gstatic.com/cloudssh/images/open-btn.svg)](https://shell.cloud.google.com/cloudshell/editor?cloudshell_git_repo=https://github.com/roxsross/roxs-devops-jenkins.git&cloudshell_tutorial=tutorial.md)

**Opción 2: Docker Compose (Sin problemas de permisos)**
```bash
# Clona este proyecto
git clone https://github.com/roxsross/roxs-devops-jenkins.git
cd roxs-devops-jenkins

# ¡Inicia todo con Docker!
./docker-start.sh
```

**Opción 3: Instalación tradicional**
```bash
# Clona este proyecto
git clone https://github.com/roxsross/roxs-devops-jenkins.git
cd roxs-devops-jenkins

# ¡Instala todo con un comando!
sudo ./instalar.sh

# Inicialización rápida y URLs (específico para Cloud Shell)
./test-init.sh
```

> 💡 **¿Cuál elegir?**
> - 🐳 **Docker**: Sin problemas de permisos, más rápido, fácil de limpiar
> - 🔧 **Tradicional**: Instalación directa en el sistema, más control
> 
> **Optimizaciones específicas para Cloud Shell**:
> - ✅ Detección automática del entorno Cloud Shell
> - ✅ Timeouts ajustados para el rendimiento de Cloud Shell
> - ✅ Configuración de permisos específica (solo tradicional)
> - ✅ URLs automáticas con Web Preview
> - ✅ Scripts de diagnóstico adaptados

### 🖥️ En tu propia computadora Linux:
```bash
# Clona este proyecto
git clone https://github.com/roxsross/roxs-devops-jenkins.git
cd roxs-devops-jenkins

# ¡Instala todo con un comando!
sudo ./instalar.sh
```

> 💡 **El script es inteligente**: Detecta automáticamente si tu sistema usa systemd (Ubuntu moderno) o SysV init (Cloud Shell, contenedores) y usa los comandos correctos.

⏱️ **Tiempo**: 5-10 minutos  

---

## 🌐 Paso 2: Abrir Jenkins

### ☁️ En Google Cloud Shell (Método optimizado):

**Método 1: Web Preview (Recomendado)**
1. Busca el menú **⋮** (tres puntos) en la parte superior derecha de Cloud Shell
2. Haz clic en **"Web Preview"** → **"Preview on port 8080"**
3. Se abrirá Jenkins en una nueva pestaña

**Método 2: Comando rápido**
```bash
./test-init.sh  # Te muestra URLs y estado del sistema
```

**Método 3: URLs directas**
```bash
./cloud-shell-helper.sh  # URLs específicas para tu sesión
```

### 🖥️ En tu computadora:
- Abre: `http://localhost:8080`

### 🔧 Configurar Jenkins:
1. **Copia la contraseña** que apareció al final de la instalación
2. **Pégala** en Jenkins
3. **Instala plugins sugeridos** (espera 5 minutos)
4. **Crea tu usuario**:
   - Usuario: `admin`
   - Contraseña: `admin123`
   - Nombre: Tu nombre
   - Email: tu email

---

## 🌊 Paso 2.5: Habilitar Blue Ocean (Interfaz Moderna - OPCIONAL)

Blue Ocean es la interfaz moderna y visual de Jenkins. ¡Te encantará!

### 🔧 Instalar Blue Ocean:
1. **En Jenkins** → Ve a **"Administrar Jenkins"**
2. **Clic en "Administrar Plugins"**
3. **Pestaña "Disponibles"**
4. **Busca**: `Blue Ocean`
5. **Marca la casilla** de "Blue Ocean"
6. **Clic en "Instalar sin reiniciar"**
7. **Espera 2-3 minutos** ⏳

### 🎨 Usar Blue Ocean:
1. **Ve a la página principal** de Jenkins
2. **Verás un botón azul**: **"Abrir Blue Ocean"**
3. **¡Clic y disfruta** la interfaz moderna!

> 💡 **¿Qué es Blue Ocean?**
> - 🎨 Interfaz mucho más bonita
> - 📊 Visualización clara de pipelines
> - 🚀 Experiencia más moderna
> - 📱 Mejor en móviles

**¡Blue Ocean hace que Jenkins se vea espectacular!** Puedes usar cualquiera de las dos interfaces.

---

## 🏗️ Paso 3: Crear tu primer Pipeline

### En Jenkins:
1. **Clic en "Nueva Tarea"**
2. **Nombre**: `desplegar-portafolio`
3. **Selecciona**: "Pipeline"
4. **Clic en "OK"**

### Configurar el Pipeline:
1. Baja hasta **"Pipeline"**
2. En **"Definition"** selecciona: `Pipeline script from SCM`
3. En **"SCM"** selecciona: `Git`
4. En **"Repository URL"** pon: `https://github.com/roxsross/roxs-devops-jenkins.git`
5. En **"Branch"** pon: `*/master`
6. **Guarda**

> 💡 **El pipeline está configurado para usar tu directorio `portafolio-web` automáticamente**

---

## 🚀 Paso 4: ¡Ejecutar tu Pipeline!

1. **Clic en "Construir ahora"**
2. **Ve los logs**: Clic en el número del build → "Console Output"
3. **¡Espera a que termine!** (2-3 minutos)

> 💡 **¿Instalaste Blue Ocean?** También puedes ver tu pipeline en la interfaz moderna:
> - **Clic en "Abrir Blue Ocean"** (botón azul)
> - **Selecciona tu pipeline** `mi-primer-pipeline`
> - **¡Disfruta la vista visual!** 🎨

### 🐳 Con Docker (Recomendado):
**¡No hay problemas de permisos!** El pipeline debería funcionar inmediatamente.

### 🔧 Con instalación tradicional:
Si el pipeline falla por permisos (normal la primera vez):

1. **Abre una nueva terminal** en Cloud Shell
2. **Ejecuta**: `sudo ./arreglar-permisos.sh`
3. **Vuelve a Jenkins** y ejecuta el pipeline otra vez

> 💡 **¿Por qué usar Docker?** Sin problemas de permisos, más rápido, más limpio.

---

## 🌐 Paso 5: Ver tu sitio web

### ☁️ En Google Cloud Shell:

**Método rápido:**
1. Busca el menú **⋮** (tres puntos) en la parte superior derecha
2. Haz clic en **"Web Preview"** → **"Preview on port 8088"**
3. ¡Verás tu portafolio funcionando!

**URLs específicas:**
```bash
./test-init.sh        # Estado y URLs actuales
./cloud-shell-helper.sh  # URLs detalladas para tu sesión
```

### 🖥️ En tu computadora:
- Abre: `http://localhost:8088`

**¡Deberías ver tu página web funcionando!** 🎉

> 💡 **En Cloud Shell**: Guarda las URLs que muestra `cloud-shell-helper.sh` para acceso rápido

---

## 🎮 Paso 6: ¡Experimenta!

### Cambia tu sitio web:
```bash
# Edita el archivo principal
nano site/gaming-hub.html

# Haz algunos cambios y guarda
```

### Haz que se actualice automáticamente:
1. **Sube los cambios**:
   ```bash
   git add .
   git commit -m "Mi primer cambio"
   git push
   ```
2. **En Jenkins**: Ejecuta el pipeline otra vez
3. **¡Refresca tu sitio** y verás los cambios!

---

## 🐛 ¿Algo no funciona?

### Jenkins no abre (Error: "Unable to forward your request"):
```bash
# 1. Ejecutar diagnóstico automático
./diagnostico.sh

# 2. Verificar que Jenkins esté corriendo
sudo systemctl status jenkins

# 3. Si no está activo, iniciarlo:
sudo systemctl start jenkins

# 4. Esperar 2-3 minutos y verificar:
curl http://localhost:8080
```

### Jenkins tarda en cargar:
```bash
# Jenkins puede tomar 2-5 minutos en iniciarse completamente
# Espera y verifica cada minuto:
sudo journalctl -u jenkins -f
```

### El sitio no se ve:
```bash
# Verifica nginx
sudo systemctl status nginx

# Si no está activo:
sudo systemctl start nginx
```

### ¿Olvidaste la contraseña?
```bash
sudo cat /var/lib/jenkins/secrets/initialAdminPassword
```

### En Google Cloud Shell:
- **Jenkins**: Web Preview → Preview on port 8080
- **Tu aplicación**: Web Preview → Preview on port 8088
- Si no funciona, espera 3-5 minutos y reintenta

---

## 🎉 ¡Felicitaciones!

Has creado tu primer sistema de **CI/CD** (Integración y Despliegue Continuo).

### 🧠 ¿Qué aprendiste?
- ✅ Qué es Jenkins y para qué sirve
- ✅ Cómo crear un "pipeline" automático  
- ✅ Cómo conectar código con despliegue automático
- ✅ Los conceptos básicos de DevOps

### 🚀 ¿Qué sigue?
- � **Blue Ocean**: Si no lo instalaste, ¡hazlo! La interfaz es increíble
- �🎨 Personaliza tu sitio web
- 🔗 Conecta tu propio repositorio de GitHub
- 📱 Agrega notificaciones
- 🧪 Agrega tests automáticos
- 📊 Explora las métricas en Blue Ocean

---

## 🤝 Comunidad

- 📺 **YouTube**: [RoxsRoss DevOps](https://youtube.com/@295devops)
- 🐦 **Twitter**: [@roxsross](https://twitter.com/roxsross)
- 💼 **LinkedIn**: [RoxsRoss](https://www.linkedin.com/in/roxsross/)

---

<div align="center">

**¡Acabas de dar tu primer paso en DevOps!** 🚀  
*Creado con ❤️ por [RoxsRoss](https://github.com/roxsross)*

</div>