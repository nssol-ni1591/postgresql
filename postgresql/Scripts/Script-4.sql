CREATE TABLE programming(
  id SERIAL,
  name VARCHAR(255) NOT NULL,
  first_appeared INT NOT NULL
);

INSERT INTO programming(name, first_appeared) VALUES
  ('Lisp', 1958),
  ('C', 1972),
  ('SQL', 1974),
  ('python', 1991),
  ('Java', 1995),
  ('PHP', 1995),
  ('Scala', 2004),
  ('Rust', 2010);

select * from programming;

DROP FUNCTION IF EXISTS years_ago(INTEGER);

CREATE OR REPLACE FUNCTION years_ago(INTEGER)
RETURNS INTEGER AS $$
  SELECT (extract(year from current_date)::INTEGER - first_appeared)
  FROM programming
  WHERE id = $1;
$$ LANGUAGE sql;

SELECT name, first_appeared, years_ago(id) FROM programming;

CREATE OR REPLACE FUNCTION years_ago(in first_appeared INTEGER)
RETURNS INTEGER AS $$
begin
   RETURN (extract(year from current_date)::INTEGER - first_appeared);
end
$$ LANGUAGE plpgsql;

SELECT name, first_appeared, years_ago(first_appeared) FROM programming;

CREATE OR REPLACE FUNCTION years_ago(first_appeared INTEGER)
RETURNS INTEGER AS $$
  DECLARE
    current_year INTEGER := extract(year from current_date)::INTEGER;
  BEGIN
    RETURN current_year - first_appeared;
  END;
$$ LANGUAGE plpgsql;

