# doc_vlm_tsv.ring -- the prediction files of _rig/doc_vlm_run.ring, read and written (IM7, :doc-vlm).
# One line per block: kind, level, text (a table's rows joined by U+001E, its cells by U+001F); a backslash, a tab and a
# newline in a text are written \\, \t and \n -- the format of base/test/document/_doc_score.py. Loaded by the runner
# and by the guard from base/test/image.

func BlocksFromTsv(cPath)
	aOut = []
	aL = StzSplit(read(cPath), char(10))
	for i = 1 to len(aL)
		if aL[i] = "" loop ok
		aF = StzSplit(aL[i], char(9))
		if len(aF) < 3 loop ok
		if aF[1] = "table"
			aRows = []
			aR = StzSplit(aF[3], char(30))
			for r = 1 to len(aR)
				aCells = StzSplit(aR[r], char(31))
				for c = 1 to len(aCells)
					aCells[c] = Unesc(aCells[c])
				next
				aRows + aCells
			next
			aOut + [ :kind = "table", :level = 0, :text = "", :rows = aRows ]
		else
			aOut + [ :kind = aF[1], :level = 0 + aF[2], :text = Unesc(aF[3]), :rows = [] ]
		ok
	next
	return aOut

func Unesc(c)
	if len(StzFind("\", c)) = 0 return c ok
	cOut = ""
	n = len(c)
	i = 1
	while i <= n
		if c[i] = "\" and i < n
			cN = c[i + 1]
			if cN = "t" cOut += char(9)
			but cN = "n" cOut += char(10)
			else cOut += cN ok
			i += 2
		else
			cOut += c[i]
			i++
		ok
	end
	return cOut

func Tsv(aB)
	cTsv = ""
	for j = 1 to len(aB)
		if aB[j][:kind] = "table"
			cRows = ""
			for r = 1 to len(aB[j][:rows])
				if r > 1 cRows += char(30) ok
				aRow = aB[j][:rows][r]
				for c = 1 to len(aRow)
					if c > 1 cRows += char(31) ok
					cRows += Esc(aRow[c])
				next
			next
			cTsv += "table" + char(9) + "0" + char(9) + cRows + char(10)
		else
			cTsv += aB[j][:kind] + char(9) + aB[j][:level] + char(9) + Esc(aB[j][:text]) + char(10)
		ok
	next
	return cTsv

func Esc(c)
	c = StzReplace(c, "\", "\\")
	c = StzReplace(c, char(9), "\t")
	c = StzReplace(c, char(10), "\n")
	return c
