SHELL := /bin/bash

VERSION := `cat VERSION`
CURRENT := storm:${VERSION}
DOCKERHUB_TARGET := enterhaken/storm:${VERSION}
DOCKERHUB_TARGET_LATEST := enterhaken/storm:latest

.PHONY: default
default: build

.PHONY: check_deps
check_deps:
	if [ ! -d deps ]; then mix deps.get; fi
	make -C assets

.PHONY: build
build: check_deps 
	mix compile --force --warnings-as-errors

.PHONY: run 
run: build start_dev_db
	iex -S mix phx.server

.PHONY: clean
clean:
	rm _build/ -rf || true

.PHONY: clean_deps
clean_deps:
	rm deps/ -rf || true
	
.PHONY: clean_assets
clean_assets:
	rm assets/node_modules -rf || true

.PHONY: clean_priv_static
clean_priv_static:
	rm priv/static -rf || true

.PHONY: clean_docker
clean_docker:
	docker stop storm_app || true
	docker rm storm_app || true
	docker rmi storm_app || true
	# TODO: add filter
	docker image prune -f
	docker container prune -f
	docker volume rm storm_db || true

.PHONY: deep_clean
deep_clean: clean clean_deps clean_assets clean_priv_static clean_docker

.PHONY: release
release: 
	mix deps.get --only prod
	MIX_ENV=prod mix compile --warnings-as-errors
	npm install --prefix ./assets
	npm run deploy --prefix ./assets
	MIX_ENV=prod mix phx.digest
	MIX_ENV=prod mix release

.PHONY: test
test: build start_test_db
	mix test --no-start

.PHONY: docker
docker: 
	docker build -t ${CURRENT} .

.PHONY: docker_run
docker_run:
	docker run \
		-p 4000:4000 \
		--name storm \
		-d \
		-t ${CURRENT} 

.PHONY: docker_push
docker_push:
	docker tag $(CURRENT) $(DOCKERHUB_TARGET) 
	docker push $(DOCKERHUB_TARGET)
	docker tag $(CURRENT) $(DOCKERHUB_TARGET_LATEST) 
	docker push $(DOCKERHUB_TARGET_LATEST)

.PHONY: up 
up:
	if [ ! -f ".env" ]; then ./create_env.sh; fi;
	docker-compose up -d
	docker logs -tf storm_postgres_prod

.PHONY: down
down:
	docker-compose down

.PHONY: update
update: docker
	docker stop storm 
	docker rm storm 
	make docker_run

# used by silver searcher
.PHONY: ignore
ignore:
	find deps/ > .ignore || true
	find doc/ >> .ignore || true
	find _build/ >> .ignore || true
	find assets/node_modules/ >> .ignore || true
	find priv/ >> .ignore || true

.PHONY: start_test_db
start_test_db: 
	make -C db env=test all wait || true

.PHONY: start_dev_db
start_dev_db: 
	make -C db all wait || true
