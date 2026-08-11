with player_details as (
    select distinct
        batter as player_id,
        age_bat as age
    from {{ source('mlb', 'raw_pitch_level') }}
    
    union all
    
    select distinct
        pitcher as player_id,
        age_pit as age
    from {{ source('mlb', 'raw_pitch_level') }}
),

player_base as (
    select distinct
        a.key_mlbam as mlbam_player_id,
        concat(a.name_first, ' ', a.name_last) as name_full,
        a.name_first,
        a.name_last,
        b.age
    from {{ source('mlb', 'raw_player_names') }} a
    left join player_details b 
        on a.key_mlbam = b.player_id
)

select
    row_number() over (order by mlbam_player_id) as id_player,
    *,
    current_timestamp as date_updated
from player_base