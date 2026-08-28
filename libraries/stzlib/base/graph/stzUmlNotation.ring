#-------------------------------------------------------------------------#
#  stzUmlNotation -- UML CLASS DIAGRAMS AS A NOTATION PROFILE (DN4)        #
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
# SCOPE: the CLASS diagram. Sequence and activity diagrams are separate
# notations that happen to share a name, and folding them in here would
# be the "one profile per family" mistake this plane exists to avoid.
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
