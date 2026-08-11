from pathlib import Path
import duckdb

DATA_DIR = Path("data/statcast")

# Connect to MotherDuck
con = duckdb.connect("md:MLB")

# Create tracking table
con.execute("""
CREATE TABLE IF NOT EXISTS loaded_files (
    filename VARCHAR PRIMARY KEY,
    loaded_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
)
""")

# Get list of local parquet files
parquet_files = sorted(DATA_DIR.glob("*.parquet"))

# 1. Initialize raw_pitch_level using the NEWEST file to guarantee all 119 columns exist in the target schema
if parquet_files:
    newest_file = parquet_files[-1]  # Latest file in sorted order
    con.execute(f"""
    CREATE TABLE IF NOT EXISTS raw_pitch_level AS
    SELECT *
    FROM read_parquet('{newest_file.as_posix()}')
    LIMIT 0
    """)

# Get already-loaded files
loaded_files = set(
    row[0]
    for row in con.execute(
        "SELECT filename FROM loaded_files"
    ).fetchall()
)

# 2. Iterate through and insert files individually
for file_path in parquet_files:

    filename = file_path.name

    if filename in loaded_files:
        print(f"Skipping already loaded file: {filename}")
        continue

    print(f"Loading {filename}")

    try:
        # INSERT ... BY NAME automatically maps matching columns 
        # and fills missing columns (like the 119th column in older files) with NULL
        con.execute(f"""
        INSERT INTO raw_pitch_level BY NAME
        SELECT *
        FROM read_parquet('{file_path.as_posix()}')
        """)

        # Track loaded file
        con.execute("""
        INSERT INTO loaded_files (filename)
        VALUES (?)
        """, [filename])

        print(f"Loaded {filename}")

    except Exception as e:
        print(f"FAILED loading {filename}: {e}")

print("Done.")