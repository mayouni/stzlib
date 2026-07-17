# stzGraphAsciiVisualizer -- the graph's own picture.
#
# This class had no suite, and could not really have one: every line went
# straight to `?`, so the art could only land on a console. Nothing could
# write it to a file, put it in a report, or ASSERT on it -- which is exactly
# how its box glyphs stayed double-encoded for months, printing garbage
# without ever raising. A print is invisible to a test; only a return value
# can be wrong out loud.
#
# So the art is data now (AsciiArt() / AsciiArtHorizontal(), beside Show(),
# which still prints byte for byte), and this asks it the questions a picture
# should answer: are the glyphs the RIGHT codepoints, does the shape follow
# the graph, and does a cycle terminate instead of looping forever.

load "../../stzBase.ring"

nPass = 0
nFail = 0

# the glyphs, named by their codepoint rather than pasted in -- a literal here
# is exactly what got double-encoded in the source this reads
cRoundTL = char(226) + char(149) + char(173)   # U+256D
cRoundTR = char(226) + char(149) + char(174)   # U+256E
cRoundBL = char(226) + char(149) + char(176)   # U+2570
cRoundBR = char(226) + char(149) + char(175)   # U+256F
cHoriz   = char(226) + char(148) + char(128)   # U+2500
cVert    = char(226) + char(148) + char(130)   # U+2502
cArrowUp = char(226) + char(134) + char(145)   # U+2191

pr()

? "-- Scene 1: a chain draws a box per node --"

oA = new stzGraph("chain")
oA.AddNode("a")  oA.AddNode("b")  oA.AddNode("c")
oA.AddEdge("a", "b")  oA.AddEdge("b", "c")

cArt = oA.AsciiArt()
chk("the art comes back as data at all", len(cArt) > 0)
chk("every node is boxed", StzCountCS(cArt, cRoundTL, :CS = TRUE) = 3)
chk("... each box closed at the bottom", StzCountCS(cArt, cRoundBL, :CS = TRUE) = 3)
chk("the boxes have real sides", StzFindFirst(cArt, cVert) > 0)
chk("... and real tops", StzFindFirst(cArt, cHoriz) > 0)
chk("each node's id is in its box",
	StzFindFirst(cArt, "a") > 0 and StzFindFirst(cArt, "b") > 0 and
	StzFindFirst(cArt, "c") > 0)
chk("flow goes DOWN between them", StzFindFirst(cArt, "v") > 0)

? ""
? "-- Scene 2: the glyphs are the RIGHT characters --"

# this is the assertion that would have caught the mojibake: a double-encoded
# corner still prints, it just prints the wrong bytes
chk("the corner is U+256D, not a mangled run",
	StzFindFirst(cArt, cRoundTL) > 0 and StzFindFirst(cArt, char(195)) = 0)
chk("no stray a-circumflex anywhere in the art",
	StzFindFirst(cArt, char(226) + char(130)) = 0)

? ""
? "-- Scene 3: the picture follows the GRAPH --"

# a bottleneck is marked !x! -- b carries all the traffic in a -> b -> c
chk("the bottleneck is marked", StzFindFirst(cArt, "!b!") > 0)
chk("... and a non-bottleneck is not", StzFindFirst(cArt, "!a!") = 0)

oB = new stzGraph("branch")
oB.AddNode("root")  oB.AddNode("left")  oB.AddNode("right")
oB.AddEdge("root", "left")  oB.AddEdge("root", "right")
cBranch = oB.AsciiArt()
chk("a branch draws BOTH children",
	StzFindFirst(cBranch, "left") > 0 and StzFindFirst(cBranch, "right") > 0)
chk("... separated as distinct branches", StzFindFirst(cBranch, "////") > 0)
chk("... and the shared parent carries the up-marker", StzFindFirst(cBranch, cArrowUp) > 0)

? ""
? "-- Scene 4: a cycle TERMINATES --"

oC = new stzGraph("cycle")
oC.AddNode("x")  oC.AddNode("y")
oC.AddEdge("x", "y")
oC.AddEdgeXT("y", "x", "retries")

cCyc = oC.AsciiArt()
chk("the drawing finishes at all (no infinite walk)", len(cCyc) > 0)
chk("the cycle is NAMED rather than redrawn", StzFindFirst(cCyc, "<CYCLE:") > 0)
chk("... and it names the edge that closes it", StzFindFirst(cCyc, "retries") > 0)
chk("the node is referenced, not boxed again", StzFindFirst(cCyc, "[x]") > 0)

? ""
? "-- Scene 5: horizontal is a different picture of the same graph --"

cH = oA.AsciiArtHorizontal()
chk("it draws too", len(cH) > 0)
chk("boxes sit side by side, joined by connectors", StzFindFirst(cH, "---->") > 0)
chk("... with the same three nodes", StzCountCS(cH, cRoundTL, :CS = TRUE) = 3)
chk("and it is NOT the vertical picture", cH != cArt)

? ""
? "-- Scene 6: Show() still prints, unchanged --"

# the art below is what Show() puts on the console -- the return path and the
# print path go through the ONE emitter, so this cannot drift from the above
? ""
oA.Show()

? ""
? "=========================================="
? "TOTAL: " + (nPass + nFail) + " assertions, " + nPass + " pass, " + nFail + " fail"
? "=========================================="

pf()

func chk(cLabel, bCond)
	if bCond
		nPass++
		? "  [OK] " + cLabel
	else
		nFail++
		? "  [FAIL] " + cLabel
	ok
