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

C_Fields = FOREACH Coaches GENERATE coachID as coachID,year as year, games as games, wins as wins, (float)wins/(float)games as winRate;
C_Group_Year = GROUP C_Fields BY year;

C_Max_Wr = FOREACH C_Group_Year GENERATE group as year, MAX(C_Fields.winRate) as winRate;

C_C_Join = JOIN C_Max_Wr by (year,winRate), C_Fields by (year, winRate);

C_C_Fields = FOREACH C_C_Join GENERATE coachID as coachID, C_Max_Wr::year as year, games as games, wins as wins, C_Max_Wr::winRate as winRate;

M_Fields = FOREACH Master GENERATE coachID as coachID, firstName as firstName, lastName as lastName;
M_Fields_CoachOnly = FILTER M_Fields BY coachID != '';

M_C_Join = JOIN C_C_Fields by coachID, M_Fields_CoachOnly by coachID;

Result_Out = FOREACH M_C_Join GENERATE firstName as firstName, lastName as LastName, year as year, games as games, wins as wins, winRate as winRate;

STORE Result_Out INTO 'Task_3_2' using PigStorage(',','-schema');


copyToLocal Task_3_2 Task_3_2;