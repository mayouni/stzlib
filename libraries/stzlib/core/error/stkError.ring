
# For optimisation reasons, especially when used in embedded platforms
# with constrained resources (like RasperryPI and MS-DOS, both supported
# by Ring), SoftanzaCore library uses numbers to codify errors.

# The numbers convey a classification of errors by category. For example,
# errors from 1 to 9 are related tt PARAMS, from 10 to 19 to OBJECTS CREATION,
# and so on. #TODO: Rethink this classification.

func StkError(cErr)

	switch cErr

	# ~~~ PARAMS ~~~

	on :IncorrectParamType
		return 1

	on :IncorrectParamValue
		return 2

	on :IncorrectNumberOfParams
		return 3

	# ~~~ OBJECTS CREATION ~~~

	on :CanNotCreateObject
		return 10

	# ~~~ OPERATORS ~~~

	on :UnsupportedOperator
		return 20

	# ~~~ RANGES ~~~

	on :OutOfRangeValue
		return 30

	# ~~~ NUMBER ~~~

	on :DivisionByZero
		return 40

	off


	func StzCoreError(cErr)
		return StkError(cErr)
