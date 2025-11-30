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

# Creating a stkChar object from Qt QChar object

oQChar = new QChar(30899)
? classname(oQChar)
#--> qchar

o1 = new stkChar(oQChar)
? o1.Content()
#--> 碳

pf()
# Executed in 0.002 second(s) in Ring 1.22

/*---

pr()

# The stzCoreChar object give you access to all QChar methods
# supported in RingQt. To call them, use the Qt() small function:

o1 = new stkChar("ض")
? o1.Qt().category()
#--> 18

# Unlike the more elaborated Softanza BASE layer, where category()
# returns an expressive lable (:arabic_char), what we get here
# is what Qt provides as, a number 18.

# To deal with it, read this Qt documentation entry:
# List here: https://doc.qt.io/qt-5/qchar.html#Category-enum

# Also, to stay minimalistic, SoftanzaCore won't include its own
# alternative to an existing Qt method, if this method obyes to
# semantic style and mental model provided by Softanza.

# Hence, there is no need to inculde an isLetter() method (working
# directly against the object as o1.IsLetter), because it's quiet	
# simply to do it in pure Qt:

? o1.Qt().isLetter()
#--> TRUE

? o1.Qt().IsLetterOrNumber()
#--> TRUE

pf()
# Executed in 0.001 second(s) in Ring 1.22

/*---

pr()

# SoftanzaCore offers a direct way to get the unicode codepoint
# (in decimal) of a given char:


o1 = new stkChar("🞖")
? o1.Unicode()
#--> 55357

# If you would make it in Qt, it will be as tricky as:

	oQStr = new QString2()
	oQStr.append("🞖")
	? oQStr.unicode().unicode()

# since we don't have a way do get it directly from QChar object.

# I made this sample to show that, unlike more generous Softanza BASE layer,
# Softanza CORE invests in enhancing RingQt only when required.

#NOTE For technical reasons, we permit the parameter to be a string not a char
o1 = new stkChar("mansour")
? o1.Content()
#--> m

pf()
# Executed in 0.001 second(s) in Ring 1.22

# In this case, the remaing part is ignored.

/*--- Major Qt() methods ssupported in RingQt QChar class
*/
pr()

o1 = new stkChar("r")
? o1.Qt().isLower()
#--> TRUE

o1 = new stkChar(1617)
? o1.Qt().isMark() # Arabic shaddah
#--> TRUE

o1 = new stkChar(65534)
? o1.Qt().isNonCharacter()
#--> TRUE

o1 = new stkChar("")
? o1.Qt().isNull()
#--> TRUE

o1 = new stkChar("9")
? o1.Qt().isNumber()
#--> TRUE

o1 = new stkChar("M")
? o1.Qt().isPrint()
#--> TRUE

o1 = new stkChar(65534)
? o1.Qt().isPrint()
#--> FALSE

o1 = new stkChar(";")
? o1.Qt().isPunct()
#--> TRUE

o1 = new stkChar(" ")
? o1.Qt().isSpace()
#--> TRUE

o1 = new stkChar("T")
? o1.Qt().isUpper()
#--> TRUE

o1 = new stkChar("༺")
? o1.Mirrored()
#--> ༻

o1 = new stkChar("ص")
? o1.Qt().script()
#--> 8
# List of scripts: https://doc.qt.io/qt-5/qchar.html#Script-enum

o1 = new stkChar("༺")
? o1.Qt().unicodeVersion()
#--> 2

o1 = new stkChar("༺")
? o1.Qt().direction()
#--> 10
# List of directions: https://doc.qt.io/qt-5/qchar.html#Direction-enumerate

o1 = new stkChar("5")
? o1.Qt().isdigit()
#--> TRUE

pf()
# Executed in 0.004 second(s) in Ring 1.22
