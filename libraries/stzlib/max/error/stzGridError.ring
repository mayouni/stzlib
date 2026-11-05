func stzGridError(pcError)
	cErrorMsg = "in file stzgrid.ring:" + char(10)

	switch pcError
	on :CanNotDefineRankOfCentralHorizontalLine
		cErrorMsg += "   What : Can't define the rank of the central horizontal line!" + char(10)
		cErrorMsg += "   Why  : The grid has no a central horizontal line because the number of horizontal lines is even." + char(10)
		cErrorMsg += "   Todo : Well, nothing."

	off

	return cErrorMsg + char(10)
