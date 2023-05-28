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
#################################################################################################################
SET GLOBAL log_bin_trust_function_creators = 1; -- (nödvändig för funktionen).
############################################################## Klar:
drop procedure if exists AddStuga;
delimiter $$
create procedure AddStuga (in nyBoendeID varchar(10), in nyGrundPrisPerDag_kr float, in nyYta_m2 float, in nySpis varchar(3), in nyUgn varchar(3),
in nyToalett varchar(3), in nyDusch varchar(3), in nyAntalSängar int, in nyAntalBokningar int)
# Procedur för att lägga till en stuga i tabellen. (Finnas ett default grundpris beroende på yta.)
deterministic
begin

    insert into Stuga(BoendeID, GrundPrisPerDag_kr, Yta_m2, Spis, Ugn, Toalett, Dusch, AntalSängar, AntalBokningar) values
    (nyBoendeID, nyGrundPrisPerDag_kr, nyYta_m2, nySpis, nyUgn, nyToalett, nyDusch, nyAntalSängar, nyAntalBokningar);

end$$
delimiter ;

# Exempel:
-- call AddStuga('S200', 500, 30, 'ja', 'ja', 'ja', 'nej', 4, 0);
############################################################## Klar:
drop procedure if exists AddKund;
delimiter $$
create procedure AddKund (in inFödelsedatum date, in inFödelsenummer varchar(4), in inMobilnummer varchar(11), in inMailadress varchar(100),
in inFörnamn varchar(100), in inEfternamn varchar(100))
# Procedur för att lägga till en kund i tabellen.
deterministic
begin
	
    insert into Kunder(Födelsedatum, Födelsenummer, Mobilnummer, Mailadress, Förnamn, Efternamn) values
    (inFödelsedatum, inFödelsenummer, inMobilnummer, inMailadress, inFörnamn, inEfternamn);

end$$
delimiter ;

# Exempel:
-- call AddKund('1980-01-01', '1111', '0725-555555', 'hej@home.com', 'hej', 'hejssan');
############################################################## Klar:
drop procedure if exists AddCampingplats;
delimiter $$
create procedure AddCampingplats (in inBoendeID varchar(10), in inGrundPrisPerDag_kr float, in inYta_m2 float, in inEl varchar(20), in inAntalBokningar int)
# Procedur för att lägga till en Campingplats i tabellen.
begin

	insert into Campingplats(BoendeID, GrundPrisPerDag_kr, Yta_m2, El, AntalBokningar) values
    (inBoendeID, inGrundPrisPerDag_kr, inYta_m2, inEl, inAntalBokningar);

end$$
delimiter ;
# Exempel:
-- call AddCampingplats('C3000', 500, 50, 'ja', 0);
############################################################## Klar:
drop procedure if exists VisaBokningarAvPersonFödda;
delimiter //
create procedure VisaBokningarAvPersonFödda (in infödelsedatum varchar(10))
# Procedur som visar bokningar av personer födda på samma form som inparametern har.
begin

	set @string1 = concat(infödelsedatum, '%');
    -- Väljer alla bokningar på Campingplats där personerna är födda enligt ovan.
	select C.BoendeID, concat(K.Födelsedatum, '-', K.Födelsenummer) as Personnummer, K.Förnamn, K.Efternamn, BC.Bokningsnummer, BC.Startdatum, BC.Slutdatum, C.AntalBokningar
    from BokningCamping BC
    inner join Kunder K
    on BC.födelsedatum = K.födelsedatum and BC.födelsenummer = K.födelsenummer
    inner join Campingplats C
    on C.BoendeID = BC.BoendeID
	where BC.födelsedatum like @string1
    
    union all
    -- Väljer alla bokningar på Stuga där personerna är födda enligt ovan.
    select S.BoendeID, concat(K.Födelsedatum, '-', K.Födelsenummer) as Personnummer, K.Förnamn, K.Efternamn, BS.Bokningsnummer, BS.Startdatum, BS.Slutdatum, S.AntalBokningar
    from BokningStuga BS
    inner join Kunder K
    on BS.födelsedatum = K.födelsedatum and BS.födelsenummer = K.födelsenummer
    inner join Stuga S
    on S.BoendeID = BS.BoendeID
    where BS.födelsedatum like @string1
    order by BoendeID;

end//
delimiter ;
# Exempel:
call VisaBokningarAvPersonFödda('19');
############################################################## Klar:
drop function if exists AvbokaSCB;
delimiter $$
create function AvbokaSCB(inBoendeID varchar(10), inBokningsnummer int) returns bool
# Avbokar stuga och campingplats om (nuvarande datum) < startdatum.
# Returnerar True (1) om avbokningen blev lyckad, annars False (0).
begin
	declare avbokad bool;
    set avbokad = False;

    -- Avboka stuga:
    if (inBoendeID like 'S%') then
		if inBoendeID in (select BS.BoendeID from bokningstuga BS where BS.bokningsnummer = inBokningsnummer and current_date() < BS.startdatum) then
			delete from bokningstuga BS
            where BS.bokningsnummer = inBokningsnummer;
            set avbokad = True;
		end if;

    -- Avboka campingplats:
    elseif (inBoendeID like 'C%') then
		if inBoendeID in (select BC.BoendeID from bokningcamping BC where BC.bokningsnummer = inBokningsnummer and current_date() < BC.startdatum) then
			delete from bokningcamping BC
            where BC.bokningsnummer = inBokningsnummer;
            set avbokad = True;
		end if;
	end if;
    return avbokad;
end$$
delimiter ;

############################################################## Klar:
drop view if exists KunderÅrtionde;
create view KunderÅrtionde as
-- Grupperar antal kunder under olika årtionde
select floor(year(födelsedatum) / 10) * 10 as Årtionde, count(*) as AntalKunder from Kunder
group by Årtionde;
# Exempel:
select * from KunderÅrtionde;
############################################################## Klar:
drop trigger if exists MinskaAntalBokningarStuga;
create trigger MinskaAntalBokningarStuga
-- Minskar antal bokningar på specifik stuga när den blir avbokad.
after delete on bokningstuga for each row
update stuga
set stuga.antalbokningar = stuga.antalbokningar - 1
where stuga.boendeID = old.boendeID;
############################################################## Klar:
drop trigger if exists MinskaAntalBokningarCampingplats;
create trigger MinskaAntalBokningarCampingplats
-- Minskar antal bokningar på specifik campingplats när den blir avbokad.
after delete on bokningcamping for each row
update campingplats
set campingplats.antalbokningar = campingplats.antalbokningar - 1
where campingplats.boendeID = old.boendeID;
