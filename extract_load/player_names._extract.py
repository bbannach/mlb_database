import duckdb
from pybaseball import playerid_reverse_lookup


# Connect to MotherDuck
con = duckdb.connect("md:MLB")

# get list of ids
player_ids = [row[0] for row in con.execute(""" select distinct batter from mlb.raw_pitch_level  union all  select distinct pitcher from mlb.raw_pitch_level """).fetchall()]

player_names = playerid_reverse_lookup(player_ids, key_type='mlbam')

# create or re-load table with player names
con.execute("""
    CREATE OR REPLACE TABLE mlb.raw_player_names AS 
    SELECT * FROM player_names
""")
