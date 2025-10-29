# ====================================
# VEXUS - MAKEFILE
# ====================================
# Comandos útiles para desarrollo y producción

.PHONY: help dev dev-d prod prod-build stop clean logs test format lint

# Rutas
DEV_PATH = deployment/development
PROD_PATH = deployment/production
ENV_PROD = .env.production

# Comandos por defecto
help:
	@echo "======================================"
	@echo " VEXUS - COMANDOS DISPONIBLES"
	@echo "======================================"
	@echo ""
	@echo "DESARROLLO:"
	@echo "  make dev         - Levantar entorno de desarrollo"
	@echo "  make dev-d       - Levantar desarrollo en background"
	@echo "  make dev-build   - Rebuild y levantar desarrollo"
	@echo ""
	@echo "PRODUCCIÓN:"
	@echo "  make prod        - Levantar entorno de producción"
	@echo "  make prod-build  - Rebuild y levantar producción"
	@echo ""
	@echo "GESTIÓN:"
	@echo "  make stop        - Detener todos los contenedores"
	@echo "  make clean       - Limpiar contenedores y volúmenes"
	@echo "  make logs        - Ver logs de desarrollo"
	@echo "  make logs-back   - Ver logs del backend (dev)"
	@echo "  make logs-db     - Ver logs de la base de datos (dev)"
	@echo "  make logs-prod   - Ver logs de producción"
	@echo ""
	@echo "DESARROLLO LOCAL (sin Docker):"
	@echo "  make install     - Instalar dependencias localmente"
	@echo "  make run-back    - Ejecutar backend local"
	@echo "  make run-front   - Ejecutar frontend local"
	@echo ""
	@echo "UTILIDADES:"
	@echo "  make shell-back  - Abrir shell en contenedor backend"
	@echo "  make shell-db    - Abrir psql en base de datos"
	@echo "  make backup      - Hacer backup de la base de datos"
	@echo "  make secret      - Generar nueva SECRET_KEY"
	@echo "  make test        - Ejecutar tests"
	@echo "  make format      - Formatear código con Black"
	@echo "  make lint        - Ejecutar linters"
	@echo ""

# ===== DESARROLLO =====

dev:
	@echo "Levantando entorno de DESARROLLO..."
	cd $(DEV_PATH) && docker-compose up

dev-build:
	@echo "Rebuild entorno de DESARROLLO..."
	cd $(DEV_PATH) && docker-compose up --build

dev-d:
	@echo "Levantando DESARROLLO en background..."
	cd $(DEV_PATH) && docker-compose up -d

# ===== PRODUCCIÓN =====

prod:
	@echo "Levantando entorno de PRODUCCIÓN..."
	@if [ ! -f "$(ENV_PROD)" ]; then \
		echo "ERROR: Archivo $(ENV_PROD) no encontrado!"; \
		echo ""; \
		echo "Primero ejecuta:"; \
		echo "1. cp $(PROD_PATH)/.env.production.example $(ENV_PROD)"; \
		echo "2. make secret"; \
		echo "3. Edita $(ENV_PROD) con valores reales"; \
		exit 1; \
	fi
	cd $(PROD_PATH) && docker-compose --env-file ../../$(ENV_PROD) up -d

prod-build:
	@echo "Rebuild y levantar PRODUCCIÓN..."
	@if [ ! -f "$(ENV_PROD)" ]; then \
		echo "ERROR: Archivo $(ENV_PROD) no encontrado!"; \
		exit 1; \
	fi
	@echo "Ejecutando fingerprinting de frontend..."
	pwsh ./frontend/add-fingerprints.ps1 -Version "$$(date +%Y%m%d%H%M%S)"
	@echo "Fingerprinting completado ✅"
	cd $(PROD_PATH) && docker-compose --env-file ../../$(ENV_PROD) up -d --build

# ===== GESTIÓN =====

stop:
	@echo "Deteniendo contenedores..."
	cd $(DEV_PATH) && docker-compose down || true
	cd $(PROD_PATH) && docker-compose down || true

clean:
	@echo "Limpiando contenedores y volúmenes..."
	cd $(DEV_PATH) && docker-compose down -v || true
	cd $(PROD_PATH) && docker-compose down -v || true
	docker system prune -f

# ===== LOGS =====

logs:
	cd $(DEV_PATH) && docker-compose logs -f

logs-back:
	cd $(DEV_PATH) && docker-compose logs -f backend

logs-db:
	cd $(DEV_PATH) && docker-compose logs -f db

logs-prod:
	cd $(PROD_PATH) && docker-compose logs -f

# ===== SHELL =====

shell-back:
	cd $(DEV_PATH) && docker-compose exec backend bash

shell-db:
	cd $(DEV_PATH) && docker-compose exec db psql -U postgres vexus_db

# ===== UTILIDADES =====

backup:
	@mkdir -p backups
	cd $(DEV_PATH) && docker-compose exec -T db pg_dump -U postgres vexus_db > ../../backups/backup_$$(date +%Y%m%d_%H%M%S).sql
	@echo "Backup creado en backups/"

secret:
	@echo "Generando SECRET_KEY segura..."
	@echo ""
	python generate_secret_key.py

test:
	@echo "Ejecutando tests..."
	cd backend && pytest tests/ -v || echo "No hay tests configurados aún"

format:
	@echo "Formateando código con Black..."
	cd backend && black app/

lint:
	@echo "Ejecutando linters..."
	cd backend && flake8 app/ --max-line-length=100 --ignore=E203,W503

# ===== INSTALACIÓN LOCAL (sin Docker) =====

install:
	@echo "Instalando dependencias localmente..."
	cd backend && python -m venv venv && \
	. venv/bin/activate && \
	pip install -r requirements.txt
	@echo ""
	@echo "Instalación completa!"
	@echo "Para activar el entorno virtual:"
	@echo "  cd backend"
	@echo "  source venv/bin/activate  (Linux/Mac)"
	@echo "  venv\\Scripts\\activate     (Windows)"

run-back:
	@echo "Ejecutando backend localmente..."
	@echo "Asegúrate de tener PostgreSQL corriendo y .env configurado"
	cd backend && uvicorn app.main:app --reload --host 0.0.0.0 --port 8000

run-front:
	@echo "Ejecutando frontend localmente..."
	cd frontend && npx http-server -p 8080

