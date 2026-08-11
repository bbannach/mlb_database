    with cte as (
    select distinct 
    pitch_type code_pitch
    , pitch_name name_pitch
    , case 
        when pitch_type in ('FF','SI','FC') then 'fastball'
        when pitch_type in ('SL','KC','CS','ST','SV','CU') then 'breaking'
        when pitch_type in ('CH','FO','FS') then 'off-speed'
        when pitch_type in ('KN','EP') then 'specialty'
        else 'other'
        end "category"
    from {{ source('mlb', 'raw_pitch_level') }}
    )

    select
    row_number() over(order by category) id_pitch_type
    ,*
    ,current_timestamp as date_updated
    from cte
