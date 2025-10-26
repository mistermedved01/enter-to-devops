## Light:

1. Разверните виртуальне машины с linux: db01 и air01. Можно использовать любые способы создания, например в облаках или локально на Vagrant. Для машины "db01" необходимо использовать сервер с GPU, такие есть в наших партнёрских облаках Immers Cloud и Selectel
2. Установи СУБД PostgreSQL на виртуальную машину "db01". Создать базу данных "<code>airflow</code>" и пользователя "<code>airflow</code>" для доступа к ней.
3. Установить расширение "<code>pg_strom</code>" и добавить его в "<code>shared_preload_libraries</code>"
4. Установи Apache Airflow на виртуальную машину "air01"
5. Настроить подключение Airflow к PostgreSQL на хосте db01
6. Развернуть [DAG](https://gitlab.deusops.com/deuslearn/classbook/mlops-dag-01) в Airflow
