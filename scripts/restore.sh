#!/bin/bash
set -euo pipefail

# CONFIGURATION, MODIFY AS NEEDED
DB_NAME=""
AGE_PRIVATE_KEY=""

# CHECKS
if [ $# -ne 1 ]; then
  echo "Usage: $0 <backup.dump.age>"
  exit 1
fi

# ARG, INPUT ENCRYPTED BACKUP FILE
ENCRYPTED_BACKUP_FILE="$1"

if [ ! -f "$ENCRYPTED_BACKUP_FILE" ]; then
  echo "Backup file not found: $ENCRYPTED_BACKUP_FILE"
  exit 1
fi

if [ ! -f "$AGE_PRIVATE_KEY" ]; then
  echo "Age private key not found: $AGE_PRIVATE_KEY"
  exit 1
fi

# RESTORE
age -d -i "$AGE_PRIVATE_KEY" "$ENCRYPTED_BACKUP_FILE" \
  | pg_restore \
    -d "$DB_NAME" \
    --clean \
    --if-exists
