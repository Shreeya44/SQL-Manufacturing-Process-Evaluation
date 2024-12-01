CREATE DATABASE manufacturing;
USE manufacturing;

SELECT * FROM parts;

-- Calculate Average Height, Standard Deviation, UCL, and LCL
WITH stats AS (
    SELECT
        AVG(height) AS avg_height,
        STDDEV(height) AS stddev_height
    FROM parts
)
SELECT
    avg_height,
    stddev_height,
    avg_height + 3 * (stddev_height / SQRT(5)) AS ucl,
    avg_height - 3 * (stddev_height / SQRT(5)) AS lcl
FROM stats;

-- Identify Parts Outside Control Limits
WITH stats AS (
    SELECT
        AVG(height) AS avg_height,
        STDDEV(height) AS stddev_height
    FROM parts
),
control_limits AS (
    SELECT
        avg_height,
        stddev_height,
        avg_height + 3 * (stddev_height / SQRT(5)) AS ucl,
        avg_height - 3 * (stddev_height / SQRT(5)) AS lcl
    FROM stats
)
SELECT
    item_no,
    height,
    operator,
    CASE
        WHEN height > ucl THEN 'Above UCL'
        WHEN height < lcl THEN 'Below LCL'
        ELSE 'Within Control'
    END AS status
FROM parts, control_limits
WHERE height > ucl OR height < lcl;

-- Summary of items by status
WITH stats AS (
    SELECT
        AVG(height) AS avg_height,
        STDDEV(height) AS stddev_height
    FROM parts
),
control_limits AS (
    SELECT
        avg_height,
        stddev_height,
        avg_height + 3 * (stddev_height / SQRT(5)) AS ucl,
        avg_height - 3 * (stddev_height / SQRT(5)) AS lcl
    FROM stats
),
part_status AS (
    SELECT
        item_no,
        height,
        operator,
        CASE
            WHEN height > ucl THEN 'Above UCL'
            WHEN height < lcl THEN 'Below LCL'
            ELSE 'Within Control'
        END AS status
    FROM parts, control_limits
)
SELECT
    status,
    COUNT(*) AS count
FROM part_status
GROUP BY status;
