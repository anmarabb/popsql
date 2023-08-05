from pyspark.sql import SparkSession

# Database configuration
driver = "org.postgresql.Driver"
database_host = "prod-floranow.cluster-ro-c47qrxmyb1ht.eu-central-1.rds.amazonaws.com"
database_port = "5432"
database_name = "marketplace_prod"
user = "readonly"
password = "UfnpdeKIxseRwUsYzkKm"
url = f"jdbc:postgresql://{database_host}:{database_port}/{database_name}"

spark = SparkSession.builder.getOrCreate()

tables = spark.read.format("jdbc") \
    .option("url", url) \
    .option("driver", driver) \
    .option("user", user) \
    .option("password", password) \
    .option("dbtable", "(SELECT tablename FROM pg_catalog.pg_tables WHERE schemaname != 'pg_catalog' AND schemaname != 'information_schema') as tablenames") \
    .load().collect()

total_size = 0
all_tables = []

for table in tables:
    table_name = table["tablename"]
    size_query = f"(SELECT pg_relation_size('{table_name}')) as tablesize"
    size = spark.read.format("jdbc") \
        .option("url", url) \
        .option("driver", driver) \
        .option("user", user) \
        .option("password", password) \
        .option("dbtable", size_query) \
        .load().collect()[0][0]
    total_size += size

    rows_query = f"(SELECT COUNT(*) FROM {table_name}) as tablerows"
    rows = spark.read.format("jdbc") \
        .option("url", url) \
        .option("driver", driver) \
        .option("user", user) \
        .option("password", password) \
        .option("dbtable", rows_query) \
        .load().collect()[0][0]

    cols_query = f"(SELECT COUNT(*) FROM information_schema.columns WHERE table_name='{table_name}') as tablecols"
    cols = spark.read.format("jdbc") \
        .option("url", url) \
        .option("driver", driver) \
        .option("user", user) \
        .option("password", password) \
        .option("dbtable", cols_query) \
        .load().collect()[0][0]

    all_tables.append((table_name, size, rows, cols))

# Define function to convert bytes to human readable format
def convert_bytes(num):
    """
    this function will convert bytes to MB.... GB... etc
    """
    for x in ['bytes', 'KB', 'MB', 'GB', 'TB']:
        if num < 1024.0:
            return "%3.1f %s" % (num, x)
        num /= 1024.0

# Sort all_tables by size in descending order
all_tables.sort(key=lambda x: x[1], reverse=True)

# Print each table's size in a human-readable format and number of rows
for table_name, size, rows, cols in all_tables:
    size_category = "Large table" if size >= 1024**3 else "Small table"
    size_pretty = convert_bytes(size)
    print(f"{size_category}: {table_name}, Size: {size_pretty}, Rows: {rows}, Columns: {cols}")

# Print total size of all tables
total_size_pretty = convert_bytes(total_size)
print(f"Total size of all tables: {total_size_pretty}")



-