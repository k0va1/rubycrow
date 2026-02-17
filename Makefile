.PHONY: test

# Start services (postgres, redis in Docker)
services:
	docker compose up -d postgres redis

services-stop:
	docker compose down

# Local development
install:
	bundle install
	yarn install

start: services
	bin/dev

console:
	bundle exec rails console

test:
	bundle exec rails test

lint:
	bundle exec rake standard
	herb-format --check

lint-fix:
	bundle exec rake standard:fix
	herb-format

db-reset:
	bundle exec rails db:drop
	RAILS_ENV=test bundle exec rails db:drop

db-prepare: db-reset
	bundle exec rails db:create db:migrate db:seed
	RAILS_ENV=test bundle exec rails db:create db:migrate

db-migrate:
	bundle exec rails db:migrate
	RAILS_ENV=test bundle exec rails db:migrate

db-rollback:
	bundle exec rails db:rollback

db-open:
	bundle exec rails db -p

change-secrets:
	bundle exec rails credentials:edit --environment=$(filter-out $@,$(MAKECMDGOALS))

g:
	bundle exec rails g $(filter-out $@,$(MAKECMDGOALS))

d:
	bundle exec rails d $(filter-out $@,$(MAKECMDGOALS))

%:
	@:

clear-jobs:
	bundle exec rails runner 'Sidekiq.redis { |conn| conn.flushdb }'
