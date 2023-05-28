import mysql.connector
from mysql.connector import Error

#Välkommen till BTHs nya campings bokningssystem

#db.commit(); # apply the changes to the database while insert/delete/update

#visaSelect: skriver ut resultatet av en select
#viaProcedur: skriver ut resultatet av en procudur som innehåller något att skriva ut


# Ansluter till servern localhost och till databasen dv1663camping
db = mysql.connector.connect(
    host = "localhost",
    user = "root",
    password = "MySQL23",
    database = "dv1663camping"
)

campingCursor = db.cursor()


def visaSelect():
    print()
    resultat = campingCursor.fetchall()
    for x in resultat:
        print(x)
    print()

def visaProcedur():
    sparatResultat = campingCursor.stored_results()
    for resultat in sparatResultat:
        prettyPrint = resultat.fetchall()
        for x in prettyPrint:
            print(x)

def egetSelectStatement():
    egetSelect = input("Skriv ett Select statement här: ")
    try:
        campingCursor.execute(egetSelect)
        visaSelect()
    except:
        print("Detta är inte ett korrekt select statement")

def läggTillEnKund():
    """Lägger till en kund i databasen enligt den lagrade proceduren 'Addkund'"""

    födelseDatum = input("Skriv in födelsedatum på formatet (YYYY-MM-DD): ")
    födelseNummer = input("Skriv in de fyra sista siffrorna i ditt personnummer: ")
    mobilNummer = input("Skriv in ditt mobilnummer på formatet (0123-456789): ")
    email = input("Skriv in din email adress: ")
    förNamn = input("Skriv in ditt förnamn: ")
    efterNamn = input("Skriv in ditt efternamn: ")
    arg = (födelseDatum, födelseNummer, mobilNummer, email, förNamn, efterNamn)

    try:
        campingCursor.callproc('Addkund', arg)
    except:
        print("\n\nLyckades inte lägga till en kund med dessa angivna personuppgifterna.\nKontrollera att alla uppgifterna är korrekta!\n")
    else:
        db.commit()
        print("Registreringen lyckades!")


def läggTillBokningFunktion():
    startDatum = input("Skriv in start datum på formatet (YYYY-MM-DD): ")
    slutDatum = input("Skriv in slut datum på formatet (YYYY-MM-DD): ")
    antalVuxna = int(input("Skriv antalet vuxna: "))
    antalBarn = int(input("Skriv antalet barn: "))
    bokningsId = input("skriv på formatet 'C101' för att boka en campingplats eller 'S101' för att boka en stuga: ")
    födelseDatum = input("Skriv in födelse datum på formatet (YYYY-MM-DD): ")
    födelseNummer = input("Skriv in de sista fyra siffrorna i personnummret (t.ex: 1234): ")
    prisVuxen = int(input("Ange pris för vuxen: "))
    prisBarn = int(input("Ange pris för barn: "))
    print()

    try:
        args = (startDatum, slutDatum, antalVuxna, antalBarn, bokningsId, födelseDatum, födelseNummer, prisVuxen, prisBarn)
        campingCursor.callproc('LäggTillBokning', args)
        db.commit()
    except:
        print("Boendet kunde inte bokas, antingen på grund av att något inmatat värde inte var på rätt format eller att du inte har registrerat dig som kund ännu,\ndå kan du göra det genom att välja 'Lägg till kund'")

def läggTillStuga():
    """Lägger till stuga med lagrad procedur 'AddStuga'"""

    print("\nMata in önskade parametrar till den nya stugan:")
    acceptedValues = False
    attempts = 0
    maxattempts = 3
    while acceptedValues == False and attempts < maxattempts:
        attempts += 1
        try:
            boendeId = input("Ange boendeID på formatet 'S###': ")
            grundPrisPerDag = float(input("Ange grundpris per dag i kronor: "))
            yta = float(input("Ange ytan i kvadratmeter: "))
            spis = input("Ange om spis finns (Ja/Nej): ")
            ugn =  input("Ange om ugn finns (Ja/Nej): ")
            toalett = input("Ange om toalett finns (Ja/Nej): ")
            dusch = input("Ange om dusch finns (Ja/Nej): ")
            antalSängar = int(input("Ange antal sängar i stugan: "))
        except:
            print(f"\nDu har angett felaktig data. Försök nummer {attempts}/{maxattempts} misslyckades.")
            print(f"Tänk på att använda '.' vid inmatning av decimaler.\n")
        else:
            acceptedValues = True
    
    if acceptedValues == True:
        antalBokningar = 0
        arg = (boendeId, grundPrisPerDag, yta, spis, ugn, toalett, dusch, antalSängar, antalBokningar)
        try:
            campingCursor.callproc('AddStuga', arg)
        except:
            print("\nLyckades inte!\nSe över inmatade parametrar.\n")
        else:
            db.commit()
            print("\nStugan är nu tillagd!\n")
    else:
        print("Du har anget felaktig data för många gånger! Återgår...\n")


def läggTillCampingplats():
    """Lägger till campingplats med lagrad procedur 'AddCampingplats'"""

    print("\nMata in önskade parametrar till den nya campingplatsen:")
    acceptedValues = False
    attempts = 0
    maxattempts = 3
    while acceptedValues == False and attempts < maxattempts:
        attempts += 1
        try:
            boendeId = input("Ange boendeID på formatet 'C###': ")
            grundPrisPerDag = float(input("Ange grundpris per dag i kronor: "))
            yta = float(input("Ange ytan för Campingplatsen i kvadratmeter: "))
            el = input("Ange om campingplatsen har el (Ja/Nej): ")
        except:
            print(f"\nDu har angett felaktig data. Försök nummer {attempts}/{maxattempts} misslyckades.")
            print(f"Tänk på att använda '.' vid inmatning av decimaler.\n")
        else:
            acceptedValues = True
    
    if acceptedValues == True:
        antalBokningar = 0
        arg = (boendeId, grundPrisPerDag, yta, el, antalBokningar)    
        try:
            campingCursor.callproc('AddCampingplats', arg)
        except:
            print("\nLyckades inte!\nSe över inmatade parametrar.\n")
        else:
            db.commit()
            print("\nCampingplatsen är nu tillagd!\n")
    else:
        print("Du har anget felaktig data för många gånger! Återgår...\n")


def taBortBokning():
    """Tar bort en bokning med den lagrade funktionen 'AvbokaSCB' (Avboka Stuga eller Campingplats)
    returnerar siffran '1' ifall avbokningen lyckades, annars '0'"""

    print("\nVälj den bokning som du vill ska tas bort:")
    boendeId = input("Ange boendeID på formatet 'C101' för att avboka en campingplats eller 'S101' för att avboka en stuga: ")
    bokningsnummer = input("Ange bokningsnummer: ")
    
    query = "select AvbokaSCB(%s, %s)"
    arg = (boendeId, bokningsnummer)
    try:
        campingCursor.execute(query, arg)
    except:
        print("\nLyckades inte, se över de inmatade värdena att de är korrekta!")
    else:
        result = campingCursor.fetchone()[0]
        db.commit()
        if result == 1:
            print("\nAvbokningen lyckades!")
        else:
            print("\nLyckades inte, se över de inmatade värdena att de är korrekta!\nOBS! Det går inte avboka ifall startdatumet passerats.")


def ärBoendeLedigt():
    startDatum = input("Skriv in start datum på formatet (YYYY-MM-DD): ")
    slutDatum = input("Skriv in slut datum på formatet (YYYY-MM-DD): ")
    boendeId = input("skriv på formatet 'C101' för att boka en campingplats eller 'S101' för att boka en stuga: ")
    try:
        var = "SELECT ledigtBoende(%s, %s, %s)"
        args = (startDatum, slutDatum, boendeId)
        campingCursor.execute(var, args)
        
        tuple = campingCursor.fetchone()
        boendeLedigt = tuple[0]

        if boendeLedigt == -1:
            print("Boende är inte ledigt")
        elif boendeLedigt == 1:
            print("Boende är ledigt")
        else:
            print("BoendeId är på fel format")
    except:
        print("Antingen är datumen eller boende id på fel format")
#select ledigtBoende('2022-03-15','2022-03-19','S101')

def visaBokningarPersonerFödda():
    årtal = input("Skriv 20 för 2000-talet, 201 för 2010-talet o.s.v.: ")
    args = (årtal,)    
    campingCursor.callproc('VisaBokningarAvPersonFödda', args)
    #print("\nBoendeId, Personnummer, Förnamn, Efternamn, Bokningsnummer, Startdatum, Slutdatum, AntalBokningar")
    #visaProcedur()

    print(f"{'BoendeID'}  {'Personnummer':<17} {'Förnamn':<9} {'Efternamn':<12}{'Bokningsnummer':<16}{'Startdatum':<13}{'Slutdatum':<13}{'BokningarPåBoendet'} ")
    sparatresultat = campingCursor.stored_results()
    #print(resultat.fetchall())
    for element in sparatresultat:
        for boendeID, personnummer, förnamn, efternamn, bokningsnummer, startdatum, slutdatum, antalbokningarboendet in element.fetchall():
            print(f"{boendeID:<10}{personnummer:<18}{förnamn:<10}{efternamn:<12}{bokningsnummer:<16}{startdatum}   {slutdatum}   {antalbokningarboendet:<5}")

def visaKunderOlikaÅrtionden():
    #Grupperar antal kunder under olika årtionde
    årtionde = "SELECT * FROM KunderÅrtionde"
    campingCursor.execute(årtionde)
    print("Årtionde, Antal Personer")
    visaSelect()

def visaAntaletBokningarAntalVuxnaÄrTvå():
    campingCursor.execute("SELECT count(*) FROM bokningcamping where AntalVuxna = 2")
    tuple = campingCursor.fetchone()
    antaletBokningar = tuple[0]
    print(f"Antalet bokningar med två vuxna är: {antaletBokningar} st")

def Menu():
    """Valmöjligheter att ställa olika förfrågningar i databasen. Avslutas vid val '0'"""

    print("\nVälkommen till BTHs nya campinplats!\n")
    while True:
        print("Gör ett val i tabellen")
        print("*"*22)
        print("0. Avsluta Programmet")#klar
        print("1. Ange ett eget select statement")#-S
        print("2. Lägg till en kund")#klar-O
        print("3. Lägg till en bokning")#-S
        print("4. Lägg till stuga") #-O
        print("5. Lägg till campingplats")#-O

        print("6. Ta bort bokning")#klar-o
        print("7. Kolla om valt boende är ledigt")#-S
        print("8. Visa bokningar för personer födda ...")#klar-S
        print("9. Visa kunder födda olika årtionden") #Fungerar klar-S
        print("10. Visa antalet bokningar som har två vuxna")
        print(". Visa förutbestämde select statements")

        acceptedValue = False
        while acceptedValue == False:
            val = input("\nVälj vad du vill göra i menyn: ")
            try:
                val = int(val)
            except:
                print(f"Ange en heltalssiffra!\n'{val}' är inte giltigt.")
            else:
                acceptedValue = True
        
        if val==0:
            print("\nProgrammet avslutas...\n")
            break
        elif val == 1:
            egetSelectStatement()
        elif val==2:
            läggTillEnKund()
        elif val == 3:
            läggTillBokningFunktion()
        elif val== 4:
            läggTillStuga()
        elif val == 5:
            läggTillCampingplats()
        elif val == 6:
            taBortBokning()
        elif val == 7:
            ärBoendeLedigt()
        elif val == 8:
            visaBokningarPersonerFödda()
        elif val == 9:
            visaKunderOlikaÅrtionden()
        elif val == 10:
            visaAntaletBokningarAntalVuxnaÄrTvå()
        else:
            print("\n\nAnge ett giltligt val!\n.....")
        
        print("Tryck enter för att se menyn igen.")
        input()

def main():
    Menu()
    if db.is_connected():
        campingCursor.close()
        db.close()

if __name__=="__main__":
    main()

