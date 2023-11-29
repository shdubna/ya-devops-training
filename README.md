# Тестовое задание "Тренировки DevOps"

## Запуск

Заполнить переменные, см [variables.tfvars.example](variables.tfvars.example)

[Получить авторизационные данные](https://cloud.yandex.ru/docs/tutorials/infrastructure-management/terraform-quickstart#get-credentials) в облаке в `tf_key.json`.

Запустить container registry:
```bash
terraform plan -target yandex_container_registry.registry -var-file="variables.tfvars"
terraform apply -target yandex_container_registry.registry -var-file="variables.tfvars"
```

Получить id реестра из вывода terraform.

Выполнить сборку контейнера с приложением и запушить в registry:
```bash
container_registry_id=""
docker build -t cr.yandex/${container_registry_id}/bingo:20231121T1537 .

cat ./tf_key.json | \
  docker login --username json_key --password-stdin cr.yandex

docker push cr.yandex/${container_registry_id}/bingo:20231121T1537
```

Выполнить полный deploy:
```bash
terraform plan -var-file="variables.tfvars"
terraform apply -var-file="variables.tfvars"
```

Вручную добавить DNS запись, адрес взять из вывода terraform.


## Комментарии

Представленное решение имеет ряд "костылей", обусловленных тем что был недоступен managed k8s в предоставленном гранте.
По моему мнению использование k8s было бы предпочтительней.

### HTTP3
Настройка произведена, однако не удалось выставить UDP порт через nlb, 
при применении конфигурации получаю ошибку отсутствия прав в облаке:
`code = PermissionDenied desc = Permission denied to create UDP listener`.
В описании провайдера есть возможность использования UDP.
Соответствующий код закомментирован в конфигурации [nlb](bingo.tf).
Если назначить публичный адрес непосредственно на VM, то проверка http3 проходит. 

### Порт в переменных terraform
Мне не удалось разгадать загадку с алгоритмом генерации порта. Точно ясно что он зависит от введенного email.
Загадку с лог директорией удалось решить - первые 10 символов от sha1 хеша строки email.

### Логирование в /dev/null
Информация в логе малоинформативна, имеет большой объем. 
Я не нашел возможности сконфигурировать уровень логирования или настроить логирование в stdout.

### Autoheal контейнер
Не самое красивое решение, но compose не умеет автоматически перезапускать unhealthy сервисы.
В kubernetes решается с помощью livenessProbe.

### Метрики
Выполнить не удалось. Как решение экспорта метрик из nginx можно реализовать на Fluentd парсингом логов.


