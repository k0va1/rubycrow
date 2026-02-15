ARG RUBY_VERSION
FROM ruby:$RUBY_VERSION-slim AS base

WORKDIR /rails

ENV RAILS_ENV="production" \
  BUNDLE_DEPLOYMENT="1" \
  BUNDLE_PATH="/usr/local/bundle" \
  BUNDLE_WITHOUT="development:test" \
  HOME=/rails

FROM base as build

RUN apt-get update -qq && \
  apt-get install -y build-essential curl libpq-dev nodejs git

ARG NODE_VERSION
ARG YARN_VERSION
ENV PATH=/usr/local/node/bin:$PATH
RUN curl -sL https://github.com/nodenv/node-build/archive/master.tar.gz | tar xz -C /tmp/ && \
    /tmp/node-build-master/bin/node-build "${NODE_VERSION}" /usr/local/node && \
    npm install -g yarn@$YARN_VERSION && \
    rm -rf /tmp/node-build-master

COPY Gemfile Gemfile.lock ./
RUN bundle install && \
    rm -rf ~/.bundle/ "${BUNDLE_PATH}"/ruby/*/cache "${BUNDLE_PATH}"/ruby/*/bundler/gems/*/.git

COPY package.json yarn.lock ./
RUN yarn install --frozen-lockfile

COPY . .

RUN --mount=type=secret,id=RAILS_MASTER_KEY \
  SECRET_KEY_BASE_DUMMY=1 \
  RAILS_MASTER_KEY=$(cat /run/secrets/RAILS_MASTER_KEY) \
  RAILS_ENV=production \
  bundle exec rails assets:precompile && \
  rm -rf /usr/local/bundle/cache

FROM base

RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y libvips postgresql-client imagemagick tzdata curl vim && \
    rm -rf /var/lib/apt/lists /var/cache/apt/archives

RUN useradd www --create-home --shell /bin/bash

USER www

COPY --from=build --chown=www /usr/local/node /usr/local/node
COPY --from=build --chown=www /usr/local/bundle /usr/local/bundle
COPY --from=build --chown=www /rails /rails

ENTRYPOINT ["/rails/bin/docker-entrypoint"]

EXPOSE 3000
CMD ["./bin/rails", "server"]
