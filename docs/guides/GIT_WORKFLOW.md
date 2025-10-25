# Git Workflow - Vexus Platform

## Configuración Inicial (Solo una vez)

### 1. Crear y Configurar Branches

```bash
# Asegurarte de estar en main
git checkout main

# Crear branch develop
git checkout -b develop
git push -u origin develop

# Configurar develop como branch por defecto (opcional)
# Ir a GitHub -> Settings -> Branches -> Default branch -> develop
```

### 2. Proteger Branches en GitHub

**Para `main` (Producción):**
1. Ir a: Settings → Branches → Add rule
2. Branch name pattern: `main`
3. Configurar:
   - ✅ Require a pull request before merging
   - ✅ Require approvals (1 o más)
   - ✅ Require status checks to pass before merging
   - ✅ Require branches to be up to date before merging
   - ✅ Include administrators

**Para `develop` (Opcional pero recomendado):**
1. Branch name pattern: `develop`
2. Configurar:
   - ✅ Require a pull request before merging
   - ✅ Require status checks to pass before merging

---

## Estructura de Branches

```
main (producción)
  ↓
  ├── develop (desarrollo activo)
  │     ↓
  │     ├── feature/user-notifications
  │     ├── feature/email-verification
  │     ├── feature/admin-dashboard
  │     └── bugfix/fix-login-redirect
  │
  └── hotfix/critical-security-patch (directo desde main)
```

### Tipos de Branches

| Tipo | Desde | Hacia | Propósito | Ejemplo |
|------|-------|-------|-----------|---------|
| `main` | - | - | Código en producción | `main` |
| `develop` | `main` | `main` | Integración de desarrollo | `develop` |
| `feature/*` | `develop` | `develop` | Nueva funcionalidad | `feature/add-chat` |
| `bugfix/*` | `develop` | `develop` | Arreglo de bug | `bugfix/fix-upload` |
| `hotfix/*` | `main` | `main` + `develop` | Fix urgente producción | `hotfix/security-fix` |
| `release/*` | `develop` | `main` + `develop` | Preparar release | `release/v1.1.0` |

---

## Workflows Comunes

### Workflow 1: Nueva Feature

```bash
# 1. Actualizar develop
git checkout develop
git pull origin develop

# 2. Crear branch de feature
git checkout -b feature/user-profile-photo

# 3. Trabajar en tu feature
# ... hacer cambios ...

# 4. Commits frecuentes
git add .
git commit -m "feat: add profile photo upload endpoint"

git add .
git commit -m "feat: add frontend UI for photo upload"

git add .
git commit -m "feat: add image validation and resize"

# 5. Push a GitHub
git push origin feature/user-profile-photo

# 6. Crear Pull Request en GitHub
# feature/user-profile-photo → develop

# 7. Después del merge, limpiar
git checkout develop
git pull origin develop
git branch -d feature/user-profile-photo
git push origin --delete feature/user-profile-photo
```

### Workflow 2: Bugfix

```bash
# 1. Desde develop
git checkout develop
git pull origin develop

# 2. Crear branch de bugfix
git checkout -b bugfix/fix-login-validation

# 3. Arreglar el bug
# ... hacer cambios ...

# 4. Commit
git add .
git commit -m "fix: correct email validation in login"

# 5. Push y PR
git push origin bugfix/fix-login-validation
# Crear PR: bugfix/fix-login-validation → develop

# 6. Después del merge
git checkout develop
git pull origin develop
git branch -d bugfix/fix-login-validation
```

### Workflow 3: Hotfix (Urgente en Producción)

```bash
# 1. Desde main (no develop!)
git checkout main
git pull origin main

# 2. Crear branch de hotfix
git checkout -b hotfix/fix-critical-security-bug

# 3. Arreglar
# ... hacer el fix ...

# 4. Commit
git add .
git commit -m "hotfix: patch critical security vulnerability"

# 5. Push
git push origin hotfix/fix-critical-security-bug

# 6. Crear 2 PRs:
#    PR 1: hotfix/fix-critical-security-bug → main
#    PR 2: hotfix/fix-critical-security-bug → develop

# 7. Después de mergear ambos:
git checkout main
git pull origin main
git checkout develop
git pull origin develop
git branch -d hotfix/fix-critical-security-bug
```

### Workflow 4: Release

```bash
# 1. Cuando develop está listo para producción
git checkout develop
git pull origin develop

# 2. Crear branch de release
git checkout -b release/v1.1.0

# 3. Preparar release (actualizar versión, changelog, etc)
# Editar version en archivos necesarios
git add .
git commit -m "chore: bump version to 1.1.0"

# 4. Push
git push origin release/v1.1.0

# 5. Crear 2 PRs:
#    PR 1: release/v1.1.0 → main
#    PR 2: release/v1.1.0 → develop

# 6. Después de mergear a main, crear tag
git checkout main
git pull origin main
git tag -a v1.1.0 -m "Release version 1.1.0"
git push origin v1.1.0

# 7. Limpiar
git checkout develop
git pull origin develop
git branch -d release/v1.1.0
```

---

## Convenciones de Commits

Usar formato: `tipo: descripción`

### Tipos de Commits

| Tipo | Uso | Ejemplo |
|------|-----|---------|
| `feat` | Nueva funcionalidad | `feat: add email notifications` |
| `fix` | Arreglo de bug | `fix: correct password validation` |
| `refactor` | Refactorización | `refactor: improve database queries` |
| `docs` | Documentación | `docs: update API documentation` |
| `style` | Formateo, estilo | `style: format code with black` |
| `test` | Tests | `test: add unit tests for auth` |
| `chore` | Mantenimiento | `chore: update dependencies` |
| `perf` | Performance | `perf: optimize image loading` |
| `ci` | CI/CD | `ci: add GitHub Actions workflow` |

### Ejemplos de Buenos Commits

```bash
# ✅ Buenos
git commit -m "feat: add user profile photo upload"
git commit -m "fix: correct email validation in registration"
git commit -m "refactor: extract database logic to service layer"
git commit -m "docs: add deployment guide"
git commit -m "test: add integration tests for auth endpoints"

# ❌ Malos
git commit -m "changes"
git commit -m "fix"
git commit -m "update"
git commit -m "asdfasdf"
git commit -m "commit"
```

### Commits más Descriptivos (Opcional)

```bash
git commit -m "feat: add user profile photo upload

- Add /api/v1/users/photo endpoint
- Implement image validation (max 5MB, jpg/png only)
- Add automatic image resize to 800x800
- Update user model to include photo_url field"
```

---

## Comandos Git Esenciales

### Básicos

```bash
# Ver estado
git status

# Ver branches
git branch -a

# Cambiar de branch
git checkout nombre-branch

# Crear y cambiar a branch
git checkout -b nuevo-branch

# Ver diferencias
git diff
git diff archivo.py

# Ver historial
git log
git log --oneline
git log --graph --all --oneline
```

### Sincronización

```bash
# Traer cambios
git fetch origin
git pull origin develop

# Subir cambios
git push origin feature/mi-feature

# Actualizar branch con develop
git checkout feature/mi-feature
git merge develop
# O
git rebase develop
```

### Deshacer Cambios

```bash
# Descartar cambios en archivo
git checkout -- archivo.py

# Descartar todos los cambios
git reset --hard

# Deshacer último commit (mantener cambios)
git reset --soft HEAD~1

# Deshacer último commit (descartar cambios)
git reset --hard HEAD~1

# Revertir commit específico
git revert abc123
```

### Stash (Guardar Temporalmente)

```bash
# Guardar cambios temporalmente
git stash

# Ver stashes
git stash list

# Recuperar último stash
git stash pop

# Recuperar stash específico
git stash apply stash@{0}

# Eliminar stash
git stash drop
```

---

## Pull Request Checklist

Antes de crear un PR, verifica:

- [ ] Tu branch está actualizado con develop
- [ ] El código compila sin errores
- [ ] Tests pasan (si los hay)
- [ ] No hay console.log / print() innecesarios
- [ ] Commit messages son descriptivos
- [ ] Has probado los cambios localmente
- [ ] No hay archivos `.env` o secrets
- [ ] Documentación actualizada (si aplica)

---

## Resolución de Conflictos

### Cuando hay conflicto en merge/pull

```bash
# 1. Actualizar tu branch con develop
git checkout feature/mi-feature
git pull origin develop

# 2. Si hay conflictos, Git te lo dirá
# Abrir archivos con conflictos y buscar:
<<<<<<< HEAD
tu código
=======
código de develop
>>>>>>> develop

# 3. Resolver conflictos manualmente
# Editar archivo y decidir qué código mantener

# 4. Marcar como resuelto
git add archivo-con-conflicto.py

# 5. Completar merge
git commit -m "merge: resolve conflicts with develop"

# 6. Push
git push origin feature/mi-feature
```

---

## Tips y Mejores Prácticas

### 1. Commits Pequeños y Frecuentes

```bash
# ✅ Mejor
git commit -m "feat: add user model"
git commit -m "feat: add user repository"
git commit -m "feat: add user endpoints"
git commit -m "feat: add user frontend"

# ❌ Evitar
git commit -m "feat: add complete user system"
```

### 2. Mantén Develop Actualizado

```bash
# Al inicio de cada día
git checkout develop
git pull origin develop
```

### 3. Sincroniza Feature Branches

```bash
# Periódicamente (cada 1-2 días)
git checkout feature/mi-feature
git merge develop  # o git rebase develop
```

### 4. Nombres Descriptivos

```bash
# ✅ Buenos nombres
feature/user-authentication
feature/email-notifications
bugfix/fix-login-redirect
hotfix/patch-sql-injection

# ❌ Malos nombres
feature/new
bugfix/fix
feature/test
```

### 5. Usa .gitignore

Asegúrate que nunca commits:
- `.env` o `.env.production`
- `__pycache__/`
- `venv/` o `node_modules/`
- Archivos de IDE (`.vscode/`, `.idea/`)
- Archivos compilados

### 6. Revisa Antes de Commit

```bash
# Ver qué vas a commitear
git status
git diff

# Agregar archivos selectivamente
git add archivo1.py archivo2.py
# En lugar de
git add .
```

---

## Herramientas Útiles

### Alias de Git

Agregar a `~/.gitconfig`:

```ini
[alias]
    st = status
    co = checkout
    br = branch
    ci = commit
    unstage = reset HEAD --
    last = log -1 HEAD
    visual = log --graph --all --oneline --decorate
    cleanup = !git branch --merged | grep -v '\\*\\|main\\|develop' | xargs -n 1 git branch -d
```

Uso:
```bash
git st          # En lugar de git status
git co develop  # En lugar de git checkout develop
git visual      # Ver árbol de branches
git cleanup     # Eliminar branches ya mergeadas
```

### VS Code GitLens

Extensión recomendada para visualizar:
- Historial de commits
- Cambios por línea
- Branch comparisons

---

## Escenarios Comunes

### Necesito cambiar de branch pero tengo cambios sin commitear

```bash
# Opción 1: Stash
git stash
git checkout otra-branch
# ... trabajar ...
git checkout mi-branch-original
git stash pop

# Opción 2: Commit temporal
git add .
git commit -m "WIP: trabajo en progreso"
git checkout otra-branch
# ... trabajar ...
git checkout mi-branch-original
git reset --soft HEAD~1  # Deshacer commit temporal
```

### Accidentalmente commiteé en develop

```bash
# Mover commits a nueva branch
git checkout -b feature/mi-feature
git checkout develop
git reset --hard origin/develop
```

### Necesito actualizar mi PR con cambios de develop

```bash
git checkout feature/mi-feature
git merge develop
# Resolver conflictos si los hay
git push origin feature/mi-feature
```

---

**Happy Git! 🚀**
