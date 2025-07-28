# 🚀 Ejemplo Rápido - Jenkins + Tu Portafolio

## ⚡ Inicio en 3 pasos

### 1. Clonar y iniciar
```bash
git clone https://github.com/roxsross/roxs-devops-jenkins.git
cd roxs-devops-jenkins
./docker-start.sh  # Con Docker (recomendado)
```

### 2. Configurar Jenkins
- Abre: **Web Preview → Preview on port 8080**
- Usa la contraseña que muestra el script
- Instala plugins sugeridos
- Crea usuario admin

### 3. Crear pipeline
- **Nueva Tarea** → `desplegar-portafolio` → **Pipeline**
- **Pipeline script from SCM** → **Git**
- **URL**: `https://github.com/roxsross/roxs-devops-jenkins.git`
- **Guardar** → **Construir ahora**

## 🎯 ¿Qué hace el pipeline?

1. **Busca** tu directorio `portafolio-web`
2. **Copia** los archivos al servidor web
3. **Tu sitio** está listo en: **Web Preview → Preview on port 80**

## 📁 Tu estructura

```
roxs-devops-jenkins/
├── portafolio-web/          # ← Tu aplicación aquí
│   ├── index.html
│   ├── css/
│   ├── js/
│   └── images/
├── Jenkinsfile             # Pipeline simple
└── docker-compose.yml      # Configuración Docker
```

## 🔄 Flujo de trabajo

1. **Modifica** archivos en `portafolio-web/`
2. **Ejecuta** el pipeline en Jenkins
3. **Ve** los cambios en tu sitio web

¡Así de simple! 🎉