# storm database development

![schema][1]

# creating a first storm collection 

```
storm_dev=# select insert_collection();
NOTICE:  collection 814eefdc-7511-4b25-9e4b-1b6aa8a158d9 has been set to dirty (change/add user)
NOTICE:  created new collection 814eefdc-7511-4b25-9e4b-1b6aa8a158d9 with owner bea46045-33dc-4ffd-b14f-f36c9eff97ec
                                               insert_collection                                               
---------------------------------------------------------------------------------------------------------------
 {"owner_id": "bea46045-33dc-4ffd-b14f-f36c9eff97ec", "collection_id": "814eefdc-7511-4b25-9e4b-1b6aa8a158d9"}
(1 row)

```

After creating the first idea collection the collection it self and a user marked as an owner is created.

```
storm_dev=# select * from collection;
                  id                  | title | description | is_visible |                                                                                                                         json_view                                                                                                                          |         created_at         |         updated_at         
--------------------------------------+-------+-------------+------------+------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+----------------------------+----------------------------
 814eefdc-7511-4b25-9e4b-1b6aa8a158d9 |       |             | f          | {"id": "814eefdc-7511-4b25-9e4b-1b6aa8a158d9", "ideas": [], "title": null, "users": [{"id": "bea46045-33dc-4ffd-b14f-f36c9eff97ec", "name": null, "is_owner": true, "show_identity": false}], "is_dirty": false, "is_visible": false, "description": null} | 2021-02-10 12:44:54.173501 | 2021-02-10 12:44:54.173501
(1 row)
```

The `json_view` column contains all the collection data needed by the backend.

## using docker files

The easiest way to start a `storm` database is to use the `dev db docker container`.

There is a `Makefile` in place, to help you set up the database.

```
$ make run 
```

This creates a docker image `storm_postgres_dev` and starts a `db container` with auth method `trust`.

```
$ psql -h localhost -U postgres -d storm_dev
psql (13.1)
Type "help" for help.

storm_dev=# \dt
              List of relations
 Schema |      Name       | Type  |  Owner   
--------+-----------------+-------+----------
 public | browser_session | table | postgres
 public | collection      | table | postgres
 public | collection_idea | table | postgres
 public | idea            | table | postgres
 public | idea_like       | table | postgres
 public | idea_text       | table | postgres
 public | meta            | table | postgres
 public | text            | table | postgres
 public | user            | table | postgres
(9 rows)

storm_dev=# select * from meta;
                  id                  |   key   | value |         created_at         |         updated_at         
--------------------------------------+---------+-------+----------------------------+----------------------------
 bff6e213-17e2-4aac-826a-cc6afb182309 | version | 0.1.0 | 2021-02-10 12:05:27.106774 | 2021-02-10 12:05:27.106774
(1 row)

storm_dev=# 
```

[1]: assets/schema.png
