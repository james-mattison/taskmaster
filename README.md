# James Schedule App v5

Dockerized Flask + Bootstrap scheduler for `taskmaster.vixal.net`.

## Features

- Secured with HTTP Basic Auth using `/taskmaster/.htpasswd`
- Urgent tasks backed by `/taskmaster/urgent.yaml`
- Later tasks backed by `/taskmaster/tasks.yaml`
- Completed tasks backed by `/taskmaster/completed.yaml`
- Completed section is hidden by default and available from a Bootstrap dropdown
- Tasks can be added with POST forms
- Tasks can be deleted with DELETE requests
- Tasks can be marked done and moved to completed
- Completed tasks can be restored to the later-task list
- Nick Cole awareness list at the bottom of the page
- Random footer messages from `commands.yaml`
- Flask SSL context using Certbot certificates for `taskmaster.vixal.net`
- Deployment helper script: `deploy-taskmaster.sh`

## Install htpasswd tool

On Ubuntu/Debian:

```bash
sudo apt update
sudo apt install apache2-utils
```

## Create the first user

The `-c` flag creates the file. Use it only for the first user.

```bash
sudo mkdir -p /taskmaster
sudo htpasswd -c -B /taskmaster/.htpasswd james
```

## Add another user

Do not use `-c` when adding additional users, or you will overwrite the file.

```bash
sudo htpasswd -B /taskmaster/.htpasswd nick
```

## Change an existing user's password

```bash
sudo htpasswd -B /taskmaster/.htpasswd james
```

## Delete a user

```bash
sudo htpasswd -D /taskmaster/.htpasswd nick
```

## Show configured users

```bash
sudo cut -d: -f1 /taskmaster/.htpasswd
```

## Permissions

```bash
sudo chown root:root /taskmaster/.htpasswd
sudo chmod 640 /taskmaster/.htpasswd
```

If Docker cannot read it due to permissions, use:

```bash
sudo chmod 644 /taskmaster/.htpasswd
```

## Deploy

```bash
chmod +x deploy-taskmaster.sh
./deploy-taskmaster.sh
```
