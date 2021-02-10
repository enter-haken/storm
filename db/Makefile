env=dev

.PHONY: default
default: build

.PHONY: build
build:
	docker build -t storm_postgres_$(env) --file=Dockerfile_$(env) .

.PHONY: run
run: build
	docker run \
		--name storm_postgres_$(env) \
		-e POSTGRES_HOST_AUTH_METHOD=trust \
		-p 5432:5432 \
		-d storm_postgres_$(env) 

.PHONY: start
start:
	docker start storm_postgres_${env}

.PHONY: clean 
clean: 
	for container in $$(docker ps -a -f name=storm --format="{{.ID}}"); do \
		docker stop $$container || true; \
		docker rm $$container || true; \
	done

.PHONY: rmi
rmi:
	docker rmi storm_postgres_$(env) || true

.PHONY: all 
all: clean rmi build run

.PHONY: logs
logs:
	docker logs storm_postgres_$(env)

.PHONY: wait
wait:
	while [ 1 -eq $$(docker exec -t storm_postgres_$(env) psql -U postgres -d storm_$(env) -c "\l" 2>&1 | grep error | wc -l) ]; \
	do \
		echo "waiting for db..."; \
		sleep 1; \
	done
