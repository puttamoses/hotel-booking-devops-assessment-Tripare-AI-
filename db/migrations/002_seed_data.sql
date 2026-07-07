-- Deterministic seed data: 120 bookings across 5 cities, 4 orgs, 4 statuses.
INSERT INTO hotel_bookings (org_id, hotel_id, city, checkin_date, checkout_date, amount, status, created_at)
SELECT
  (ARRAY[
    '11111111-1111-1111-1111-111111111111',
    '22222222-2222-2222-2222-222222222222',
    '33333333-3333-3333-3333-333333333333',
    '44444444-4444-4444-4444-444444444444'
  ]::uuid[])[1 + (i % 4)]                                   AS org_id,
  'HTL-' || lpad((1 + (i % 15))::text, 3, '0')               AS hotel_id,
  (ARRAY['delhi','mumbai','bengaluru','hyderabad','pune'])[1 + (i % 5)] AS city,
  (CURRENT_DATE - (i % 200))                                 AS checkin_date,
  (CURRENT_DATE - (i % 200) + (1 + (i % 5)))                 AS checkout_date,
  (1000 + (i * 37) % 9000)::numeric(12,2)                    AS amount,
  (ARRAY['confirmed','pending','cancelled','completed'])[1 + (i % 4)] AS status,
  (now() - ((i % 45) || ' days')::interval)                  AS created_at
FROM generate_series(1, 120) AS s(i);

-- booking_events for a subset of bookings.
INSERT INTO booking_events (booking_id, event_type, payload, created_at)
SELECT id, 'booking_created', jsonb_build_object('source', 'seed'), created_at
FROM hotel_bookings
WHERE amount::int % 3 = 0;

INSERT INTO booking_events (booking_id, event_type, payload, created_at)
SELECT id, 'payment_received', jsonb_build_object('method', 'card'), created_at + interval '1 hour'
FROM hotel_bookings
WHERE status = 'confirmed';
