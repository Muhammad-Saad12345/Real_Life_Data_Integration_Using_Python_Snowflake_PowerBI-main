import pandas as pd
import numpy as np
import os

DATEID='20240728'
directory = "E:\SMIT\project\Real_Life_Data_Integration_Using (Python, Snowflake, Power BI)\Landing Directory"

# create directory if not exists
os.makedirs(directory, exist_ok=True)

for i in range(1,101):
    num_rows = np.random.randint(100,1000)
    data = {
        'DateID': [DATEID] * num_rows ,
        'ProductID': np.random.randint(1,1001,size=num_rows),
        'StoreID': [i] * num_rows,
        'CustomerID': np.random.randint(1,1001,size=num_rows),
        'QuantityOrderded': np.random.randint(1,21,size=num_rows),   
        'OrderAmount': np.random.randint(100,1001,size=num_rows)
        }
        
    df = pd.DataFrame(data)


    discount_perc = np.random.uniform(0.02,0.15,size=num_rows)
    shipping_cost = np.random.uniform(0.05,0.15,size=num_rows)


    # calculate columns 
    df['DiscountAmount'] = df['OrderAmount'] * discount_perc
    df['Shipping Cost'] = df['OrderAmount'] * shipping_cost
    df['TotalAmount'] = df['OrderAmount'] -(df['DiscountAmount']+df['Shipping Cost'])
    print(df)
    
    file_name=f'Store_{i}_{DATEID}.csv'
    file_path=os.path.join(directory,file_name)
    

    # if file exists remove and write again
    if os.path.exists(file_path):
        os.remove(file_path)
    
    
    df.to_csv(file_path,index=False)