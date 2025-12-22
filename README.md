# PostgreSQL Backup System

A secure PostgreSQL backup and restore system with age encryption and remote storage.

## Features

- **Encrypted backups** using [age encryption](https://github.com/FiloSottile/age)
- **Compressed PostgreSQL dumps** (format custom with compression level 9)
- **Remote storage** via SCP
- **Automatic cleanup** (keeps last 30 backups)
- **Safe restore** with clean and if-exists options

## Prerequisites

- PostgreSQL client tools (`pg_dump`, `pg_restore`)
- `age` encryption tool ([installation guide](https://github.com/FiloSottile/age#installation))
- SSH access to remote backup server
- Bash shell

## Setup

### 1. Generate Age Keys

```bash
# Generate a new age key pair
age-keygen -o backup.agekey

# Extract public key
age-keygen -y backup.agekey > backup.agepub
```

### 2. Configure SSH Access

```bash
# Generate SSH key for backups (if not already done)
# Don't set a passphrase for automated access
ssh-keygen -t ed25519 -a 100 -f ~/.ssh/pg_backup -C "postgres-backup"

# Copy public key to remote server
ssh-copy-id -i ~/.ssh/pg_backup.pub user@remote-host
```

### 3. Configure Scripts

Edit the configuration section in both scripts:

**backup.sh:**
```bash
DB_NAME="dbname"           # Your database name
DEST_USER="user"           # Remote server user
DEST_HOST="host"           # Remote server hostname/IP
DEST_DIR="/home/user/backups"  # Remote backup directory
DEST_PORT="22"             # SSH port
SSH_KEY="/home/user/.ssh/pg_backup"  # SSH private key path
AGE_PUB_KEY="/home/user/backup.agepub"  # Age public key path
```

**restore.sh:**
```bash
DB_NAME="dbname"           # Your database name
AGE_PRIVATE_KEY="/home/user/backup.agekey"  # Age private key path
```

## Usage

### Creating Backups

Run the backup script manually or via cron:

```bash
./scripts/backup.sh
```

**What it does:**
1. Creates a compressed PostgreSQL dump
2. Encrypts it with age using the public key
3. Transfers it to the remote server via SCP
4. Removes backups older than 30 days from the remote server
5. Cleans up the local temporary file

### Restoring from Backup

```bash
./scripts/restore.sh <backup-file.dump.age>
```

**Example:**
```bash
./scripts/restore.sh dbname_2024-12-22_10-30.dump.age
```

**Warning:** This will drop and recreate all database objects!

## Automation

### Daily Backups with Cron

Add to your crontab (`crontab -e`):

```bash
# Daily backup at 2:00 AM
0 2 * * * /path/to/backups/scripts/backup.sh
```

## Security Considerations

- Ensure proper file permissions:
  ```bash
  chmod 600 backup.agekey
  chmod 600 ~/.ssh/pg_backup
  ```
- Store the age private key in a **separate secure location** (not on the same server)

## File Naming Convention

Backups follow this naming pattern:
```
{DB_NAME}_{YYYY-MM-DD}_{HH-MM}.dump.age
```

Example: `mydb_2024-12-22_02-00.dump.age`

## Retention Policy

By default, the backup script keeps the **30 most recent backups** on the remote server. Older backups are automatically deleted.

## License

See [LICENSE](LICENSE) file for details.
