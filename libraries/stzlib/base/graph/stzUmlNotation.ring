#-------------------------------------------------------------------------#
#  stzUmlNotation -- UML AS NOTATION PROFILES (DN4a class, DN4b the rest) #
#-------------------------------------------------------------------------#
#
# THIS FILE IS THE WHOLE DOMAIN, and that is the claim worth reading
# before the code.
#
# Every other domain in this plane arrived beside a MODEL: the org chart
# has stzOrgChart, the state machine and BPMN have stzWorkflow. UML class
# diagrams have no model here and need none -- a class diagram IS a
# graph, its classes are nodes and its relationships are edges, and
# everything that makes it UML rather than a box-and-line drawing is
# notation. So the profile is the domain, in one file, with no renderer
# behind it. That is DN0's claim tested at its strongest: a domain the
# industry reads daily, expressed entirely as a declaration over the one
# foundation.
#
# WHAT UML NEEDED THAT THE FOUNDATION DID NOT HAVE, and the plan's KILL
# criterion asked for a measurement rather than a promise:
#
#   COMPARTMENTS. A class is one glyph divided into bands -- name,
#   attributes, operations. It is NOT a new glyph: DN0 defines a glyph as
#   the shape name the renderer already draws, and this is a plain box
#   with contents. It entered as a node PROPERTY whose size derives from
#   what it holds, over machinery that already existed -- _BoxOf gives
#   every node its own size and, since this week, every consumer reads
#   it. So the criterion passed, and it passed by measurement.
#
#   EDGE-END ADORNMENTS. A hollow triangle says "is a kind of"; a filled
#   diamond says "is part of, and dies with it"; a hollow one says "is
#   part of, and outlives it". The LINE is identical in all three and the
#   shape at its end is the entire difference. They are polygons, drawn
#   from the published paths after every edge exists.
#
#   A DASHED LINE, which is what a dependency IS. The canvas has no dash
#   and needs none: a dash is the polyline emitted as alternating
#   segments. DN3a recorded this as the channel BPMN's suspension was
#   missing, so BPMN gets it back as a side effect -- which is what a
#   shared foundation is supposed to do.
#
# WHICH END CARRIES THE ADORNMENT. The general class, or the whole, is
# the one you name FIRST:
#
#     oD.AddEdgeXTT("Shape", "Circle", "", [ :uml = :Inheritance ])
#
# reads "Shape is generalised by Circle", and the triangle sits on Shape.
# That is the direction this library already declares hierarchies in --
# an org chart is written manager to report, a tree root to leaf -- and a
# notation that reversed it for one domain would be asking the author to
# hold two conventions at once.
#
# THE FIVE RELATIONSHIPS:
#
#   :Inheritance   hollow triangle at the general end   (also :Generalization)
#   :Realization   hollow triangle, dashed              (also :Implements)
#   :Composition   filled diamond at the whole end
#   :Aggregation   hollow diamond at the whole end
#   :Dependency    dashed, no adornment but the arrow
#   :Association   a plain line -- the default, and declaring it is
#                  saying so on purpose
#
# SCOPE OF THIS PROFILE: the CLASS diagram. THE FILE covers more -- see
# DN4b below, which adds seven more diagram types.
#
# What stood here until the Principal read it said sequence and activity
# were "separate notations that happen to share a name". That was a
# JUDGEMENT written as though it were a fact, and it was wrong: they
# share a metamodel, a stereotype mechanism and a reader, and what
# differs between them is the LAYOUT -- which is the thing a profile
# exists to declare. The sentence is left described rather than deleted,
# because a scoping decision that turns out to be an opinion is worth
# more visible than tidy.
#
#=========================================================================#

func StzUmlNotation()
	_o_ = StzNotation("uml")
	if _o_.Name_() = "uml"  return _o_  ok
	_o_ = new stzNotation("uml")

	# A CLASS DIAGRAM READS DOWNWARD. Generalisation is the relationship
	# a reader traces first and it is the one with a direction in the
	# world: the general thing is drawn ABOVE the specific ones, in every
	# textbook and every tool. Ranks run top to bottom and the author
	# names the general class first, so the two agree without the author
	# having to think about it.
	_o_.SetRankDir(:TopToBottom)
	_o_.SetSplines(:ortho)

	# ...AND IT HAS NO PRINCIPAL PATH. A business process has the way
	# things go when they go well; a class model has no such thing --
	# there is no "happy path" through an inheritance lattice, and
	# naming one chain the spine would be a claim the model does not
	# make. Left undeclared on purpose, exactly as the state machine
	# leaves it (DN2).

	# THE VOCABULARY IS ONE SHAPE, and that is not a poverty -- it is
	# UML. A class, an interface, an abstract class and an enumeration
	# are all rectangles; what distinguishes them is a STEREOTYPE in the
	# name band and, for an abstract, an italic name. The shape carries
	# none of it, so declaring four shapes would be inventing a notation
	# rather than speaking one.
	_o_.AddKindXT("class", "box", "white")
	_o_.AddKindXT("interface", "box", "white")
	_o_.AddKindXT("abstract", "box", "white")
	_o_.AddKindXT("enumeration", "box", "white")
	_o_.AddKindXT("datatype", "box", "white")

	# OPEN, unlike BPMN's. BPMN is a standard with a closed list of
	# elements, so a kind it does not have is a modelling mistake. UML
	# lets a profile add stereotypes -- that is what a UML profile IS --
	# and refusing an unknown kind would refuse the extension mechanism
	# the notation is famous for.

	StzRegisterNotation(_o_)
	return _o_


#-------------------------------------------------------------------------#
#  THE REST OF UML -- DN4b                                                #
#-------------------------------------------------------------------------#
#
# UML IS NOT ONLY CLASS DIAGRAMS, and the scoping above said otherwise
# until the Principal overruled it. The wording was "sequence and
# activity are separate notations that happen to share a name", which
# was a JUDGEMENT written as though it were a fact. They share a
# metamodel, a stereotype mechanism and a reader. What differs is the
# LAYOUT -- and a layout is what a profile declares.
#
# ONE PROFILE PER DIAGRAM TYPE, and that is not duplication. A profile
# is vocabulary plus rules plus grammar, and it is the GRAMMAR that
# separates these: a use case diagram reads left to right with the
# actors outside, an activity reads top down with a spine, a package
# diagram has no flow at all. Folding them into one profile would mean
# one rankdir for all of them, which is the same as having no grammar.
#
# WHAT EACH ONE COST, measured rather than estimated:
#
#   use case      the ACTOR glyph (new)      · everything else existed
#   activity      the fork/join BAR (new)    · everything else existed
#   component     nothing new                · Component was in the table
#   package       nothing new                · Folder was in the table
#   deployment    nothing new                · Box and Cylinder
#   object        nothing new                · a class with no compartments
#   communication nothing new                · a graph with numbered edges
#
# Two glyphs for seven diagram types. That is what a shared foundation
# is worth, and it is only visible because the foundation was built
# first and the domains after.
#
#=========================================================================#

# USE CASES: what the system does, and who is outside it.
#
# The whole claim of the drawing is that the figures round the edge are
# OUTSIDE -- people, and other systems acting like people. That is why
# an actor is a stick figure and not a box: a box would say it is a part
# of what is being built. The system's own boundary is a cluster, which
# this library already draws.
func StzUmlUseCaseNotation()
	_o_ = StzNotation("umlusecase")
	if _o_.Name_() = "umlusecase"  return _o_  ok
	_o_ = new stzNotation("umlusecase")
	_o_.SetRankDir(:LeftToRight)
	_o_.SetSplines(:ortho)
	_o_.AddKindXT("actor", "actor", "white")
	_o_.AddKindXT("usecase", "ellipse", "white")
	_o_.AddKindXT("system", "box", "white")
	# AN ACTOR IS NOT A DESTINATION. A use case diagram says who starts
	# what; an arrow INTO an actor would say the system uses the person,
	# which is the relationship the other way round and almost never
	# what is meant.
	StzRegisterNotation(_o_)
	return _o_

# ACTIVITIES: the same shape as a business process, and it should be --
# BPMN and a UML activity diagram describe the same thing in two
# vocabularies, which is why this profile declares the same grammar.
#
# What it adds is the BAR: a moment when control splits into parallel
# paths or waits for them to rejoin. It carries no name because it is
# not a step, and a reader who looks for one has misread the glyph.
func StzUmlActivityNotation()
	_o_ = StzNotation("umlactivity")
	if _o_.Name_() = "umlactivity"  return _o_  ok
	_o_ = new stzNotation("umlactivity")
	_o_.SetRankDir(:TopToBottom)
	_o_.SetSplines(:ortho)
	_o_.SetRankPolicy(:Earliest)
	_o_.SetSpine(:HappyPath)
	_o_.AddKindXT("action", "box", "white")
	_o_.AddKindXT("decision", "diamond", "white")
	_o_.AddKindXT("merge", "diamond", "white")
	_o_.AddKindXTT("fork", "bar", "Neutral.Text", 0.55)
	_o_.AddKindXTT("join", "bar", "Neutral.Text", 0.55)
	_o_.AddKindXTT("initial", "circle", "Neutral.Text", 0.28)
	_o_.AddKindXTT("final", "doublecircle", "Neutral.Text", 0.36)
	_o_.ForbidFor("initial", :Inbound,
		"an initial node admits nothing -- the activity begins here")
	_o_.ForbidFor("final", :Outbound,
		"a final node releases nothing -- the activity is over")
	StzRegisterNotation(_o_)
	return _o_

# COMPONENTS: the pieces a system is assembled from, and what each one
# offers or needs. The glyph was already in the shape table, which is
# the whole of what this profile cost.
func StzUmlComponentNotation()
	_o_ = StzNotation("umlcomponent")
	if _o_.Name_() = "umlcomponent"  return _o_  ok
	_o_ = new stzNotation("umlcomponent")
	_o_.SetRankDir(:TopToBottom)
	_o_.SetSplines(:ortho)
	_o_.AddKindXT("component", "component", "white")
	_o_.AddKindXT("interface", "box", "white")
	_o_.AddKindXTT("port", "square", "white", 0.18)
	_o_.AddKindXT("artifact", "note", "white")
	StzRegisterNotation(_o_)
	return _o_

# PACKAGES: what depends on what, at the scale where a reader has
# stopped caring about classes. No flow, so no spine and no rank policy
# -- a dependency graph has no happy path and claiming one would be a
# claim the model does not make.
func StzUmlPackageNotation()
	_o_ = StzNotation("umlpackage")
	if _o_.Name_() = "umlpackage"  return _o_  ok
	_o_ = new stzNotation("umlpackage")
	_o_.SetRankDir(:TopToBottom)
	_o_.SetSplines(:ortho)
	_o_.AddKindXT("package", "folder", "white")
	_o_.AddKindXT("subsystem", "folder", "white")
	StzRegisterNotation(_o_)
	return _o_

# DEPLOYMENT: where the pieces actually run. A device holds artifacts; a
# database is drawn as a cylinder because thirty years of diagrams have
# made that shape mean "this is where the data lives", and a notation
# that ignored it would be technically free and practically unreadable.
func StzUmlDeploymentNotation()
	_o_ = StzNotation("umldeployment")
	if _o_.Name_() = "umldeployment"  return _o_  ok
	_o_ = new stzNotation("umldeployment")
	_o_.SetRankDir(:TopToBottom)
	_o_.SetSplines(:ortho)
	_o_.AddKindXT("node", "box", "white")
	_o_.AddKindXT("device", "box", "white")
	_o_.AddKindXT("database", "cylinder", "white")
	_o_.AddKindXT("artifact", "note", "white")
	_o_.AddKindXT("environment", "folder", "white")
	StzRegisterNotation(_o_)
	return _o_

# OBJECTS: a class diagram at one instant, with instances instead of
# classes. Deliberately the same vocabulary as the class profile --
# because it IS the class notation, populated. What marks an object is
# that its name is written `name : Class` and underlined, which is a
# LABEL convention and not a glyph, so there is nothing here to declare
# beyond saying the domain exists.
func StzUmlObjectNotation()
	_o_ = StzNotation("umlobject")
	if _o_.Name_() = "umlobject"  return _o_  ok
	_o_ = new stzNotation("umlobject")
	_o_.SetRankDir(:TopToBottom)
	_o_.SetSplines(:ortho)
	_o_.AddKindXT("object", "box", "white")
	_o_.AddKindXT("class", "box", "white")
	StzRegisterNotation(_o_)
	return _o_

# COMMUNICATION: the same interactions a sequence diagram shows, drawn
# as a GRAPH instead of a schedule -- participants wherever they fit,
# and the ordering carried in the message numbers rather than in the
# geometry. Which is precisely why it costs nothing here and a sequence
# diagram does not: this one IS a graph.
func StzUmlCommunicationNotation()
	_o_ = StzNotation("umlcommunication")
	if _o_.Name_() = "umlcommunication"  return _o_  ok
	_o_ = new stzNotation("umlcommunication")
	_o_.SetRankDir(:LeftToRight)
	_o_.SetSplines(:ortho)
	_o_.AddKindXT("object", "box", "white")
	_o_.AddKindXT("actor", "actor", "white")
	StzRegisterNotation(_o_)
	return _o_

# The class profile under its full name, so a caller naming the diagram
# type reads the same way for all eight.
func StzUmlClassNotation()
	return StzUmlNotation()

# SEQUENCE: the one UML diagram whose second axis is TIME.
#
# THE KILL CRITERION, MEASURED. The plan attached the plane's sharpest
# one here: a schedule is not a graph layout, and if this needed a
# renderer of its own it was to be said so. It does not, and the reason
# is that the two axes are NOT symmetrical.
#
# Only ONE axis belongs to the nodes. Participants stand side by side --
# a single row, which the layout contract already describes, and the
# mode that produces it is four lines long. The other axis belongs to
# the MESSAGES, and a message is an EDGE: its position comes from its
# ordinal in the model, exactly as a lane's depth or a summit's side
# does. So the time axis was never a layout question.
#
# WHAT IT ADDED to the renderer, and each entered the way the plane's
# earlier domains did:
#
#   A LIFELINE is a node property -- "this node has a tail of length L"
#   -- drawn by the node drawer, the way a class's compartments are.
#   A MESSAGE is one more branch of the edge drawer, beside the
#   self-loop, the summit route and the return-under-the-picture.
#   A RETURN is the dashed stroke DN4a already built for dependency.
#
# Nothing here is a second draw loop, which is the criterion the plan
# actually named.
func StzUmlSequenceNotation()
	_o_ = StzNotation("umlsequence")
	if _o_.Name_() = "umlsequence"  return _o_  ok
	_o_ = new stzNotation("umlsequence")
	_o_.SetLayoutMode(:Sequence)
	# AND NO RANK DIRECTION, deliberately. Every other profile in this
	# file declares one, and the first draft of this one declared
	# :LeftToRight by copying them -- which drew the participants in a
	# COLUMN. A rank direction rotates the layout's two axes, and a
	# sequence's axes are not interchangeable: participants are across
	# and time is down, always, in every UML document ever printed.
	# There is no such thing as a right-to-left sequence diagram, so the
	# field has no meaning here and saying nothing is the accurate thing
	# to say.
	_o_.SetSplines(:ortho)
	_o_.AddKindXT("participant", "box", "white")
	_o_.AddKindXT("object", "box", "white")
	_o_.AddKindXT("actor", "actor", "white")
	_o_.AddKindXT("boundary", "box", "white")
	_o_.AddKindXT("control", "circle", "white")
	_o_.AddKindXT("entity", "box", "white")
	StzRegisterNotation(_o_)
	return _o_
