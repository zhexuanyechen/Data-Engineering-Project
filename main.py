import config
from sqlalchemy import create_engine
import pandas as pd
import os
import requests as r
import sites

# Creating the engine to talk with the database
engine = create_engine(f'mysql://{config.user}:{config.password}@{config.host}/{config.database}')
directory = 'datasheets/'

# Pulling all datafiles from the specified websites
for name in sites.sites:
    request = r.get(sites.sites[name])
    open(f'{directory}{name}','wb').write(request.content)

# Creating tables for all datafiles in the folder datasheets
for filename in os.listdir(directory):
    if filename.endswith('.csv'):
        df= pd.read_csv(f"{directory}{filename}")
    elif filename.endswith('.xlsx'):
        df= pd.read_excel(f"{directory}{filename}")        
    df.to_sql(os.path.splitext(filename)[0],con=engine, if_exists='replace',chunksize=10000,method='multi')

# Clearing the directory that holds the datafiles 
for files in os.listdir(directory):
    os.remove(os.path.join(directory,files))






