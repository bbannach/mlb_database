from pybaseball import statcast
from datetime import datetime, timedelta
from pathlib import Path
import pandas as pd

# this makes a folder in our directory where each daily parquet file will be stored
DATA_DIR = Path("data/statcast")
DATA_DIR.mkdir(parents=True, exist_ok=True)

# we have start date of the season and today's date
START_DATE = "2026-03-20"
END_DATE = datetime.today().strftime("%Y-%m-%d")

# this converts the strings into dates
start = datetime.strptime(START_DATE, "%Y-%m-%d")
end = datetime.strptime(END_DATE, "%Y-%m-%d")

# this is the start of our loop.  
# as long as the date is less than or equal to today's date it will look for the games 
# if the file already exists, it won't download again

current = start

while current <= end:

    date_str = current.strftime("%Y-%m-%d")  # gets the date as string

    output_file = DATA_DIR / f"{date_str}.parquet" # creates a parquet file with the date in the title

    if output_file.exists():   # doesn't download if file exists, goes to the next day
        print(f"Skipping existing file: {output_file}")
        current += timedelta(days=1)
        continue

    print(f"Pulling Statcast data for {date_str}")

    try:
        df = statcast(date_str, date_str)

        if len(df) == 0:        # if there are no games on that day, don't download anything
            print(f"No data for {date_str}")
        else:
            df.to_parquet(output_file, index=False)
            print(f"Saved {len(df)} rows")

    except Exception as e:
        print(f"FAILED for {date_str}: {e}")

    current += timedelta(days=1)

print("Done.")