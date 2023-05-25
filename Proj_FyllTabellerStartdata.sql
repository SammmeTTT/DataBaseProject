
# Projekt databasteknik

# Start-inmatning till tabellerna:

insert into Kunder(Födelsedatum, Födelsenummer, Mobilnummer, Mailadress, Förnamn, Efternamn) values 
('1900-10-06', '0123', '0712-345678', 'stina@bth.teacher.se', 'Stina', 'Nilsson'),
('1925-11-08', '1234', '0722-445678', 'emil@bth.student.se', 'Emil', 'Svensson'),
('1950-12-10', '2345', '0732-545678', 'sofie12@ericsson.se', 'Sofie', 'Larsson'),
('1975-01-12', '3456', '0742-645678', 'bengt.karlsson@karlssons.svets.com', 'Bengt', 'Karlsson'),
('2000-02-14', '4567', '0752-745678', 'blackhat0x74@darknet.se', 'Karin', 'Johansson'),
('1978-04-20', '5678', '0762-845678', 'maja0x53@telia.com', 'Maja', 'Sjödahl');

select * from Kunder;

##############################################################################

insert into Campingplats(BoendeID, GrundPrisPerDag_kr, Yta_m2, El, AntalBokningar) values
('C101', 150, 16, 'nej', 3),
('C102', 620, 32, 'ja', 10),
('C103', 620, 32, 'ja', 8),
('C104', 300, 16, 'ja', 5),
('C105', 300, 16, 'ja', 12),
('C106', 620, 32, 'ja', 7),
('C107', 150, 16, 'nej', 3);

select * from Campingplats;

##############################################################################

insert into Stuga(BoendeID, GrundPrisPerDag_kr, Yta_m2, Spis, Ugn, Toalett, Dusch, AntalSängar, AntalBokningar) values
    ('S101', 550.5, 27.0, 'nej', 'ja', 'nej', 'nej', 3, 1),
    ('S102', 675.0, 33.0, 'ja', 'ja', 'ja', 'nej', 4, 3),
    ('S104', 440.5, 22.0, 'ja', 'nej', 'nej', 'nej', 2, 10),
    ('S108', 815.75, 64.0, 'ja', 'ja', 'ja', 'ja', 6, 5),
    ('S116', 420.0, 15.0, 'nej', 'nej', 'nej', 'nej', 1, 2),
    ('S132', 710.5, 40.0, 'ja', 'ja', 'ja', 'nej', 4, 15);
    
select * from Stuga;

###############################################################################

insert into BokningStuga(Bokningstid, StartDatum, SlutDatum, AntalVuxna, AntalBarn, TotalPris_kr, BoendeId, Födelsedatum, Födelsenummer) values
    ('2022-01-11 15:45:00', '2022-01-14', '2022-01-18', 2, 1, 0, 'S101', '1900-10-06', '0123'),
    ('2022-10-13 14:35:00', '2022-10-18', '2022-10-20', 4, 2, 0, 'S108', '1978-04-20', '5678'),
    ('2022-05-15 17:10:00', '2022-05-20', '2022-05-21', 2, 2, 0, 'S102', '1950-12-10', '2345'),
    ('2022-06-13 10:15:00', '2022-06-25', '2022-06-27', 2, 2, 0, 'S132', '1975-01-12', '3456'),
    ('2022-07-02 08:00:45', '2022-07-04', '2022-07-07', 2, 0, 0, 'S104', '1925-11-08', '1234'),
    ('2022-01-31 15:45:00', '2022-02-01', '2022-02-10', 1, 0, 0, 'S116', '2000-02-14', '4567');

select * from BokningStuga;

#################################################################################

insert into BokningCamping(Bokningstid, StartDatum, SlutDatum, AntalVuxna, AntalBarn, TotalPris_kr, BoendeID, Födelsedatum, Födelsenummer) values
    ('2022-01-10 13:45:00', '2022-01-15', '2022-01-20', 4, 2, 0, 'C101', '1925-11-08', '1234'),
    ('2022-04-12 11:23:30', '2022-04-17', '2022-04-18', 1, 2, 0, 'C103', '1950-12-10', '2345'),
    ('2022-07-09 16:05:15', '2022-07-20', '2022-07-26', 2, 1, 0, 'C107', '1975-01-12', '3456'),
	('2022-05-12 18:45:00', '2022-05-15', '2022-05-16', 2, 0, 0, 'C104', '1900-10-06', '0123'),
    ('2022-08-01 17:10:05', '2022-08-02', '2022-08-05', 2, 3, 0, 'C106', '1978-04-20', '5678'),
    ('2022-06-08 15:55:10', '2022-06-09', '2022-06-16', 1, 1, 0, 'C102', '2000-02-14', '4567');


select * from BokningCamping;
