#!/bin/sh
# Пароль к /status обязателен: без него контейнер не стартует, а не работает с пустым паролем.
if [ -z "${STATUS_PASSWORD:-}" ]; then
    echo "ОШИБКА: не задана переменная окружения STATUS_PASSWORD (см. .env.example)" >&2
    exit 1
fi
