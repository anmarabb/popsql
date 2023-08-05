/*
Here is a Python script that uses PySpark to load data from a PostgreSQL database into Delta Lake on Databricks.
*/

from pyspark.sql import SparkSession
import re
import multiprocessing
from concurrent.futures import ThreadPoolExecutor
from pyspark.sql.functions import from_json, col
from pyspark.sql.types import ArrayType, StringType, StructType, StructField

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

# JSON Schema for permalink extraction
json_schema = ArrayType(
    StructType([
        StructField('permalink', StringType())
    ])
)

# Query to fetch all table names from the 'public' schema
query = """
    SELECT table_schema || '.' || table_name AS full_rel_name 
    FROM information_schema.tables 
    WHERE table_schema = 'public'
"""

# Get the list of all tables
table_list = (spark.read
    .format("jdbc")
    .option("driver", driver)
    .option("url", url)
    .option("query", query)
    .option("user", user)
    .option("password", password)
    .load()
    .rdd
    .flatMap(lambda x: x)
    .collect())

def load_table(table_name): 
    try:
        print(f"Table {table_name} sync started")
        
        # custom schema string for problematic decimal columns
        if table_name == 'public.users':
            custom_schema = "pending_balance DOUBLE, credit_limit DOUBLE, credit_balance DOUBLE, debit_balance DOUBLE, remaining_credit DOUBLE"
        elif table_name == 'public.line_items':
            custom_schema = "unit_fob_price DOUBLE, unit_landed_cost DOUBLE, exchange_rate DOUBLE, total_tax DOUBLE, total_price_include_tax DOUBLE, \
                             total_price_without_tax DOUBLE, unit_price DOUBLE, calculated_price DOUBLE, price_margin DOUBLE, unit_additional_cost DOUBLE, \
                             unit_shipment_cost DOUBLE, calculated_unit_price DOUBLE, unit_tax DOUBLE, packing_list_fob_price DOUBLE"
        else:
            custom_schema = ""

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

        # If the table has a 'categorization' column, extract 'permalink'
        if 'categorization' in remote_table.columns:
            remote_table = remote_table.withColumn(
                "permalink", 
                from_json(col("categorization"), json_schema)[0]['permalink']
            )

        # Replace 'public' schema with 'floranow_dev.erp_prod' in the target table name
        target_table = table_name.replace('public.', 'fn_sources.erp.')

        # Write data to Delta Lake
        remote_table.write \
            .format("delta") \
            .mode("overwrite") \
            .option("mergeSchema", "true") \
            .saveAsTable(target_table)

        print(f"Table {target_table} has been copied to Delta Lake.")
    
    except Exception as e:
        print(f"An error occurred with table {table_name}: {e}")

# Use multithreading to load multiple tables at once
num_threads = multiprocessing.cpu_count()
with ThreadPoolExecutor(max_workers=num_threads) as pool:
    for table_name in table_list:
        if table_name not in ['public.versions','public.trackings']:
            future = pool.submit(load_table, table_name)
            try:
                print(future.result())
            except Exception as e:
                print(f"An error occurred with table {table_name}: {e}")



/**