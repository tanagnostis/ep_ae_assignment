CREATE TABLE dim_clients (
    client_id                   SERIAL PRIMARY KEY,
    name                        VARCHAR(255),
    birth_date                  TIMESTAMP, 
    email                       VARCHAR(255),
    phone_number                VARCHAR(50),
    is_active                   BOOLEAN,
    preferred_contact_method    VARCHAR(50),
    customer_segment            VARCHAR(50),
    marketing_opt_in            BOOLEAN
);

CREATE TABLE dim_addresses (
    dim_address_id              SERIAL PRIMARY KEY,
    client_id                   INTEGER REFERENCES dim_clients(client_id),
    address                     VARCHAR(100),
    city                        VARCHAR(100),
    state_province              VARCHAR(20),
    zip_code                    VARCHAR(20),
    country                     VARCHAR(100)
);

CREATE TABLE dim_accounts (
    dim_account_id              SERIAL PRIMARY KEY, 
    account_id                  VARCHAR(50), 
    client_id                   INTEGER REFERENCES dim_clients(client_id), 
    registration_date           TIMESTAMP,
    acc_currency_code           VARCHAR(10)
);

CREATE TABLE dim_dates (
    dim_date_id                 SERIAL PRIMARY KEY,
    event_date                  TIMESTAMP,
    day                         INTEGER,
    month                       INTEGER,
    month_name                  VARCHAR(20),
    quarter                     INTEGER,
    year                        INTEGER,
    weekday_name                VARCHAR(20)
);

CREATE TABLE fact_transactions (
    transaction_id              SERIAL PRIMARY KEY,
    dim_date_id                 INTEGER REFERENCES dim_dates(dim_date_id),                
    dim_account_id              INTEGER REFERENCES dim_accounts(dim_account_id),
    client_id                   INTEGER REFERENCES dim_clients(client_id),
    available_balance_delta     NUMERIC(18,2),
    available_balance           NUMERIC(18,2)
);