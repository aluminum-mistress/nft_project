import pandas as pd
import json


df = pd.read_csv('./whitelist/whitelist.csv')
print(df)

addressList = df['address'].tolist()

with open('./whitelist/whitelist.json', 'w') as f:
    json.dump(addressList, f)

