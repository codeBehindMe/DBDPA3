/*
======================================
Pig
======================================
*/


/*
** IMPORTING DATA INTO PIG **
*/

-- Look at the shell files.
sh ls;


-- copy locally.

copyFromLocal AwardsCoaches.csv AwardsCoaches.csv
copyFromLocal Coaches.csv Coaches.csv
copyFromLocal Master.csv Master.csv

-- Load

AwardsCoaches = LOAD 'AwardsCoaches.csv' USING PigStorage(',') AS (coachID:chararray, award:chararray, year:int, igid:chararray);
Coaches = LOAD 'Coaches.csv' USING PigStorage(',') AS (coachID:chararray, year:int, tmID:int,lgID:chararray, stInt:int, notes:chararray, games:Int,wins:int,losses:int,ties:int, postg:int,postw:int,postl:int,postt:int);
Master = LOAD 'Master.csv' USING PigStorage(',') AS (
    playerID:chararray,
    coachID:chararray,
    hofID:chararray,
    firstName:chararray,
    lastName:chararray,
    nameNote:chararray,
    nameGiven:chararray,
    nameNick:chararray,
    height:int,
    weight:int,
    shootCatch:chararray,
    legendsID:chararray,
    ihdbID:int,
    hrefID:chararray,
    firstNHL:int,
    lastNHL:int,
    firstWHA:int,
    lastWHA:int,
    pos:chararray,
    birthYear:int,
    birthMon:int,
    birthDay:int,
    birthCountry:chararray,
    birthState:chararray,
    birthCity:chararray,
    deathYear:int,
    deathMon:int,
    deathDay:int,
    deathCountry:chararray,
    deathState:chararray,
    deathCity:chararray
);



-- i : Coaches who have won more than 1 award
-- FirstName, LastName, DateOfBirth, BirthCountry, NumberOfAwards

-- Tables:
----------
-- Master.
-- AwardCoaches.

AC_Year = FOREACH AwardsCoaches GENERATE coachID AS coachID, year AS year; -- Get relevant coach columns.
AC_Coach_Group = GROUP AC_Year BY (coachID); -- Group by Coach ID.
AC_Coach_Awards = FOREACH AC_Coach_Group GENERATE group as coachID, COUNT(AC_Year) as AwardsCount; -- Count the number of awards per coach.
AC_Coach_MultiAward = FILTER AC_Coach_Awards BY (int)AwardsCount > 1; -- Excatch coaches with more than 1 award.

M_Fields = FOREACH Master GENERATE coachID as coachID, firstName as firstName, lastName as lastName, CONCAT((chararray)birthYear,'/',(chararray)birthMon,'/',(chararray)birthDay) as birthDate, birthCountry as birthCountry; -- Extract relevant fields for join.
M_Fields_CoachOnly = FILTER M_Fields BY coachID != ''; -- Filter coaches from master list.

M_AC_Join = JOIN M_Fields_CoachOnly by coachID, AC_Coach_MultiAward by coachID;

Result_Out = FOREACH M_AC_Join GENERATE firstName as firstName, lastName as lastName, birthDate as birthDate, birthCountry, AwardsCount as AwardsCount;

dump Result_Out;

-- ii: Coach who had the highest winrate for each year.
-- FirstName, LastName, Year, Games(g), Wins(w), WinRate

-- Tables:
-----------
-- Master
-- Coaches

C_Fields = FOREACH Coaches GENERATE coachID as coachID,year as year, games as games, wins as wins, (float)wins/(float)games as winRate;
C_Group_Year = GROUP C_Fields BY year;

C_Max_Wr = FOREACH C_Group_Year GENERATE group as year, MAX(C_Fields.winRate) as winRate;

C_C_Join = JOIN C_Max_Wr by (year,winRate), C_Fields by (year, winRate);

C_C_Fields = FOREACH C_C_Join GENERATE coachID as coachID, C_Max_Wr::year as year, games as games, wins as wins, C_Max_Wr::winRate as winRate;

M_Fields = FOREACH Master GENERATE coachID as coachID, firstName as firstName, lastName as lastName;
M_Fields_CoachOnly = FILTER M_Fields BY coachID != '';

M_C_Join = JOIN C_C_Fields by coachID, M_Fields_CoachOnly by coachID;

Result_Out = FOREACH M_C_Join GENERATE firstName as firstName, lastName as LastName, year as year, games as games, wins as wins, winRate as winRate;