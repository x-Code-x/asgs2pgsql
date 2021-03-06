
-- To the extent possible under law, the person who associated CC0
-- with this work has waived all copyright and related or neighboring
-- rights to this work.
-- http://creativecommons.org/publicdomain/zero/1.0/

-- This schema is partly derived from the ASGS structure.
-- http://www.abs.gov.au/websitedbs/D3310114.nsf/home/Australian+Statistical+Geography+Standard+%28ASGS%29

CREATE SCHEMA asgs_2011;



--
-- CREATE DOMAINS
--

CREATE DOMAIN asgs_2011.ste_code AS char(1)
CHECK (
  VALUE ~ E'^\\d$'
);

CREATE DOMAIN asgs_2011.gccsa_code AS char(5)
CHECK (
  VALUE ~ E'^\\d\\w{4}$'
);

CREATE DOMAIN asgs_2011.sa4_code AS char(3)
CHECK (
  VALUE ~ E'^\\d{3}$'
);

CREATE DOMAIN asgs_2011.sa3_code AS char(5)
CHECK (
  VALUE ~ E'^\\d{5}$'
);

CREATE DOMAIN asgs_2011.sa2_code AS char(9)
CHECK (
  VALUE ~ E'^\\d{9}$'
);

CREATE DOMAIN asgs_2011.sa1_code AS char(11)
CHECK (
  VALUE ~ E'^\\d{11}$'
);

CREATE DOMAIN asgs_2011.sa1_code_7digit AS char(7)
CHECK (
  VALUE ~ E'^\\d{7}$'
);

CREATE DOMAIN asgs_2011.mb_code AS char(11)
CHECK (
  VALUE ~ E'^\\d{11}$'
);

CREATE DOMAIN asgs_2011.add_code AS char(3)
CHECK (
  VALUE ~ E'^D\\d{2}$'
);

CREATE DOMAIN asgs_2011.poa_code AS char(4)
CHECK (
  VALUE ~ E'^\\d{4}$'
);

CREATE DOMAIN asgs_2011.ssc_code AS char(5)
CHECK (
  VALUE ~ E'^\\d{5}$'
);

CREATE DOMAIN asgs_2011.ced_code AS char(3)
CHECK (
  VALUE ~ E'^\\d{3}$'
);

CREATE DOMAIN asgs_2011.sed_code AS char(5)
CHECK (
  VALUE ~ E'^\\d{5}$'
);

CREATE DOMAIN asgs_2011.nrmr_code AS char(3)
CHECK (
  VALUE ~ E'^\\d{3}$'
);

CREATE DOMAIN asgs_2011.lga_code AS char(5)
CHECK (
  VALUE ~ E'^\\d{5}$'
);

CREATE DOMAIN asgs_2011.tr_code AS char(5)
CHECK (
  VALUE ~ E'^\\d\\w{4}$'
);

CREATE DOMAIN asgs_2011.iloc_code AS char(8)
CHECK (
  VALUE ~ E'^\\d{8}$'
);

CREATE DOMAIN asgs_2011.iare_code AS char(6)
CHECK (
  VALUE ~ E'^\\d{6}$'
);

CREATE DOMAIN asgs_2011.ireg_code AS char(3)
CHECK (
  VALUE ~ E'^\\d{3}$'
);

CREATE DOMAIN asgs_2011.sua_code AS char(4)
CHECK (
  VALUE ~ E'^\\d{4}$'
);

CREATE DOMAIN asgs_2011.ucl_code AS char(6)
CHECK (
  VALUE ~ E'^\\d{6}$'
);

CREATE DOMAIN asgs_2011.sosr_code AS char(3)
CHECK (
  VALUE ~ E'^\\d{3}$'
);

CREATE DOMAIN asgs_2011.sos_code AS char(2)
CHECK (
  VALUE ~ E'^\\d{2}$'
);

CREATE TYPE asgs_2011.landuse AS ENUM (
  'Residential',
  'Education',
  'Industrial',
  'Transport',
  'Other',
  'OFFSHORE',
  'NOUSUALRESIDENCE',
  'Parkland',
  'Hospital/Medical',
  'Water',
  'SHIPPING',
  'ANTARCTICA',
  'Agricultural',
  'Commercial',
  'MIGRATORY'
);

CREATE TYPE asgs_2011.ssc_confidence AS ENUM (
  'Very good',
  'Good',
  'Acceptable',
  'Poor',
  'Very poor',
  'NA'
);



--
-- Create functions to extract higher level codes from the code of lower level codes
--

-- From the GCCSA code extract the STE code
CREATE FUNCTION asgs_2011.gccsa_ste(asgs_2011.gccsa_code) RETURNS asgs_2011.ste_code AS $$
  SELECT substring($1 from 1 for 1)::asgs_2011.ste_code;
$$ LANGUAGE SQL;

-- From the SA4 code extract the STE code
CREATE FUNCTION asgs_2011.sa4_ste(asgs_2011.sa4_code) RETURNS asgs_2011.ste_code AS $$
  SELECT substring($1 from 1 for 1)::asgs_2011.ste_code;
$$ LANGUAGE SQL;

-- From the SA3 code extract the SA4 code
CREATE FUNCTION asgs_2011.sa3_sa4(asgs_2011.sa3_code) RETURNS asgs_2011.sa4_code AS $$
  SELECT substring($1 from 1 for 3)::asgs_2011.sa4_code;
$$ LANGUAGE SQL;

-- From the SA2 code extract the SA3 code
CREATE FUNCTION asgs_2011.sa2_sa3(asgs_2011.sa2_code) RETURNS asgs_2011.sa3_code AS $$
  SELECT substring($1 from 1 for 5)::asgs_2011.sa3_code;
$$ LANGUAGE SQL;

-- From the SA1 code extract the SA2 code
CREATE FUNCTION asgs_2011.sa1_sa2(asgs_2011.sa1_code) RETURNS asgs_2011.sa2_code AS $$
  SELECT substring($1 from 1 for 9)::asgs_2011.sa2_code;
$$ LANGUAGE SQL;

-- From the MB code extract the STE code
CREATE FUNCTION asgs_2011.mb_ste(asgs_2011.mb_code) RETURNS asgs_2011.ste_code AS $$
  SELECT substring($1 from 1 for 1)::asgs_2011.ste_code;
$$ LANGUAGE SQL;

-- From the ILOC code extract the IARE code
CREATE FUNCTION asgs_2011.iloc_iare(asgs_2011.iloc_code) RETURNS asgs_2011.iare_code AS $$
  SELECT substring($1 from 1 for 5)::asgs_2011.iare_code;
$$ LANGUAGE SQL;

-- From the IARE code extract the IREG code
CREATE FUNCTION asgs_2011.iare_ireg(asgs_2011.iare_code) RETURNS asgs_2011.ireg_code AS $$
  SELECT substring($1 from 1 for 3)::asgs_2011.ireg_code;
$$ LANGUAGE SQL;

-- From the IREG code extract the STE code
CREATE FUNCTION asgs_2011.ireg_ste(asgs_2011.ireg_code) RETURNS asgs_2011.ste_code AS $$
  SELECT substring($1 from 1 for 1)::asgs_2011.ste_code;
$$ LANGUAGE SQL;

-- From the LGA code extract the STE code
CREATE FUNCTION asgs_2011.lga_ste(asgs_2011.lga_code) RETURNS asgs_2011.ste_code AS $$
  SELECT substring($1 from 1 for 1)::asgs_2011.ste_code;
$$ LANGUAGE SQL;

-- From the NRMR code extract the STE code
CREATE FUNCTION asgs_2011.nrmr_ste(asgs_2011.nrmr_code) RETURNS asgs_2011.ste_code AS $$
  SELECT substring($1 from 1 for 1)::asgs_2011.ste_code;
$$ LANGUAGE SQL;

-- From the CED code extract the STE code
CREATE FUNCTION asgs_2011.ced_ste(asgs_2011.ced_code) RETURNS asgs_2011.ste_code AS $$
  SELECT substring($1 from 1 for 1)::asgs_2011.ste_code;
$$ LANGUAGE SQL;

-- From the TR code extract the STE code
CREATE FUNCTION asgs_2011.tr_ste(asgs_2011.tr_code) RETURNS asgs_2011.ste_code AS $$
  SELECT substring($1 from 1 for 1)::asgs_2011.ste_code;
$$ LANGUAGE SQL;

-- From the UCL code extract the SOSR code
CREATE FUNCTION asgs_2011.ucl_sosr(asgs_2011.ucl_code) RETURNS asgs_2011.sosr_code AS $$
  SELECT substring($1 from 1 for 3)::asgs_2011.sosr_code;
$$ LANGUAGE SQL;

-- From the SOS code extract the STE code
CREATE FUNCTION asgs_2011.sos_ste(asgs_2011.sos_code) RETURNS asgs_2011.ste_code AS $$
  SELECT substring($1 from 1 for 1)::asgs_2011.ste_code;
$$ LANGUAGE SQL;

-- From the SOS code extract the SOS Identifier
CREATE FUNCTION asgs_2011.sos_identifier(asgs_2011.sos_code) RETURNS char(1) AS $$
  SELECT substring($1 from 2 for 1);
$$ LANGUAGE SQL;

-- From the SOSR code extract the SOS code
CREATE FUNCTION asgs_2011.sosr_sos(asgs_2011.sosr_code) RETURNS asgs_2011.sos_code AS $$
  SELECT substring($1 from 1 for 2)::asgs_2011.sos_code;
$$ LANGUAGE SQL;
