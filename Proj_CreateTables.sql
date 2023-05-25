
# Projekt databasteknik

# Drop Tabeller
drop table kunder;
drop table campingplats;
drop table stuga;
drop table bokningcamping;
drop table bokningstuga;

# Tabeller:

create database DV1663Camping;
use DV1663Camping;

create table Kunder(
Födelsedatum date not null,
Födelsenummer varchar(4) not null,
Mobilnummer varchar(11) not null,
Mailadress varchar(100) not null,
Förnamn varchar(100) not null,
Efternamn varchar(100) not null,

-- Primary key
primary key (Födelsedatum, Födelsenummer));

select * from Kunder;
###############################################
create table Campingplats(
BoendeID varchar(10) not null,
GrundPrisPerDag_kr float not null,
Yta_m2 float not null,
El varchar(20) not null,
AntalBokningar int not null,

-- primary key
primary key (BoendeID));

select * from Campingplats;
###############################################
create table Stuga(
BoendeID varchar(10) not null,
GrundPrisPerDag_kr float not null,
Yta_m2 float not null,
Spis varchar(3) not null,
Ugn varchar(3) not null,
Toalett varchar(3) not null,
Dusch varchar(3) not null,
AntalSängar int not null,
AntalBokningar int not null,

-- primary key
primary key (BoendeID));

select * from Stuga;
###############################################
create table BokningStuga(
Bokningsnummer int auto_increment not null,
Bokningstid datetime not null,
Startdatum date not null,
Slutdatum date not null,
AntalVuxna int not null,
AntalBarn int not null,
TotalPris_kr float not null,
BoendeID varchar(10),
Födelsedatum date not null,
Födelsenummer varchar(4) not null,

-- Primary key
primary key (Bokningsnummer),
-- foreign key
foreign key (Födelsedatum, Födelsenummer) references Kunder(Födelsedatum, Födelsenummer),
foreign key (BoendeID) references Stuga(BoendeID)
);

select * from BokningStuga;

##########################################################################

create table BokningCamping(
Bokningsnummer int auto_increment not null,
Bokningstid datetime not null,
Startdatum date not null,
Slutdatum date not null,
AntalVuxna int not null,
AntalBarn int not null,
TotalPris_kr float not null,
BoendeID varchar(10),
Födelsedatum date not null,
Födelsenummer varchar(4) not null,

-- Primary key
primary key (Bokningsnummer),
-- foreign key
foreign key (Födelsedatum, Födelsenummer) references Kunder(Födelsedatum, Födelsenummer),
foreign key (BoendeID) references Campingplats(BoendeID)
);

select * from BokningCamping;

###################################################################################################################

DROP TRIGGER IF EXISTS ökaAntaletBokningarCampingplats;

delimiter //
create trigger ökaAntaletBokningarCampingplats after insert on bokningcamping for each row
	begin
		update campingplats set campingplats.AntalBokningar = campingplats.AntalBokningar + 1;
	end //
delimiter ;

insert into BokningCamping(Bokningstid, StartDatum, SlutDatum, AntalVuxna, AntalBarn, TotalPris_kr, BoendeID, Födelsedatum, Födelsenummer) values
    ('2022-05-10 15:45:00', '2022-05-24', '2022-05-30', 2, 2, 0, 'C101', '1978-04-20', '5678');

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

drop function if exists totalaPrisetFörBokning; 

delimiter //
create function totalaPrisetFörBokning(Startdatum date, Slutdatum date, AntalVuxna int, AntalBarn int, inBoendeID varchar(10), parameterPrisVuxen int, parameterPrisBarn int) returns int
	deterministic
    begin
    
    declare prisBarn float;
    declare prisVuxen float;
    declare prisAllaVuxna float;
    declare prisAllaBarn float;
    declare prisFörBokning float;
    declare totaltPris float;
    declare prisPerDag float;
    declare antalDagar float;
    
    set prisBarn = ifnull(parameterPrisBarn, 200.0);
    set prisVuxen = ifnull(parameterPrisVuxen, 500.0);
    set prisAllaBarn = antalBarn * prisBarn;
    set prisAllavuxna = antalVuxna * prisVuxen;
    set prisFörBokning = prisAllaBarn + prisAllaVuxna;
        
    if (inBoendeID like 'C%') then
		#set prisPerDag = campingplats.GrundPrisPerDag_kr;
        #(select GrundPrisPerDag_kr from campingplats where BoendeID = inBoendeID) into prisPerDag;
        set totaltPris = prisFörBokning;
	elseif (inBoendeID like 'S%') then
		(select GrundPrisPerDag_kr from stuga where BoendeID = inBoendeID) into prisPerDag;
        #set prisPerDag = stuga.GrundPrisPerDag_kr;
        set totaltPris = prisFörBokning + prisPerDag;
	end if;
    
    return(totaltPris);
    end //
delimiter ;

select totalaPrisetFörBokning('2022-01-14', '2022-01-18', 2, 1, 'C101',null,null);




