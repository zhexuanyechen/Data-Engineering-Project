import config
from sqlalchemy import create_engine
import pandas as pd
import os
import requests as r
import sites
import sqlqueries
 
# Creating the engine to talk with the database
engine = create_engine(f'mysql://{config.user}:{config.password}@{config.host}/{config.database}')
directory = 'datasheets/'

# Pulling all datafiles from the specified websites
print("Pulling files")
for name in sites.sites:
    request = r.get(sites.sites[name])
    open(f'{directory}{name}','wb').write(request.content)

# Creating tables for all datafiles in the folder datasheets
try:
    print("Creating Tables")
    for filename in os.listdir(directory):
        if filename.endswith('.xlsx'):
            sheets = pd.read_excel(f"{directory}{filename}",sheet_name=None)
            if(len(sheets) > 1):
                print(f"{filename} has more than 1 datasheet")
                for sheet in sheets: 
                    df = pd.read_excel(f"{directory}{filename}",sheet_name=f"{sheet}")
                    df.to_sql(f"{filename}-{sheet}",con=engine, if_exists='replace',chunksize=10000,method='multi')
            elif(len(sheets) == 1):       
                df= pd.read_excel(f"{directory}{filename}")  
                df.to_sql(os.path.splitext(filename)[0],con=engine, if_exists='replace',chunksize=10000,method='multi') 
        elif filename.endswith('.csv'):          
            df= pd.read_csv(f"{directory}{filename}")
            df.to_sql(os.path.splitext(filename)[0],con=engine, if_exists='replace',chunksize=10000,method='multi')  
except Exception as error:
    print("Removing datafiles because of an error in creating the data tables")
    print(error)
    for filename in os.listdir(directory):
        if not filename.startswith('mp'):
            os.remove(os.path.join(directory,filename))

# Clearing the directory that holds the datafiles 
print("Removing datafiles")
for filename in os.listdir(directory):
    if not filename.startswith('mp'):
        os.remove(os.path.join(directory,filename))


# Applying queries to prepare data
print("Executing queries")
with engine.begin() as connection:
    for query in sqlqueries.queries:
        connection.execute(query)
     






