load "SoftanzaLib.ring"

o1 = new stzString("00120")
? o1.TrimCharFrom("0",:LeftAndRight)


// StzSemantics.ring
func SameAs(paSynonyms)
	
func ReverseOf(pValue)
	switch pValue
	on TRUE  	return FALSE
	on FALSE 	return TRUE

	on :Left 	return :Right
	on :Right 	return :Left

	on :Min 	return :Max
	on :Max 	return :Min

	on :Up 		return :Down
	on :Down 	return :Up

	on :With 	return :Without
	on :Without 	return :Many

	on :All		return :None
	on :None	return	:All
	off
