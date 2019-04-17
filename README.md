# Bulk Expression Atlas Solr scripts
Scripts to create and version-manage Solr collections used by [bulk Expression
Atlas](https://www.ebi.ac.uk/gxa).

## Environment variables
The following environment variables are used in all scripts. Default values are
indicated in parentheses.
* `SOLR_HOST`: host and port of the Solr server (`localhost:8983`)
* `SOLR_COLLECTION`: name of the collection to create (`bulk-analytics-v1`)
* `SOLR_BASE_CONFIG`: base configset to use for the collection (`default`)
* `SOLR_NUM_SHARDS`: number of shards (`1`, recommended value `2`)
* `SOLR_REPLICATION_FACTOR`: replication factor (`1`)

## Collection `bulk-analytics`
This collection is used by Expression Atlas to store data and metadata of all
experiments.

To create the collection run the following two scripts:
```bash
./bin/create-bulk-analytics-collection.sh
./bin/create-bulk-analytics-schema.sh
```

The scripts delete any previous version of the collection, its fields and field
types, so error messages are to be expected the first time the scripts are run.

The collection is populated from the web app using these URLs:
* `/admin/analyticsIndex/buildIndex`: imports the data of public experiments
only. Use the URL `/admin/analyticsIndex/buildIndex/status` to follow the
indexing progress.
* `/admin/experiments/{experiment-accession}/ANALYTICS_IMPORT`: loads into the
collection a single experiment. Use
`/admin/experiments/{experiment-accession}/LOG` to track progress. Private
experiments may be loaded using this endpoint.
* `/admin/experiments/{experiment-accession}/ANALYTICS_DELETE`: removes data of
a single experiment from the collection.
