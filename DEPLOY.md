# Развёртывание калькулятора

Приложение — статический сайт: gulp собирает `source/` в `build/`, а в контейнере его раздаёт nginx.
Код приложения не менялся; добавлены только файлы развёртывания.

| Файл | Назначение |
|---|---|
| `Dockerfile` | двухстадийная сборка: Node 10 собирает статику, nginx (без root) её раздаёт |
| `docker/nginx/` | шаблоны конфигурации nginx; значения подставляются из переменных окружения при старте |
| `compose.yaml`, `.env.example` | воспроизводимый запуск через Docker Compose |
| `k8s/` | манифесты Kubernetes: Namespace, ConfigMap, Secret (образец), Deployment, Service |
| `cluster/kind-config.yaml` | локальный кластер kind из одного узла с пробросом порта 30080 |

## Настройки (переменные окружения)

| Переменная | Где задаётся | Смысл |
|---|---|---|
| `NGINX_PORT` | `.env` / ConfigMap | порт nginx внутри контейнера |
| `APP_ENV` | `.env` / ConfigMap | метка окружения, отдаётся в заголовке `X-App-Env` |
| `STATUS_USER` | `.env` / ConfigMap | логин к служебной странице `/status` |
| `STATUS_PASSWORD` | `.env` / Secret | пароль к `/status`; без него контейнер не стартует |
| `WEB_PORT` | `.env` | порт на компьютере (только для Compose) |

`.env` и `k8s/secret.yaml` содержат пароль и в Git не попадают.

## Docker Compose

```bash
git clone <URL этого репозитория> calculator && cd calculator
cp .env.example .env          # задать свой STATUS_PASSWORD
docker compose up -d
# приложение: http://localhost:8080
```

## Kubernetes (kind)

```bash
kind create cluster --config cluster/kind-config.yaml
docker build -t calculator:1.2.1 .
kind load docker-image calculator:1.2.1 --name lab
cp k8s/secret.yaml.example k8s/secret.yaml   # задать свой STATUS_PASSWORD
kubectl apply -f k8s/
kubectl get pods,services,deployments -n calculator
# приложение: http://localhost:30080
```
