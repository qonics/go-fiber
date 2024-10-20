APP_BINARY = app-release
t = latest

## up: starts all containers in the background without forcing build
up:
	@echo "Starting Docker images..."
	docker-compose up -d
	@echo "Docker images started"

## up_build: stops docker-compose (if running), builds all projects and starts docker compose, you can add more service after build_service, use space as separator
up_build: web-service ussd-service logger-service
	@echo "Stopping docker images (if running...)"
	docker-compose down
	@echo "Building (when required) and starting docker images..."
	docker-compose up --build -d
	@echo "Docker images built and started!"

## Build single service and pass the service by using the argument s. Ex: make build s=my-service
build: $(s)
	@echo "Stoping single service:" $(s)
	docker-compose down $(s)
	@echo "Building and starting single service:" $(s)
	docker-compose up --build -d $(s)
	@echo $(s) "built and started!"

## down: destroy docker compose
down:
	@echo "destroy docker compose..."
	docker-compose down
	@echo "Done!"

## down: stop docker compose
stop:
	@echo "Stopping docker compose..."
	docker-compose stop
	@echo "Done!"

## down: start docker compose
start:
	@echo "Starting docker compose..."
	docker-compose start
	@echo "Done!"

## web-service: builds the service binary as a linux executable, you will create many command as you add more services
web-service:
	@echo "Building web service binary..."
	cd ./services/web-service && go mod tidy
	cd ./services/web-service/controller && go test -v
	cd ./services/web-service && env GOOS=linux CGO_ENABLED=0 go build -o ${APP_BINARY}
	@echo "Done!"

## web-service: builds the service binary as a linux executable, you will create many command as you add more services
ussd-service:
	@echo "Building ussd service binary..."
	cd ./services/ussd-service && go mod tidy
	cd ./services/ussd-service/controller && go test -v
	cd ./services/ussd-service && env GOOS=linux CGO_ENABLED=0 go build -o ${APP_BINARY}
	@echo "Done!"

## web-service: builds the service binary as a linux executable, you will create many command as you add more services
logger-service:
	@echo "Building logger service binary..."
	cd ./services/logger-service && go mod tidy
	cd ./services/logger-service/controller && go test -v
	cd ./services/logger-service && env GOOS=linux CGO_ENABLED=0 go build -o ${APP_BINARY}
	@echo "Done!"

deploy: $(s)
	@echo "Building and deploying single service:" $(s)
	docker compose build $(s)
	@echo "Tag single service:" $(s)
	docker tag bralirwa-api-$(s) qonicsinc/lottery-$(s):$(t)
	@echo "Pushing image to docker hub" $(s)
	docker push qonicsinc/lottery-$(s):$(t)
	@if [ "$(t)" != "latest" ]; then \
		echo "Build also latest image"; \
		docker tag bralirwa-api-$(s) qonicsinc/lottery-$(s):latest; \
		echo "Push latest image"; \
		docker push qonicsinc/lottery-"$(s)":latest; \
	fi
	@echo $(s) "image pushed"