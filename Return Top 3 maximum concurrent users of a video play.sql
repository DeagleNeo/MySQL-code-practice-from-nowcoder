WITH events AS 
    (
        SELECT cid, start_time AS event_time, 1 AS event_type
        FROM play_record_tb
        UNION ALL
        SELECT cid, end_time, -1
        FROM play_record_tb
    )
,
sorted AS
    (
        SELECT cid, event_time, event_type
        FROM events
        ORDER BY cid, event_time, event_type
    )
,
cumulative AS
    (
        SELECT cid, event_time,
        SUM(event_type) OVER (PARTITION BY cid ORDER BY event_time, event_type) AS current_user_cnt
        FROM sorted
    )

SELECT cid, CAST(MAX(current_user_cnt) AS DECIMAL(10,3)) AS max_peak_uv
FROM cumulative
GROUP BY cid
ORDER BY max_peak_uv DESC
LIMIT 3
