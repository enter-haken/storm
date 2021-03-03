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

# production 

When you want to run `storm` in production mode, 
you can use the `docker-compose.yml` file with.

```
$ make up
```

Currently the data is dropped on every start.
