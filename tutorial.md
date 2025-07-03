# 🚀 Jenkins para Principiantes - ¡Tu Primer Pipeline!

¡Bienvenid@ a Jenkins! Vamos a crear tu primer sistema de despliegue automático en **menos de 30 minutos**.

## 🎯 ¿Qué vamos a hacer?

✅ Instalar Jenkins con un solo comando  
✅ Crear tu primer "pipeline" (flujo automático)  
✅ Desplegar una página web automáticamente  
✅ ¡Ver tu sitio funcionando!  

---

## 🚀 Paso 1: Instalar todo (¡súper fácil!)

### En Google Cloud Shell:
```bash
# Clona este proyecto
git clone https://github.com/roxsross/roxs-devops-jenkins.git
cd roxs-devops-jenkins

# ¡Instala todo con un comando!
sudo ./instalar.sh
```

> 💡 **El script es inteligente**: Detecta automáticamente si tu sistema usa systemd (Ubuntu moderno) o SysV init (Cloud Shell, contenedores) y usa los comandos correctos.

### En tu propia computadora Linux:
Usa los mismos comandos de arriba.

⏱️ **Tiempo**: 5-10 minutos  

---

## 🌐 Paso 2: Abrir Jenkins

### En Google Cloud Shell:
- Haz clic en **"Web Preview"** → **"Preview on port 8080"**

### En tu computadora:
- Abre: `http://localhost:8080`

### Configurar Jenkins:
1. **Copia la contraseña** que apareció al final de la instalación
2. **Pégala** en Jenkins
3. **Instala plugins sugeridos** (espera 5 minutos)
4. **Crea tu usuario**:
   - Usuario: `admin`
   - Contraseña: `admin123`
   - Nombre: Tu nombre
   - Email: tu email

---

## 🏗️ Paso 3: Crear tu primer Pipeline

### En Jenkins:
1. **Clic en "Nueva Tarea"**
2. **Nombre**: `mi-primer-pipeline`
3. **Selecciona**: "Pipeline"
4. **Clic en "OK"**

### Configurar el Pipeline:
1. Baja hasta **"Pipeline"**
2. En **"Definition"** selecciona: `Pipeline script from SCM`
3. En **"SCM"** selecciona: `Git`
4. En **"Repository URL"** pon: `https://github.com/roxsross/roxs-devops-jenkins.git`
5. En **"Branch"** pon: `*/master`
6. **Guarda**

---

## 🚀 Paso 4: ¡Ejecutar tu Pipeline!

1. **Clic en "Construir ahora"**
2. **Ve los logs**: Clic en el número del build → "Console Output"
3. **¡Espera a que termine!** (2-3 minutos)

---

## 🌐 Paso 5: Ver tu sitio web

### En Google Cloud Shell:
- **Web Preview** → **"Preview on port 80"**

### En tu computadora:
- Abre: `http://localhost`

**¡Deberías ver tu página web funcionando!** 🎉

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
- **Tu sitio**: Web Preview → Preview on port 80
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
- 🎨 Personaliza tu sitio web
- 🔗 Conecta tu propio repositorio de GitHub
- 📱 Agrega notificaciones
- 🧪 Agrega tests automáticos

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