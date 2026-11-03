# Automated Backup System

## Project Description

A Bash-based infrastructure automation project
that automatically compresses application log files
and manages backup retention.

## Technologies Used

- Bash
- Linux Ubuntu
- Cron
- Git and GitHub
- Environment Variables
- Tar and Gzip

## Features

- Automated log file discovery
- Timestamped compressed backups
- Automatic backup retention
- Execution logging
- Cron scheduling
- Environment variable configuration
- Secrets protection using .gitignore
- Optional HTTP webhook notifications

## Execution

Run the script manually:

./scripts/backup.sh

## Scheduling

The script is scheduled through Linux cron
to execute daily at 6:00 PM.

## Security

Sensitive environment configuration is stored
in .env and excluded from Git.

Generated backups and execution logs are also
excluded from version control.

## Author

Your Name
