with cte as (
select distinct
  events
  , case when events in ('single','double','triple','home_run','catcher_interf','hit_by_pitch','intent_walk','walk') then 'safe'
         else 'out'
         end as "safe_out_classification"
  , case when events in ('single','double','triple','home_run') then 'hit'
         when events like '%strikeout%' then 'strikeout'
         when events like '%walk%' then 'walk'
         when events = 'hit_by_pitch' then 'hit_by_pitch'
         when events in ('field_out','fielders_choice','fielders_choice_out','force_out','double_play') then 'field_out'
         when events like '%sac%' then 'sacrifice'
         else 'other'
         end category
  , case when events in ('catcher_interf','hit_by_pitch','intent_walk','sac_bunt','sac_fly','walk') then 'N'
         else 'Y'
         end "at_bat_classifcation"
from {{ source('mlb', 'raw_pitch_level') }}
order by
  category
)

select
row_number() over(order by category, safe_out_classification) id_plate_appearance_outcome
,*
, current_timestamp as date_updated
from cte

union all

select distinct
-1 as id_plate_appearance_outcome
,'pa_in_progress'
,'pa_in_progress'
,'pa_in_progress'
,'pa_in_progress'
, current_timestamp as date_updated
from raw_pitch_level