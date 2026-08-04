## RUN THIS TO SET UP DATA WAREHOUSE IN POSTGRES (ENV-BASED CONFIG) ##

import os
import psycopg2
from datetime import datetime
from decimal import Decimal

# Read DB config from environment variables (safe for GitHub)
DB_CONFIG = {
    "host": os.getenv("DB_HOST", "localhost"),
    "dbname": os.getenv("DB_NAME", "data_warehouse"),
    "user": os.getenv("DB_USER", "your_user"),
    "password": os.getenv("DB_PASSWORD", "your_password"),
    "port": int(os.getenv("DB_PORT", "5432")),
}

def get_connection():
    conn = psycopg2.connect(
        host=DB_CONFIG["host"],
        dbname=DB_CONFIG["dbname"],
        user=DB_CONFIG["user"],
        password=DB_CONFIG["password"],
        port=DB_CONFIG["port"],
    )
    return conn

def create_tables(conn):
    cur = conn.cursor()

    # Drop tables if they exist (clean reset)
    cur.execute("DROP TABLE IF EXISTS fact_order;")
    cur.execute("DROP TABLE IF EXISTS dim_customer;")
    cur.execute("DROP TABLE IF EXISTS dim_product;")

    # Dimension: Customer (surrogate PK)
    cur.execute("""
        CREATE TABLE dim_customer (
            customer_sk         SERIAL PRIMARY KEY,
            customer_id         INTEGER NOT NULL,
            customer_name       TEXT NOT NULL,
            customer_email      TEXT,
            country             TEXT NOT NULL,
            signup_date         DATE,
            city                TEXT,
            segment             TEXT
        );
    """)

    # Dimension: Product (surrogate PK)
    cur.execute("""
        CREATE TABLE dim_product (
            product_sk          SERIAL PRIMARY KEY,
            product_id          INTEGER NOT NULL,
            product_name        TEXT NOT NULL,
            category            TEXT NOT NULL,
            unit_price          NUMERIC(10,2) NOT NULL,
            brand               TEXT,
            sub_category        TEXT,
            is_discontinued     INTEGER DEFAULT 0
        );
    """)

    # Fact: Order
    # Grain: row per customer per product --> each row represents an order line-item
    cur.execute("""
        CREATE TABLE fact_order (
            order_id        INTEGER NOT NULL,
            order_date      DATE NOT NULL,
            customer_sk     INTEGER NOT NULL,
            product_sk      INTEGER NOT NULL,
            quantity        INTEGER NOT NULL,
            amount          NUMERIC(10,2) NOT NULL,
            order_year      INTEGER,
            order_month     TEXT,
            discount_amount NUMERIC(10,2),
            net_amount      NUMERIC(10,2),
            PRIMARY KEY (order_id, customer_sk, product_sk),
            FOREIGN KEY (customer_sk) REFERENCES dim_customer(customer_sk),
            FOREIGN KEY (product_sk)  REFERENCES dim_product(product_sk)
        );
    """)

    conn.commit()
    cur.close()

def seed_data(conn):
    cur = conn.cursor()

    # ---- Seed dim_customer ----
    customers = [
        (101, "Alice Rossi",        "alice.rossi@example.com",       "Italy",    "2024-01-10", "Cagliari",   "Retail"),
        (102, "Marco Bianchi",      "marco.bianchi@example.com",     "Italy",    "2024-01-15", "Rome",       "Retail"),
        (103, "Giulia Verdi",       "giulia.verdi@example.com",      "Italy",    "2024-02-01", "Milan",      "Online"),
        (104, "Luca Neri",          "luca.neri@example.com",         "Italy",    "2024-02-10", "Cagliari",   "Retail"),
        (105, "John Smith",         "john.smith@example.com",        "UK",       "2024-02-20", "London",     "Corporate"),
        (106, "Emily Brown",        "emily.brown@example.com",       "UK",       "2024-03-01", "Manchester", "Online"),
        (107, "Carlos Garcia",      "carlos.garcia@example.com",     "Spain",    "2024-03-05", "Madrid",     "Retail"),
        (108, "Maria Lopez",        "maria.lopez@example.com",       "Spain",    "2024-03-10", "Barcelona",  "Online"),
        (109, "Hans Müller",        "hans.mueller@example.com",      "Germany",  "2024-03-15", "Berlin",     "Corporate"),
        (110, "Anna Schmidt",       "anna.schmidt@example.com",      "Germany",  "2024-03-20", "Munich",     "Retail"),
        (111, "Sofia Conti",        "sofia.conti@example.com",       "Italy",    "2024-03-25", "Turin",      "Retail"),
        (112, "Tom Clark",          "tom.clark@example.com",         "USA",      "2024-04-01", "New York",   "Corporate"),
        (113, "Laura Davis",        "laura.davis@example.com",       "USA",      "2024-04-05", "Boston",     "Online"),
        (114, "Pedro Alvarez",      "pedro.alvarez@example.com",     "Portugal", "2024-04-10", "Lisbon",     "Retail"),
        (115, "Chiara Romano",      "chiara.romano@example.com",     "Italy",    "2024-04-15", "Naples",     "Online"),
        (116, "George Wilson",      "george.wilson@example.com",     "UK",       "2024-04-20", "Bristol",    "Retail"),
        (117, "Isabel Fernandez",   "isabel.fernandez@example.com",  "Spain",    "2024-04-25", "Valencia",   "Corporate"),
        (118, "Francesco Riva",     "francesco.riva@example.com",    "Italy",    "2024-05-01", "Cagliari",   "Retail"),
        (119, "Marta Rossi",        "marta.rossi@example.com",       "Italy",    "2024-05-05", "Florence",   "Retail"),
        (120, "David Thompson",     "david.thompson@example.com",    "USA",      "2024-05-10", "Chicago",    "Online"),
    ]

    cur.executemany("""
        INSERT INTO dim_customer (
            customer_id,
            customer_name,
            customer_email,
            country,
            signup_date,
            city,
            segment
        )
        VALUES (%s, %s, %s, %s, %s, %s, %s);
    """, customers)

    # ---- Seed dim_product ----
    products = [
        (201, "Tennis Racket Pro",          "Sports",     150.0, "Wilson",   "Racket",       0),
        (202, "Tennis Racket Basic",        "Sports",      90.0, "Babolat",  "Racket",       0),
        (203, "Tennis Balls (Pack of 3)",   "Sports",       8.0, "Head",     "Balls",        0),
        (204, "Tennis Strings",             "Sports",      25.0, "Luxilon",  "Strings",      0),
        (205, "Wristbands",                 "Sports",       5.0, "Nike",     "Accessories",  0),
        (206, "Protein Powder Vanilla",     "Nutrition",   35.0, "MyProtein","Protein",      0),
        (207, "Protein Powder Chocolate",   "Nutrition",   37.0, "MyProtein","Protein",      0),
        (208, "Electrolyte Drink Mix",      "Nutrition",   12.0, "Nuun",     "Hydration",    0),
        (209, "Energy Bar",                 "Nutrition",    3.0, "Clif",     "Snacks",       0),
        (210, "Shaker Bottle",              "Accessories", 10.0, "Generic",  "Bottles",      0),
        (211, "Tennis Bag",                 "Accessories", 60.0, "Wilson",   "Bags",         0),
        (212, "Cap",                        "Accessories", 18.0, "Nike",     "Headwear",     0),
        (213, "Running Shoes",              "Sportswear", 120.0, "Asics",    "Shoes",        0),
        (214, "Training Shorts",            "Sportswear",  30.0, "Nike",     "Clothing",     0),
        (215, "Training T-Shirt",           "Sportswear",  25.0, "Adidas",   "Clothing",     0),
        (216, "Hoodie",                     "Sportswear",  55.0, "Adidas",   "Clothing",     0),
        (217, "Socks (Pack of 3)",          "Sportswear",   9.0, "Puma",     "Clothing",     0),
        (218, "Foam Roller",                "Recovery",    22.0, "Decathlon","Recovery",     0),
        (219, "Resistance Band Set",        "Recovery",    28.0, "Decathlon","Recovery",     0),
        (220, "Massage Ball",               "Recovery",    15.0, "Generic",  "Recovery",     0),
    ]

    cur.executemany("""
        INSERT INTO dim_product (
            product_id,
            product_name,
            category,
            unit_price,
            brand,
            sub_category,
            is_discontinued
        )
        VALUES (%s, %s, %s, %s, %s, %s, %s);
    """, products)

    # ---- Fetch surrogate keys to use in fact table ----
    cur.execute("SELECT customer_sk, customer_id FROM dim_customer;")
    customer_map = {row[1]: row[0] for row in cur.fetchall()}

    cur.execute("SELECT product_sk, product_id FROM dim_product;")
    product_map = {row[1]: row[0] for row in cur.fetchall()}

    # ---- Seed fact_order ----
    raw_orders = [
        (1001, "2024-04-01", 101, 201, 1,  0.0),
        (1001, "2024-04-01", 101, 203, 4,  0.0),
        (1002, "2024-04-02", 102, 202, 1,  5.0),
        (1002, "2024-04-02", 102, 203, 2,  0.0),
        (1003, "2024-04-03", 103, 206, 1,  3.0),
        (1004, "2024-04-04", 104, 201, 1, 10.0),
        (1004, "2024-04-04", 104, 208, 3,  0.0),
        (1005, "2024-04-05", 105, 213, 1, 15.0),
        (1005, "2024-04-05", 105, 217, 2,  0.0),
        (1006, "2024-04-06", 106, 211, 1,  0.0),
        (1007, "2024-04-07", 107, 201, 1,  0.0),
        (1007, "2024-04-07", 107, 203, 3,  0.0),
        (1008, "2024-04-08", 108, 206, 2,  4.0),
        (1009, "2024-04-09", 109, 213, 1,  0.0),
        (1010, "2024-04-10", 110, 214, 2,  0.0),
        (1011, "2024-04-11", 111, 215, 1,  0.0),
        (1012, "2024-04-12", 112, 208, 4,  2.0),
        (1013, "2024-04-13", 113, 201, 1,  0.0),
        (1013, "2024-04-13", 113, 203, 2,  0.0),
        (1014, "2024-04-14", 114, 218, 1,  0.0),
    ]

    fact_rows = []
    for order_id, order_date_str, customer_id, product_id, quantity, discount_amount in raw_orders:
        customer_sk = customer_map[customer_id]
        product_sk = product_map[product_id]

        cur.execute(
            "SELECT unit_price FROM dim_product WHERE product_sk = %s;",
            (product_sk,)
        )
        unit_price = cur.fetchone()[0]

        from decimal import Decimal

        # unit_price is likely already a Decimal from psycopg2; if not, we force it:
        unit_price = Decimal(str(unit_price))

        amount = unit_price * Decimal(quantity)
        discount_amount = Decimal(str(discount_amount))
        net_amount = amount - discount_amount

        dt = datetime.strptime(order_date_str, "%Y-%m-%d")
        order_year = dt.year
        order_month = f"{dt.year}-{dt.month:02d}"

        fact_rows.append(
            (
                order_id,
                order_date_str,
                customer_sk,
                product_sk,
                quantity,
                amount,
                order_year,
                order_month,
                discount_amount,
                net_amount
            )
        )

    cur.executemany("""
        INSERT INTO fact_order (
            order_id,
            order_date,
            customer_sk,
            product_sk,
            quantity,
            amount,
            order_year,
            order_month,
            discount_amount,
            net_amount
        )
        VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s);
    """, fact_rows)

    conn.commit()
    cur.close()

def main():
    conn = get_connection()
    try:
        create_tables(conn)
        seed_data(conn)
        print("PostgreSQL data warehouse setup complete.")
    finally:
        conn.close()

if __name__ == "__main__":
    main()