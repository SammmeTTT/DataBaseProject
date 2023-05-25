create database CampingProject;
use CampingProject;

#######################################################################################################

/*en procedur för att lägga till en rad i båda bokningstabeller*/
DROP PROCEDURE IF EXISTS LäggTillBokning;

DELIMITER //
CREATE PROCEDURE LäggTillBokning(IN inBokningsTid datetime, IN inStartdatum date, IN inSlutdatum date, IN inAntalVuxna int, IN inAntalBarn int, IN inBoendeId varchar(10), IN inFödelsedatum date, IN inFödelsenummer varchar(4), IN inPrisVuxen int, IN inPrisBarn int)
BEGIN
	#declare inTotaltPris int;
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

CALL LäggTillBokning('2022-03-11 15:45:00', '2022-03-14', '2022-03-18', 1, 1, 'C101', '1900-10-06', '0123', '250', '100');

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
select distinct bokning.Bokningsnummer, bokning.Startdatum, bokning.Slutdatum, Kunder.FörNamn, Kunder.EfterNamn, datediff(bokning.Slutdatum, bokning.Startdatum) as antalNätter from bokning inner join Kunder where bokning.PersonNummer = kunder.PersonNummer order by antalNätter;



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
    
    declare prisBarn int;
    declare prisVuxen int;
    declare prisAllaVuxna int;
    declare prisAllaBarn int;
    declare prisFörBokning int;
    declare totaltPris int;
    declare prisPerDag int;
    
    set prisBarn = ifnull(parameterPrisBarn, 200);
    set prisVuxen = ifnull(parameterPrisVuxen, 500);
    set prisAllaBarn = antalBarn * prisBarn;
    set prisAllavuxna = antalVuxna * prisVuxen;
    set prisFörBokning = prisAllaBarn + prisAllaVuxna;
        
    if (inBoendeID like 'C%') then
		set prisPerDag = campingplats.GrundPrisPerDag_kr;
	elseif (inBoendeID like 'S%') then
		set prisPerDag = stuga.GrundPrisPerDag_kr;
	end if;
    
    set totaltPris = prisFörBokning + prisPerDag;
    
    return(totaltPris);
    end //
delimiter ;



