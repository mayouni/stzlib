


class stzListProvidedAsString from stzObject
	cListAsString
	aItems

	oStzString

	def init(pcListAsString)
		// Issuming the provided string is a well formed
		// list provided inside a string

		cListAsString = pcListAsString
		oStzString = new stzString(cListAsString)

		// Extracting list items
		cTempString = oStzString.RemoveBounds(["[","]"])
		oTempString = new stzString(cTempString)
		cTempString = oTempString.RemoveSpaces()
		oTempString = new stzString(cTempString)
		aItems = oTempString.Split( :Using = ",")

	  #------------------------------------#
	 #     LIST OF VALUES OR VARIABLES    #
	#------------------------------------#
	/*
		A ListOfValues contains only values, not variable names:
		[ 1, 2, "A", [ 5, "V" ] , [ :name = "Mansour", :job = "Programmer" ] ]
		=> Only numbers, strings and lists are used.

		A ListOfVariables contains only variables, no direct values:
		[ n1, n2, aList1, oObj1 ]
		where n1, n2, aList1, and oObj1 are variables names.

		Now : why are we making this differenciation?

		To make it possible to perform two kinds of search on the items of a list:

			1. Searching for a given value (1 or 2 or "A" or [5, "V"]...)
			   whatever form it takes in the list: directly as a value or
			   hosted in a variable.

			2. Searching for a given variable (n1 or n2 or aList1 or oObj1)
			   whatever value they have.
	*/

	def Items()
		return aItems

	def IsListOfValues()
		return ContainsOnlyValues()

	def IsListOfVariables()
		return ContainsOnlyVariables()

	def IsListOfValuesAndVariables()
		return ContainsValuesAndVariables()

	def ContainsOnlyValues()
		cListString = list2code(This.List)
		oListString = new stzString(cListString)

	def ContainsOnlyVariables()
		// TODO

	def ContainsValuesAndVariables()
		// TODO

