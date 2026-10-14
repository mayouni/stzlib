


# Holds a list that was provided as text, such as '[ 1, 2, "A" ]', to tell values from variable names; unfinished today.
#
# The idea, from the comment in its file: a list written as text can hold values (1, "A", [ 5, "V"
# ]) or variable names (n1, aList1), and a search must be able to look for a value wherever it is
# hosted or for a variable whatever its value. Today the class does not deliver it: Items answers an
# empty list for every text, ContainsOnlyValues and IsListOfValues raise error R12, and the three
# other tests are empty stubs answering an empty text. To evaluate a list written as text use
# stzListInString, which turns it into a real list.
#
#   receiver   o1 = new stzListProvidedAsString('[ 1, 2, "A" ]')
#   example    ? @@( o1.Items() )
#              #--> [ ]
#   see        stzListInString, stzList
class stzListProvidedAsString from stzObject
	_cListAsString_
	_aItems_

	_oStzString_

	# Builds the object from a text that spells a list, such as '[ 1, 2, "A" ]', and tries to split out its items.
	#
	#   pcListAsString   the text that spells the list, assumed well formed and in square brackets
	#   returns          nothing; the object is built, with an empty item list today
	#   warning          The items are always empty today: init uses the answer of
	#                    RemoveTheseBounds, which changes the text in place and answers nothing, so
	#                    the text it splits is empty; the text is not validated either
	#   see              Items
	def init(pcListAsString)
		// Issuming the provided string is a well formed
		// list provided inside a string

		_cListAsString_ = pcListAsString
		_oStzString_ = new stzString(_cListAsString_)

		// Extracting list items
		_cTempString_ = _oStzString_.RemoveTheseBounds("[","]")
		_oTempString_ = new stzString(_cTempString_)
		_cTempString_ = _oTempString_.RemoveSpaces()
		_oTempString_ = new stzString(_cTempString_)
		_aItems_ = _oTempString_.Split( :Using = ",")

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

	# Returns the items of the list text as pieces of text, split at the commas, with spaces removed.
	#
	#   returns    a list of texts; [ ] today whatever the text, see init
	#   warning    Answers [ ] for every text today, '[ 1, 2, "A" ]', '[ n1, n2 ]' and '[ [1,2], 3
	#              ]' included, because init extracts nothing; a comma inside a quoted text would
	#              also split it
	#   see        IsListOfValues
	def Items()
		return _aItems_

	# Raises error R12 today instead of telling whether the list text holds only values and no variable names.
	#
	#   returns    nothing today: it raises error R12
	#   warning    Raises error R12 (property not found: list) today instead of TRUE or FALSE,
	#              because ContainsOnlyValues reads a property that does not exist
	#   see        IsListOfVariables, ContainsOnlyValues
	def IsListOfValues()
		return ContainsOnlyValues()

	# Returns an empty text today instead of telling whether the list text holds only variable names and no values.
	#
	#   returns    an empty text today, never TRUE or FALSE
	#   warning    Not implemented: ContainsOnlyVariables is an empty TODO stub, so the answer is ""
	#              whatever the text, and a test on it is always false
	#   see        IsListOfValues, ContainsOnlyVariables
	def IsListOfVariables()
		return ContainsOnlyVariables()

	# Returns an empty text today instead of telling whether the list text mixes values and variable names.
	#
	#   returns    an empty text today, never TRUE or FALSE
	#   warning    Not implemented: ContainsValuesAndVariables is an empty TODO stub, so the answer
	#              is "" whatever the text
	#   see        IsListOfValues, ContainsValuesAndVariables
	def IsListOfValuesAndVariables()
		return ContainsValuesAndVariables()

	# Raises error R12 today instead of telling whether the list text holds only values, such as numbers, texts and lists.
	#
	#   returns    nothing today: it raises error R12
	#   warning    Raises error R12 (property not found: list) today, because its first line reads
	#              This.List, a property the class does not have
	#   see        IsListOfValues
	def ContainsOnlyValues()
		_cListString_ = list2code(This.List)
		_oListString_ = new stzString(_cListString_)

	# Returns an empty text today instead of telling whether the list text holds only variable names.
	#
	#   returns    an empty text today, never TRUE or FALSE
	#   warning    Not implemented: the body is a TODO comment, so the answer is "" whatever the
	#              text
	#   see        IsListOfVariables
	def ContainsOnlyVariables()
		// TODO

	# Returns an empty text today instead of telling whether the list text holds both values and variable names.
	#
	#   returns    an empty text today, never TRUE or FALSE
	#   warning    Not implemented: the body is a TODO comment, so the answer is "" whatever the
	#              text
	#   see        IsListOfValuesAndVariables
	def ContainsValuesAndVariables()
		// TODO

