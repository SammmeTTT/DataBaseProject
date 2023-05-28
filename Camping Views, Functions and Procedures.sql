create database CampingProject;
use CampingProject;

#######################################################################################################

select * from kunder;

/*en procedur för att lägga till en rad i båda bokningstabeller*/
DROP PROCEDURE IF EXISTS LäggTillBokning;

DELIMITER //
CREATE PROCEDURE LäggTillBokning(IN inStartdatum date, IN inSlutdatum date, IN inAntalVuxna int, IN inAntalBarn int, IN inBoendeId varchar(10), IN inFödelsedatum date, IN inFödelsenummer varchar(4), IN inPrisVuxen int, IN inPrisBarn int)
BEGIN
    declare inBokningsTid datetime;
    set inBokningsTid = current_timestamp();
    set @inTotaltPris = totalaPrisetFörBokning(inStartdatum, inSlutdatum, inAntalVuxna, inAntalBarn, inBoendeId, inPrisVuxen, inPrisBarn);
   
    IF (inBoendeId like 'C%') THEN
		insert into BokningCamping(Bokningstid, StartDatum, SlutDatum, AntalVuxna, AntalBarn, TotalPris_kr, BoendeId, Födelsedatum, Födelsenummer)
		values (inBokningsTid, inStartdatum, inSlutdatum, inAntalVuxna, inAntalBarn, @inTotaltPris, inBoendeId, inFödelsedatum, inFödelsenummer);
	ELSEIF (inBoendeId like 'S%') THEN
		insert into BokningStuga(Bokningstid, StartDatum, SlutDatum, AntalVuxna, AntalBarn, TotalPris_kr, BoendeId, Födelsedatum, Födelsenummer)
		values (inBokningsTid, inStartdatum, inSlutdatum, inAntalVuxna, inAntalBarn, @inTotaltPris, inBoendeId, inFödelsedatum, inFödelsenummer);
    END IF;

END //
DELIMITER ;

CALL LäggTillBokning('2022-03-12 15:45:00', '2022-03-15', '2022-03-19', 1, 1, 'C101', '1900-10-06', '0123', '250', '100');
CALL LäggTillBokning('2022-03-12 15:45:00', '2022-03-15', '2022-03-19', 2, 1, 'S101', '1900-10-06', '0123', '250', '100');

select * from bokningstuga;
select * from stuga;

select * from bokningcamping;
select * from campingplats;
/*
trigger insert, addera 1 till antalet bokningar i den tabell som avses (antingen campingplats eller stuga) 
*/

###################################################################################################################

DROP TRIGGER IF EXISTS ökaAntaletBokningarCampingplats;

delimiter //
create trigger ökaAntaletBokningarCampingplats after insert on bokningcamping for each row
	begin
		update campingplats set campingplats.AntalBokningar = campingplats.AntalBokningar + 1;
	end //
delimiter ; 

insert into BokningCamping(Bokningstid, StartDatum, SlutDatum, AntalVuxna, AntalBarn, TotalPris_kr, BoendeID, Födelsedatum, Födelsenummer) values
    ('2022-05-08 15:45:00', '2022-05-23', '2022-05-29', 2, 2, 0, 'C101', '1978-04-20', '5678');

select* from kunder;
select * from bokningcamping;
select * from campingplats;

###############################################################################################################################

DROP TRIGGER IF EXISTS ökaAntaletBokningarStuga;

delimiter //
create trigger ökaAntaletBokningarStuga after insert on bokningstuga for each row
	begin
		update stuga set stuga.AntalBokningar = stuga.AntalBokningar + 1;
	end //
delimiter ; 

insert into BokningStuga(Bokningstid, StartDatum, SlutDatum, AntalVuxna, AntalBarn, TotalPris_kr, BoendeId, Födelsedatum, Födelsenummer) values
    ('2022-01-11 15:45:00', '2022-02-21', '2022-02-23', 1, 2, 0, 'S101', '1900-10-06', '0123');

select * from bokningstuga;
select * from stuga;


/*Visa bokningar för respektive boendetyp, vem som bokade och hur många nätter det gällde och visa dem utifrån antalet nätter*/
select distinct bokningstuga.BoendeID, bokningstuga.Startdatum, bokningstuga.Slutdatum, Kunder.FörNamn, Kunder.EfterNamn, datediff(bokningstuga.Slutdatum, bokningstuga.Startdatum) as antalNätter from bokningstuga inner join Kunder where bokningstuga.Födelsenummer = kunder.Födelsenummer order by antalNätter; #ev into



/*
function som räknar ut hur mycket en bokning kostar, antalet barn och vuxna och deras priser sammanlagda i totalPrice 
ev också vem som har bokat

IF myVarParam = '' THEN SET myVarParam = 'default-value'; END IF;
  ...your code here...
  
  SET myParam = IFNULL(myParam, 0);
Explanation: IFNULL(expression_1, expression_2)

The IFNULL function returns expression_1 if expression_1 is not NULL; otherwise it returns expression_2.
The IFNULL function returns a string or a numeric based on the context where it is used.
*/

drop function if exists totalaPrisetFörBokning; 

delimiter //
create function totalaPrisetFörBokning(Startdatum date, Slutdatum date, AntalVuxna int, AntalBarn int, inBoendeID varchar(10), parameterPrisVuxen int, parameterPrisBarn int) returns int
	deterministic
    begin
    
    declare prisBarn float;
    declare prisVuxen float;
    declare prisAllaVuxna float;
    declare prisAllaBarn float;
    declare prisAntalPersoner float;
    declare totaltPris float;
    declare prisPerDag float;
    declare antalDagar float;
    #declare prisAllaDagar float;
    
    set prisBarn = ifnull(parameterPrisBarn, 200.0);
    set prisVuxen = ifnull(parameterPrisVuxen, 500.0);
    set prisAllaBarn = antalBarn * prisBarn;
    set prisAllaVuxna = antalVuxna * prisVuxen;
    set prisAntalPersoner = prisAllaBarn + prisAllaVuxna;
	set antalDagar = datediff(Slutdatum, Startdatum);
    
    
    if (inBoendeID like 'C%') then
        (select GrundPrisPerDag_kr from campingplats where BoendeID = inBoendeID) into prisPerDag;
        set totaltPris = prisPerDag * antalDagar;
	elseif (inBoendeID like 'S%') then
		(select GrundPrisPerDag_kr from stuga where BoendeID = inBoendeID) into prisPerDag;
        set totaltPris = (prisAntalPersoner + prisPerDag) * antalDagar;
	end if;
    
    return(totaltPris);
    end //
delimiter ;

#################################################################################################################
drop function if exists ledigtBoende; 

 delimiter //
 CREATE FUNCTION ledigtBoende(inStartdatum date, inSlutdatum date, inBoendeID varchar(10)) RETURNS int
    DETERMINISTIC
begin
	declare ledigAttBoka int;
	declare antalBokade integer;

	set antalBokade = -2;
	
    if (inBoendeID like 'C%') then
		select count(*) into antalBokade from campingplats,bokningcamping where bokningcamping.Startdatum <= inSlutdatum and bokningcamping.Slutdatum >= inStartdatum and bokningcamping.BoendeID = inBoendeID; 
	elseif (inBoendeID like 'S%') then
		select count(*) into antalBokade from stuga,bokningstuga where bokningstuga.Startdatum <= inSlutdatum and bokningstuga.Slutdatum >= inStartdatum and bokningstuga.BoendeID = inBoendeID; 
	end if;
	
	if (antalBokade > 0)then set ledigAttBoka = -1; #is not availible
	elseif (antalBokade = 0) then set ledigAttBoka = 1; #is availible
	end if;

	return(ledigAttBoka);
	end //
delimiter ;

select * from bokningstuga;
select ledigtBoende('20220315','20220319','102');

###############################################################################################################

/*Visar totala priset för bokningar inom ett visst tidsintervall*/
select year(bokningstuga.Startdatum) as år, sum(TotalPris_kr) as ÅrsInkomst from bokningstuga group by år;
select year(bokningcamping.Startdatum) as år, sum(TotalPris_kr) as ÅrsInkomst from bokningcamping group by år;

/*Visar alla kunder som har gjort en stugbokning*/
select kunder.Förnamn, kunder.efternamn, bokningstuga.Födelsedatum, bokningstuga.Födelsenummer, bokningstuga.BoendeID, bokningstuga.Startdatum, bokningstuga.Slutdatum from kunder left JOIN bokningstuga on kunder.Födelsedatum = bokningstuga.Födelsedatum;

