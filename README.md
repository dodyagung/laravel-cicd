For development, just run :

```yaml
docker compose -f compose.development.yaml down && \
UID=$(id -u) GID=$(id -g) docker compose -f compose.development.yaml up -d
```
