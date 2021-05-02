# backend builder
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

RUN make release

# backend runner 

FROM elixir:1.11.2-slim AS runner

ENV PGHOST ${PGHOST}
ENV PGDATABASE ${PGDATABASE}
ENV PGUSER ${PGUSER}
ENV PGPASSWORD ${PGPASSWORD}

WORKDIR /app

COPY --from=backend_builder /app/_build/prod/rel/storm .

EXPOSE 4000 

CMD ["bin/storm", "start"]
