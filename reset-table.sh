#!/bin/bash

# =============================================================
# Script para dropar toda a base e reiniciar todas as tables no banco de teste
# Uso: ./reset-table.sh
# =============================================================

set -e

DB_URL="postgresql://postgres:postgres@localhost:5432/fakeflix_test"

echo "=========================================="
echo "  Resetando banco de teste: fakeflix_test"
echo "=========================================="
echo ""

# --- 1. Identity (Prisma) Drop & Migrate (Wipes DB) ---
echo "🔹 [1/5] Identity (Prisma) - prisma db push --force-reset"
DATABASE_URL=$DB_URL yarn identity:db:migrate --force-reset
echo "✅ Identity: Base de dados limpa e migrada"
echo ""

# --- 2. Content (TypeORM) schema:drop (Clears public schema to avoid enum conflicts with Drizzle) ---
echo "🔹 [2/5] Content (TypeORM) - schema:drop"
DATABASE_URL=$DB_URL yarn content:db:drop
echo "✅ Content: Tabelas public dropadas com sucesso"
echo ""

# --- 3. Billing (Drizzle) ---
echo "🔹 [3/5] Billing (Drizzle) - drizzle-kit push"
yarn billing:db:push --force
echo "✅ Billing migrado com sucesso"
echo ""

# --- 4. Content (TypeORM) ---
echo "🔹 [4/5] Content (TypeORM) - typeorm migration:run"
DATABASE_URL=$DB_URL yarn content:db:migrate
echo "✅ Content migrado com sucesso"
echo ""

# --- 5. Identity (Prisma) Generate Client ---
echo "🔹 [5/5] Identity (Prisma) - generate client types"
yarn identity:db:generate
echo "✅ Identity: Tipos gerados com sucesso"
echo ""

echo "=========================================="
echo "  ✅ Base resetada e migrations finalizadas!"
echo "  Rode 'yarn test:e2e' para verificar."
echo "=========================================="
