-- Although Australia is in the ASGS diagram, it doesn't seem to form
-- part of the official ASGS 2011. However the 2011 does release
-- statistics against the region.

-- Ideally the ASGS would include it, until that time so we can support
-- the 2011 Census a hack is included here.

CREATE DOMAIN asgs_2011.aust_code AS char(1)
CHECK (
  VALUE ~ '^\d$'
);

CREATE TABLE asgs_2011.aust
(
  "code" asgs_2011.aust_code PRIMARY KEY,
  "name" text
);

INSERT INTO asgs_2011.aust (code, name) VALUES
(0, 'Australia');
