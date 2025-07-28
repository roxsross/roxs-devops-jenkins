# 🔧 Solución: Error de Permisos en Jenkins

## ❌ Problema
Tu pipeline falló con el mensaje: "Jenkins no tiene permisos sudo configurados"

## ✅ Solución Rápida (2 minutos)

### Para Google Cloud Shell:

1. **Abre una nueva terminal** en Cloud Shell (botón `+` junto a las pestañas)

2. **Navega al directorio del proyecto:**
   ```bash
   cd roxs-devops-jenkins
   ```

3. **Ejecuta el script de permisos:**
   ```bash
   sudo ./arreglar-permisos.sh
   ```

4. **Vuelve a Jenkins** y ejecuta el pipeline otra vez:
   - Web Preview → Preview on port 8080
   - Clic en tu pipeline
   - Clic en "Construir ahora"

## 🎉 ¡Listo!

Después de esto, tu pipeline debería funcionar perfectamente y podrás ver tu sitio web en:
- Web Preview → Preview on port 80

---

## 🔧 Solución Manual (si prefieres)

Si prefieres hacerlo manualmente, ejecuta estos comandos en la terminal:

```bash
# Configurar permisos para Jenkins
echo 'jenkins ALL=(ALL) NOPASSWD: /bin/cp, /bin/chown, /bin/rm, /usr/bin/unzip, /bin/mv, /bin/chmod' | sudo tee /etc/sudoers.d/jenkins

# Verificar que la configuración es válida
sudo visudo -c

# Crear directorio si no existe
sudo mkdir -p /var/www/portfolio
sudo chown -R www-data:www-data /var/www/portfolio
```

---

## 💡 ¿Por qué pasa esto?

Jenkins necesita permisos especiales para:
- Copiar archivos al servidor web (`/var/www/portfolio`)
- Cambiar permisos de archivos
- Reiniciar servicios si es necesario

Esto es **completamente normal** y **seguro** - solo le damos a Jenkins los permisos mínimos necesarios para desplegar tu sitio web.

---

## 🆘 ¿Necesitas ayuda?

Si algo no funciona, ejecuta:

```bash
./diagnostico.sh    # Diagnóstico completo
./verificar.sh      # Estado de servicios
./test-init.sh      # URLs y estado actual
```

---

## 🌐 URLs de Acceso

- **Jenkins**: Web Preview → Preview on port 8080
- **Tu sitio web**: Web Preview → Preview on port 80 (después del pipeline exitoso)

¡Este problema solo ocurre la primera vez! Una vez configurado, todo funcionará automáticamente. 🚀