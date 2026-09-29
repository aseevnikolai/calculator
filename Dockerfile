# syntax=docker/dockerfile:1
# Платформа сборочной стадии задана константой намеренно (см. комментарий ниже) — отключаем это правило линтера.
# check=skip=FromPlatformFlagConstDisallowed

# ---------- Стадия 1: сборка статики ----------
# Проект зафиксирован на node-sass 4.11.0: готовые бинарники у него есть только для x86_64
# и Node <= 11. Поэтому сборка идёт на Node 10 под linux/amd64 (на Apple Silicon — через эмуляцию).
# Результат сборки — статические файлы, от архитектуры процессора он не зависит.
FROM --platform=linux/amd64 node:10.24.1-buster AS build
WORKDIR /app
COPY package.json package-lock.json ./
# --ignore-scripts: не скачивать бинарники imagemin — они нужны только необязательной задаче `npm run img`.
# node-sass затем пересобирается отдельно: ему нужен свой нативный модуль.
RUN npm ci --ignore-scripts && npm rebuild node-sass
COPY gulpfile.js ./
COPY source ./source
RUN npx gulp build

# ---------- Стадия 2: веб-сервер ----------
FROM nginxinc/nginx-unprivileged:1.31.6-alpine
# Конфигурация nginx собирается из шаблонов при старте контейнера:
# значения переменных окружения подставляет штатный envsubst образа nginx.
COPY docker/nginx/templates/ /etc/nginx/templates/
COPY docker/nginx/10-require-status-password.sh /docker-entrypoint.d/
COPY --from=build /app/build/ /usr/share/nginx/html/
ENV NGINX_PORT=8080 \
    APP_ENV=production \
    STATUS_USER=admin
EXPOSE 8080
