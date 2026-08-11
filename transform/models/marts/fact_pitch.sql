select
    md5(concat(rpl.game_pk, '_', rpl.at_bat_number, '_', rpl.pitch_number)) as id_pitch,
    dg.id_game,
    dpbatter.id_player as id_batter,
    dppitcher.id_player as id_pitcher,
    rpl.at_bat_number as plate_appearance_number,
    rpl.pitch_number,
    dpt.id_pitch_type,
    dpo.id_pitch_outcome,
    coalesce(dpao.id_plate_appearance_outcome, -1) as id_plate_appearance_outcome,
    coalesce(dbb.id_batted_ball, -1) as id_batted_ball,
    rpl.balls,
    rpl.strikes,
    rpl.outs_when_up,
    rpl.inning,
    rpl.inning_topbot,
    rpl.hit_distance_sc,
    rpl.hc_x as hit_coordinate_x,
    rpl.hc_y as hit_coordinate_y,
    rpl.launch_speed as exit_velocity,
    rpl.launch_angle,
    rpl.estimated_ba_using_speedangle as xba,
    rpl.estimated_woba_using_speedangle as xwoba,
    rpl.estimated_slg_using_speedangle as xslg,
    rpl.woba_value,
    rpl.woba_denom,
    rpl.iso_value,
    rpl.spin_axis,
    rpl.bat_speed,
    rpl.swing_length,
    rpl.swing_path_tilt,
    rpl.attack_angle,
    rpl.attack_direction,
    rpl.effective_speed,
    rpl.release_speed,
    rpl.release_extension,
    rpl.release_spin_rate,
    rpl.release_pos_x as release_position_horizontal,
    rpl.release_pos_y as release_position_vertical,
    rpl.release_pos_z,
    rpl.pfx_x as movement_horizontal,
    rpl.pfx_z as movement_vertical,
    rpl.sz_top as strike_zone_top,
    rpl.sz_bot as strike_zone_bottom,
    rpl.plate_x as pitch_location_horizontal,
    rpl.plate_z as pitch_location_vertical,
    rpl.vx0 as velocity_horizontal,
    rpl.vy0 as velocity_forward,
    rpl.vz0 as velocity_vertical,
    rpl.ax as acceleration_horizontal,
    rpl.ay as acceleration_vertical,
    rpl.az as acceleration_forward,
    rpl.n_thruorder_pitcher,
    rpl.arm_angle,
    current_timestamp as date_updated
from {{ source('mlb', 'raw_pitch_level') }} rpl
left join {{ ref('dim_game') }} dg
    on rpl.game_pk = dg.game_pk
left join {{ ref('dim_pitch_type') }} dpt
    on rpl.pitch_type = dpt.code_pitch
left join {{ ref('dim_pitch_outcome') }} dpo
    on rpl.type = dpo.type 
    and rpl.description = dpo.description
left join {{ ref('dim_plate_appearance_outcome') }} dpao
    on rpl.events = dpao.events
left join {{ ref('dim_batted_ball') }} dbb
    on rpl.bb_type = dbb.bb_type
    and rpl.launch_speed_angle = dbb.launch_speed_angle
left join {{ ref('dim_players') }} dpbatter
    on rpl.batter = dpbatter.mlbam_player_id
left join {{ ref('dim_players') }} dppitcher
    on rpl.pitcher = dppitcher.mlbam_player_id