load "stzlib.ring"

? UnicodeToChar(107)

/*
? MaxCalculableNumber()

/*--------------

decimals(90)
n1 = 12.34
? n1

/*--------------

# In Ring, it is possible to define a global function
# and then use the same name to define a method inside
# an object (doesn't work for native functions!)

? datatype(5)

o1 = new thing(5)
? o1.datatype()

func datatype(v)
	return lower(type(v))

class thing
	value
	def init(p)
		value = p
	def datatype()
		return lower(type(value))

/*--------------

? _(5).@.DataType()
? _("Ring").@.DataType()
? _(1:3).@.DataType()

obj = new Person { name = "Nehro" }
? _(obj).@.DataType()

class Person name
/*

? _([ "a", 2, 3, "a", 5, "a" ]).@.FindAllOccurrencesOf("a")

/*
aList = [ "=", 7, "&", "_", 7, "@", 7 ]
? find( aList, 7)

bFoundSomething = FALSE

anResult = []
while bFoundSomething
	
	n = find(aList, 7)
	if n = 0
		bFoundSomething = FALSE
	else
		anResult + n
		if n < oList.NumberOfItems()
			aList = oList.Section( n+1, :end )
		else
			exit
		ok
	ok

end

? anResult
