# Data Warehouse Setup (PostgreSQL + Python)

This project connects to a PostgreSQL database using Python and environment variables.  
Real credentials are **never** stored in the code or in the Git repository; they are provided via a local `.env` file that is gitignored.

## Requirements

- Python 3.10+
- PostgreSQL server installed **locally** on your machine
- `pip` for installing dependencies

## Installation

1. Clone this repository:

   ```bash
   git clone https://github.com/your-username/your-repo.git
   cd your-repo
   ```

2. Install dependencies:

   ```bash
   pip install -r requirements.txt
   ```

   The `requirements.txt` file should include at least:

   ```text
   psycopg2
   python-dotenv
   ```

## Configure PostgreSQL (local)

PostgreSQL should be already installed and running locally on your machine (for example via the official installer or your OS package manager).  

From there (run in 'psql'), create a database and user that this project will use.
Example SQL:

```psql
CREATE DATABASE data_warehouse;
CREATE USER myapp_user WITH PASSWORD 'your_strong_password';
GRANT ALL PRIVILEGES ON DATABASE data_warehouse TO myapp_user;
```

You can change the database name, user, and password if you prefer; just keep the `.env` file in sync.

## Environment Variables (.env)

This project reads database configuration from environment variables.  
For local development, those variables come from a `.env` file in the project root (which is **not** committed to Git).

1. Create a new file called `.env` in the project root:

   ```env
   DB_HOST=localhost
   DB_NAME=data_warehouse
   DB_USER=myapp_user
   DB_PASSWORD=your_strong_password
   DB_PORT=5432
   ```

2. Ensure `.env` is listed in `.gitignore` so your secrets are not pushed to Git.

3. In the code, `python-dotenv` loads these values:

   ```python
   from dotenv import load_dotenv
   load_dotenv()  # loads .env into os.environ
   ```

   Then the script uses `os.getenv("DB_HOST")`, etc., to build the connection.

## Running the Script

With PostgreSQL running locally and `.env` configured:

```bash
python data_warehouse_setup.py
```

The script will:

- Load environment variables from `.env`
- Use them to create a PostgreSQL connection via `psycopg2`
- Run whatever logic is implemented to set up the data warehouse (e.g. creating tables, inserting seed data)