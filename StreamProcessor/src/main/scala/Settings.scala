//TODO: verify environment variables issue

import com.typesafe.config.Config

class Settings(config: Config) extends Serializable {

  var cassandra: Map[String, String] = {
    Map(
      "host" -> config.getString("cassandra.host"),
      "keyspace" -> config.getString("cassandra.keyspace"),
      "username" -> config.getString("cassandra.username"),
      "password" -> config.getString("cassandra.password"),
      "trades" -> config.getString("cassandra.tables.trades"),
      "aggregates" -> config.getString("cassandra.tables.aggregates")
    )
  }

  var kafka: Map[String, String] = {
    Map(
      "server_address" -> s"${config.getString("kafka.server")}:${config.getString("kafka.port")}",
      "topic_market" -> config.getString("kafka.topics.market"),
      "min_partitions" -> config.getString("kafka.min_partitions.StreamProcessor")
    )
  }

  var spark: Map[String, String] = {
    Map(
      "master" -> config.getString("spark.master"),
      "appName" -> config.getString("spark.appName.StreamProcessor"),
      "max_offsets_per_trigger" -> config.getString("spark.max_offsets_per_trigger.StreamProcessor"),
      "shuffle_partitions" -> config.getString("spark.shuffle_partitions.StreamProcessor"),
      "deprecated_offsets" -> config.getString("spark.deprecated_offsets.StreamProcessor")
    )
  }

  var schemas: Map[String, String] = {
    Map(
      "trades" ->  config.getString("schemas.trades")
    )
  }

}
