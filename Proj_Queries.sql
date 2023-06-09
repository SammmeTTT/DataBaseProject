
# Projekt databasteknik
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
delimiter $$
create procedure VisaBokningarAvPersonFödda(in infödelsedatum varchar(10))
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

end$$
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


