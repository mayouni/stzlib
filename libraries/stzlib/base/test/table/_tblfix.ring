# Shared fixtures of the stzTable defect guards (t03 onwards). Only functions: load it at the top.
#
#   M3()   a 3 x 3 table    a = 1 4 7    b = 2 5 8    c = 3 6 9
#   M4()   a 4 x 2 table    a = x z x r  b = y w q y
#   MW()   a 3 x 2 table    name = Andy Ali Alia    job = Maestro Abraham Ali   (texts that contain texts)
#   Does(cCode)         the value of an expression, written, or "RAISES"; the code sees o (3 x 3), o4 (4 x 2) and ow (MW)
#   After(cCode, cShow) run a mutator on fresh o, o4 and ow, then write what cShow gives, or "RAISES"
#   Tn(text, got, expected)  Then() with ' standing for " in the expected text

func M3()
	return new stzTable([ [ :A, :B, :C ], [ 1, 2, 3 ], [ 4, 5, 6 ], [ 7, 8, 9 ] ])

func M4()
	return new stzTable([ [ :A, :B ], [ "x", "y" ], [ "z", "w" ], [ "x", "q" ], [ "r", "y" ] ])

func MW()
	return new stzTable([ [ :NAME, :JOB ], [ "Andy", "Maestro" ], [ "Ali", "Abraham" ], [ "Alia", "Ali" ] ])

func Does(cCode)
	cOut = ""
	try
		eval("o = M3()" + nl + "o4 = M4()" + nl + "ow = MW()" + nl + "xr = " + cCode + nl + "cOut = @@(xr)")
	catch
		cOut = "RAISES"
	done
	return cOut

func After(cCode, cShow)
	cOut = ""
	try
		eval("o = M3()" + nl + "o4 = M4()" + nl + "ow = MW()" + nl + cCode + nl + "cOut = @@(" + cShow + ")")
	catch
		cOut = "RAISES"
	done
	return cOut

func Tn(cText, xActual, xExpected)
	Then(cText, xActual, substr(xExpected, "'", char(34)))
