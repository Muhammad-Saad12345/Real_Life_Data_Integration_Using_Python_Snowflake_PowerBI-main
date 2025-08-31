# import pandas library
import pandas as pd

# start date and end date between which we need to generate our dates
start_date ='2014-01-01'
end_date='2024-12-31'


# generate a series of dates between the start and the end date 
date_range = pd.date_range(start=start_date, end= end_date)

# convert these series of dates into a data frame 
data_dimension = pd.DataFrame(date_range, columns=['Date'])


# add new columns to our dataframe DayofWeek Month Quarter Year Isweekend DateID
data_dimension['DayofWeek'] = data_dimension['Date'].dt.dayofweek
data_dimension['Month'] = data_dimension['Date'].dt.month
data_dimension['Quarter'] = data_dimension['Date'].dt.quarter
data_dimension['Year'] = data_dimension['Date'].dt.year
data_dimension['Isweekend'] = data_dimension['DayofWeek'].isin([5,6])
data_dimension['DateID'] = data_dimension['Date'].dt.strftime('%Y%m%d').astype(int)


# reorder our data frame so that the dateid becomes the 1st column
cols = ['DateID'] + [col for col in data_dimension.columns if col != 'DateID']
date_dimension=data_dimension[cols]


# export it into a csv index column to be ignored 
date_dimension.to_csv('DimDate.csv',index=False)