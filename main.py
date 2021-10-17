import config
from sqlalchemy import create_engine
import pandas as pd
import os

engine = create_engine(f'mysql://{config.user}:{config.password}@{config.host}/{config.database}')

for filename in os.listdir("datasheets/"):
    print(filename)
    df= pd.read_excel(f"datasheets/{filename}")
    df.to_sql(filename,con=engine, chunksize=10000,method='multi')





