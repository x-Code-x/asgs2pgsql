-- Given an ABS structure code return which ABS struture that code is for.
-- Although all ABS struture codes appear to be distinct, I'm unsure how to
-- distinguish MB codes from SA1 codes. For now all 11 digit codes are returned
-- as SA1 even if they are actually MB codes.
CREATE OR REPLACE FUNCTION asgs_2011.match_abs_structure_code(code character varying(11)) RETURNS text AS $$
BEGIN
  IF code ~ E'^\\d$' THEN
      return 'ste';

  ELSIF code ~ E'^\\d{3}$' THEN
      return 'sa4';

  -- if 5 digits then is SA3
  -- UNLESS ends with 99 and 3rd last char is not a 9
  ELSIF code ~ E'^\\d{5}$' THEN
    IF code ~ '[0-8]99$' THEN
      return 'gccsa';
    ELSE
      return 'sa3';
    END IF;

  ELSIF code ~ E'^\\w{5}$' THEN
      return 'gccsa';

  ELSIF code ~ E'^\\d{9}$' THEN
      return 'sa2';

  ELSIF code ~ E'^\\d{11}$' THEN
      return 'sa1';
  END IF;
END
$$ LANGUAGE plpgsql;

-- For a given ASGS_2011.LGA name return a short version of the name
CREATE OR REPLACE FUNCTION asgs_2011.shorten_lga_name(name text) RETURNS text AS $$
BEGIN
  return regexp_replace(name, E' \\(.*', '');
END
$$ LANGUAGE plpgsql;

-- For a given ASGS_2011.LGA name return the LGA status type code
CREATE OR REPLACE FUNCTION asgs_2011.lga_status_type_code(name text) RETURNS text AS $$
BEGIN
  return (regexp_matches(name, E'\\((.*)\\)'))[1]::text;
END
$$ LANGUAGE plpgsql;

-- For a given ASGS_2011.LGA status type code return the full name for that Status Type
CREATE OR REPLACE FUNCTION asgs_2011.lga_status_type_code_to_name(code text) RETURNS text AS $$
BEGIN
  CASE code
    WHEN 'C' THEN
      return 'City';
    WHEN 'A' THEN
      return 'Area';
    WHEN 'RC' THEN
      return 'Rural City';
    WHEN 'B' THEN
      return 'Borough';
    WHEN 'S' THEN
      return 'Shire';
    WHEN 'T' THEN
      return 'Town';
    WHEN 'R', 'RegC' THEN
      return 'Regional Council';
    WHEN 'M' THEN
      return 'Municipality';
    WHEN 'DC' THEN
      return 'District Council';
    WHEN 'AC' THEN
      return 'Aboriginal Council';
    ELSE
      return null;
  END CASE;
END
$$ LANGUAGE plpgsql;

-- For a given ASGS_2011.UCL name return a string indicating if this is a locality or urban centre
CREATE OR REPLACE FUNCTION asgs_2011.ucl_type(name text) RETURNS text AS $$
BEGIN
  IF name ~ E'\\((L)\\)$' THEN
    return 'locality';
  ELSE
    return 'urban centre';
  END IF;
END
$$ LANGUAGE plpgsql;

-- From the SOS Identifier give the Identifier name
CREATE FUNCTION asgs_2011.sos_identifier_name(identifier char(1)) RETURNS text AS $$
BEGIN
  CASE identifier
    WHEN '0' THEN
      return 'Major Urban';
    WHEN '1' THEN
      return 'Other Urban';
    WHEN '2' THEN
      return 'Bounded Locality';
    WHEN '3' THEN
      return 'Rural Balance';
    ELSE
      return null;
  END CASE;
END
$$ LANGUAGE plpgsql;
