
load "../max/stzmax.ring"
load "gamelib.ring"

/*-----

pron()

# Qt String is not performant for appending a large
# number of strings (takes a lot of time to append
# 1000000 arabic strings)

# Check it by yourself:

	salem = new QString2()
	for i = 1 to 1_000_000
		salem.append("السّلام عليكم ورحمة الله")
	next

	? ElapsedTime() + NL


# Instead of QString, use QStringList which does
# the job very quickly:

	ResetTimer()

	oQStrList = new QStringLis()
	for i = 1 to 1_000_000
		oQStrList.append("السّلام عليكم ورحمة الله")
	next

# In practice, you would need that QStringList to quickly
# concatenate the list usig the join() method:

	str = oQStrList.join("")

proff()

/*------------

pron()

list = []
for i = 1 to 1_000_000
	list + "السّلام عليكم ورحمة الله"
next

proff()
# Executed in 0.38 second(s) in Ring 1.22

/*------------

pron()

str = ""
for i = 1 to 1_000_000
	str += "السّلام عليكم ورحمة الله"
next
? "Finished"

proff()
# Executed in 44.65 second(s) in Ring 1.22


/*=========== RingAllegro #TODO use it instead of Qt in Softanza

pron()

# Creating a string

	salem = al_ustr_new("السّلام عليكم ورحمة الله")

# Getting the string value
	
	? al_cstr(salem)
	#o--> السّلام عليكم ورحمة الله

# Appending a string with an other string

for i = 1 to 1_000_000
	baraket = al_ustr_new(" و بركاته")
	al_ustr_append(salem, baraket)
next
	al_cstr(salem) ? "finished"

proff()
# Executed in 3.01 second(s) in Ring 1.22

/*
# Getting the size (in bytes) of the string

	? al_ustr_size(salem)
	#--> 60

# Getting the number of chars (lenght) of the string

	? al_ustr_length(salem) + NL
	#--> 32

# removing a range of the string (a substring in fact)

	substr = al_ustr_new("السّلام عليكم و ")
	nLen = al_ustr_size(substr)
	al_ustr_remove_range(salem, 1, nLen)
	al_cstr(salem) ? "Also fine" + NL
//	#o--> رحمة الله و بركاته

# Comparing two strings

	alif = al_ustr_new("ألف")
	bee = al_ustr_new("باء")
	
	? al_ustr_compare(alif, bee)
	#--> -5

proff()
#--> Executed in 1.84 second(s) in Ring 1.22
