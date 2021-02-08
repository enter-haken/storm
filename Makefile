.PHONY: default
default: build

.PHONY: check_deps
check_deps:
	if [ ! -d deps ]; then mix deps.get; fi
	if [ ! -d assets/node_modules ]; then pushd assets; npm install; popd; fi

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

.PHONY: deep_clean
deep_clean: clean clean_deps clean_assets

.PHONY: release
release: build
	MIX_ENV=prod mix release

.PHONY: test
test: build start_test_db
	mix test --no-start

.PHONY: docker
docker: 
	docker build -t ${IMG} .
	docker tag ${IMG} ${LATEST}

.PHONY: docker_run
docker_run:
	docker run \
		-p 5054:4000 \
		--name storm \
		-d \
		-t ${LATEST} 

.PHONY: update
update: docker
	docker stop storm 
	docker rm storm 
	make docker_run

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


