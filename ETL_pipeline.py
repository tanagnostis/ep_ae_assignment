# 0. Import packages/libraries
import pandas as pd
from sqlalchemy import create_engine
import psycopg2
# 1. Dataset - Loading, Exploration and Cleaning

# 1.1 Dataset - Load
data = pd.read_csv('./data/dataset.csv')
print(f"Initial data rows: {data.shape[0]}")
print(f"Initial data columns: {data.shape[1]}")

# 1.2 Dataset - Explore
# data.info()
# data.head()

# data[data['client_name']=='Henry Ford']

# data[data['client_name']=='Bob Johnson'][['registration_date', 'balance_event_date', 'available_balance', 'available_balance_delta']]

unique_column_values = {column: (data[column].nunique(), data[column].unique()) for column in data.columns}
# print(unique_column_values)

# data.groupby(['substring', 'client_name', 'birth_date', 'registration_date']).size().reset_index().rename(columns={0:'count'})

# 1.3 Dataset - Cleaning
# 1.3.1 Convert specific columns to date and timestamps/datetimes

# data[['birth_date', 'registration_date', 'balance_event_date']]

data['birth_date'] =  pd.to_datetime(data['birth_date'], format='mixed')#.dt.date
data['registration_date'] =  pd.to_datetime(data['registration_date'], format='mixed')
data['balance_event_date'] =  pd.to_datetime(data['balance_event_date'], format='mixed')

# 1.3.2 Convert balance columns to float/numeric

data['available_balance_delta'] = pd.to_numeric(data['available_balance_delta'].str.replace('.','').str.replace(',','.'))
data['available_balance'] = pd.to_numeric(data['available_balance'].str.replace('.','').str.replace(',','.'))

# 1.3.3 - Rename columns substring and client_name

data.rename(columns = {'substring': 'account_id', 'client_name': 'account_holder'}, inplace = True)

print("Columns have been renamed")

# 1.3.4 - Create column client_id

client_mapping = {}
count = 1
for name in data['account_holder'].unique():
    client_mapping[name] = count
    count+=1

data['client_id'] = data['account_holder'].map(client_mapping)

# 2. Schema creation - Kimball style

# 2.1 Dimension table - Clients
clients_dim = data[['client_id', 'account_holder', 'birth_date', 'email', 'phone_number',
        'is_active',  'preferred_contact_method', 'customer_segment',
       'marketing_opt_in']].drop_duplicates()
clients_dim.rename(columns = {'account_holder': 'name'}, inplace= True)

print("Dim Clients table")
print(f"Dim Clients rows: {clients_dim.shape[0]}")
print(f"Dim Clients columns: {clients_dim.shape[1]}")

# 2.2 Dimension table - Accounts
accounts_dim = data[['account_id', 'client_id', 'registration_date', 'acc_currency_code']].drop_duplicates().reset_index(drop = True)

# 2.2.1 Create surrogate key dim_account_id
accounts_dim['dim_account_id'] = accounts_dim.index + 1

# 2.2.2 Rearrange columns
accounts_dim = accounts_dim.iloc[:, [-1, 0, 1, 2, 3,]]

print("Dim Accounts table")
print(f"Dim Accounts rows: {accounts_dim.shape[0]}")
print(f"Dim Accounts columns: {accounts_dim.shape[1]}")

# 2.3 Dimension table - Addresses
addresses_dim = data[['client_id', 'address', 'city', 'state_province','zip_code', 'country']].drop_duplicates().reset_index(drop = True)

# 2.3.1 Create surrogate key dim_address_id
addresses_dim['dim_address_id'] = addresses_dim.index + 1

# 2.3.2 Rearrange columns
addresses_dim = addresses_dim.iloc[:, [-1, 0, 1, 2, 3, 4, 5]]

print("Dim Address table")
print(f"Dim Address rows: {addresses_dim.shape[0]}")
print(f"Dim Address columns: {addresses_dim.shape[1]}")

# 2.4 Dimension table - Dates
dim_date = data['balance_event_date'].drop_duplicates().sort_values().reset_index()

dim_date['dim_date_id'] = dim_date.index + 1
dim_date['day'] = dim_date['balance_event_date'].dt.day
dim_date['month'] = dim_date['balance_event_date'].dt.month
dim_date['month_name'] = dim_date['balance_event_date'].dt.month_name()
dim_date['quarter'] = dim_date['balance_event_date'].dt.quarter
dim_date['year'] = dim_date['balance_event_date'].dt.year
dim_date['weekday_name'] = dim_date['balance_event_date'].dt.day_name()
dim_date.rename(columns={'balance_event_date': 'event_date'}, inplace=True)

dim_date = dim_date.iloc[:, [2, 1, 3, 4, 5, 6, 7, 8]]
print("Dim Date table")
print(f"Dim Date rows: {dim_date.shape[0]}")
print(f"Dim Date columns: {dim_date.shape[1]}")


# 2.5 Fact table - Transactions
data = data.merge(dim_date[['dim_date_id', 'event_date']], left_on='balance_event_date', right_on='event_date', how='left')
data = data.merge(accounts_dim[['dim_account_id', 'account_id']], on='account_id', how='left')
data = data.sort_values('balance_event_date', ascending = True).reset_index(drop = True)

print('Facts Table')
facts = data[['dim_date_id', 'dim_account_id', 'client_id', 'available_balance_delta', 'available_balance']]

print(f"Facts table rows: {facts.shape[0]}")
print(f"Facts table columns: {facts.shape[1]}")