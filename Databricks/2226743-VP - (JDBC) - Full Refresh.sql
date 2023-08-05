/*

*/
from pyspark.sql import SparkSession
import re
import multiprocessing
from concurrent.futures import ThreadPoolExecutor

# Create Spark Session
spark = SparkSession.builder.getOrCreate()

# Database configuration
driver = "org.postgresql.Driver"
database_host = "prod-floranow.cluster-ro-c47qrxmyb1ht.eu-central-1.rds.amazonaws.com"
database_port = "5432"
database_name = "grower_portal_db"
user = "readonly"
password = "UfnpdeKIxseRwUsYzkKm"

url = f"jdbc:postgresql://{database_host}:{database_port}/{database_name}"

# Function to sanitize column names (remove special characters)
def sanitize_column_name(name):
    return re.sub(r'[^A-Za-z0-9_]', '_', name)

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

def load_table (table_name): 
    try:
        print(f"Table {table_name} sync started")
        

        # Load data from the remote table
        remote_table = (spark.read
            .format("jdbc")
            .option("driver", driver)
            .option("url", url)
            .option("dbtable", table_name)
            .option("user", user)
            .option("password", password)
            .load())

        # Sanitize column names
        for column_name in remote_table.columns:
            sanitized_column_name = sanitize_column_name(column_name)
            remote_table = remote_table.withColumnRenamed(column_name, sanitized_column_name)

        # Replace 'public' schema with 'prod_mkp.1_source' in the target table name
        target_table = table_name.replace('public.', 'fn_sources.vp.')

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
        if table_name not in ['public.versions']:
            future = pool.submit(load_table, table_name)
            try:
                print(future.result())
            except Exception as e:
                print(f"An error occurred with table {table_name}: {e}")