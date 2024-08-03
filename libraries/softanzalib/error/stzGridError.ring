func stzGridError(pcError)
	cErrorMsg = "in file stzgrid.ring:" + NL

	switch pcError
	on :CanNotDefineRankOfCentralHorizontalLine
		cErrorMsg += "   What : Can't define the rank of the central horizontal line!" + NL
		cErrorMsg += "   Why  : The grid has no a central horizontal line because the number of horizontal lines is even." + NL
		cErrorMsg += "   Todo : Well, nothing."

	off

	return cErrorMsg + NL
