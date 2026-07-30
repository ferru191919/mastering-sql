## RUN THIS TO SET UP DATA WAREHOUSE ##

import sqlite3

DB_PATH = "order_dw.db"

def create_tables(conn):
    cur = conn.cursor()

    # Drop tables if they exist (clean reset)
    cur.execute("DROP TABLE IF EXISTS fact_order;")
    cur.execute("DROP TABLE IF EXISTS dim_customer;")
    cur.execute("DROP TABLE IF EXISTS dim_product;")

    # Dimension: Customer (surrogate PK)
    cur.execute("""
        CREATE TABLE dim_customer (
            customer_sk         INTEGER PRIMARY KEY,            
            customer_id         INTEGER NOT NULL,                        
            customer_name       TEXT NOT NULL,
            customer_email      TEXT,
            country             TEXT NOT NULL,
            signup_date         DATE
        );
    """)

    # Dimension: Product (surrogate PK)
    cur.execute("""
        CREATE TABLE dim_product (
            product_sk          INTEGER PRIMARY KEY,      
            product_id          INTEGER NOT NULL,                         
            product_name        TEXT NOT NULL,
            category            TEXT NOT NULL,
            unit_price          REAL NOT NULL
        );
    """)

    # Fact: Order
    # Grain: one row per product per customer --> This allows me to perform very specific analytics
    # Primary key: composite of (order_id, customer_key, product_key)
    cur.execute("""
        CREATE TABLE fact_order (
            order_id        INTEGER NOT NULL,
            order_date      DATE NOT NULL,
            customer_sk     INTEGER NOT NULL,
            product_sk      INTEGER NOT NULL,
            quantity        INTEGER NOT NULL,
            order_amount    REAL NOT NULL,
            PRIMARY KEY (order_id, customer_sk, product_sk),
            FOREIGN KEY (customer_sk) REFERENCES dim_customer(customer_sk),
            FOREIGN KEY (product_sk)  REFERENCES dim_product(product_sk)
        );
    """)

    conn.commit()

def seed_data(conn):
    cur = conn.cursor()

    # ---- Seed dim_customer ----
    customers = [
        (101, "Alice Rossi",        "alice.rossi@example.com",       "Italy",    "2024-01-10"),
        (102, "Marco Bianchi",      "marco.bianchi@example.com",     "Italy",    "2024-01-15"),
        (103, "Giulia Verdi",       "giulia.verdi@example.com",      "Italy",    "2024-02-01"),
        (104, "Luca Neri",          "luca.neri@example.com",         "Italy",    "2024-02-10"),
        (105, "John Smith",         "john.smith@example.com",        "UK",       "2024-02-20"),
        (106, "Emily Brown",        "emily.brown@example.com",       "UK",       "2024-03-01"),
        (107, "Carlos Garcia",      "carlos.garcia@example.com",     "Spain",    "2024-03-05"),
        (108, "Maria Lopez",        "maria.lopez@example.com",       "Spain",    "2024-03-10"),
        (109, "Hans Müller",        "hans.mueller@example.com",      "Germany",  "2024-03-15"),
        (110, "Anna Schmidt",       "anna.schmidt@example.com",      "Germany",  "2024-03-20"),
        (111, "Sofia Conti",        "sofia.conti@example.com",       "Italy",    "2024-03-25"),
        (112, "Tom Clark",          "tom.clark@example.com",         "USA",      "2024-04-01"),
        (113, "Laura Davis",        "laura.davis@example.com",       "USA",      "2024-04-05"),
        (114, "Pedro Alvarez",      "pedro.alvarez@example.com",     "Portugal", "2024-04-10"),
        (115, "Chiara Romano",      "chiara.romano@example.com",     "Italy",    "2024-04-15"),
        (116, "George Wilson",      "george.wilson@example.com",     "UK",       "2024-04-20"),
        (117, "Isabel Fernandez",   "isabel.fernandez@example.com",  "Spain",    "2024-04-25"),
        (118, "Francesco Riva",     "francesco.riva@example.com",    "Italy",    "2024-05-01"),
        (119, "Marta Rossi",        "marta.rossi@example.com",       "Italy",    "2024-05-05"),
        (120, "David Thompson",     "david.thompson@example.com",    "USA",      "2024-05-10"),
    ]
    cur.executemany("""
        INSERT INTO dim_customer (
            customer_id, customer_name, customer_email, country, signup_date
        )
        VALUES (?, ?, ?, ?, ?);
    """, customers)

    # ---- Seed dim_product ----
    products = [
        (201, "Tennis Racket Pro",          "Sports",     150.0),
        (202, "Tennis Racket Basic",        "Sports",     90.0),
        (203, "Tennis Balls (Pack of 3)",   "Sports",     8.0),
        (204, "Tennis Strings",             "Sports",     25.0),
        (205, "Wristbands",                 "Sports",     5.0),
        (206, "Protein Powder Vanilla",     "Nutrition",  35.0),
        (207, "Protein Powder Chocolate",   "Nutrition",  37.0),
        (208, "Electrolyte Drink Mix",      "Nutrition",  12.0),
        (209, "Energy Bar",                 "Nutrition",  3.0),
        (210, "Shaker Bottle",              "Accessories",10.0),
        (211, "Tennis Bag",                 "Accessories",60.0),
        (212, "Cap",                        "Accessories",18.0),
        (213, "Running Shoes",              "Sportswear",120.0),
        (214, "Training Shorts",            "Sportswear",30.0),
        (215, "Training T-Shirt",           "Sportswear",25.0),
        (216, "Hoodie",                     "Sportswear",55.0),
        (217, "Socks (Pack of 3)",          "Sportswear",9.0),
        (218, "Foam Roller",                "Recovery",   22.0),
        (219, "Resistance Band Set",        "Recovery",   28.0),
        (220, "Massage Ball",               "Recovery",   15.0),
    ]
    cur.executemany("""
        INSERT INTO dim_product (
            product_id, product_name, category, unit_price
        )
        VALUES (?, ?, ?, ?);
    """, products)

    # ---- Fetch surrogate keys to use in fact table ----
    # Map customer_id -> customer_sk
    cur.execute("SELECT customer_sk, customer_id FROM dim_customer;")
    customer_map = {row[1]: row[0] for row in cur.fetchall()}

    # Map product_id -> product_sk
    cur.execute("SELECT product_sk, product_id FROM dim_product;")
    product_map = {row[1]: row[0] for row in cur.fetchall()}

    # ---- Seed fact_order ----
    # Each tuple: (order_id, order_date, customer_id, product_id, quantity)
    # order_amount will be derived as quantity * unit_price for simplicity
    raw_orders = [
        (1001, "2024-04-01", 101, 201, 1),
        (1001, "2024-04-01", 101, 203, 4),
        (1002, "2024-04-02", 102, 202, 1),
        (1002, "2024-04-02", 102, 203, 2),
        (1003, "2024-04-03", 103, 206, 1),
        (1004, "2024-04-04", 104, 201, 1),
        (1004, "2024-04-04", 104, 208, 3),
        (1005, "2024-04-05", 105, 213, 1),
        (1005, "2024-04-05", 105, 217, 2),
        (1006, "2024-04-06", 106, 211, 1),
        (1007, "2024-04-07", 107, 201, 1),
        (1007, "2024-04-07", 107, 203, 3),
        (1008, "2024-04-08", 108, 206, 2),
        (1009, "2024-04-09", 109, 213, 1),
        (1010, "2024-04-10", 110, 214, 2),
        (1011, "2024-04-11", 111, 215, 1),
        (1012, "2024-04-12", 112, 208, 4),
        (1013, "2024-04-13", 113, 201, 1),
        (1013, "2024-04-13", 113, 203, 2),
        (1014, "2024-04-14", 114, 218, 1),
    ]

    fact_rows = []
    # Build fact rows with surrogate keys and computed order_amount
    for order_id, order_date, customer_id, product_id, quantity in raw_orders:
        customer_sk = customer_map[customer_id]
        product_sk = product_map[product_id]
        # lookup unit_price
        cur.execute(
            "SELECT unit_price FROM dim_product WHERE product_sk = ?",
            (product_sk,)
        )
        unit_price = cur.fetchone()[0]
        order_amount = quantity * unit_price
        fact_rows.append(
            (order_id, order_date, customer_sk, product_sk, quantity, order_amount)
        )

    cur.executemany("""
        INSERT INTO fact_order (
            order_id, order_date, customer_sk, product_sk, quantity, order_amount
        )
        VALUES (?, ?, ?, ?, ?, ?);
    """, fact_rows)

    conn.commit()

def main():
    conn = sqlite3.connect(DB_PATH)
    try:
        create_tables(conn)
        seed_data(conn)
        print("Data warehouse setup complete.")
    finally:
        conn.close()

if __name__ == "__main__":
    main()