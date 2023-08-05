------------- grower_portal_db -------------



------------- marketplace_prod -------------
# Database configuration
driver = "org.postgresql.Driver"
#database_host = "prod-floranow.cluster-c47qrxmyb1ht.eu-central-1.rds.amazonaws.com"  #prduction don't use.
database_host = "prod-floranow.cluster-ro-c47qrxmyb1ht.eu-central-1.rds.amazonaws.com" #readonly use this.
database_port = "5432"
database_name = "marketplace_prod"
user = "readonly"
password = "UfnpdeKIxseRwUsYzkKm"
url = f"jdbc:postgresql://{database_host}:{database_port}/{database_name}"

# Create Spark session
spark = SparkSession.builder.getOrCreate()

# Test database connection
try:
    df = spark.read \
        .format("jdbc") \
        .option("driver", driver) \
        .option("url", url) \
        .option("user", user) \
        .option("password", password) \
        .option("dbtable", "(SELECT 1) as test") \
        .load()

    print("Database connection successful!")
except Exception as e:
    print("Database connection failed: ", str(e))



------------- grower_portal_db -------------

# Database configuration
driver = "org.postgresql.Driver"
#database_host = "prod-floranow.cluster-c47qrxmyb1ht.eu-central-1.rds.amazonaws.com"  #prduction don't use.
database_host = "prod-floranow.cluster-ro-c47qrxmyb1ht.eu-central-1.rds.amazonaws.com" #readonly use this.
database_port = "5432"
database_name = "grower_portal_db"
user = "readonly"
password = "UfnpdeKIxseRwUsYzkKm"
url = f"jdbc:postgresql://{database_host}:{database_port}/{database_name}"

# Create Spark session
spark = SparkSession.builder.getOrCreate()

# Test database connection
try:
    df = spark.read \
        .format("jdbc") \
        .option("driver", driver) \
        .option("url", url) \
        .option("user", user) \
        .option("password", password) \
        .option("dbtable", "(SELECT 1) as test") \
        .load()

    print("Database connection successful!")
except Exception as e:
    print("Database connection failed: ", str(e))