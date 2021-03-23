# Storm

Finding ideas

# Requirements

* docker
* asdf

# first run

```
$ asdf install
```

will install all necessary requirements.

# running locally 

```
make run
```

Will do

* check the dependencies (if necessary)
  * set up the node environment in the `assets` folder
  * make a `mix deps.get`
* do a `mix compile --force --warnings-as-errors`
* setups the database
* and run the server 

The database will be resetted on every run

# launch production version

When you want to run `storm` in production mode, 
you can use the `docker-compose.yml` file with.

```
$ make up
```

A local `.env` file like

```
POSTGRES_HOST=storm_postgres_prod
POSTGRES_DB=storm_prod
POSTGRES_PASSWORD=kDf1hGn8empcXc1qJD5lyWfOvudRrtwrxg7pEHlb99U=
POSTGRES_USER=postgres
```

will be created, if missing.

# contact

[hake.one](https://hake.one). Jan Frederik Hake, <jan_hake@gmx.de>. [@enter_haken](https://twitter.com/enter_haken) on Twitter. [enter-haken#7260](https://discord.com) on discord.
