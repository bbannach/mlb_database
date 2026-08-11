WITH cte AS (
    SELECT DISTINCT
        bb_type,
        launch_speed_angle, 
        CASE launch_speed_angle
            WHEN 6 THEN 'Barrel'
            WHEN 5 THEN 'Solid Contact'
            WHEN 4 THEN 'Flare / Burner'
            WHEN 3 THEN 'Topped Ball'
            WHEN 2 THEN 'Weak Contact'
            WHEN 1 THEN 'Under Ball'
            ELSE 'unknown'
        END AS "category"
    FROM {{ source('mlb', 'raw_pitch_level') }}
) 
SELECT
    ROW_NUMBER() OVER(ORDER BY bb_type) AS id_batted_ball,
    *,
    CURRENT_TIMESTAMP AS date_updated
FROM cte

UNION ALL


SELECT 
    -1 AS id_batted_ball,
    'no_batted_ball', 
    NULL,
    'no_batted_ball',
    CURRENT_TIMESTAMP AS date_updated