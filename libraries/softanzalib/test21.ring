
o1 = new Book

o1 {
	# Setting information

	SetTitle("Borhen book") 
	SetAuthor("Mazen cherif")
	SetEdition(3)
	SetNumberOfPages(1000)

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

	? @title
	? @price

}

//////////////////////

class Book
	@title
	@author
	@edition
	@NumberOfPages

	// Setting object data

	def SetTitle(cTitle)
		
		@title = cTitle

	def SetAuthor(cAuthor)
		@author = cAuthor

	def SetEdition(nEdition)
		@edition = nEdition

	def SetNumberOfPages(n)
		@NumberOfPages = n

	// Getting object data

	def title()
		return @title

	def author()
		return @author

	def edition()
		return @edition

	def NumberOfPages()
		return @NumberOfPages

	// Chaging the object data

	def AddPages(n)
		 @NumberOfPages = @NumberOfPages + n

	def RemovePages(n)
		 @NumberOfPages = @NumberOfPages - n

	//////////////////////////////////

	PRIVATE

	@price


