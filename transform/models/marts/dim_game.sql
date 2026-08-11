with cte as (
    select distinct
    game_pk
    ,game_date
    ,game_type
    ,home_team
    ,away_team
    ,post_home_score
    ,post_away_score
    ,at_bat_number
    ,pitch_number
    ,max(at_bat_number) over(partition by game_pk) max_at_bat
    ,max(pitch_number) over(partition by game_pk, at_bat_number) max_pitch
    from {{ source('mlb', 'raw_pitch_level') }}
    )

    select
    row_number() over(order by game_pk) id_game
    ,game_pk
    ,game_date
    ,game_type
    ,home_team
    ,away_team
    ,post_home_score home_score
    ,post_away_score away_score
    ,current_timestamp as date_updated
    from cte
    where 1=1
    and max_at_bat = at_bat_number
    and max_pitch = pitch_number