load "stzlib.ring"

/*-------------------

cCode = "
	for i=1 to 100_000_000
		i * 200
	next i
"
? ExecutionTime(cCode, :InSecondsAndClocks)

/*-------------------

? WaitForNMinutes(0.25)

/*-------------------
