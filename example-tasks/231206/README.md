# Введение:

Однажды твой друг решил пойти изучать DevOps, но он забыл спросить, где это можно сделать лучше всего - как результат, он купил курсы в ООО СкиллСаня. Когда дело дошло до домашки, он прибежал к тебе с просьбой объяснить "как деплоить котиков". Тут на тебя нахлынули вьетнамские флэшбэки лекций, в которых объяснялось что web-сервера нужны чтобы два друга обменивались котиками. Но, что еще страннее, ты подумал - а ведь действительно, что делать, если я захочу получить сервер для обмена котиками? Твое больное воображение уже было не остановить. В попытках помочь своему другу - ты начал разворачивать file hosting web сайт…

## Документация:

- [Как поднимать виртуальные машины в Vagrant](https://gitlab.com/deusops/lessons/documentation/vagrant)
- [Wikipedia - NFS](https://ru.wikipedia.org/wiki/Network_File_System)
- [File Storage Types and Protocols for Beginners](https://www.youtube.com/watch?v=ABQ7okl09RY)
- [Ubuntu Wiki - NFS](https://help.ubuntu.ru/wiki/nfs)
- [Документация по Docker](https://gitlab.com/deusops/lessons/documentation/docker)
- [Документация по Gitlab Cl](https://gitlab.com/deusops/lessons/documentation/gitlab-ci)
- [Гайд по ролям](https://docs.ansible.com/ansible/latest/user_guide/playbooks_reuse_roles.html) и [Гайд по Galaxy](https://docs.ansible.com/ansible/latest/galaxy/user_guide.html)
- [NFS в качестве PersistentVolume](https://www.digitalocean.com/community/tutorials/how-to-set-up-readwritemany-rwx-persistent-volumes-with-nfs-on-digitalocean-kubernetes-ru)
- Kubernetes: [StorageClasses](https://kubernetes.io/docs/concepts/storage/storage-classes/) / [PV](https://kubernetes.io/docs/concepts/storage/persistent-volumes/) / [PV и PVC](https://rtfm.co.ua/kubernetes-persistentvolume-i-persistentvolumeclaim-obzor-i-primery/)

## Чекпойнты по уровню сложности:

### Light:

1. Разверните две виртуальные машины c linux: web01 и files01. Можно использовать любые способы создания, например в Яндекс Облаке или локально на Vagrant
2. Установите NFS-сервер на виртуальную машину "files01". Настройте экспорт директории /files
3. Установить NFS-клиент на виртуальную машину "web01". Настроить подключение к серверу и получить директории с сервера
4. Установите и настройте Nginx на виртуальную машину "web01". Настроить сервер в качестве proxy на localhost
5. Установить на "web01" Django, запустить [django-приложение](https://gitfront.io/r/deusops/BC6tmrogTrbh/django-filesharing/) и проверить что всё работает
6. Настроить сервер так, чтобы файлы через web-сайт оказывались на NFS-хранилище

### Normal:

1. Написать Dockerfile для приложения, установить на "web01" Docker и запустить приложение в контейнере. Убедиться, что всё работает так, как настраивали в уровне Light
2. Написать gitlab-cі пайплайн для автоматической сборки и публикации Docker-образа с приложением
3. Написать ansible-playbook настраивающий сервера web01 и files01
4. Написать ansible-роль "nfs", для установки nfs-сервера и nfs-клиента. Придумать как разделять Server и Client на уровне ролей и на уровне inventory-hosts-file
5. Написать ansible-роль "nginx", для установки nginx и темплейт для конфигурации proxy на localhost
6. Написать ansible-роль "docker", для установки docker и темплейт для запуска docker-compose с нужным нам приложением
7. Добавить в gitlab-ci шаг с деплоем приложения на сервера. Ansible-роли должны находиться в отдельных репозиториях и работать через galaxy

### Hard:

1. Развернуть в облаке kubernetes-кластер и настроить ingress для доступа извне
2. Используя созданные ранее ansible-роли, настроить виртуальную машину для NFS-сервера
3. Подключить в kubernetes [nfs-subdir-external-provisioner](https://github.com/kubernetes-sigs/nfs-subdir-external-provisioner). настроить работу волумов через NFS
4. Создать helm-чарт для деплоя приложения в kubernetes-кластер
5. Доработать пайплайн для автоматического развертывания приложения в kubernetes-кластер
6. Вынести инфраструктурные элементы іaс из репозитория проекта в инфраструктурный репозиторий

### Expert:

1. Создать документацию с описанием архитектуры, настроек и процедур обслуживания для вашей инфраструктуры
2. Продумать флоу доставки приложения на контура, разработать Gitlab CI пайплайн для автоматического развертывания инфраструктуры
3. Оформить развертывание всей инфраструктуры в Яндекс Облаке через Terraform. Провижн виртуальных машин оставить силами Ansible.
