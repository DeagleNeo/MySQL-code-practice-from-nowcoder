SELECT user_id, MAX(consec) DIV 1 AS max_consec_days
FROM
(SELECT
    user_id, fdate,
    @consecutive := IF(@prev_user = user_id AND DATEDIFF(fdate, @prev_date) = 1, 
        @consecutive + 1,
        1
    ) AS consec,
    @prev_user := user_id,
    @prev_date := fdate
FROM
(
    SELECT DISTINCT user_id, fdate
    FROM tb_dau
    WHERE YEAR(fdate) = 2023 AND MONTH(fdate) = 1
    ORDER BY user_id, fdate
) t, (SELECT @prev_user := NULL, @prev_date := NULL, @consecutive := 0) vars
) cons_t
GROUP BY user_id
