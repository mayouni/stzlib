#==============================================================#
#  STZDRAKONNOTATION -- DN6, and the kill measured before code  #
#==============================================================#

/*--- WHY DRAKON, AND WHY IT IS THE PLANE'S NEXT DOMAIN RATHER THAN
	ANOTHER NOTATION ON THE PILE.

	DRAKON is the visual language built for the Buran space programme and
	kept since; the Principal named it "the best visual language for
	designing any diagram", to be embraced as a first-class citizen. Its
	three governing ideas are laws about READING, not about drawing:

	    the skewer      one vertical line carries the main path
	    no crossings    guaranteed by construction, not by a router
	    happy path left the normal case is the leftmost line, and
	                    horizontal distance measures how unusual a
	                    branch is

	The third is the one this library already discovered the hard way.
	The Principal ruled, over several sessions of marked-up pictures,
	that the affirmative branch continues down the main line and the
	refusal steps aside -- which is DRAKON's law arrived at from the
	other end, by looking at pictures that were wrong. DN6 is where it
	stops being a rule this plane patched in and becomes the law a
	notation declares.

--- THE KILL CRITERION, AND THE MEASUREMENT THAT ANSWERED IT.

	The plane's discipline is that a domain states what would kill it
	before any code is written, and measures.

	    KILL: DRAKON's no-crossing guarantee is not free -- it comes from
	    the source being a STRUCTURED algorithm, so that every path can
	    be laid on vertical skewers with only downward flow. A general
	    directed graph carries no such guarantee: an IRREDUCIBLE flow
	    graph cannot be drawn as skewers without either a crossing or
	    duplicating a node. If the models this plane actually holds are
	    irreducible, a DRAKON profile would either draw crossings in a
	    notation that forbids them, or refuse most real models -- and the
	    domain waits for the model to grow.

	MEASURED over every model in the plane's own fixtures, by extracting
	the edge lists and running the standard T1/T2 collapse:

	    models (weakly connected, 3+ nodes)      139
	      containing a cycle                      52
	      with exactly one entry                 110
	      REDUCIBLE once given a single entry    117
	      genuinely IRREDUCIBLE                    0

	The kill does NOT fire. Every flow model this plane holds is
	skewer-expressible. The remaining 22 have no entry node at all --
	they are circuits and ring lifecycles, which are not algorithms and
	are outside DRAKON's scope by construction, not by failure.

	THE INSTRUMENT TOOK THREE PASSES AND THE FIRST TWO WERE WRONG, which
	is worth recording because the wrong answers were plausible. Pass one
	read a variable name per file, so scenes that reuse `_o_` merged into
	one graph and a FOREST failed the collapse test; it reported 117 of
	140. Pass two split by connected component and reported 7
	irreducible -- all of them ACYCLIC, which is impossible, since an
	acyclic flow graph is always reducible. That impossibility is what
	exposed the real cause: those 7 have several roots, and T2 needs a
	unique predecessor, so a multi-entry DAG fails for a reason that has
	nothing to do with control flow. A DRAKON diagram BEGINS somewhere,
	so pass three gives each root a virtual entry -- which is what a
	Title icon is -- and asks the question the criterion actually meant.

--- WHAT THIS PROFILE DECLARES, AND WHAT IT REFUSES.

	The vocabulary is DRAKON's icon set mapped onto glyphs the renderer
	already draws, which is DN0's rule for what a glyph is. The
	distinctive one is not a glyph at all: SetBranchSide(:Right) is the
	skewer law, and it is declared here rather than coded into the
	layout, because "there is a normal path" is a claim about the DOMAIN.
	An org chart's siblings are peers and keep the plane's two-sided law
	untouched.

	REFUSED, and each is a rule rather than a convention:

	  - nothing enters the Title. It is where the algorithm begins, and
	    an arrow into it would say there is somewhere earlier.
	  - nothing leaves the End, for the mirror reason.
	  - a Question has exactly two exits. DRAKON's rhombus is a yes/no
	    icon; three answers is a Select, which is a different icon with
	    a different law.

--- WHAT IS NOT DONE, named rather than left to be found.

	The SILHOUETTE -- DRAKON's form for a large algorithm, where several
	skewers stand side by side each under its own header and control
	jumps from the foot of one to the head of another. This profile
	builds the PRIMITIVE, the single-skewer form, which is what every
	fixture in this plane is. The silhouette is a second layout mode and
	is named in the plan.
*/

func StzDrakonNotation()
	_o_ = StzNotation("drakon")
	if _o_.Name_() = "drakon"  return _o_  ok
	_o_ = new stzNotation("drakon")
	_o_.SetRankDir(:TopDown)
	_o_.SetSplines(:ortho)

	# THE SKEWER. The happy path holds the main line -- the plane already
	# owns that rule and DRAKON is where it is finally declared instead
	# of inferred -- and every alternative stands to the RIGHT of it, so
	# that distance from the line measures distance from the normal case.
	_o_.SetSpine(:HappyPath)
	_o_.SetBranchSide(:Right)

	# THE ICONS, each mapped to a shape the renderer already draws.
	_o_.AddKindXT("title", "ellipse", "#eef2ff")
	_o_.AddKindXT("end", "ellipse", "#eef2ff")
	_o_.AddKindXT("action", "box", "white")
	# THE QUESTION IS A HEXAGON, AND THE BOOK SAYS SO IN ONE SENTENCE:
	# "Note that the If icon is a hexagon, not a diamond like its
	# flowchart counterpart. The hexagon shape saves vertical space on
	# the diagram."
	#
	# This profile drew a rhombus. That is not a near miss -- it is the
	# glyph DRAKON exists to replace, and the language's own teaching
	# picture is captioned "an old messy flowchart" beside "a modern
	# DRAKON flowchart", with the diamonds on the left and the hexagons
	# on the right. Every DRAKON diagram this plane has published so far
	# announced itself as the thing being argued against.
	_o_.AddKindXT("question", "hexagon", "#fff7e6")
	# ...AND THE SELECT IS NOT THE SAME ICON AS THE QUESTION. A Switch
	# is "one Select icon that contains a question" and two or more Case
	# icons; drawing the Select as an If says the reader may answer it
	# yes or no.
	_o_.AddKindXT("select", "parallelogram", "#fff7e6")
	# THE QUESTION IS WRITTEN IN THE RHOMBUS, which is what makes it
	# read as a decision rather than as a marker with a caption. The
	# plane writes a name UNDER a diamond because a diamond is usually
	# a small mark; DRAKON sizes it to the question, so it holds it.
	_o_.SetNameInside("question")
	_o_.SetNameInside("select")
	# A CASE IS NOT AN ACTION, and drawn as one it claims to be.
	#
	# Both were rounded boxes, so a picture of a three-way choice read
	# as a step followed by a step: the icon that NAMES an alternative
	# and the icon that DOES something were the same glyph, and only the
	# wires said which was which. DRAKON draws the case with its lower
	# corners cut, so it reads as one of several openings beneath the
	# selector -- narrower at the foot, where the one path out leaves.
	_o_.AddKindXT("case", "invhouse", "#fff7e6")
	# an insertion is a call to another algorithm: the component glyph
	# is the table's nearest reading, a body with something attached
	_o_.AddKindXT("insertion", "component", "white")
	_o_.AddKindXT("shelf", "tab", "white")
	_o_.AddKindXT("input", "parallelogram", "white")
	_o_.AddKindXT("output", "parallelogram", "white")
	_o_.AddKindXT("timer", "hexagon", "#f3f4f6")
	_o_.AddKindXT("pause", "hexagon", "#f3f4f6")
	_o_.AddKindXT("comment", "note", "#fffbe6")

	# THE SILHOUETTE'S TWO ICONS -- DN6b.
	#
	# A large algorithm does not fit one skewer, and DRAKON's answer is
	# not a longer picture: it is several skewers side by side, each
	# under its own NAME, with control leaving the foot of one and
	# resuming at the head of another. The transfer is written, not
	# drawn -- an ADDRESS names where control goes, and that is why a
	# silhouette has no long connecting lines to cross.
	#
	# The branches are named by the AUTHOR, not derived. That is the
	# plane's doctrine (the author writes MEANING, the layout owns
	# geometry) and it is also DRAKON's: a branch is a phase of the
	# algorithm with a name a reader recognises, and no decomposition
	# computed from the graph knows what to call it.
	# ...AND THE ICONS THE REFERENCE ENGINE HAS THAT THIS PROFILE DID
	# NOT. Read from DrakonWidget's own item list rather than from
	# memory of DRAKON's pictures: action, address, branch, case, end,
	# header, question, select, foreach, insertion, comment, parblock,
	# par, timer, pause, duration, shelf, process, input, output,
	# ctrlstart, ctrlend.
	#
	# FOREACH IS THE ONE THAT MATTERED. A language for algorithms
	# without a LOOP icon is not that language, and this profile had
	# none -- a gap invisible from the pictures I had been correcting,
	# because none of them looped.
	# ...AND NOT AS A HEXAGON, WHICH IS THE IF ICON'S SHAPE. Once the
	# question became the hexagon the book requires, the loop was
	# wearing it too -- two icons, one glyph, in the language whose
	# whole claim is that a reader never has to work out which is which.
	#
	# NAMED AND NOT DONE: DRAKON's FOR is genuinely TWO icons, Begin For
	# and End For, with the repeated work standing between them -- "the
	# For icon is actually two icons". This profile has one, so it can
	# say a loop exists and cannot yet say where its body ends. The
	# trapezium is the icon table's shape for the pair's opening half.
	_o_.AddKindXT("foreach", "trapezium", "#eef2ff")
	# ...AND IT HOLDS ITS OWN NAME. "for each line" is the loop, not a
	# caption near it -- written outside it landed on the loop's own
	# return wires, which is the same defect the question had.
	_o_.SetNameInside("foreach")
	_o_.AddKindXT("process", "box", "white")
	_o_.AddKindXT("duration", "hexagon", "#f3f4f6")
	_o_.AddKindXT("par", "box", "#f5f3ff")
	_o_.AddKindXT("parblock", "tab", "#f5f3ff")
	_o_.AddKindXT("ctrlstart", "circle", "#eef2ff")
	_o_.AddKindXT("ctrlend", "doublecircle", "#eef2ff")
	# the reference engine calls the two ends HEADER and END, and draws
	# them alike; "title" is kept as the name this profile shipped with
	_o_.AddKindXT("header", "ellipse", "#eef2ff")

	# EVERY ICON THAT CARRIES TEXT CARRIES IT INSIDE ITSELF.
	#
	# Declared one at a time as each picture showed a name outside, which
	# is why the list was three long and wrong: the rhombus was declared
	# because the Principal marked it, the loop because its name landed
	# on its own return wires -- and the input icon went on writing
	# "Read credentials" underneath an empty parallelogram in the very
	# first fixture, unmarked and unnoticed, for as long as this profile
	# has existed.
	#
	# In DRAKON a name outside an icon is not a variant, it is a
	# different statement: the icons are the sentences and a word beside
	# one is a note about it. So the question is not which icons happen
	# to look wrong, it is which icons SAY something -- and the answer is
	# all of them except the two control marks, which are punctuation.
	_o_.SetNameInside("action")
	_o_.SetNameInside("input")
	_o_.SetNameInside("output")
	_o_.SetNameInside("insertion")
	_o_.SetNameInside("shelf")
	_o_.SetNameInside("process")
	_o_.SetNameInside("case")
	_o_.SetNameInside("timer")
	_o_.SetNameInside("pause")
	_o_.SetNameInside("duration")
	_o_.SetNameInside("par")
	_o_.SetNameInside("parblock")
	_o_.SetNameInside("comment")
	_o_.SetNameInside("title")
	_o_.SetNameInside("header")
	_o_.SetNameInside("end")

	# THE BRANCH ENTRY AND THE ADDRESS ARE THE TWO ENDS OF A BRANCH, and
	# the icon table draws them as each other's mirror: the entry carries
	# a point at the BOTTOM, where the flow leaves it going down into the
	# branch, and the address carries a point at the TOP, where the flow
	# arrives before leaving the branch by name. A tab was this plane's
	# nearest reading of "a header"; it is a folder, and says nothing
	# about which way anything flows.
	_o_.AddKindXT("branch", "invhouse", "#eef2ff")
	_o_.AddKindXT("address", "house", "#eef2ff")
	_o_.SetNameInside("branch")
	_o_.SetNameInside("address")

	StzRegisterNotation(_o_)
	return _o_

# THE ICONS THIS PROFILE KNOWS, answered from the profile rather than
# listed a second time here -- the lesson DN3 paid for twice was that a
# family written down in two places drifts.
func StzDrakonIcons()
	_o_ = StzDrakonNotation()
	return _o_.Kinds()
