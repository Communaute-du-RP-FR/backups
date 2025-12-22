#!/bin/bash
set -euo pipefail

# CONFIGURATION, MODIFY AS NEEDED
DB_NAME="dbname"
DEST_USER="user"
DEST_HOST="host"
DEST_DIR="/home/user/backups"
DEST_PORT="22"
SSH_KEY="/home/user/.ssh/pg_backup"
AGE_PUB_KEY="/home/user/backup.agepub"

TMP_DIR="/tmp/pg_backups"
DATE="$(date +%F_%H-%M)"
BACKUP_FILE="${DB_NAME}_${DATE}.dump"
ENCRYPTED_BACKUP_FILE="${BACKUP_FILE}.age"

# BACKUP AND ENCRYPT
mkdir -p "$TMP_DIR"
pg_dump -F c -Z 9 "$DB_NAME" \
  | age -R "$AGE_PUB_KEY" \
  > "$TMP_DIR/$ENCRYPTED_BACKUP_FILE"

# SEND TO REMOTE SERVER
scp -i "$SSH_KEY" -P "$DEST_PORT" \
  "$TMP_DIR/$ENCRYPTED_BACKUP_FILE" \
  "${DEST_USER}@${DEST_HOST}:${DEST_DIR}/"

# CLEANUP OLD BACKUPS
ssh -i "$SSH_KEY" -p "$DEST_PORT" "${DEST_USER}@${DEST_HOST}" "
  set -e
  cd '$DEST_DIR'
  ls -1t ${DB_NAME}_*.dump.age | tail -n +31 | xargs -r rm --
"

# CLEANUP LOCAL FILE
rm -f "$TMP_DIR/$ENCRYPTED_BACKUP_FILE"
