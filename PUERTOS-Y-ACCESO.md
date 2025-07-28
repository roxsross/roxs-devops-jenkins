# 🌐 Puertos y Acceso - Configuración Actualizada

## 🔌 Configuración de Puertos

| Servicio | Puerto | Descripción |
|----------|--------|-------------|
| **Jenkins** | `8080` | Interfaz de administración CI/CD |
| **Tu Aplicación** | `8088` | Portafolio web desplegado |

## 🚀 Acceso en Google Cloud Shell

### 🔧 Jenkins (Administración)
- **Método**: Web Preview → Preview on port **8080**
- **URL**: `https://8080-{tu-session-id}.googleusercontent.com`
- **Uso**: Crear y ejecutar pipelines

### 🌐 Tu Aplicación (Portafolio)
- **Método**: Web Preview → Preview on port **8088**
- **URL**: `https://8088-{tu-session-id}.googleusercontent.com`
- **Uso**: Ver tu sitio web desplegado

## 💻 Acceso Local

```bash
# Jenkins
http://localhost:8080

# Tu aplicación
http://localhost:8088
```

## 🐳 Docker Compose

```yaml
services:
  web:
    ports:
      - "8088:80"  # Tu aplicación
  jenkins:
    ports:
      - "8080:8080"  # Jenkins
```

## 🔄 Flujo de Trabajo

1. **Desarrolla** en `portafolio-web/`
2. **Ejecuta pipeline** en Jenkins (`puerto 8080`)
3. **Ve resultado** en tu app (`puerto 8088`)

## 🛠️ Comandos Útiles

```bash
# Verificar servicios
docker-compose ps

# Ver logs de la aplicación
docker-compose logs web

# Ver logs de Jenkins
docker-compose logs jenkins

# Reiniciar aplicación
docker-compose restart web

# Health check de la aplicación
curl http://localhost:8088/health
```

## 🎯 URLs de Health Check

- **Aplicación**: `http://localhost:8088/health`
- **Jenkins**: `http://localhost:8080/login`

¡Ahora tu aplicación corre en el puerto 8088! 🚀