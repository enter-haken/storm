#!/bin/bash

# WARNING: keep the `.env` file out of version control.
# these are the credentials for your prod storm instance

if [ ! -f ".env" ]; then
cat <<EOT >.env
POSTGRES_HOST=storm_postgres_prod
POSTGRES_DB=storm_prod
POSTGRES_PASSWORD=$(openssl rand -base64 32)
POSTGRES_USER=postgres
EOT
fi;
