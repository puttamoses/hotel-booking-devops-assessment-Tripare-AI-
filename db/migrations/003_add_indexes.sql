-- Speeds up filtering by city + recent created_at, grouped by org_id/status.
CREATE INDEX IF NOT EXISTS idx_hotel_bookings_city_created_at
  ON hotel_bookings (city, created_at)
  INCLUDE (org_id, status, amount);
