
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


