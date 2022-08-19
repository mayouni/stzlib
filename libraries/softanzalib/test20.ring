
o1 = new Book

o1 {
	# Setting information

	title 		= "Kiteb El Borhen"
	author		= "Mazen cherif"
	edition		= 3
	NumberOfPages	= 1000

	# Getting information

	? title()		#--> "Kiteb El Borhen"	# OK
	? author()		#--> "Mazen cherif"	# OK
	? edition()		#--> 3

	? NumberOfPages()	#--> 1000

	# Adding pages

	AddPages(20)		#--> NULL
	? NumberOfPages()	#--> 1020

	AddPages(10)
	? NumberOfPages()	#--> 1030

	# Remving pages
	RemovePages(10)
	? NumberOfPages()	#--> 1020

}

//////////////////////

class Book

	title
	author
	edition
	NumberOfPages
	
	def title()
		return title

	def author()
		return author

	def edition()
		return edition

	def NumberOfPages()
		return NumberOfPages
	
	def AddPages(n)
		 NumberOfPages = NumberOfPages + n

	def RemovePages(n)
		 NumberOfPages = NumberOfPages - n




