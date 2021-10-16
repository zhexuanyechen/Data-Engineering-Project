import config
from sqlalchemy import create_engine
import pandas as pd

engine = create_engine(f'mysql://{config.user}:{config.password}@{config.host}/{config.database}')






