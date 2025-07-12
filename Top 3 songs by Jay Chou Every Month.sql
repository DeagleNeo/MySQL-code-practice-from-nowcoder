SELECT `month`, `row_number` DIV 1 AS ranking, song_name, play_pv
FROM
(SELECT `month`,
    @row_num := IF(@current_month = `month`, @row_num + 1, 1) AS `row_number`,
    @current_month := `month` AS dummy,
    song_name,
    play_pv
FROM
    (SELECT
    MONTH(p.fdate) AS `month`,
    i.song_name AS song_name,
    COUNT(*) AS play_pv,
    p.song_id AS song_id
    FROM
        (SELECT user_id FROM
        user_info
        WHERE age BETWEEN 18 AND 25) a
    INNER JOIN
        (
        SELECT * FROM play_log
        WHERE YEAR(fdate) = 2022
        ) p
    ON a.user_id = p.user_id
    INNER JOIN 
        (
        SELECT * FROM song_info
        WHERE singer_name = '周杰伦'        
        ) i
    ON i.song_id = p.song_id
    GROUP BY MONTH(p.fdate), song_name, song_id) t,
    (SELECT @row_num := 0, @current_month := NULL) vars
ORDER BY `month`, play_pv DESC, song_id) all_data
WHERE `row_number` <= 3
