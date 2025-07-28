# 🐳 Configuración con Docker Compose

## ¿Por qué Docker?

- ✅ **Sin problemas de permisos** - No necesitas configurar sudo
- ✅ **Instalación más rápida** - Todo en contenedores
- ✅ **Entorno aislado** - No afecta tu sistema
- ✅ **Fácil de limpiar** - Un comando para detener todo

## 🚀 Inicio Rápido

```bash
# 1. Clona el proyecto
git clone https://github.com/roxsross/roxs-devops-jenkins.git
cd roxs-devops-jenkins

# 2. Inicia con Docker
./docker-start.sh

# 3. Accede a Jenkins
# En Cloud Shell: Web Preview → Preview on port 8080
# Local: http://localhost:8080
```

## 📁 Tu Directorio `portafolio-web`

El Docker Compose está configurado para usar automáticamente tu directorio `portafolio-web`:

```
roxs-devops-jenkins/
├── portafolio-web/          # ← Tu aplicación web aquí
│   ├── index.html
│   ├── css/
│   ├── js/
│   └── images/
├── docker-compose.yml       # Configuración de contenedores
├── Jenkinsfile             # Pipeline que despliega tu app
└── docker-start.sh         # Script de inicio
```

## 🔧 Comandos Útiles

```bash
# Ver estado de contenedores
docker-compose ps

# Ver logs en tiempo real
docker-compose logs -f

# Reiniciar servicios
docker-compose restart

# Detener todo
docker-compose down

# Iniciar de nuevo
docker-compose up -d

# Obtener contraseña de Jenkins
docker-compose exec jenkins cat /var/jenkins_home/secrets/initialAdminPassword
```

## 🌐 URLs de Acceso

### En Google Cloud Shell:
- **Jenkins**: Web Preview → Preview on port 8080
- **Tu sitio**: Web Preview → Preview on port 80

### En sistema local:
- **Jenkins**: http://localhost:8080
- **Tu sitio**: http://localhost

## 🔄 Cómo Funciona el Pipeline

1. **Jenkins** lee tu `Jenkinsfile`
2. **Busca** archivos en `portafolio-web/`
3. **Copia** los archivos al contenedor Nginx
4. **Tu sitio** se actualiza automáticamente

## 🐳 Arquitectura Docker

```
┌─────────────────┐    ┌─────────────────┐
│   Jenkins       │    │     Nginx       │
│   Puerto 8080   │    │   Puerto 80     │
│                 │    │                 │
│ ┌─────────────┐ │    │ ┌─────────────┐ │
│ │ Jenkinsfile │ │────▶ │ portafolio- │ │
│ │ Pipeline    │ │    │ │ web/        │ │
│ └─────────────┘ │    │ └─────────────┘ │
└─────────────────┘    └─────────────────┘
         │                       │
         └───────────────────────┘
              Volumen compartido
```

## 🔧 Personalización

### Cambiar puertos:
Edita `docker-compose.yml`:
```yaml
ports:
  - "8080:8080"  # Jenkins
  - "80:80"      # Tu sitio
```

### Agregar más servicios:
```yaml
services:
  jenkins:
    # ... configuración existente
  
  nginx:
    # ... configuración existente
  
  database:
    image: postgres:13
    # ... tu configuración
```

## 🆘 Solución de Problemas

### Jenkins no inicia:
```bash
docker-compose logs jenkins
```

### Sitio web no se ve:
```bash
docker-compose logs nginx
docker-compose exec nginx ls -la /usr/share/nginx/html
```

### Reiniciar todo:
```bash
docker-compose down
docker-compose up -d
```

### Limpiar completamente:
```bash
docker-compose down -v  # Elimina también volúmenes
docker system prune     # Limpia Docker
```

## 💡 Tips para Cloud Shell

1. **Docker ya está instalado** en Cloud Shell
2. **Usa Web Preview** para acceder a los puertos
3. **Los volúmenes persisten** entre sesiones
4. **Guarda tu trabajo** en el directorio `portafolio-web`

¡Disfruta desarrollando con Docker! 🚀