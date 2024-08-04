
# For optimisation reasons, especially when used in embedded platforms
# with constrained resources (like RasperryPI and MS-DOS, both supported
# by Ring), SoftanzaCore library uses numbers to codify errors.

func StkError(cErr)

	switch cErr
	on :IncorrectParamType
		return 1

	on :IncorrectParamValue
		return 2

	on :UnsupportedOperator
		return 3
	off

	func StzCoreError(cErr)
		return StkError(cErr)
