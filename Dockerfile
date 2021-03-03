# backend builder

ARG POSTGRES_HOST=${POSTGRES_HOST}
ARG POSTGRES_DB=${POSTGRES_DB}
ARG POSTGRES_USER=${POSTGRES_USER}
ARG POSTGRES_PASSWORD=${POSTGRES_PASSWORD}

FROM elixir:1.11.2 AS backend_builder

# TODO: extract node related stuff to seperate stage.
# TODO: remove node related stuff from `make release` target.

# Reason: having more control about the used node version
# - node is only needed for the build process

RUN apt-get update && apt-get install nodejs npm -y
RUN npm i npm@latest -g

WORKDIR /app

COPY . .

RUN mix local.hex --force
RUN mix local.rebar --force

ARG POSTGRES_HOST

# The POSTGRES_HOST variable is needed at build time.
# otherwise it is set to `localhost` per default.

# see: https://github.com/elixir-ecto/postgrex/blob/v0.15.8/lib/postgrex.ex#L168
# and: https://github.com/elixir-ecto/postgrex/blob/v0.15.8/lib/postgrex/utils.ex#L83

ENV POSTGRES_HOST ${POSTGRES_HOST}

RUN make release

# backend runner 

FROM elixir:1.11.2-slim AS runner

ARG POSTGRES_HOST
ARG POSTGRES_DB
ARG POSTGRES_USER
ARG POSTGRES_PASSWORD

ENV POSTGRES_HOST ${POSTGRES_HOST}
ENV POSTGRES_DB ${POSTGRES_DB}
ENV POSTGRES_USER ${POSTGRES_USER}
ENV POSTGRES_PASSWORD ${POSTGRES_PASSWORD}

WORKDIR /app

COPY --from=backend_builder /app/_build/prod/rel/storm .

EXPOSE 4000 

CMD ["bin/storm", "start"]
