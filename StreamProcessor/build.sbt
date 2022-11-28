name := "StreamProcessor"

version := "1.0"

scalaVersion := "2.12.15"

libraryDependencies ++= Seq(
    "org.apache.spark" %% "spark-core" % "3.2.1" % "provided",
    "org.apache.spark" %% "spark-sql" % "3.2.1" % "provided",
    "org.apache.spark" %% "spark-avro" % "3.2.1" % "provided",
    "com.datastax.spark" %% "spark-cassandra-connector" % "3.2.0" % "provided",
    "com.datastax.cassandra" % "cassandra-driver-core" % "3.11.3" % "provided",
    "com.typesafe" % "config" % "1.4.1"
)

assemblyMergeStrategy in assembly := {
 case PathList("META-INF", _*) => MergeStrategy.discard
 case _                        => MergeStrategy.first
}