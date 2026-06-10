# James Schedule App v7

This version uses your supplied YAML files exactly as the seed data:

```text
seed-taskmaster/tasks.yaml
seed-taskmaster/completed.yaml
seed-taskmaster/urgent.yaml
```

The deploy script copies them into `/taskmaster` only if the corresponding host file is missing. It does not rewrite existing `/taskmaster/*.yaml` files.

## Behavior

- `urgent.yaml` displays as urgent tasks.
- `tasks.yaml` displays as medium-term tasks.
- `completed.yaml` displays as **Things I Have Already Done and Want Nick Cole to Know About**.
- Clicking **Done** on an urgent task moves it from `urgent.yaml` to `completed.yaml`.
- Clicking **Done** on a medium-term task moves it from `tasks.yaml` to `completed.yaml`.
- Footer says: `fuck you james`.
- HTTP Basic Auth uses `/taskmaster/.htpasswd`.
- TLS uses Certbot certs for `taskmaster.vixal.net`.

## htpasswd

Install:

```bash
sudo apt update
sudo apt install apache2-utils
```

Create first user:

```bash
sudo mkdir -p /taskmaster
sudo htpasswd -c -B /taskmaster/.htpasswd james
```

Add another user:

```bash
sudo htpasswd -B /taskmaster/.htpasswd nick
```

## Deploy

```bash
chmod +x deploy-taskmaster.sh
./deploy-taskmaster.sh
```

Then visit:

```text
https://taskmaster.vixal.net
```

## Force replacing host YAMLs with the supplied versions

The deploy script does not overwrite existing `/taskmaster/*.yaml`.

If you want to replace them manually:

```bash
sudo cp seed-taskmaster/tasks.yaml /taskmaster/tasks.yaml
sudo cp seed-taskmaster/completed.yaml /taskmaster/completed.yaml
sudo cp seed-taskmaster/urgent.yaml /taskmaster/urgent.yaml
```
