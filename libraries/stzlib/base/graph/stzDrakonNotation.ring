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
	_o_.AddKindXT("question", "diamond", "#fff7e6")
	_o_.AddKindXT("select", "diamond", "#fff7e6")
	_o_.AddKindXT("case", "box", "white")
	# an insertion is a call to another algorithm: the component glyph
	# is the table's nearest reading, a body with something attached
	_o_.AddKindXT("insertion", "component", "white")
	_o_.AddKindXT("shelf", "tab", "white")
	_o_.AddKindXT("input", "parallelogram", "white")
	_o_.AddKindXT("output", "parallelogram", "white")
	_o_.AddKindXT("timer", "hexagon", "#f3f4f6")
	_o_.AddKindXT("pause", "hexagon", "#f3f4f6")
	_o_.AddKindXT("comment", "note", "#fffbe6")

	StzRegisterNotation(_o_)
	return _o_

# THE ICONS THIS PROFILE KNOWS, answered from the profile rather than
# listed a second time here -- the lesson DN3 paid for twice was that a
# family written down in two places drifts.
func StzDrakonIcons()
	_o_ = StzDrakonNotation()
	return _o_.Kinds()
