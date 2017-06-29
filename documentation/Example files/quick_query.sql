WITH -- Create temporary tables that makes SELECT easier
    NewsCount AS -- make the LEFT JOIN clearer
    (SELECT Reference, COUNT() as Count
     FROM News_table GROUP BY Reference) -- GROUP BY Reference allows to COUNT the number of row for each Reference

SELECT -- Select the columns you want to have:
  Reference,
  CASE
    WHEN NewsCount.Count IS NOT NULL
    THEN 'yes' ELSE 'no'
  END News_Uptake,
  CASE
    WHEN NewsCount.Count IS NOT NULL
    THEN NewsCount.Count ELSE 0
  END Total_News

FROM NewsCount
