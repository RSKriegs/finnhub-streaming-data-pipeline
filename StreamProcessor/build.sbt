//Optional TO DO: verify configs
lazy val root = (project in file(".")).
  settings(
    name := "streamprocessor",
    version := "1.0",
    scalaVersion := "2.12.15"
  )

val sparkVersion = "3.0.0"

//probably some of these libraries below are unnecessary to be included in such a manner
//TODO: verify it
libraryDependencies ++= Seq(
    "org.apache.spark" %% "spark-core" % sparkVersion % "provided",
    "org.apache.spark" %% "spark-sql" % sparkVersion % "provided",
    "org.apache.spark" %% "spark-avro" % sparkVersion % "provided",
    "org.apache.spark" %% "spark-sql-kafka-0-10" % sparkVersion % "provided",
    "com.datastax.spark" %% "spark-cassandra-connector" % sparkVersion % "provided",
    "com.datastax.cassandra" % "cassandra-driver-core" % "3.11.3" % "provided",
    "com.typesafe" % "config" % "1.4.1"
)

javaOptions := Seq("-Dconfig.resource=deployment.conf")

//below filename is default for assembly, but I include it for readability
assemblyJarName in assembly := "streamprocessor-assembly-1.0.jar"

assemblyMergeStrategy in assembly := {
  case "reference.conf" => MergeStrategy.concat
  case "META-INF/services/org.apache.spark.sql.sources.DataSourceRegister" => MergeStrategy.concat
  case PathList("META-INF", xs@_*) => MergeStrategy.discard
  case _ => MergeStrategy.first
}
