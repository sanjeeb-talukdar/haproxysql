.PHONY: help

help: ## This help.
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)

build: ## Build the containers
	docker-compose build $(name)

up: ## Run all containers
	docker-compose up --scale mysql=4 --scale proxysql=4

up-svc: ## Run specific containers
	docker-compose up $(name)

down: ## Stop all containers
	docker-compose down $(name)

ps: ## Show status for all containers
	docker-compose ps

clear: ## Remove all images with <none> name
	- docker ps -a -q | xargs docker rm
	- docker images | grep "^<none>" | awk '{print $$3}' | xargs docker rmi

console: ## Enter in MySQL console bypass from ProxySQL
	mysql -h 127.0.0.1 -u sandbox -psandbox -P 3306

admin-proxysql: ## Enter in ProxySQL console
	docker exec -it haproxysql_proxysql_$(number) /bin/mysql -h 127.0.0.1 -u admin -padmin -P 6032

mysql-direct: ## Enter in ProxySQL console
	docker exec -it haproxysql_mysql_$(number) /bin/mysql -h 127.0.0.1 -u sandbox  -psandbox  -P 3306

multimaster: ## Configure MultiMaster replication topology
	./scripts/multimaster.sh

