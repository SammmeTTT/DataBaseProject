import mysql.connector
#from mysqlx.errors import DatabaseError

#Välkommen till BTHs nya campings bokningssystem

#db.commit(); # apply the changes to the database while insert/delete/update
#showSelect: skriver ut resultatet av en select


# Connect to server on localhost
db = mysql.connector.connect(
    host = "localhost",
    user = "root",
    password = "MySQL23",
    database = "dv1663camping"
)


campingCursor = db.cursor()

#campingCursor.execute("SELECT * FROM bokningcamping where AntalVuxna = 2");
#campingCursor.execute("select ledigtBoende('2022-03-15','2022-03-19','S102')")
#campingCursor.execute("SELECT * FROM KunderÅrtionde")



def showSelect():
    for x in campingCursor:
        print(x)

def egetSelectStatement():
    egetSelect = input("Skriv ett Select statement här: ")
    campingCursor.execute(egetSelect)
    showSelect()

def läggTillEnKund():
    födelseDatum = input("Skriv in födelse datum på formatet (YYYY-MM-DD): ")
    födelseNummer = input("Skriv in de fyra sista siffrorna i ditt personnummer")
    mobilNummer = input("Skriv in ditt mobilNummer")
    email = input("Skriv in din email address")
    förNamn = input("Skriv in ditt förnamn")
    efterNamn = input("Skriv in ditt efternamn")

    kund = f"CALL AddKund({födelseDatum},{födelseNummer},{mobilNummer},{email},{förNamn},{efterNamn})"
    campingCursor.execute(kund)
    db.commit()


def läggTillBokning():
    datumOchTid = input("Skriv in datum och tid du vill boka på formatet (YYYY-MM-DD HH-MM-SS): ")
    startDatum = input("Skriv in start datum på formatet (YYYY-MM-DD): ")
    slutDatum = input("Skriv in slut datum på formatet (YYYY-MM-DD): ")
    antalVuxna = int(input("Skriv antalet vuxna"))
    antalBarn = int(input("Skriv antalet barn"))
    bokningsId = input("skriv på formatet 'C101' för att boka en campingplats eller 'S101' för att boka en stuga: ")
    födelseDatum = input("Skriv in födelse datum på formatet (YYYY-MM-DD): ")
    födelseNummer = int(input("Skriv in de sista fyra siffrorna i personnummret (t.ex: 1234): "))
    prisVuxen = int(input("Ange pris för vuxen"))
    prisBarn = int(input("Ange pris för barn"))

    bokning= f"CALL LäggTillBokning({datumOchTid}, {startDatum}, {slutDatum}, {antalVuxna}, {antalBarn}, {bokningsId}, {födelseDatum}, {födelseNummer}, {prisVuxen}, {prisBarn})"
    #CALL LäggTillBokning('2022-03-12 15:45:00', '2022-03-15', '2022-03-19', 2, 1, 'S101', '1900-10-06', '0123', '250', '100');
    campingCursor.execute(bokning)
    db.commit()


def läggTillStuga():
    boendeId = input("skriv på formatet 'C101' för att boka en campingplats eller 'S101' för att boka en stuga: ")
    grundPrisPerDag = float(input())
    yta = float(input())
    spis = input()
    ugn =  input()
    toalett = input()
    dusch = input()
    antalSängar = int(input())
    antalBokningar = 0

    stuga = f"CALL AddStuga({boendeId}, {grundPrisPerDag}, {yta}, {spis}, {ugn}, {toalett}, {dusch}, {antalSängar}, {antalBokningar})"
    campingCursor.execute(stuga)
    db.commit()

def läggTillCampingplats():
    boendeId = input("skriv på formatet 'C101' för att boka en campingplats eller 'S101' för att boka en stuga: ")
    grundPrisPerDag = float(input("Ange grundpris för campingplats"))
    yta = float(input("Ange yta för Campingplats"))
    el = input("Har campingplats el? (ja/nej)")
    antalBokningar = 0

    campingplats = f"CALL AddCampingplats({boendeId},{grundPrisPerDag},{yta},{el},{antalBokningar})"
    campingCursor.execute(campingplats)
    db.commit()

def taBortBokning():
    ""

def ärBoendeLedigt():
    boendeLedigt = -1
    startDatum = input("Skriv in start datum på formatet (YYYY-MM-DD): ")
    slutDatum = input("Skriv in slut datum på formatet (YYYY-MM-DD): ")
    boendeId = input("skriv på formatet 'C101' för att boka en campingplats eller 'S101' för att boka en stuga: ")
    campingCursor.execute(f"SELECT ledigtBoende({startDatum}, {slutDatum}, {boendeId}) into {boendeLedigt}")
    if boendeLedigt == 0:
        print("Boende är inte ledigt")
    elif boendeLedigt == 1:
        print("Boende är ledigt")


def visaBokningarAvPersonerFödda():
    årtal = input("Skriv 20 för 2000-talet, 201 för 2010-talet osv.")
    visaBokningarFödda = f"CALL VisaBokningAvPersonerFödda({årtal})"
    campingCursor.execute(visaBokningarFödda)
    showSelect()

def visaKunderOlikaÅrtionden():
    årtionde = "SELECT * FROM KunderÅrtionde"
    global campingCursor
    campingCursor.execute(årtionde)
    showSelect()


def Menu():
    print("Välkommen till BTHs nya campinplats!")
    while True:
        print("0. Avsluta Programmet")
        print("1. Ange ett eget select statement")
        print("2. Lägg till en kund")
        print("3. Lägg till en bokning")
        print("4. Lägg till stuga") 
        print("5. Lägg till campingplats")

        print("6. Ta bort bokning")
        print("7. Kolla om valt boende är ledigt") 
        print("8. Visa bokningar för personer födda ...")
        print("Visa kunder födda olika årtionden") #KunderÅrtionde
        print(". Visa förutbestämde select statements")
        print(". Visa förutbestämde select statements")


        val = int(input(" Välj vad du vill göra i menyn:\n "))
        if val==0:
            break
        elif val == 1:
            egetSelectStatement()
        elif val==2:
            läggTillEnKund()
        elif val == 3:
            läggTillBokning()
        elif val== 4:
            läggTillStuga()
        elif val == 5:
            läggTillCampingplats()
        elif val == 6:
            taBortBokning()
        elif val == 7:
            ärBoendeLedigt()
        elif val == 8:
            visaBokningarAvPersonerFödda()
        elif val == 9:
            visaKunderOlikaÅrtionden()
        else:
            print("Ange ett giltligt val...")

def main():
    Menu()

if __name__=="__main__":
    main()

