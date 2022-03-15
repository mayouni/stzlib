load "stzlib.ring"

? UnicodeNames()

#? StzSetQ([ 7, 3, 5, 7, 7, 9, 2, 6, 2 ]).Content()
/*
? StzListOfNumbersQ([ 7, 3, 5, 9, 2, 6, 2 ]).Min()
? StzListOfNumbersQ([ 7, 3, 5, 9, 2, 6, 2 ]).Max()

/*
for c in LocaleScriptsXT()
	? c[2]
next
/*
// Getting upper text in native Ring
? upper("Πόλη") # returns the same string, which is incorrect
		# In fact, in Greece, the upper should be ΠΌΛΗ

// Getting upper text using StzLib
o1 = new stzString("Πόλη")
o1 {
	# Sets the current local to the Greek language in Greece
	SetLocale(:Country = :Greece) # or SetLocale(:Language = :Greek)
	ToUpper() } # returns ΠΌΛΗ
}



/*
? localescripts()
? unicodescriptsXT()
