/*
Here is a Python script that uses PySpark to load data from a PostgreSQL database into Delta Lake on Databricks.
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
database_name = "marketplace_prod"
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
        target_table = table_name.replace('public.', 'fn_sources.mkp.')

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
        if table_name not in ['public.friendly_id_slugs']:
            future = pool.submit(load_table, table_name)
            try:
                print(future.result())
            except Exception as e:
                print(f"An error occurred with table {table_name}: {e}")



/*
calculates and compares the row counts for the source (PostgreSQL) and destination (Databricks Delta Lake) tables. The output should help you verify that the ETL process was successful.
*/

from pyspark.sql import SparkSession

# Create Spark Session
spark = SparkSession.builder.getOrCreate()

# Database configuration
# Database configuration
driver = "org.postgresql.Driver"
database_host = "prod-floranow.cluster-ro-c47qrxmyb1ht.eu-central-1.rds.amazonaws.com"
database_port = "5432"
database_name = "marketplace_prod"
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

# Function to fetch row count from PostgreSQL
def get_postgresql_row_count(table_name):
    query = f"SELECT COUNT(*) as count FROM {table_name}"
    row_count = (spark.read
        .format("jdbc")
        .option("driver", driver)
        .option("url", url)
        .option("query", query)
        .option("user", user)
        .option("password", password)
        .load()
        .collect()[0]["count"])
    return row_count

# Function to fetch row count from Databricks Delta Lake
def get_databricks_row_count(table_name):
    delta_table = spark.table(table_name)
    row_count = delta_table.count()
    return row_count

# Initialize lists for good and check tables
good_tables = []
check_tables = []

# Iterate over the tables
for table_name in table_list:
    if table_name not in ['public.friendly_id_slugs']:
        postgresql_table_name = table_name
        databricks_table_name = table_name.replace('public.', 'fn_sources.mkp.')
        try:
            postgresql_row_count = get_postgresql_row_count(postgresql_table_name)
            databricks_row_count = get_databricks_row_count(databricks_table_name)
            
            if postgresql_row_count == databricks_row_count:
                good_tables.append((table_name, postgresql_row_count))
            else:
                diff = abs(postgresql_row_count - databricks_row_count)
                check_tables.append((table_name, postgresql_row_count, databricks_row_count, diff))
            
        except Exception as e:
            print(f"An error occurred with table {table_name}: {e}")

# Print the results
print("Good Tables:")
for table_name, row_count in good_tables:
    print(f"- {table_name} - Source: {row_count}, Databricks: {row_count}")
    
print("\nCheck Tables:")
for table_name, postgresql_row_count, databricks_row_count, diff in check_tables:
    print(f"- {table_name} - Source: {postgresql_row_count}, Databricks: {databricks_row_count}, diff: {diff}")