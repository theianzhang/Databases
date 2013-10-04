----------------------------------------------------------------------
-- DROP statements: We begin with these to ensure that everytime we
-- start with a clean database state.
--
-- NOTE: If you create additional triggers, remember to drop therm
-- there (and BEFORE dropping the tables they are based on).

DROP TRIGGER TG_StealthStartup ON StealthStartup;
DROP TRIGGER TG_PrivateStartup ON PrivateStartup;
DROP VIEW StealthStartup;
DROP VIEW PrivateStartup;
DROP TABLE TargetOf;
DROP TABLE Fund;
DROP TABLE PrivateCompany;
DROP TABLE StealthCompany;
DROP TABLE Startup;
DROP TABLE Sector;
DROP TABLE Industry;
DROP TABLE VCFund;

----------------------------------------------------------------------
-- Tables:
-- You will need to modify this section to add constraints (such as
-- primary, unique, and foreign keys).

CREATE TABLE VCFund(
    vcid INTEGER NOT NULL,
    name VARCHAR(50) NOT NULL,
    number INTEGER NOT NULL,
    size INTEGER NOT NULL,
    closing_date DATE NOT NULL,
    PRIMARY KEY (vcid)
);
CREATE TABLE Industry(
    name VARCHAR(50) NOT NULL,
    market_size INTEGER NOT NULL,
    PRIMARY KEY (name)
);
CREATE TABLE Sector(
    industry_name VARCHAR(50) NOT NULL,
    sector_name VARCHAR(50) NOT NULL,
    project_growth INTEGER NOT NULL,
    PRIMARY KEY (industry_name, sector_name),
    FOREIGN KEY (industry_name) REFERENCES Industry(name)
);
CREATE TABLE Startup(
    sid INTEGER NOT NULL,
    industry_name VARCHAR(50) NOT NULL,
    startup_name VARCHAR(50) NOT NULL,
    address VARCHAR(200) NOT NULL,
    PRIMARY KEY (sid),
    FOREIGN KEY (industry_name) REFERENCES Industry(name)
);
CREATE TABLE StealthCompany(
    sid INTEGER NOT NULL,
    buzz_factor INTEGER NOT NULL,
    PRIMARY KEY (sid),
    FOREIGN KEY (sid) REFERENCES Startup(sid)
);
CREATE TABLE PrivateCompany(
    sid INTEGER NOT NULL,
    CEO VARCHAR(50) NOT NULL,
    website VARCHAR(50) NOT NULL,
    sector_name VARCHAR(50) NOT NULL,
    PRIMARY KEY (sid),
    FOREIGN KEY (sid) REFERENCES Startup(sid)
);
CREATE TABLE Fund(
    vcid INTEGER NOT NULL,
    sid INTEGER NOT NULL,
    PRIMARY KEY (vcid, sid)
);
CREATE TABLE TargetOf(
    target_sid INTEGER NOT NULL,
    sid INTEGER NOT NULL,
    PRIMARY KEY (target_sid, sid)
);

-- StealthStartup view and associated trigger/function:
--
-- You do not need to edit this section, but do read it to get an idea
-- about what to do for PrivateStartup view.
--
-- StealthStartup view "wraps" Startup and StealthCompany, so that
-- users can access complete information about stealth startups
-- through this view.  The trigger below allows users to modify this
-- view.  To make constraints easier to enforce, you may assume that
-- users CANNOT modify Startup and StealthCompany directly (which can
-- be ensured by GRANT statements---a topic that we don't cover in
-- class but you can read more about by yourself).

CREATE VIEW
  StealthStartup(sid, industry_name, startup_name, address,
                 buzz_factor) AS
  SELECT Startup.sid, industry_name, startup_name, address, buzz_factor
  FROM Startup, StealthCompany
  WHERE Startup.sid = StealthCompany.sid;
CREATE VIEW

CREATE OR REPLACE FUNCTION TF_StealthStartup() RETURNS TRIGGER AS $$
BEGIN
  IF (TG_OP = 'INSERT') THEN
    INSERT INTO Startup
    VALUES(NEW.sid, NEW.industry_name, NEW.startup_name, NEW.address);
    INSERT INTO StealthCompany
    VALUES(NEW.sid, NEW.buzz_factor);
  ELSEIF (TG_OP = 'UPDATE') THEN
    IF (NEW.sid <> OLD.sid) THEN
      RAISE EXCEPTION 'Cannot update Startup(sid)';
    ELSE
      UPDATE Startup
      SET industry_name = NEW.industry_name,
          startup_name = NEW.startup_name,
          address = NEW.address
      WHERE sid = NEW.sid;
      UPDATE StealthCompany
      SET buzz_factor = NEW.buzz_factor
      WHERE sid = NEW.sid;
    END IF;
  ELSEIF (TG_OP = 'DELETE') THEN
    DELETE FROM StealthCompany WHERE sid = OLD.sid;
    DELETE FROM Startup WHERE sid = OLD.sid;
  END IF;
  RETURN NULL;
END;
$$ LANGUAGE plpgsql;
CREATE FUNCTION

CREATE TRIGGER TG_StealthStartup
  INSTEAD OF INSERT OR UPDATE OR DELETE
  ON StealthStartup
  FOR EACH ROW
  EXECUTE PROCEDURE TF_StealthStartup();
CREATE TRIGGER

-- PrivateStartup view and associated trigger/function:
--
-- You need to complete this section.
--
-- PrivateStartup view "wraps" Startup and PrivateCompany, so that
-- users can access complete information about private startups
-- through this view.  The trigger below allows users to modify this
-- view.  To make constraints easier to enforce, you may assume that
-- users CANNOT modify Startup and PrivateCompany directly (which can
-- be ensured by GRANT statements---a topic that we don't cover in
-- class but you can read more about by yourself).
--

CREATE VIEW
  PrivateStartup(sid, industry_name, startup_name, address,
                 CEO, website, sector_name) AS
  SELECT Startup.sid, industry_name, startup_name, address, CEO, website, sector_name
  FROM Startup, PrivateCompany
  WHERE Startup.sid = PrivateCompany.sid;
CREATE VIEW

CREATE OR REPLACE FUNCTION TF_PrivateStartup() RETURNS TRIGGER AS $$
BEGIN
  IF (TG_OP = 'INSERT') THEN
    INSERT INTO Startup
    VALUES(NEW.sid, NEW.industry_name, NEW.startup_name, NEW.address);
    INSERT INTO PrivateCompany
    VALUES(NEW.sid, NEW.CEO, NEW.website, NEW.sector_name);
  ELSEIF (TG_OP = 'UPDATE') THEN
    IF (NEW.sid <> OLD.sid) THEN
      RAISE EXCEPTION 'Cannot update Startup(sid)';
    ELSE
      UPDATE Startup
      SET industry_name = NEW.industry_name,
          startup_name = NEW.startup_name,
          address = NEW.address
      WHERE sid = NEW.sid;
      UPDATE PrivateCompany
      SET CEO = NEW.CEO
      SET website = NEW.website
      SET sector_name = NEW.sector_name
      WHERE sid = NEW.sid;
    END IF;
  ELSEIF (TG_OP = 'DELETE') THEN
    DELETE FROM PrivateCompany WHERE sid = OLD.sid;
    DELETE FROM Startup WHERE sid = OLD.sid;
  IF (NEW.sector_name NOT IN (SELECT sector_name from Sector)) THEN
  RAISE EXCEPTION 'Not a valid startup';
  ELSE
  END IF;
  RETURN NULL;
END;
$$ LANGUAGE plpgsql;
CREATE FUNCTION

CREATE TRIGGER TG_PrivateStartup
  INSTEAD OF INSERT OR UPDATE OR DELETE
  ON PrivateStartup
  FOR EACH ROW
  EXECUTE PROCEDURE TF_PrivateStartup();
CREATE TRIGGER

-- Other triggers/functions, if any, should go here:

----------------------------------------------------------------------
-- Data modification statements:

-- The following statements should be accepted:
INSERT INTO VCFund VALUES(101, 'Kleiner Perkins', 7, 76923, '2013-12-31');
INSERT INTO VCFund VALUES(102, 'Sequoia Capital', 3, 52631, '2014-08-31');
INSERT INTO Industry VALUES('IT', 10000);
INSERT INTO Industry VALUES('Education', 500);
INSERT INTO Industry VALUES('Entertainment', 9000);
INSERT INTO Sector VALUES('Education', 'Higher Education', 0);
INSERT INTO StealthStartup VALUES
  (1, 'IT', '316 Consulting', 'Box 90129, Durham, NC', 100);
INSERT INTO PrivateStartup VALUES
  (2, 'Education', 'Blue Devils', 'Durham, NC',
   'Brodhead', 'www.duke.edu', 'Higher Education');
INSERT INTO PrivateStartup VALUES
  (3, 'Education', 'Tar Heels', 'Chapel Hill, NC',
   'Folt', 'www.unc.edu', 'Higher Education');
INSERT INTO Fund VALUES(101, 1);
INSERT INTO Fund VALUES(101, 2);
INSERT INTO Fund VALUES(102, 3);
INSERT INTO TargetOf VALUES(1, 2);
INSERT INTO TargetOf VALUES(1, 3);

-- The following statement should fail because (Entertainment, Higher
-- Education) is not a valid industry sector.
INSERT INTO PrivateStartup VALUES
  (4, 'Entertainment', 'Wolf Pack', 'Raleigh, NC',
   'Folt', 'www.unc.edu', 'Higher Education');

-- The following two statements should fail because a stealth company
-- cannot be financed by more than one VC fund.
INSERT INTO Fund VALUES(102, 1);
UPDATE Fund SET sid = 1 WHERE vcid = 102 AND sid = 3;

-- The following statement should fail because a VC fund cannot fund
-- two private startups in the same sector.
INSERT INTO Fund VALUES(102, 2);

-- The following statements should fail because only stealth companies
-- can be targets of private companies.
INSERT INTO TargetOf VALUES(2, 3);

-- Write modification statements below (one per constraint) that
-- illustrate how the following constraints are enforced by your
-- schema:

-- 1. No two VC funds can be identical in both name and number:

INSERT INTO VCFund VALUES(102, 'Sequoia Capital', 3, 52631, '2014-08-31');
INSERT INTO VCFund VALUES(102, 'Sequoia Capital', 3, 52631, '2014-08-31');

-- 2. Every industry has a unique name.

INSERT INTO Industry VALUES('IT', 10000);
INSERT INTO Industry VALUES('IT', 10000);

-- 3. No two startups in the same industry can have a same name.  You
-- should write a modification statement on StealthStartup or
-- PrivateStartup (recall that we don't allow direct modifications to
-- Startup, StealthCompany, and PrivateCompany).

INSERT INTO PrivateStartup VALUES
  (3, 'Education', 'Tar Heels', 'Chapel Hill, NC',
   'Folt', 'www.unc.edu', 'Higher Education');
INSERT INTO PrivateStartup VALUES
  (3, 'Education', 'Tar Heels', 'Chapel Hill, NC',
   'Folt', 'www.unc.edu', 'Higher Education');

-- 4. Sector names are unique within an industry.

INSERT INTO Sector VALUES('Education', 'Higher Education', 0);
INSERT INTO Sector VALUES('Education', 'Higher Education', 0);
