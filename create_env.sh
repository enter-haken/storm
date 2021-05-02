#!/bin/bash

# WARNING: keep the `.env` file out of version control.
# these are the credentials for your prod storm instance

if [ ! -f ".env" ]; then
cat <<EOT >.env
PGHOST=storm_postgres_prod
PGDATABASE=storm_prod
PGPASSWORD=$(openssl rand -base64 32)
PGUSER=postgres
EOT
fi;
