## Data Ops Evaluation

The goal of this test project is to evaluate various "big data" and "distributed
compute" tools/services/apps/frameworks/products. Run in a test/lab environment,
but aiming to base the code on production-quality infrastructure (run on AWS).


### Apps / Tools up for consideration:

* TensorFlow
* Kafka
* Storm
* Neo4j
* StreamSets
* Apache Flume
* Spark
* AWS Redshift
* Elasticsearch


### Goals

* get experience setting up a few data ops tools/services
* demonstrate some meaningful examples, "toy" examples similar to expected use
* create some code we can re-use, or use as examples to demonstrate implementation


### Interesting Targets

* dynamic, load-based, autoscaling cluster
* screenshot web uis available
* track all files/scripts/setup steps/etc to make it happen
* map out one or more meaningful demonstrations that pull together (preferrably)
  several data ops tools into a pipeline or collection of services, examples:
    * run tensorflow image recognition library
    * follow some twitter stream, with different types of analysis running on
      incoming events in parallel
    * run batch-type analysis on stored data / results
    * application log analysis and storage
    * log-centric web app demo
