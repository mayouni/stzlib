load "stzlib.ring"


pron()

? Q(462).PrimeDividors() 
? Q(462).Factors()
proff()

/*----------

pron()

? Q(169).IsPrime()
#--> FALSE

? Q(17).IsPrime()
#--> TRUE

? Q(54).Divirdos()	# Misspelled, but works!

? Q(54).Factors()

? Q(54).PrimeFactors()

proff()
# Executed in 0.03 second(s)

/*----------
Task
StzList -->
Remplimenting FindAll() based on DuplicatesZ()

Task
StzList -->
Writing code for FindNth()


/*-----------

pron()
bigstr = "ring php ruby ring qt csharp ring cobol"
for i = 1 to 3_000_000
	bigstr += "."
next
bigstr += "ring php ruby ring qt csharp ring cobol"

? ELpasedTime() + NL

o1 = new stzString(bigstr)
? o1.FindAllCS("ring", 0)

//? FindAllCS(bigstr, "ring", 0)

proff()

func findAllCS(str, substr, bcase)
    positions = []
    startAt = 0
    foundAt = -1

    oStr = new QString2()
    oStr.append(str)

    while TRUE
	foundAt = oStr.indexOf(substr, startAt, bcase)
	if foundAt != -1
	        positions + foundAt
	        startAt = foundAt + 1
	else
		exit
	ok
    end

    return positions

/*-------
