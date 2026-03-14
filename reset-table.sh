#!/bin/bash

# Configuration
CONTAINER_NAME="fakeflix-db"
DB_NAME="fakeflix_test"
DB_USER="postgres"

echo "----------------------------------------------------------"
echo "Starting Database Reset for $DB_NAME..."
echo "----------------------------------------------------------"

# Step 1: Hard Drop of schemas to ensure a clean slate
# This removes all tables, sequences, and types created by previous ORMs (Prisma/Drizzle) or TypeORM
echo "Step 1: Dropping existing schemas (identity, test, public)..."
docker exec -i $CONTAINER_NAME psql -U $DB_USER -d $DB_NAME -c "
  DROP SCHEMA IF EXISTS identity CASCADE;
  DROP SCHEMA IF EXISTS test CASCADE;
  DROP SCHEMA IF EXISTS public CASCADE;
  CREATE SCHEMA public;
  GRANT ALL ON SCHEMA public TO $DB_USER;
  GRANT ALL ON SCHEMA public TO public;
"

# Step 2: Run migrations using the unified command in package.json
echo "Step 2: Running TypeORM migrations for all modules..."
yarn db:migrate:all

echo "----------------------------------------------------------"
echo "Database reset complete!"
echo "----------------------------------------------------------"
