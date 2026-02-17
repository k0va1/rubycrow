# syntax=docker/dockerfile:1
# check=error=true

ARG RUBY_VERSION=4.0.1

FROM ruby:$RUBY_VERSION-slim AS base

WORKDIR /rails

RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y \
    curl \
    libvips \
    libyaml-dev \
    postgresql-client \
    imagemagick \
    tzdata \
    ffmpeg && \
    rm -rf /var/lib/apt/lists /var/cache/apt/archives

ENV RAILS_ENV="production" \
    BUNDLE_DEPLOYMENT="1" \
    BUNDLE_PATH="/usr/local/bundle" \
    BUNDLE_WITHOUT="development:test" \
    HOME=/rails

FROM base AS build

RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y build-essential curl libpq-dev libyaml-dev nodejs git && \
    rm -rf /var/lib/apt/lists /var/cache/apt/archives

# Install JavaScript dependencies
ARG NODE_VERSION
ARG YARN_VERSION
ENV PATH=/usr/local/node/bin:$PATH
RUN curl -sL https://github.com/nodenv/node-build/archive/master.tar.gz | tar xz -C /tmp/ && \
    /tmp/node-build-master/bin/node-build "${NODE_VERSION}" /usr/local/node && \
    npm install -g yarn@$YARN_VERSION && \
    rm -rf /tmp/node-build-master

# Install application gems
COPY .ruby-version Gemfile Gemfile.lock ./
RUN --mount=type=cache,target=/usr/local/bundle/cache \
    bundle install && \
    rm -rf ~/.bundle/ "${BUNDLE_PATH}"/ruby/*/cache "${BUNDLE_PATH}"/ruby/*/bundler/gems/*/.git && \
    bundle exec bootsnap precompile --gemfile

# Install node modules
COPY package.json yarn.lock ./
RUN yarn install --frozen-lockfile

# Copy application code
COPY . .

# Precompile bootsnap code for faster boot times
RUN bundle exec bootsnap precompile app/ lib/

# Precompile assets for production
RUN SECRET_KEY_BASE_DUMMY=1 ./bin/rails assets:precompile

# Remove node_modules to reduce image size (not needed at runtime)
RUN rm -rf node_modules

# Final stage for app image
FROM base

# Run and own only the runtime files as a non-root user for security
RUN groupadd --system --gid 1000 www && \
    useradd www --uid 1000 --gid 1000 --create-home --shell /bin/bash
USER 1000:1000

# Copy built artifacts: gems, application
COPY --chown=www:www --from=build "${BUNDLE_PATH}" "${BUNDLE_PATH}"
COPY --chown=www:www --from=build /rails /rails

# Entrypoint prepares the database.
ENTRYPOINT ["/rails/bin/docker-entrypoint"]

# Start the server by default, this can be overwritten at runtime
EXPOSE 3000
CMD ["./bin/rails", "server"]
