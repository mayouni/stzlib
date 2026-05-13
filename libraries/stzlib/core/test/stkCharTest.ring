#----------------------------#
#  LOADING THE CORE LIBRARY  #
#----------------------------#

# You either load the hole SoftanzaCore library (all classes)

	load "../stklib.ring" # or /stzcore.ring to be expressive

# Or just the files you actually need
/*
	load "lightguilib.ring"

	load "../object/stkobject.ring"
	load "../string/stkchar.ring"

	load "../error/stkerror.ring"
	load "../common/stkprofiler.ring"
	load "../common/stkringfuncs.ring"
*/
#----------------#
#  TEST SAMPLES  #
#----------------#

decimals(3)
t0 = clock()

/*----

pr()

# Creating a stkCoreChar object from its unicode

o1 = new stkChar(30899) # Or stzCoreChar() to be more expressive
? o1.Content()
#--> 碳

# Creating a stzCoreChar from the char litteral

o1 = new stkChar("碳")
? o1.Unicode()
#--> 30899

# Creating a stkChar from its unicode codepoint

o1 = new stkChar(30899)
? o1.Content()
#--> 碳

? o1.Unicode()
#--> 30899

pf()
# Executed in 0.002 second(s) in Ring 1.22

/*---

pr()

# The Engine provides char classification via StkEngineChar* functions:

o1 = new stkChar("ض")
? o1.IsLetter()
#--> TRUE

? o1.Unicode()
#--> 1590

pf()
# Executed in 0.001 second(s)

/*---

pr()

# SoftanzaCore offers a direct way to get the unicode codepoint
# (in decimal) of a given char:


o1 = new stkChar("🞖")
? o1.Unicode()
#--> 55357

# The Engine handles this directly via StkEngineCharUnicode(),
# making unicode access simple and Qt-free.

#NOTE For technical reasons, we permit the parameter to be a string not a char
o1 = new stkChar("mansour")
? o1.Content()
#--> m

pf()
# Executed in 0.001 second(s) in Ring 1.22

# In this case, the remaing part is ignored.

/*--- Engine-based char classification tests
*/
pr()

o1 = new stkChar("r")
? o1.IsLower()
#--> TRUE

? o1.IsLetter()
#--> TRUE

o1 = new stkChar("T")
? o1.IsUpper()
#--> TRUE

? o1.IsLetter()
#--> TRUE

o1 = new stkChar("5")
? o1.IsDigit()
#--> TRUE

? o1.IsLetter()
#--> FALSE

o1 = new stkChar(" ")
? o1.IsLetter()
#--> FALSE

? o1.IsDigit()
#--> FALSE

pf()
# Executed in 0.001 second(s)
