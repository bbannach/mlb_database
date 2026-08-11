with cte as (
    select distinct
        type,
        case 
            when type = 'S' and description like '%swinging%' then 'swinging strike'
            when type = 'S' and description like '%called%' then 'called strike'
            when type = 'S' and description like '%foul%' then 'foul'
            else 'other'
        end as subtype,
        description
    from {{ source('mlb', 'raw_pitch_level') }}
) 

select
    row_number() over(order by type, subtype) as id_pitch_outcome,
    type,
    subtype,
    description,
    current_timestamp as date_updated
from cte