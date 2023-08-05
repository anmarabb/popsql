from pyspark.sql import SparkSession
from pyspark.sql.functions import from_json, col, split, current_timestamp
from pyspark.sql.types import StringType, ArrayType, StructType, StructField
import re

# Create Spark Session
spark = SparkSession.builder.getOrCreate()

# Database configuration
driver = "org.postgresql.Driver"
database_host = "production-floranow-erp.cluster-ro-c47qrxmyb1ht.eu-central-1.rds.amazonaws.com"
database_port = "5432"
database_name = "floranow_erp_db"
user = "read_only"
password = "dENW5_J9DXcS@7"

url = f"jdbc:postgresql://{database_host}:{database_port}/{database_name}"

# Function to sanitize column names (remove special characters)
def sanitize_column_name(name):
    return re.sub(r'[^A-Za-z0-9_]', '_', name)

# Specify the table name directly
table_name = 'public.line_items'
 
try:
    print(f"Table {table_name} sync started")

    # Custom schema string for problematic decimal columns
    custom_schema = "unit_fob_price DOUBLE, unit_landed_cost DOUBLE, exchange_rate DOUBLE, total_tax DOUBLE, total_price_include_tax DOUBLE, \
                     total_price_without_tax DOUBLE, unit_price DOUBLE, calculated_price DOUBLE, price_margin DOUBLE, unit_additional_cost DOUBLE, \
                     unit_shipment_cost DOUBLE, calculated_unit_price DOUBLE, unit_tax DOUBLE, packing_list_fob_price DOUBLE"

    # Load data from the remote table
    remote_table = (spark.read
        .format("jdbc")
        .option("driver", driver)
        .option("url", url)
        .option("dbtable", table_name)
        .option("user", user)
        .option("password", password)
        .option("customSchema", custom_schema)
        .load())

    # Sanitize column names
    for column_name in remote_table.columns:
        sanitized_column_name = sanitize_column_name(column_name)
        remote_table = remote_table.withColumnRenamed(column_name, sanitized_column_name)

    # Replace 'public' schema with 'prod_erp.1_source' in the target table name
    target_table = table_name.replace('public.', 'dev_floranow.default.')

    # Define the schema for the 'categorization' column
    categorization_schema = ArrayType(
        StructType([
            StructField("permalink", StringType())
        ])
    )

    # Parse the 'categorization' JSON string into an array of objects and extract the 'permalink' of the first object
    remote_table = remote_table.withColumn("permalink", from_json(col("categorization"), categorization_schema).getItem(0)["permalink"])

    # Split the 'permalink' into categories
    remote_table = remote_table.withColumn("categories", split(col("permalink"), "/"))

    # Create new 'category' fields
    num_categories = len(remote_table.select("categories").first()[0])
    for i in range(1, num_categories):
        remote_table = remote_table.withColumn("category" + str(i), remote_table["categories"].getItem(i))

    # Add 'ingestion_timestamp' column
    remote_table = remote_table.withColumn("ingestion_timestamp", current_timestamp())

    # Write data to Delta Lake
    remote_table.write \
        .format("delta") \
        .mode("overwrite") \
        .option("mergeSchema", "true") \
        .saveAsTable(target_table)

    print(f"Table {target_table} has been copied to Delta Lake.")

except Exception as e:
    print(f"An error occurred with table {table_name}: {e}")