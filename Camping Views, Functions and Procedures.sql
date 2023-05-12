create database CampinProject;
use CampingProject;

/*
triigger insers, kolla om börjar på s eller c (kolla första tecknet) och adder 1 till antalet bokningar i den tabell som avses 
*/

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

delimiter //
create function totala_priset_för_bokning(startDatum date, slutDatum date, antalBarn int, antalVuxna int, prisBarn int, prisVuxna int, boendeId int) returns int
	deterministic
    begin
    declare prisAllaVuxna int;
    declare prisAllaBarn int;
    declare prisFörBokning int;
    declare prisPerDag int;
    
    set prisAllaBarn = antalBarn * prisBarn;
    set prisAllavuxna = antalVuxna * prisVuxna;
    set prisFörBokning = prisAllaBarn + prisAllaVuxna;
    
    select sum(prisBarn)* antalBarn, antalVuxna, prisBarn, prisVuxna from Bokning;  
    
    return(prisFörBokning);
    end //
delimiter ;

/*antal dagar stugor/camping plats har blivit bokad*/