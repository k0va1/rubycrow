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
	bin/brakeman --no-pager

lint-fix:
	bundle exec rake standard:fix
	herb-format
	bin/brakeman --no-pager

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

kamal:
	@env $$(cat .env.prod | xargs) kamal $(filter-out $@,$(MAKECMDGOALS))

deploy:
	@env $$(cat .env.prod | xargs) kamal deploy

infra-setup:
	@env $$(cat .env.prod | xargs) ansible-playbook -i infra/inventory/hosts infra/setup.yml

prod-cons:
	@env $$(cat .env.prod | xargs) kamal app exec -i 'bin/rails console'

prod-ssh:
	ssh www@$(shell grep '^HOST=' .env.prod | cut -d '=' -f2)

%:
	@:

clear-jobs:
	bundle exec rails runner 'Sidekiq.redis { |conn| conn.flushdb }'
