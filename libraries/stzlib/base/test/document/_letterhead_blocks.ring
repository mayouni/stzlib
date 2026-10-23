# _letterhead_blocks.ring -- list the top-band blocks of page 1 of every PDF of a golden set, with their features.
#
#     ring _letterhead_blocks.ring <golden dir> <out tsv>
#
# One line per block: id, text (backslash, tab and newline escaped), ratio, largest (1/0), rank, reader.
# _letterhead_label.py then labels each block from the golden set's own furniture lists.

load "../../stzBase.ring"
decimals(2)

cGolden = sysargv[3]
cOut = sysargv[4]
aFiles = dir(cGolden)
cTsv = ""
for i = 1 to len(aFiles)
	cName = aFiles[i][1]
	if right(lower(cName), 4) != ".pdf" loop ok
	cId = left(cName, len(cName) - 4)
	aTop = StzPdfTopBlocks(StzPdfQ(cGolden + "/" + cName))
	for j = 1 to len(aTop)
		r = aTop[j]
		nL = 0
		if r[:largest] nL = 1 ok
		cTsv += cId + char(9) + _Esc(r[:text]) + char(9) + r[:ratio] + char(9) + nL + char(9) + r[:rank] + char(9) + r[:reader] + char(10)
	next
next
write(cOut, cTsv)
? "blocks written"

func _Esc(c)
	c = StzReplace(c, "\", "\\")
	c = StzReplace(c, char(9), "\t")
	c = StzReplace(c, char(10), "\n")
	return c
