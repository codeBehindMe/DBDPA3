/*
======================================
Hive
======================================
*/


/*
** IMPORTING DATA INTO HIVE **
*/

USE taru3;

SHOW tables;
-- basketball_master
-- basketball_players
-- basketball_ teams
-- temp_master
-- temp_players
-- temp_teams

DROP TABLE temp_master;
DROP TABLE temp_players;
DROP TABLE temp_teams;

SHOW tables;
-- basketball_master
-- basketball_players
-- basketball_ teams


-- Create temporary tables
DROP TABLE temp_Master;
DROP TABLE temp_AwardsCoaches;
DROP TABLE temp_Coaches;

CREATE TABLE temp_Master (col_value STRING);
CREATE TABLE temp_AwardsCoaches (col_value STRING);
CREATE TABLE temp_Coaches (col_value STRING);

-- Load data into temporary tables.
LOAD DATA LOCAL INPATH 'Master.csv' OVERWRITE INTO TABLE temp_Master;
LOAD DATA LOCAL INPATH 'AwardsCoaches.csv' OVERWRITE INTO TABLE temp_AwardsCoaches;
LOAD DATA LOCAL INPATH 'Coaches.csv' OVERWRITE INTO TABLE temp_Coaches;

-- Create Persistent tables.
DROP TABLE p_Master;
DROP TABLE p_AwardsCoaches;
DROP TABLE p_Coaches;

CREATE TABLE p_Master (coachID STRING, firstName STRING, lastName STRING, birthDay INT, birthMon INT, birthYear INT, birthCountry STRING);
CREATE TABLE p_AwardsCoaches (coachID STRING, year INT);
CREATE TABLE p_Coaches (coachID STRING, year INT, games INT, wins INT, losses INT, ties INT);

-- Write data into persistent tables using regex.
INSERT OVERWRITE TABLE p_Master
SELECT
regexp_extract(col_value, '^(?:([^,]*)\,?){2}',1) coachID,
regexp_extract(col_value, '^(?:([^,]*)\,?){4}',1) firstName,
regexp_extract(col_value, '^(?:([^,]*)\,?){5}',1) lastName,
regexp_extract(col_value, '^(?:([^,]*)\,?){22}',1) birthDay,
regexp_extract(col_value, '^(?:([^,]*)\,?){21}',1) birthMon,
regexp_extract(col_value, '^(?:([^,]*)\,?){20}',1) birthYear,
regexp_extract(col_value, '^(?:([^,]*)\,?){23}',1) birthCountry
FROM temp_Master;

INSERT OVERWRITE TABLE p_AwardsCoaches 
SELECT
regexp_extract(col_value, '^(?:([^,]*)\,?){1}',1) coachID,
regexp_extract(col_value, '^(?:([^,]*)\,?){3}',1) year
FROM temp_AwardsCoaches;




INSERT OVERWRITE TABLE p_Coaches
SELECT
regexp_extract(col_value, '^(?:([^,]*)\,?){1}',1) coachID,
regexp_extract(col_value, '^(?:([^,]*)\,?){2}',1) year,
regexp_extract(col_value, '^(?:([^,]*)\,?){7}',1) games,
regexp_extract(col_value, '^(?:([^,]*)\,?){8}',1) wins,
regexp_extract(col_value, '^(?:([^,]*)\,?){9}',1) losses,
regexp_extract(col_value, '^(?:([^,]*)\,?){10}',1) ties
FROM temp_Coaches;

-- Remove header from becoming data row.
INSERT OVERWRITE TABLE p_Master
SELECT * 
FROM p_Master
WHERE coachID != 'coachID';

INSERT OVERWRITE TABLE p_AwardsCoaches
SELECT * 
FROM p_AwardsCoaches
WHERE coachID != 'coachID';

INSERT OVERWRITE TABLE p_Coaches
SELECT * 
FROM p_Coaches
WHERE coachID != 'coachID';


-- i : Coaches who have won more than 1 award
-- FirstName, LastName, DateOfBirth, BirthCountry, NumberOfAwards

-- Tables:
----------
-- Master.
-- AwardCoaches.


SELECT firstName, lastName, concat(birthDay,'/',birthMon,'/',birthYear) AS birthDate, birthCountry, AwardCount
FROM (SELECT substring(coachID,1,20) AS CoachID, count(*) as AwardCount FROM AwardsCoaches GROUP BY substring(coachID,1,20)) t1
LEFT JOIN Master t2 ON SUBSTRING(t1.coachID, 1, 20) = SUBSTRING(t2.coachID, 1, 20);

-- ii: Coach who had the highest winrate for each year.
-- FirstName, LastName, Year, Games(g), Wins(w), WinRate

-- Tables:
-----------
-- Master
-- Coaches

-- Inserting data into hive


