# 👋 LÉEME PRIMERO - Vexus Platform

## 🎯 ¿Qué quieres hacer?

### 🛠️ OPCIÓN 1: DESARROLLAR (Programar en tu computadora)

**¿Cuándo usar?**
- Cuando quieres programar nuevas funcionalidades
- Para arreglar bugs
- Para probar cambios en tu computadora local

**Paso a paso:**

1. **Abre:** [deployment/development/README.md](deployment/development/README.md)
2. **Ejecuta (Windows):**
   ```bash
   start-dev.bat
   ```
   **O (Linux/Mac):**
   ```bash
   ./start-dev.sh
   ```
3. **Accede a:**
   - http://localhost:8080 (frontend)
   - http://localhost:8000/docs (API)

**Eso es todo!** Los cambios que hagas en el código se reflejan automáticamente.

---

### 🚀 OPCIÓN 2: DEPLOYAR A PRODUCCIÓN (Poner en servidor)

**¿Cuándo usar?**
- Cuando quieres subir tu aplicación a internet
- Para que usuarios reales la usen
- Cuando ya terminaste de desarrollar

**Paso a paso:**

1. **Abre:** [deployment/production/README.md](deployment/production/README.md)
2. **Configura variables:**
   ```bash
   cp deployment/production/.env.production.example .env.production
   python generate_secret_key.py
   # Edita .env.production con valores reales
   ```
3. **Ejecuta (Linux/Mac):**
   ```bash
   ./start-prod.sh
   ```

**Lee la guía completa en** [deployment/production/README.md](deployment/production/README.md)

---

## 📂 ESTRUCTURA SÚPER SIMPLE

```
VexusPage/
│
├── deployment/
│   ├── development/  ← 🛠️ TODO PARA DESARROLLAR
│   └── production/   ← 🚀 TODO PARA PRODUCCIÓN
│
├── docs/guides/      ← 📚 GUÍAS DETALLADAS
│
├── backend/          ← Código del backend (API)
├── frontend/         ← Código del frontend (HTML/CSS/JS)
│
└── Scripts de inicio:
    ├── start-dev.bat     (Windows)
    ├── start-dev.sh      (Linux/Mac)
    └── start-prod.sh     (Linux/Mac)
```

---

## 🎓 DOCUMENTACIÓN

### Empieza aquí:

| Lee esto | Si quieres |
|----------|------------|
| **[deployment/development/README.md](deployment/development/README.md)** | Desarrollar |
| **[deployment/production/README.md](deployment/production/README.md)** | Deployar |
| **[QUICK_START.md](QUICK_START.md)** | Guía rápida general |
| **[ESTRUCTURA.md](ESTRUCTURA.md)** | Entender la organización |

### Profundizar:

| Guía | Descripción |
|------|-------------|
| [docs/guides/DEVELOPMENT_GUIDE.md](docs/guides/DEVELOPMENT_GUIDE.md) | Desarrollo completo |
| [docs/guides/GIT_WORKFLOW.md](docs/guides/GIT_WORKFLOW.md) | Git y branches |
| [docs/guides/DEPLOYMENT.md](docs/guides/DEPLOYMENT.md) | Deploy detallado |
| [docs/guides/SECURITY_CHECKLIST.md](docs/guides/SECURITY_CHECKLIST.md) | Seguridad |

---

## ⚡ INICIO SÚPER RÁPIDO

### Desarrollo (1 comando):

**Windows:**
```bash
start-dev.bat
```

**Linux/Mac:**
```bash
./start-dev.sh
```

**Listo!** Abre http://localhost:8080

---

### Producción (3 pasos):

```bash
# 1. Configurar
cp deployment/production/.env.production.example .env.production
python generate_secret_key.py
nano .env.production  # Editar con valores reales

# 2. Iniciar
./start-prod.sh

# 3. Verificar
curl http://localhost:8000/health
```

---

## 🤔 ¿Confundido?

### Pregunta 1: ¿Qué archivo abro?

**Para desarrollar:**
- [deployment/development/README.md](deployment/development/README.md)

**Para deployar:**
- [deployment/production/README.md](deployment/production/README.md)

### Pregunta 2: ¿Cómo inicio la aplicación?

**Desarrollo:**
```bash
# Windows:
start-dev.bat

# Linux/Mac:
./start-dev.sh
```

**Producción:**
```bash
./start-prod.sh
```

### Pregunta 3: ¿Dónde está mi código?

```
backend/   ← Código del backend (Python/FastAPI)
frontend/  ← Código del frontend (HTML/CSS/JS)
```

### Pregunta 4: ¿Dónde está la configuración?

**Desarrollo:**
- `deployment/development/docker-compose.yml`
- `backend/.env.example` (copiar a `.env`)

**Producción:**
- `deployment/production/docker-compose.yml`
- `deployment/production/.env.production.example` (copiar a `.env.production`)

---

## 📋 REGLAS SIMPLES

### ✅ HACER:

1. **Desarrollar** → Usar `deployment/development/`
2. **Deployar** → Usar `deployment/production/`
3. **Leer README** de la carpeta donde estés trabajando
4. **Nunca commitear** archivos `.env` a Git

### ❌ NO HACER:

1. **NO** mezclar archivos de desarrollo con producción
2. **NO** usar configuración de desarrollo en producción
3. **NO** subir secrets (.env, passwords) a GitHub
4. **NO** hacer commits directos a branch `main`

---

## 🆘 AYUDA

### Error: "Port already in use"

```bash
# Windows
netstat -ano | findstr :8000
taskkill /PID <PID> /F

# Linux/Mac
lsof -ti:8000 | xargs kill -9
```

### Error: "Cannot connect to database"

```bash
# Ver logs
cd deployment/development
docker-compose logs db
```

### ¿Más ayuda?

- Desarrollo: [deployment/development/README.md](deployment/development/README.md)
- Producción: [deployment/production/README.md](deployment/production/README.md)
- Git: [docs/guides/GIT_WORKFLOW.md](docs/guides/GIT_WORKFLOW.md)

---

## 🎯 RESUMEN EN 3 LÍNEAS

1. **Desarrollo** = `deployment/development/` + ejecutar `start-dev.bat` o `./start-dev.sh`
2. **Producción** = `deployment/production/` + configurar `.env.production` + ejecutar `./start-prod.sh`
3. **Documentación** = `docs/guides/` + lee según lo que necesites

---

## 🚀 SIGUIENTE PASO

**¿Vas a desarrollar?**
→ Abre [deployment/development/README.md](deployment/development/README.md)

**¿Vas a deployar?**
→ Abre [deployment/production/README.md](deployment/production/README.md)

**¿Quieres entender mejor el proyecto?**
→ Abre [QUICK_START.md](QUICK_START.md)

---

**¡Elige una opción y comienza! 🎉**
