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

AC_Year = FOREACH AwardsCoaches GENERATE coachID AS coachID, year AS year; 
AC_Coach_Group = GROUP AC_Year BY (coachID); 
AC_Coach_Awards = FOREACH AC_Coach_Group GENERATE group as coachID, COUNT(AC_Year) as AwardsCount; 
AC_Coach_MultiAward = FILTER AC_Coach_Awards BY (int)AwardsCount > 1; 

M_Fields = FOREACH Master GENERATE coachID as coachID, firstName as firstName, lastName as lastName, CONCAT((chararray)birthYear,'/',(chararray)birthMon,'/',(chararray)birthDay) as birthDate, birthCountry as birthCountry;
M_Fields_CoachOnly = FILTER M_Fields BY coachID != '';

M_AC_Join = JOIN M_Fields_CoachOnly by coachID, AC_Coach_MultiAward by coachID;

Result_Out = FOREACH M_AC_Join GENERATE firstName as firstName, lastName as lastName, birthDate as birthDate, birthCountry, AwardsCount as AwardsCount;

STORE Result_Out INTO 'Task_3_1' using PigStorage(',');


copyToLocal Task_3_1 Task_3_1;