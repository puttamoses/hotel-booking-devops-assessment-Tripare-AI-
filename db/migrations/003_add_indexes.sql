-- Optimizes:
--   SELECT org_id, status, COUNT(*), SUM(amount)
--   FROM hotel_bookings
--   WHERE city = 'delhi' AND created_at >= NOW() - INTERVAL '30 days'
--   GROUP BY org_id, status;
--
-- (city, created_at) matches the WHERE clause: city is an equality filter so
-- it leads the index, created_at is a range filter so it comes second,
-- letting Postgres do a single index range scan instead of a full table
-- scan. org_id/status/amount are added via INCLUDE (not part of the key, so
-- they don't affect sort order) purely so the query can be answered as an
-- index-only scan without visiting the heap for every matching row.
CREATE INDEX IF NOT EXISTS idx_hotel_bookings_city_created_at
  ON hotel_bookings (city, created_at)
  INCLUDE (org_id, status, amount);
