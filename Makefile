build:
	docker compose build
build-no-cache:
	docker compose build --no-cache
build-composer:
	docker build -t laravel-composer --target vendor -f docker/php/Dockerfile .
build-js:
	docker build -t laravel-js --target frontend -f docker/php/Dockerfile .
up:
	docker compose up -d
serve:
	@make up
	open http://localhost
composer-install:
	docker run -it --rm -v $(shell pwd):/app laravel-composer bash -c "composer install"
js-build:
	docker run -it --rm -v $(shell pwd):/app laravel-js bash -c "npm install && npm run build"
key-generate:
	docker compose run app php artisan key:generate
migrate:
	docker compose exec app php artisan migrate
seed:
	docker compose exec app php artisan db:seed
down:
	docker compose down
init:
	cp .env.example .env
	@make build
	@make build-composer
	@make build-js
	sleep 10
	@make composer-install
	sleep 10
	@make js-build
	sleep 10
	@make key-generate
	@make up
	sleep 10
	@make migrate
	@make seed
	@make down