import mysql.connector
import config

mydb = mysql.connector.connect(
  host=config.host,
  user=config.user,
  password=config.password,
  database=config.database,
)

print(mydb)