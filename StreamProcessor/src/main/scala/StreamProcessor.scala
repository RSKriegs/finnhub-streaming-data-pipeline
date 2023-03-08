//this is the main Spark app responsible for stream processing.
//it retrieves messages from Kafka, transforms it in Spark engine and loads into Cassandra.

import org.apache.spark.sql._
import org.apache.spark.sql.functions._
import org.apache.spark.sql.avro.functions._
import org.apache.spark.sql.streaming._
import org.apache.spark.sql.types._
import org.apache.spark.sql.cassandra._

import com.datastax.oss.driver.api.core.uuid.Uuids
import com.datastax.spark.connector._

import com.typesafe.config.{Config, ConfigFactory}

import scala.io.Source

object StreamProcessor {
    def main(args:Array[String]): Unit =
    {
        // loading configuration
        val conf: Config = ConfigFactory.load()
        val settings: Settings = new Settings(conf)
        
        // loading trades schema
        val tradesSchema: String = Source.fromInputStream( 
            getClass.getResourceAsStream(settings.schemas("trades"))).mkString

        // udf for Cassandra uuids
        val makeUUID = udf(() => Uuids.timeBased().toString)
        
        // create Spark session
        val spark = SparkSession
            .builder
            .master(settings.spark("master"))
            .appName(settings.spark("appName"))
            .config("spark.cassandra.connection.host",settings.cassandra("host"))
            .config("spark.cassandra.connection.host",settings.cassandra("host"))
            .config("spark.cassandra.auth.username", settings.cassandra("username"))
            .config("spark.cassandra.auth.password", settings.cassandra("password"))
            .config("spark.sql.shuffle.partitions", settings.spark("shuffle_partitions"))
            .getOrCreate()
        
        // proper processing code below
        import spark.implicits._

        // read streams from Kafka
        val inputDF = spark
            .readStream
            .format("kafka")
            .option("kafka.bootstrap.servers",settings.kafka("server_address"))
            .option("subscribe",settings.kafka("topic_market"))
            .option("minPartitions", settings.kafka("min_partitions"))
            .option("maxOffsetsPerTrigger", settings.spark("max_offsets_per_trigger"))
            .option("useDeprecatedOffsetFetching",settings.spark("deprecated_offsets"))
            .load()

        // explode the data from Avro
        val expandedDF = inputDF
            .withColumn("avroData",from_avro(col("value"),tradesSchema))
            .select($"avroData.*")
            .select(explode($"data"),$"type")
            .select($"col.*")

        // rename columns and add proper timestamps
         val finalDF = expandedDF
            .withColumn("uuid", makeUUID())
            .withColumnRenamed("c", "trade_conditions")
            .withColumnRenamed("p", "price")
            .withColumnRenamed("s", "symbol")
            .withColumnRenamed("t","trade_timestamp")
            .withColumnRenamed("v", "volume")
            .withColumn("trade_timestamp",(col("trade_timestamp") / 1000).cast("timestamp"))
            .withColumn("ingest_timestamp",current_timestamp().as("ingest_timestamp"))

        // write query to Cassandra
        val query = finalDF
            .writeStream
            .foreachBatch { (batchDF:DataFrame,batchID:Long) =>
                println(s"Writing to Cassandra $batchID")
                batchDF.write
                    .cassandraFormat(settings.cassandra("trades"),settings.cassandra("keyspace"))
                    .mode("append")
                    .save()
            }
            .outputMode("update")
            .start()

        // another dataframe with aggregates - running averages from last 15 seconds
        val summaryDF = finalDF
            .withColumn("price_volume_multiply",col("price")*col("volume"))
            .withWatermark("trade_timestamp","15 seconds")
            .groupBy("symbol")
            .agg(avg("price_volume_multiply"))
    
        //rename columns in dataframe and add UUIDs before inserting to Cassandra
        val finalsummaryDF = summaryDF
            .withColumn("uuid", makeUUID())
            .withColumn("ingest_timestamp",current_timestamp().as("ingest_timestamp"))
            .withColumnRenamed("avg(price_volume_multiply)","price_volume_multiply")
        
        // write second query to Cassandra
        val query2 = finalsummaryDF
            .writeStream
            .trigger(Trigger.ProcessingTime("5 seconds"))
            .foreachBatch { (batchDF:DataFrame,batchID:Long) =>
                println(s"Writing to Cassandra $batchID")
                batchDF.write
                    .cassandraFormat(settings.cassandra("aggregates"),settings.cassandra("keyspace"))
                    .mode("append")
                    .save()
            }
            .outputMode("update")
            .start()
        
        // let query await termination
        spark.streams.awaitAnyTermination()
    }
}