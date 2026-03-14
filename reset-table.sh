#!/bin/bash

# =============================================================
# Script para dropar toda a base e reiniciar todas as tables no banco de teste
# Uso: ./reset-table.sh
# =============================================================

set -e

DB_URL="postgresql://postgres:postgres@localhost:5432/fakeflix_test"
DB_NAME="fakeflix_test"
DB_USER="postgres"
CONTAINER_NAME="fakeflix-db"

echo "=========================================="
echo "  Resetando banco de teste: $DB_NAME"
echo "=========================================="
echo ""

# --- 0. Hard Drop (Ensure a truly clean state) ---
echo "🔹 [0/4] Hard Drop - Limpando schemas via Docker"
docker exec -i $CONTAINER_NAME psql -U $DB_USER -d $DB_NAME -c "DROP SCHEMA IF EXISTS identity CASCADE; DROP SCHEMA IF EXISTS test CASCADE; DROP SCHEMA IF EXISTS public CASCADE; CREATE SCHEMA public;"
echo "✅ Base de dados limpa (schemas removidos)"
echo ""

# --- 1. Identity (Prisma) Migrate ---
echo "🔹 [1/4] Identity (Prisma) - yarn identity:db:migrate"
DATABASE_URL=$DB_URL yarn identity:db:migrate
echo "✅ Identity: Tabelas criadas via Prisma"
echo ""

# --- 2. Billing (Drizzle) ---
echo "🔹 [2/4] Billing (Drizzle) - yarn billing:db:push"
DATABASE_URL=$DB_URL yarn billing:db:push --force
echo "✅ Billing: Tabelas recriadas via Drizzle"
echo ""

# --- 3. Content (TypeORM) ---
echo "🔹 [3/4] Content (TypeORM) - yarn content:db:migrate"
DATABASE_URL=$DB_URL yarn content:db:migrate
echo "✅ Content: Tabelas recriadas via TypeORM migrations"
echo ""

# --- 4. Identity (Prisma) Generate Client ---
echo "🔹 [4/4] Identity (Prisma) - yarn identity:db:generate"
yarn identity:db:generate
echo "✅ Identity: Tipos do Prisma Client gerados"
echo ""

echo "=========================================="
echo "  ✅ Base resetada e migrations finalizadas!"
echo "  Rode 'yarn test:e2e' para verificar."
echo "=========================================="
