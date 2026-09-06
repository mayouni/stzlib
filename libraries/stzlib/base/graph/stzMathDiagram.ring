#=====================================================================#
#  STZMATHDIAGRAM -- DN7: a mathematical diagram is a CONSTRAINT       #
#  PROBLEM over shapes, solved by the engine, drawn by the one canvas  #
#=====================================================================#
/*
	Penrose (Ye, Ni, Krieger, Ma'ayan, Wise, Aldrich, Sunshine, Crane;
	SIGGRAPH 2020) separates a diagram into three programs, and DN7 keeps
	the split because it is the whole idea and not a detail of it:

	    DOMAIN     what a field of mathematics is made of -- its types,
	               relations and functions. "type Set; predicate
	               Subset(Set, Set)". Purely abstract: it says nothing
	               about drawing and nothing about representation.
	    SUBSTANCE  one diagram's content, in that domain. "Set A, B;
	               Subset(B, A)". No coordinate, no size, no colour --
	               the paper's rule is that graphical data is EXCLUDED
	               from Substance, so the same content can wear many
	               representations.
	    STYLE      the mapping from domain to picture: a Set is a
	               circle; Subset(x, y) means y's circle CONTAINS x's;
	               Disjoint means they do not meet. Written as rules
	               over patterns ("forall Set x; Set y where Subset(x,
	               y)"), with two verbs: ENSURE, a constraint the
	               picture must satisfy, and ENCOURAGE, a preference.

	The picture is then SOLVED, not placed: every unknown -- a centre, a
	radius, a label's position -- is a variable, every ensure is a
	penalty max(0, g)^2 that is zero when satisfied, every encourage is
	an energy, and the sum is minimised. Penrose's method is an EXTERIOR
	POINT scheme: start anywhere, minimise objective + lambda * penalties
	with L-BFGS, and raise lambda tenfold until no constraint is
	violated. That is what this file does.

	WHAT IS SOFTANZA'S OWN HERE, and it is the part that matters:

	  - THE SOLVER IS THE ENGINE THIS LIBRARY ALREADY HAS. autodiff.zig
	    compiles an expression to a reverse-mode tape and lbfgs.zig
	    minimises it with a strong-Wolfe line search. DN7 writes the
	    energy as ONE expression string and hands it over. No new Zig
	    was needed to reach feasibility on Penrose's own seven-set
	    example -- measured before this file was written, three random
	    starts, one penalty round each, maximum violation zero. The one
	    engine change was a constant: the tape's variable cap, 64 to 256.

	  - THE CANVAS IS THE ONE RENDERER. Circles, rectangles, lines and
	    text go through stzCanvas exactly as every other domain's do, so
	    a mathematical diagram gets both tiers (SVG and PNG), the pick
	    channel, and the id/class channel DN3b added -- every Set's
	    circle is <g id="A" class="circle set el_A"> to a consumer. The
	    plane's law is that a domain is never a second draw loop, and
	    this one is not.

	  - RULES ARE DATA. A Style rule is a list, not a closure: it can be
	    printed, compared, checked, and written to a file. The plane
	    already ruled this for notation profiles, and it holds here.

	  - STAGED, and JOINT FIRST, because Penrose learnt it the hard way
	    and so did this file. Stage 0 moves every unknown together; stage
	    1 polishes labels against frozen shapes. Shapes-first-then-labels
	    is the staging Penrose's own blog demonstrates failing, and it
	    failed here too: circles sized without their text had no room
	    for it.

	DN7b ADDED WHAT A SECOND AND THIRD DOMAIN NEEDED:

	  - EXPRESSIONS OVER PATHS. A shape property may be a number (a
	    constant), an expression over other shapes' properties (DERIVED,
	    never a variable), or absent (an unknown the solver owns). An
	    axis is a line whose ends are "U.ox - U.axis" and "U.ox + U.axis";
	    a segment is a line from "p.icon.cx" to "q.icon.cx". The
	    expression language is the tape's -- +, -, *, /, ^, sqrt, abs,
	    min, max, sin, cos -- plus a few computations over SHAPES:
	    dist(a, b), len(l), dot(l1, l2), cross(l1, l2), midx/midy(l),
	    ux/uy(l) the unit direction, nx/ny(l) the unit normal.

	  - FIELDS. [ :field, "U.ox", 250 ] names a constant or an
	    expression on an object with no shape behind it -- Penrose's
	    "U.origin".

	  - OVERRIDE. [ :override, "u.arrow.x2", "v.arrow.x2 + w.arrow.x2 -
	    U.ox" ] turns an unknown into a derived value: the arrow for u :=
	    addV(v, w) ENDS where the sum says, by construction, and the
	    solver never sees a variable there.

	  - FUNCTION APPLICATIONS IN WHERE. "u := addV(v, w)" binds three
	    variables to one definition in the Substance.

	  - LITERAL SELECTORS. "Set `A`" matches only the object named A.

	  - Lines carry arrowheads; a shape may be :hidden (a bound that
	    constrains without drawing).

	Three domains ship: set theory (Penrose's setTheory.domain, with
	euler.style AND tree.style -- one Substance, two representations,
	which is the claim the whole split exists to make), linear algebra
	(vector spaces, vectors, orthogonality, unit length, addition), and
	Euclidean geometry (points, segments, triangles, angles; right
	angles, equal lengths, parallels, perpendiculars).

	WHAT IS NOT DONE, named rather than left to be found. Ellipses,
	polygons and paths as shapes; Penrose's `delete`; a text box against
	a circle uses the box's corners for containment and its bounding
	circle for separation, which is conservative rather than exact;
	spherical and hyperbolic styles for the geometry domain need asin,
	acos and atan2 on the tape, which it does not have.
*/

#---------------------------------------------------------------------#
#  CONSTRUCTORS AND THE BUILT-IN DOMAINS AND STYLES                    #
#---------------------------------------------------------------------#

func StzMathDomainQ(pcName)
	return new stzMathDomain(pcName)

func StzMathSubstanceQ(poDomain)
	return new stzMathSubstance(poDomain)

func StzMathStyleQ()
	return new stzMathStyle()

func StzMathDiagramQ(poDomain, poSubstance, poStyle)
	return new stzMathDiagram(poDomain, poSubstance, poStyle)

# Set theory, as Penrose ships it -- the "hello world" of the system.
func StzSetTheoryDomain()
	_o_ = new stzMathDomain("settheory")
	_o_.AddType("Set")
	_o_.AddPredicate("Subset", [ "Set", "Set" ])
	_o_.AddSymmetricPredicate("Disjoint", [ "Set", "Set" ])
	_o_.AddSymmetricPredicate("Intersecting", [ "Set", "Set" ])
	return _o_

# Penrose's euler.style, as data: a Set is a disk, Subset is containment.
func StzEulerStyle()
	_o_ = new stzMathStyle()
	_o_.SetCanvas(800, 700)
	_o_.ForAll("Set x", [
		[ :shape, "x.icon", :circle, [ :fill = [ :alpha, "primary", 0.2 ], :stroke = "neutral",
		                               :strokeWidth = 1 ] ],
		[ :shape, "x.text", :text, [ :fill = [ :on, "paper" ] ] ],
		[ :ensure, "greaterThan", [ "x.icon.r", 25 ] ],
		[ :ensure, "contains", [ "x.icon", "x.text", 4 ] ],
		[ :encourage, "sameCenter", [ "x.text", "x.icon" ] ],
		[ :layer, "x.text", :above, "x.icon" ] ])
	_o_.ForAllWhere("Set x; Set y", "Subset(x, y)", [
		[ :ensure, "contains", [ "y.icon", "x.icon", 5 ] ],
		[ :ensure, "disjoint", [ "y.text", "x.icon", 10 ] ],
		[ :layer, "x.icon", :above, "y.icon" ] ])
	_o_.ForAllWhere("Set x; Set y", "Disjoint(x, y)", [
		[ :ensure, "disjoint", [ "x.icon", "y.icon", 0 ] ] ])
	_o_.ForAllWhere("Set x; Set y", "Intersecting(x, y)", [
		[ :ensure, "overlapping", [ "x.icon", "y.icon", 0 ] ],
		[ :ensure, "disjoint", [ "y.text", "x.icon", 0 ] ],
		[ :ensure, "disjoint", [ "x.text", "y.icon", 0 ] ] ])
	return _o_

# Penrose's tree.style, as data: THE SAME SUBSTANCE, A DIFFERENT
# REPRESENTATION. A Set is its name; Subset is an arrow from the subset
# up to its superset; supersets sit above and children fight to align
# with their parent's x. The paper's own point about this pair: disks
# must shrink exponentially for deep nesting, a tree stays readable.
func StzTreeStyle()
	_o_ = new stzMathStyle()
	_o_.SetCanvas(800, 700)
	_o_.ForAll("Set x", [
		[ :shape, "x.text", :text, [ :fill = [ :on, "paper" ] ] ],
		[ :shape, "x.bounds", :circle, [ :cx = "x.text.cx", :cy = "x.text.cy",
		                                 :r = 18, :hidden = 1 ] ] ])
	_o_.ForAll("Set x; Set y", [
		[ :encourage, "notTooClose", [ "x.bounds", "y.bounds", 5 ] ] ])
	_o_.ForAllWhere("Set x; Set y", "Subset(x, y)", [
		[ :shape, "x.link", :line, [ :x1 = "x.text.cx", :y1 = "x.text.cy",
		                             :x2 = "y.text.cx", :y2 = "y.text.cy", :hidden = 1 ] ],
		[ :shape, "x.arrow", :line, [
			:x1 = "x.text.cx + 22*ux(x.link)", :y1 = "x.text.cy + 22*uy(x.link)",
			:x2 = "y.text.cx - 22*ux(x.link)", :y2 = "y.text.cy - 22*uy(x.link)",
			:stroke = "neutral", :strokeWidth = 3, :arrow = "end" ] ],
		[ :ensure, "greaterThan", [ "len(x.link)", 70 ] ],
		[ :encourage, "above", [ "y.bounds", "x.bounds", 100 ] ],
		[ :encourage, "equal", [ "x.bounds.cx", "y.bounds.cx" ] ] ])
	return _o_

# Linear algebra, after Penrose's linear-algebra.domain and the paper's
# Sec. 5.4: what a vector space, a vector, orthogonality, unit length
# and addition ARE, with no coordinate anywhere in it.
func StzLinearAlgebraDomain()
	_o_ = new stzMathDomain("linearalgebra")
	_o_.AddType("Scalar")
	_o_.AddType("VectorSpace")
	_o_.AddType("Vector")
	_o_.AddFunction("addV", [ "Vector", "Vector" ], "Vector")
	_o_.AddFunction("neg", [ "Vector" ], "Vector")
	_o_.AddPredicate("In", [ "Vector", "VectorSpace" ])
	_o_.AddSymmetricPredicate("Orthogonal", [ "Vector", "Vector" ])
	_o_.AddPredicate("Unit", [ "Vector" ])
	_o_.AddSymmetricPredicate("Independent", [ "Vector", "Vector" ])
	return _o_

# ...and how it is drawn: a space is a square with axes, a vector is an
# arrow from the origin to a solved end, a right-angle mark for
# orthogonality, and u := addV(v, w) ends where the sum says BY
# CONSTRUCTION -- an override, never a constraint the solver could miss.
func StzVectorStyle()
	_o_ = new stzMathStyle()
	_o_.SetCanvas(520, 520)
	_o_.ForAll("VectorSpace U", [
		[ :field, "U.ox", 260 ], [ :field, "U.oy", 260 ], [ :field, "U.axis", 170 ],
		[ :shape, "U.box", :rect, [ :cx = "U.ox", :cy = "U.oy", :w = 400, :h = 400,
		                            :fill = [ :alpha, "primary", 0.08 ], :stroke = "muted", :strokeWidth = 1 ] ],
		[ :shape, "U.xaxis", :line, [ :x1 = "U.ox - U.axis", :y1 = "U.oy",
		                              :x2 = "U.ox + U.axis", :y2 = "U.oy",
		                              :stroke = "muted", :strokeWidth = 1.5, :arrow = "end" ] ],
		[ :shape, "U.yaxis", :line, [ :x1 = "U.ox", :y1 = "U.oy + U.axis",
		                              :x2 = "U.ox", :y2 = "U.oy - U.axis",
		                              :stroke = "muted", :strokeWidth = 1.5, :arrow = "end" ] ],
		[ :shape, "U.text", :text, [ :cx = "U.ox - U.axis + 12", :cy = "U.oy - U.axis + 12",
		                             :fill = "neutral" ] ],
		[ :layer, "U.xaxis", :above, "U.box" ], [ :layer, "U.yaxis", :above, "U.box" ] ])
	_o_.ForAllWhere("Vector v; VectorSpace U", "In(v, U)", [
		[ :shape, "v.arrow", :line, [ :x1 = "U.ox", :y1 = "U.oy",
		                              :stroke = "primary", :strokeWidth = 3, :arrow = "end" ] ],
		# the name is SOLVED near the tip rather than placed beyond it: placed
		# at 1.16 of the arrow it landed on the space's axes whenever the
		# arrow ran near one, which the one gate found on both vectors
		[ :shape, "v.text", :text, [ :fill = [ :on, "paper" ] ] ],
		[ :shape, "v.tip", :circle, [ :cx = "v.arrow.x2", :cy = "v.arrow.y2", :r = 1, :hidden = 1 ] ],
		# 24 from the tip and 10 off the arrow: the head is 3.5 + 1.2*sw
		# wide either side of the line, and the name must clear the head,
		# not the line; 10 off each axis, since the tip of an axis-aligned
		# vector sits ON the axis and the name was hugging it
		[ :encourage, "near", [ "v.text", "v.tip", 24 ] ],
		[ :ensure, "disjoint", [ "v.text", "v.arrow", 10 ] ],
		[ :ensure, "disjoint", [ "v.text", "U.xaxis", 10 ] ],
		[ :ensure, "disjoint", [ "v.text", "U.yaxis", 10 ] ],
		[ :ensure, "greaterThan", [ "len(v.arrow)", 70 ] ],
		[ :ensure, "lessThan", [ "len(v.arrow)", "U.axis - 10" ] ],
		[ :layer, "v.arrow", :above, "U.xaxis" ], [ :layer, "v.arrow", :above, "U.yaxis" ] ])
	_o_.ForAllWhere("Vector u; Vector v; VectorSpace U",
	                "Orthogonal(u, v); In(u, U); In(v, U)", [
		[ :ensure, "equal", [ "dot(u.arrow, v.arrow) / (len(u.arrow) * len(v.arrow))", 0 ] ],
		[ :shape, "u.mark1", :line, [
			:x1 = "U.ox + 14*ux(u.arrow)", :y1 = "U.oy + 14*uy(u.arrow)",
			:x2 = "U.ox + 14*ux(u.arrow) + 14*ux(v.arrow)",
			:y2 = "U.oy + 14*uy(u.arrow) + 14*uy(v.arrow)", :stroke = "neutral", :strokeWidth = 1.5 ] ],
		[ :shape, "u.mark2", :line, [
			:x1 = "U.ox + 14*ux(v.arrow)", :y1 = "U.oy + 14*uy(v.arrow)",
			:x2 = "U.ox + 14*ux(u.arrow) + 14*ux(v.arrow)",
			:y2 = "U.oy + 14*uy(u.arrow) + 14*uy(v.arrow)", :stroke = "neutral", :strokeWidth = 1.5 ] ] ])
	_o_.ForAllWhere("Vector v; VectorSpace U", "Unit(v); In(v, U)", [
		[ :ensure, "equal", [ "len(v.arrow)", 90 ] ] ])
	_o_.ForAllWhere("Vector u; Vector v; VectorSpace U",
	                "Independent(u, v); In(u, U); In(v, U)", [
		[ :ensure, "greaterThan", [ "abs(cross(u.arrow, v.arrow)) / (len(u.arrow) * len(v.arrow))", 0.7 ] ] ])
	_o_.ForAllWhere("Vector u; Vector v; Vector w; VectorSpace U",
	                "u := addV(v, w); In(u, U); In(v, U); In(w, U)", [
		[ :override, "u.arrow.x2", "v.arrow.x2 + w.arrow.x2 - U.ox" ],
		[ :override, "u.arrow.y2", "v.arrow.y2 + w.arrow.y2 - U.oy" ],
		[ :shape, "u.slider1", :line, [ :x1 = "v.arrow.x2", :y1 = "v.arrow.y2",
		                                :x2 = "u.arrow.x2", :y2 = "u.arrow.y2",
		                                :stroke = "muted", :strokeWidth = 1.5 ] ],
		[ :shape, "u.slider2", :line, [ :x1 = "w.arrow.x2", :y1 = "w.arrow.y2",
		                                :x2 = "u.arrow.x2", :y2 = "u.arrow.y2",
		                                :stroke = "muted", :strokeWidth = 1.5 ] ],
		[ :ensure, "greaterThan", [ "abs(cross(v.arrow, w.arrow)) / (len(v.arrow) * len(w.arrow))", 0.5 ] ],
		[ :layer, "u.slider1", :below, "u.arrow" ], [ :layer, "u.slider2", :below, "u.arrow" ] ])
	return _o_

# Euclidean geometry, after Penrose's geometry.domain: the two-column
# proof's nouns -- points, segments, triangles, angles -- and the claims a
# proof makes about them. A Segment is CONSTRUCTED from two points; an
# Angle from three, the middle one its vertex.
func StzGeometryDomain()
	_o_ = new stzMathDomain("geometry")
	_o_.AddType("Point")
	_o_.AddType("Segment")
	_o_.AddType("Triangle")
	_o_.AddType("Angle")
	_o_.AddConstructor("Segment", [ "Point", "Point" ])
	_o_.AddConstructor("Triangle", [ "Point", "Point", "Point" ])
	_o_.AddFunction("InteriorAngle", [ "Point", "Point", "Point" ], "Angle")
	_o_.AddPredicate("Right", [ "Angle" ])
	_o_.AddSymmetricPredicate("EqualLength", [ "Segment", "Segment" ])
	_o_.AddSymmetricPredicate("Parallel", [ "Segment", "Segment" ])
	_o_.AddSymmetricPredicate("Perpendicular", [ "Segment", "Segment" ])
	# added for Thales: a circle, points on it, and a chord through its centre
	_o_.AddType("Circle")
	_o_.AddPredicate("OnCircle", [ "Point", "Circle" ])
	_o_.AddPredicate("Diameter", [ "Segment", "Circle" ])
	return _o_

# ...drawn as Euclid drew: a point is a dot with its name beside it, a
# segment is the line between its points, an angle's vertex gets a mark
# when the angle is right, equal segments wear matching ticks.
func StzEuclideanStyle()
	_o_ = new stzMathStyle()
	_o_.SetCanvas(600, 520)
	_o_.ForAll("Point p", [
		[ :shape, "p.icon", :circle, [ :r = 4, :fill = "neutral" ] ],
		[ :shape, "p.text", :text, [ :fill = [ :on, "paper" ] ] ],
		[ :ensure, "disjoint", [ "p.text", "p.icon", 4 ] ],
		[ :encourage, "near", [ "p.text", "p.icon", 16 ] ] ])
	_o_.ForAllWhere("Segment s; Point p; Point q", "s := Segment(p, q)", [
		[ :shape, "s.icon", :line, [ :x1 = "p.icon.cx", :y1 = "p.icon.cy",
		                             :x2 = "q.icon.cx", :y2 = "q.icon.cy",
		                             :stroke = "neutral", :strokeWidth = 2 ] ],
		[ :ensure, "greaterThan", [ "len(s.icon)", 110 ] ],
		[ :ensure, "lessThan", [ "len(s.icon)", 380 ] ],
		# a name never sits on a line -- the plane's rule from the electric
		# domain, and Penrose's disjoint(text, segment)
		[ :ensure, "disjoint", [ "p.text", "s.icon", 2 ] ],
		[ :ensure, "disjoint", [ "q.text", "s.icon", 2 ] ],
		[ :layer, "p.icon", :above, "s.icon" ], [ :layer, "q.icon", :above, "s.icon" ] ])
	_o_.ForAllWhere("Triangle t; Point p; Point q; Point r", "t := Triangle(p, q, r)", [
		[ :shape, "t.pq", :line, [ :x1 = "p.icon.cx", :y1 = "p.icon.cy",
		                           :x2 = "q.icon.cx", :y2 = "q.icon.cy", :stroke = "neutral", :strokeWidth = 2 ] ],
		[ :shape, "t.qr", :line, [ :x1 = "q.icon.cx", :y1 = "q.icon.cy",
		                           :x2 = "r.icon.cx", :y2 = "r.icon.cy", :stroke = "neutral", :strokeWidth = 2 ] ],
		[ :shape, "t.pr", :line, [ :x1 = "p.icon.cx", :y1 = "p.icon.cy",
		                           :x2 = "r.icon.cx", :y2 = "r.icon.cy", :stroke = "neutral", :strokeWidth = 2 ] ],
		[ :ensure, "greaterThan", [ "len(t.pq)", 110 ] ],
		[ :ensure, "greaterThan", [ "len(t.qr)", 110 ] ],
		[ :ensure, "greaterThan", [ "len(t.pr)", 110 ] ],
		[ :ensure, "lessThan", [ "len(t.pq)", 380 ] ],
		[ :ensure, "lessThan", [ "len(t.qr)", 380 ] ],
		[ :ensure, "lessThan", [ "len(t.pr)", 380 ] ],
		# not a sliver: the sine of the angle at p above a quarter
		[ :ensure, "greaterThan", [ "abs(cross(t.pq, t.pr)) / (len(t.pq) * len(t.pr))", 0.35 ] ],
		# every vertex's name off every side
		[ :ensure, "disjoint", [ "p.text", "t.pq", 2 ] ], [ :ensure, "disjoint", [ "p.text", "t.pr", 2 ] ],
		[ :ensure, "disjoint", [ "p.text", "t.qr", 2 ] ], [ :ensure, "disjoint", [ "q.text", "t.pq", 2 ] ],
		[ :ensure, "disjoint", [ "q.text", "t.qr", 2 ] ], [ :ensure, "disjoint", [ "q.text", "t.pr", 2 ] ],
		[ :ensure, "disjoint", [ "r.text", "t.qr", 2 ] ], [ :ensure, "disjoint", [ "r.text", "t.pr", 2 ] ],
		[ :ensure, "disjoint", [ "r.text", "t.pq", 2 ] ],
		[ :layer, "p.icon", :above, "t.pq" ], [ :layer, "q.icon", :above, "t.qr" ],
		[ :layer, "r.icon", :above, "t.pr" ] ])
	_o_.ForAllWhere("Angle a; Point p; Point q; Point r", "a := InteriorAngle(p, q, r)", [
		[ :shape, "a.arm1", :line, [ :x1 = "q.icon.cx", :y1 = "q.icon.cy",
		                             :x2 = "p.icon.cx", :y2 = "p.icon.cy", :hidden = 1 ] ],
		[ :shape, "a.arm2", :line, [ :x1 = "q.icon.cx", :y1 = "q.icon.cy",
		                             :x2 = "r.icon.cx", :y2 = "r.icon.cy", :hidden = 1 ] ] ])
	_o_.ForAllWhere("Angle a; Point p; Point q; Point r",
	                "a := InteriorAngle(p, q, r); Right(a)", [
		[ :ensure, "equal", [ "dot(a.arm1, a.arm2) / (len(a.arm1) * len(a.arm2))", 0 ] ],
		# the vertex's name off the mark's arms, which are ink too
		[ :ensure, "disjoint", [ "q.text", "a.mark1", 2 ] ],
		[ :ensure, "disjoint", [ "q.text", "a.mark2", 2 ] ],
		[ :shape, "a.mark1", :line, [
			:x1 = "q.icon.cx + 16*ux(a.arm1)", :y1 = "q.icon.cy + 16*uy(a.arm1)",
			:x2 = "q.icon.cx + 16*ux(a.arm1) + 16*ux(a.arm2)",
			:y2 = "q.icon.cy + 16*uy(a.arm1) + 16*uy(a.arm2)", :stroke = "neutral", :strokeWidth = 1.5 ] ],
		[ :shape, "a.mark2", :line, [
			:x1 = "q.icon.cx + 16*ux(a.arm2)", :y1 = "q.icon.cy + 16*uy(a.arm2)",
			:x2 = "q.icon.cx + 16*ux(a.arm1) + 16*ux(a.arm2)",
			:y2 = "q.icon.cy + 16*uy(a.arm1) + 16*uy(a.arm2)", :stroke = "neutral", :strokeWidth = 1.5 ] ] ])
	_o_.ForAllWhere("Segment s; Segment t", "EqualLength(s, t)", [
		[ :ensure, "equal", [ "len(s.icon)", "len(t.icon)" ] ],
		[ :shape, "s.tick", :line, [ :x1 = "midx(s.icon) - 7*nx(s.icon)", :y1 = "midy(s.icon) - 7*ny(s.icon)",
		                             :x2 = "midx(s.icon) + 7*nx(s.icon)", :y2 = "midy(s.icon) + 7*ny(s.icon)",
		                             :stroke = "neutral", :strokeWidth = 2 ] ],
		[ :shape, "t.tick", :line, [ :x1 = "midx(t.icon) - 7*nx(t.icon)", :y1 = "midy(t.icon) - 7*ny(t.icon)",
		                             :x2 = "midx(t.icon) + 7*nx(t.icon)", :y2 = "midy(t.icon) + 7*ny(t.icon)",
		                             :stroke = "neutral", :strokeWidth = 2 ] ] ])
	_o_.ForAllWhere("Segment s; Segment t", "Parallel(s, t)", [
		[ :ensure, "equal", [ "cross(s.icon, t.icon) / (len(s.icon) * len(t.icon))", 0 ] ] ])
	_o_.ForAllWhere("Segment s; Segment t", "Perpendicular(s, t)", [
		[ :ensure, "equal", [ "dot(s.icon, t.icon) / (len(s.icon) * len(t.icon))", 0 ] ] ])
	return _o_

# THE SPHERE. The same Substance the Euclidean style reads -- points,
# segments, triangles, angles, Right, EqualLength -- drawn on a sphere:
# Penrose's Fig. 1, middle. A point is a unit vector (three unknowns held
# to the sphere by one constraint), a segment is the great-circle arc, and
# every claim is a POLYNOMIAL in the coordinates: equal length is equal
# cosine, a right angle is a zero dot product between the tangents. That is
# why the tape needed no asin, acos or atan2, which the plan had assumed.
func StzSphericalStyle()
	_o_ = new stzMathStyle()
	_o_.SetCanvas(600, 520)
	_o_.ForAll("Point p", [
		[ :unknown, "p.sx", -0.6, 0.6 ], [ :unknown, "p.sy", -0.6, 0.6 ],
		[ :unknown, "p.sz", 0.5, 1 ],
		[ :shape, "_.sphere", :circle, [ :cx = 300, :cy = 260, :r = 210,
		                                 :fill = [ :alpha, "primary", 0.08 ], :stroke = "muted", :strokeWidth = 1 ] ],
		[ :shape, "p.icon", :circle, [ :cx = "300 + 210*p.sx", :cy = "260 - 210*p.sy",
		                               :r = 4, :fill = "neutral" ] ],
		[ :shape, "p.text", :text, [ :fill = [ :on, "paper" ] ] ],
		[ :ensure, "equal", [ "100*(p.sx^2 + p.sy^2 + p.sz^2)", 100 ] ],
		[ :ensure, "greaterThan", [ "100*p.sz", 30 ] ],
		[ :ensure, "disjoint", [ "p.text", "p.icon", 4 ] ],
		[ :encourage, "near", [ "p.text", "p.icon", 16 ] ],
		[ :layer, "p.icon", :above, "_.sphere" ] ])
	_o_.ForAllWhere("Segment s; Point p; Point q", "s := Segment(p, q)", [
		[ :field, "s.cosd", "p.sx*q.sx + p.sy*q.sy + p.sz*q.sz" ],
		[ :shape, "s.icon", :curve, [ :curve = "greatarc",
		    :x1 = "p.sx", :y1 = "p.sy", :z1 = "p.sz", :x2 = "q.sx", :y2 = "q.sy", :z2 = "q.sz",
		    :cx = 300, :cy = 260, :r = 210, :stroke = "neutral", :strokeWidth = 2 ] ],
		[ :ensure, "lessThan", [ "100*s.cosd", 86 ] ],
		[ :ensure, "greaterThan", [ "100*s.cosd", 35 ] ],
		# A NAME NEVER SITS ON A LINE -- the Principal's mark on the sphere.
		# disjoint() cannot see an arc's interior, so the rule is the one a
		# hand would follow: the name sits OUTSIDE the angle, more than 104
		# degrees from the chord toward the other end, for every arc that
		# leaves its point.
		[ :ensure, "lessThan", [ "100*((p.text.cx - p.icon.cx)*(q.icon.cx - p.icon.cx) + (p.text.cy - p.icon.cy)*(q.icon.cy - p.icon.cy)) / (sqrt((p.text.cx - p.icon.cx)^2 + (p.text.cy - p.icon.cy)^2 + 0.001) * sqrt((q.icon.cx - p.icon.cx)^2 + (q.icon.cy - p.icon.cy)^2 + 0.001))", -25 ] ],
		[ :ensure, "lessThan", [ "100*((q.text.cx - q.icon.cx)*(p.icon.cx - q.icon.cx) + (q.text.cy - q.icon.cy)*(p.icon.cy - q.icon.cy)) / (sqrt((q.text.cx - q.icon.cx)^2 + (q.text.cy - q.icon.cy)^2 + 0.001) * sqrt((p.icon.cx - q.icon.cx)^2 + (p.icon.cy - q.icon.cy)^2 + 0.001))", -25 ] ],
		[ :layer, "s.icon", :above, "_.sphere" ],
		[ :layer, "p.icon", :above, "s.icon" ], [ :layer, "q.icon", :above, "s.icon" ] ])
	_o_.ForAllWhere("Triangle t; Point p; Point q; Point r", "t := Triangle(p, q, r)", [
		[ :field, "t.cpq", "p.sx*q.sx + p.sy*q.sy + p.sz*q.sz" ],
		[ :field, "t.cqr", "q.sx*r.sx + q.sy*r.sy + q.sz*r.sz" ],
		[ :field, "t.cpr", "p.sx*r.sx + p.sy*r.sy + p.sz*r.sz" ],
		[ :shape, "t.pq", :curve, [ :curve = "greatarc", :x1 = "p.sx", :y1 = "p.sy", :z1 = "p.sz",
		    :x2 = "q.sx", :y2 = "q.sy", :z2 = "q.sz", :cx = 300, :cy = 260, :r = 210,
		    :stroke = "neutral", :strokeWidth = 2 ] ],
		[ :shape, "t.qr", :curve, [ :curve = "greatarc", :x1 = "q.sx", :y1 = "q.sy", :z1 = "q.sz",
		    :x2 = "r.sx", :y2 = "r.sy", :z2 = "r.sz", :cx = 300, :cy = 260, :r = 210,
		    :stroke = "neutral", :strokeWidth = 2 ] ],
		[ :shape, "t.pr", :curve, [ :curve = "greatarc", :x1 = "p.sx", :y1 = "p.sy", :z1 = "p.sz",
		    :x2 = "r.sx", :y2 = "r.sy", :z2 = "r.sz", :cx = 300, :cy = 260, :r = 210,
		    :stroke = "neutral", :strokeWidth = 2 ] ],
		[ :ensure, "lessThan", [ "100*t.cpq", 86 ] ], [ :ensure, "greaterThan", [ "100*t.cpq", 35 ] ],
		[ :ensure, "lessThan", [ "100*t.cqr", 86 ] ], [ :ensure, "greaterThan", [ "100*t.cqr", 35 ] ],
		[ :ensure, "lessThan", [ "100*t.cpr", 86 ] ], [ :ensure, "greaterThan", [ "100*t.cpr", 35 ] ],
		# not a sliver: the triple product is the volume the three points span
		[ :ensure, "greaterThan", [ "100*abs(p.sx*(q.sy*r.sz - q.sz*r.sy) - p.sy*(q.sx*r.sz - q.sz*r.sx) + p.sz*(q.sx*r.sy - q.sy*r.sx))", 8 ] ],
		# every vertex's name outside its angle: away from both chords
		[ :ensure, "lessThan", [ "100*((p.text.cx - p.icon.cx)*(q.icon.cx - p.icon.cx) + (p.text.cy - p.icon.cy)*(q.icon.cy - p.icon.cy)) / (sqrt((p.text.cx - p.icon.cx)^2 + (p.text.cy - p.icon.cy)^2 + 0.001) * sqrt((q.icon.cx - p.icon.cx)^2 + (q.icon.cy - p.icon.cy)^2 + 0.001))", -25 ] ],
		[ :ensure, "lessThan", [ "100*((p.text.cx - p.icon.cx)*(r.icon.cx - p.icon.cx) + (p.text.cy - p.icon.cy)*(r.icon.cy - p.icon.cy)) / (sqrt((p.text.cx - p.icon.cx)^2 + (p.text.cy - p.icon.cy)^2 + 0.001) * sqrt((r.icon.cx - p.icon.cx)^2 + (r.icon.cy - p.icon.cy)^2 + 0.001))", -25 ] ],
		[ :ensure, "lessThan", [ "100*((q.text.cx - q.icon.cx)*(p.icon.cx - q.icon.cx) + (q.text.cy - q.icon.cy)*(p.icon.cy - q.icon.cy)) / (sqrt((q.text.cx - q.icon.cx)^2 + (q.text.cy - q.icon.cy)^2 + 0.001) * sqrt((p.icon.cx - q.icon.cx)^2 + (p.icon.cy - q.icon.cy)^2 + 0.001))", -25 ] ],
		[ :ensure, "lessThan", [ "100*((q.text.cx - q.icon.cx)*(r.icon.cx - q.icon.cx) + (q.text.cy - q.icon.cy)*(r.icon.cy - q.icon.cy)) / (sqrt((q.text.cx - q.icon.cx)^2 + (q.text.cy - q.icon.cy)^2 + 0.001) * sqrt((r.icon.cx - q.icon.cx)^2 + (r.icon.cy - q.icon.cy)^2 + 0.001))", -25 ] ],
		[ :ensure, "lessThan", [ "100*((r.text.cx - r.icon.cx)*(p.icon.cx - r.icon.cx) + (r.text.cy - r.icon.cy)*(p.icon.cy - r.icon.cy)) / (sqrt((r.text.cx - r.icon.cx)^2 + (r.text.cy - r.icon.cy)^2 + 0.001) * sqrt((p.icon.cx - r.icon.cx)^2 + (p.icon.cy - r.icon.cy)^2 + 0.001))", -25 ] ],
		[ :ensure, "lessThan", [ "100*((r.text.cx - r.icon.cx)*(q.icon.cx - r.icon.cx) + (r.text.cy - r.icon.cy)*(q.icon.cy - r.icon.cy)) / (sqrt((r.text.cx - r.icon.cx)^2 + (r.text.cy - r.icon.cy)^2 + 0.001) * sqrt((q.icon.cx - r.icon.cx)^2 + (q.icon.cy - r.icon.cy)^2 + 0.001))", -25 ] ],
		[ :layer, "t.pq", :above, "_.sphere" ], [ :layer, "t.qr", :above, "_.sphere" ],
		[ :layer, "t.pr", :above, "_.sphere" ],
		[ :layer, "p.icon", :above, "t.pq" ], [ :layer, "q.icon", :above, "t.qr" ],
		[ :layer, "r.icon", :above, "t.pr" ] ])
	_o_.ForAllWhere("Angle a; Point p; Point q; Point r", "a := InteriorAngle(p, q, r)", [
		# the tangents at the vertex q, along the geodesics to p and to r
		[ :field, "a.dqp", "q.sx*p.sx + q.sy*p.sy + q.sz*p.sz" ],
		[ :field, "a.dqr", "q.sx*r.sx + q.sy*r.sy + q.sz*r.sz" ],
		[ :field, "a.t1x", "p.sx - a.dqp*q.sx" ], [ :field, "a.t1y", "p.sy - a.dqp*q.sy" ],
		[ :field, "a.t1z", "p.sz - a.dqp*q.sz" ],
		[ :field, "a.t2x", "r.sx - a.dqr*q.sx" ], [ :field, "a.t2y", "r.sy - a.dqr*q.sy" ],
		[ :field, "a.t2z", "r.sz - a.dqr*q.sz" ] ])
	_o_.ForAllWhere("Angle a; Point p; Point q; Point r",
	                "a := InteriorAngle(p, q, r); Right(a)", [
		[ :ensure, "equal", [ "100*(a.t1x*a.t2x + a.t1y*a.t2y + a.t1z*a.t2z) / (sqrt(a.t1x^2 + a.t1y^2 + a.t1z^2 + 0.000001) * sqrt(a.t2x^2 + a.t2y^2 + a.t2z^2 + 0.000001))", 0 ] ],
		# THE MARK, BENT TO THE SPHERE: its feet are walked along the great
		# circles themselves, so they land on the arcs the picture drew and
		# not on the chords between the vertices.
		[ :shape, "a.rmark", :mark, [ :mark = "rightangle", :curve = "greatarc",
		    :x1 = "q.sx", :y1 = "q.sy", :z1 = "q.sz",
		    :x2 = "p.sx", :y2 = "p.sy", :z2 = "p.sz",
		    :x3 = "r.sx", :y3 = "r.sy", :z3 = "r.sz",
		    :cx = 300, :cy = 260, :r = 210, :size = 17,
		    :stroke = "neutral", :strokeWidth = 1.5 ] ],
		[ :layer, "a.rmark", :above, "_.sphere" ] ])
	_o_.ForAllWhere("Segment s; Segment t", "EqualLength(s, t)", [
		[ :ensure, "equal", [ "100*s.cosd", "100*t.cosd" ] ],
		# and the ticks sit at the middle of the ARC, across it
		[ :shape, "s.tick", :mark, [ :mark = "tick", :curve = "greatarc",
		    :x1 = "s.icon.x1", :y1 = "s.icon.y1", :z1 = "s.icon.z1",
		    :x2 = "s.icon.x2", :y2 = "s.icon.y2", :z2 = "s.icon.z2",
		    :x3 = 0, :y3 = 0, :z3 = 0,
		    :cx = 300, :cy = 260, :r = 210, :size = 13, :ticks = 1,
		    :stroke = "neutral", :strokeWidth = 2 ] ],
		[ :shape, "t.tick", :mark, [ :mark = "tick", :curve = "greatarc",
		    :x1 = "t.icon.x1", :y1 = "t.icon.y1", :z1 = "t.icon.z1",
		    :x2 = "t.icon.x2", :y2 = "t.icon.y2", :z2 = "t.icon.z2",
		    :x3 = 0, :y3 = 0, :z3 = 0,
		    :cx = 300, :cy = 260, :r = 210, :size = 13, :ticks = 1,
		    :stroke = "neutral", :strokeWidth = 2 ] ],
		[ :layer, "s.tick", :above, "_.sphere" ],
		[ :layer, "t.tick", :above, "_.sphere" ] ])
	return _o_

# THE POINCARE DISK. The same Substance again, in hyperbolic geometry:
# Penrose's Fig. 1, right. A point is a pair inside the unit disk; a
# segment is the arc of the circle through both points orthogonal to the
# rim. Hyperbolic length is monotone in delta = |p-q|^2 / ((1-|p|^2)(1-|q|^2)),
# so equal length is equal delta and no acosh is needed. The model is
# CONFORMAL, so a hyperbolic angle is the Euclidean angle between the arcs'
# tangents at the vertex -- and the tangent at q is perpendicular to (q - c)
# for the arc's centre c. Writing c = N/D and clearing the denominators
# makes the right-angle test division-free: (D1*q - N1) . (D2*q - N2) = 0,
# which stays correct when an arc is a diameter and D is zero.
func StzHyperbolicStyle()
	_o_ = new stzMathStyle()
	_o_.SetCanvas(600, 520)
	_o_.ForAll("Point p", [
		[ :unknown, "p.hx", -0.55, 0.55 ], [ :unknown, "p.hy", -0.55, 0.55 ],
		[ :shape, "_.disk", :circle, [ :cx = 300, :cy = 260, :r = 220,
		                               :fill = [ :alpha, "primary", 0.08 ], :stroke = "muted", :strokeWidth = 1 ] ],
		[ :shape, "p.icon", :circle, [ :cx = "300 + 220*p.hx", :cy = "260 - 220*p.hy",
		                               :r = 4, :fill = "neutral" ] ],
		[ :shape, "p.text", :text, [ :fill = [ :on, "paper" ] ] ],
		[ :ensure, "lessThan", [ "100*(p.hx^2 + p.hy^2)", 64 ] ],
		[ :ensure, "disjoint", [ "p.text", "p.icon", 4 ] ],
		[ :encourage, "near", [ "p.text", "p.icon", 16 ] ],
		[ :layer, "p.icon", :above, "_.disk" ] ])
	_o_.ForAllWhere("Segment s; Point p; Point q", "s := Segment(p, q)", [
		[ :field, "s.delta", "((p.hx - q.hx)^2 + (p.hy - q.hy)^2) / ((1 - p.hx^2 - p.hy^2) * (1 - q.hx^2 - q.hy^2))" ],
		[ :shape, "s.icon", :curve, [ :curve = "poincare",
		    :x1 = "p.hx", :y1 = "p.hy", :z1 = 0, :x2 = "q.hx", :y2 = "q.hy", :z2 = 0,
		    :cx = 300, :cy = 260, :r = 220, :stroke = "neutral", :strokeWidth = 2 ] ],
		[ :ensure, "greaterThan", [ "100*s.delta", 12 ] ],
		[ :ensure, "lessThan", [ "100*s.delta", 220 ] ],
		# the name outside the angle, for every arc that leaves its point
		[ :ensure, "lessThan", [ "100*((p.text.cx - p.icon.cx)*(q.icon.cx - p.icon.cx) + (p.text.cy - p.icon.cy)*(q.icon.cy - p.icon.cy)) / (sqrt((p.text.cx - p.icon.cx)^2 + (p.text.cy - p.icon.cy)^2 + 0.001) * sqrt((q.icon.cx - p.icon.cx)^2 + (q.icon.cy - p.icon.cy)^2 + 0.001))", -25 ] ],
		[ :ensure, "lessThan", [ "100*((q.text.cx - q.icon.cx)*(p.icon.cx - q.icon.cx) + (q.text.cy - q.icon.cy)*(p.icon.cy - q.icon.cy)) / (sqrt((q.text.cx - q.icon.cx)^2 + (q.text.cy - q.icon.cy)^2 + 0.001) * sqrt((p.icon.cx - q.icon.cx)^2 + (p.icon.cy - q.icon.cy)^2 + 0.001))", -25 ] ],
		[ :layer, "s.icon", :above, "_.disk" ],
		[ :layer, "p.icon", :above, "s.icon" ], [ :layer, "q.icon", :above, "s.icon" ] ])
	_o_.ForAllWhere("Triangle t; Point p; Point q; Point r", "t := Triangle(p, q, r)", [
		[ :field, "t.dpq", "((p.hx - q.hx)^2 + (p.hy - q.hy)^2) / ((1 - p.hx^2 - p.hy^2) * (1 - q.hx^2 - q.hy^2))" ],
		[ :field, "t.dqr", "((q.hx - r.hx)^2 + (q.hy - r.hy)^2) / ((1 - q.hx^2 - q.hy^2) * (1 - r.hx^2 - r.hy^2))" ],
		[ :field, "t.dpr", "((p.hx - r.hx)^2 + (p.hy - r.hy)^2) / ((1 - p.hx^2 - p.hy^2) * (1 - r.hx^2 - r.hy^2))" ],
		[ :shape, "t.pq", :curve, [ :curve = "poincare", :x1 = "p.hx", :y1 = "p.hy", :z1 = 0,
		    :x2 = "q.hx", :y2 = "q.hy", :z2 = 0, :cx = 300, :cy = 260, :r = 220,
		    :stroke = "neutral", :strokeWidth = 2 ] ],
		[ :shape, "t.qr", :curve, [ :curve = "poincare", :x1 = "q.hx", :y1 = "q.hy", :z1 = 0,
		    :x2 = "r.hx", :y2 = "r.hy", :z2 = 0, :cx = 300, :cy = 260, :r = 220,
		    :stroke = "neutral", :strokeWidth = 2 ] ],
		[ :shape, "t.pr", :curve, [ :curve = "poincare", :x1 = "p.hx", :y1 = "p.hy", :z1 = 0,
		    :x2 = "r.hx", :y2 = "r.hy", :z2 = 0, :cx = 300, :cy = 260, :r = 220,
		    :stroke = "neutral", :strokeWidth = 2 ] ],
		[ :ensure, "greaterThan", [ "100*t.dpq", 12 ] ], [ :ensure, "lessThan", [ "100*t.dpq", 220 ] ],
		[ :ensure, "greaterThan", [ "100*t.dqr", 12 ] ], [ :ensure, "lessThan", [ "100*t.dqr", 220 ] ],
		[ :ensure, "greaterThan", [ "100*t.dpr", 12 ] ], [ :ensure, "lessThan", [ "100*t.dpr", 220 ] ],
		# not a sliver, in the disk's own coordinates
		[ :ensure, "greaterThan", [ "100*abs((q.hx - p.hx)*(r.hy - p.hy) - (q.hy - p.hy)*(r.hx - p.hx))", 4 ] ],
		# every vertex's name outside its angle: away from both chords
		[ :ensure, "lessThan", [ "100*((p.text.cx - p.icon.cx)*(q.icon.cx - p.icon.cx) + (p.text.cy - p.icon.cy)*(q.icon.cy - p.icon.cy)) / (sqrt((p.text.cx - p.icon.cx)^2 + (p.text.cy - p.icon.cy)^2 + 0.001) * sqrt((q.icon.cx - p.icon.cx)^2 + (q.icon.cy - p.icon.cy)^2 + 0.001))", -25 ] ],
		[ :ensure, "lessThan", [ "100*((p.text.cx - p.icon.cx)*(r.icon.cx - p.icon.cx) + (p.text.cy - p.icon.cy)*(r.icon.cy - p.icon.cy)) / (sqrt((p.text.cx - p.icon.cx)^2 + (p.text.cy - p.icon.cy)^2 + 0.001) * sqrt((r.icon.cx - p.icon.cx)^2 + (r.icon.cy - p.icon.cy)^2 + 0.001))", -25 ] ],
		[ :ensure, "lessThan", [ "100*((q.text.cx - q.icon.cx)*(p.icon.cx - q.icon.cx) + (q.text.cy - q.icon.cy)*(p.icon.cy - q.icon.cy)) / (sqrt((q.text.cx - q.icon.cx)^2 + (q.text.cy - q.icon.cy)^2 + 0.001) * sqrt((p.icon.cx - q.icon.cx)^2 + (p.icon.cy - q.icon.cy)^2 + 0.001))", -25 ] ],
		[ :ensure, "lessThan", [ "100*((q.text.cx - q.icon.cx)*(r.icon.cx - q.icon.cx) + (q.text.cy - q.icon.cy)*(r.icon.cy - q.icon.cy)) / (sqrt((q.text.cx - q.icon.cx)^2 + (q.text.cy - q.icon.cy)^2 + 0.001) * sqrt((r.icon.cx - q.icon.cx)^2 + (r.icon.cy - q.icon.cy)^2 + 0.001))", -25 ] ],
		[ :ensure, "lessThan", [ "100*((r.text.cx - r.icon.cx)*(p.icon.cx - r.icon.cx) + (r.text.cy - r.icon.cy)*(p.icon.cy - r.icon.cy)) / (sqrt((r.text.cx - r.icon.cx)^2 + (r.text.cy - r.icon.cy)^2 + 0.001) * sqrt((p.icon.cx - r.icon.cx)^2 + (p.icon.cy - r.icon.cy)^2 + 0.001))", -25 ] ],
		[ :ensure, "lessThan", [ "100*((r.text.cx - r.icon.cx)*(q.icon.cx - r.icon.cx) + (r.text.cy - r.icon.cy)*(q.icon.cy - r.icon.cy)) / (sqrt((r.text.cx - r.icon.cx)^2 + (r.text.cy - r.icon.cy)^2 + 0.001) * sqrt((q.icon.cx - r.icon.cx)^2 + (q.icon.cy - r.icon.cy)^2 + 0.001))", -25 ] ],
		[ :layer, "t.pq", :above, "_.disk" ], [ :layer, "t.qr", :above, "_.disk" ],
		[ :layer, "t.pr", :above, "_.disk" ],
		[ :layer, "p.icon", :above, "t.pq" ], [ :layer, "q.icon", :above, "t.qr" ],
		[ :layer, "r.icon", :above, "t.pr" ] ])
	_o_.ForAllWhere("Angle a; Point p; Point q; Point r", "a := InteriorAngle(p, q, r)", [
		# the arc through q and p: centre c1 = N1 / D1
		[ :field, "a.kq", "(1 + q.hx^2 + q.hy^2) / 2" ],
		[ :field, "a.kp", "(1 + p.hx^2 + p.hy^2) / 2" ],
		[ :field, "a.kr", "(1 + r.hx^2 + r.hy^2) / 2" ],
		[ :field, "a.d1", "q.hx*p.hy - q.hy*p.hx" ],
		[ :field, "a.n1x", "a.kq*p.hy - a.kp*q.hy" ], [ :field, "a.n1y", "q.hx*a.kp - p.hx*a.kq" ],
		[ :field, "a.d2", "q.hx*r.hy - q.hy*r.hx" ],
		[ :field, "a.n2x", "a.kq*r.hy - a.kr*q.hy" ], [ :field, "a.n2y", "q.hx*a.kr - r.hx*a.kq" ],
		# D*q - N: the direction from the centre to q, denominators cleared
		[ :field, "a.v1x", "a.d1*q.hx - a.n1x" ], [ :field, "a.v1y", "a.d1*q.hy - a.n1y" ],
		[ :field, "a.v2x", "a.d2*q.hx - a.n2x" ], [ :field, "a.v2y", "a.d2*q.hy - a.n2y" ] ])
	_o_.ForAllWhere("Angle a; Point p; Point q; Point r",
	                "a := InteriorAngle(p, q, r); Right(a)", [
		[ :ensure, "equal", [ "100*(a.v1x*a.v2x + a.v1y*a.v2y) / (sqrt(a.v1x^2 + a.v1y^2 + 0.000001) * sqrt(a.v2x^2 + a.v2y^2 + 0.000001))", 0 ] ],
		# THE MARK, BENT TO THE DISK: its feet are rotated about each
		# geodesic's own centre, so they sit on the arcs. The model is
		# conformal, so the square it draws IS the hyperbolic right angle.
		[ :shape, "a.rmark", :mark, [ :mark = "rightangle", :curve = "poincare",
		    :x1 = "q.hx", :y1 = "q.hy", :z1 = 0,
		    :x2 = "p.hx", :y2 = "p.hy", :z2 = 0,
		    :x3 = "r.hx", :y3 = "r.hy", :z3 = 0,
		    :cx = 300, :cy = 260, :r = 220, :size = 17,
		    :stroke = "neutral", :strokeWidth = 1.5 ] ],
		[ :layer, "a.rmark", :above, "_.disk" ] ])
	_o_.ForAllWhere("Segment s; Segment t", "EqualLength(s, t)", [
		[ :ensure, "equal", [ "100*s.delta", "100*t.delta" ] ],
		[ :shape, "s.tick", :mark, [ :mark = "tick", :curve = "poincare",
		    :x1 = "s.icon.x1", :y1 = "s.icon.y1", :z1 = 0,
		    :x2 = "s.icon.x2", :y2 = "s.icon.y2", :z2 = 0,
		    :x3 = 0, :y3 = 0, :z3 = 0,
		    :cx = 300, :cy = 260, :r = 220, :size = 13, :ticks = 1,
		    :stroke = "neutral", :strokeWidth = 2 ] ],
		[ :shape, "t.tick", :mark, [ :mark = "tick", :curve = "poincare",
		    :x1 = "t.icon.x1", :y1 = "t.icon.y1", :z1 = 0,
		    :x2 = "t.icon.x2", :y2 = "t.icon.y2", :z2 = 0,
		    :x3 = 0, :y3 = 0, :z3 = 0,
		    :cx = 300, :cy = 260, :r = 220, :size = 13, :ticks = 1,
		    :stroke = "neutral", :strokeWidth = 2 ] ],
		[ :layer, "s.tick", :above, "_.disk" ],
		[ :layer, "t.tick", :above, "_.disk" ] ])
	return _o_

# BLOBS -- Penrose's own, and the gallery's first use of a spline: the SAME
# set-theory substance the Euler style reads, each set a wobbly closed curve
# instead of a disk. The wobble is eight unknowns per set in a narrow range
# that NO term references, so the solver leaves them where the seed put
# them and every seed gives a different blob. The containment and
# separation are solved on a hidden circle, padded by the wobble it must
# cover, and the drawn curve follows.
func StzBlobStyle()
	_o_ = new stzMathStyle()
	_o_.SetCanvas(800, 700)
	_o_.ForAll("Set x", [
		[ :shape, "x.icon", :circle, [ :hidden = 1 ] ],
		[ :shape, "x.text", :text, [ :fill = [ :on, "x.blob" ] ] ],
		[ :unknown, "x.w1", -0.12, 0.12 ], [ :unknown, "x.w2", -0.12, 0.12 ],
		[ :unknown, "x.w3", -0.12, 0.12 ], [ :unknown, "x.w4", -0.12, 0.12 ],
		[ :unknown, "x.w5", -0.12, 0.12 ], [ :unknown, "x.w6", -0.12, 0.12 ],
		[ :unknown, "x.w7", -0.12, 0.12 ], [ :unknown, "x.w8", -0.12, 0.12 ],
		# eight points around the hidden circle, each at its own radius
		[ :shape, "x.blob", :spline, [ :n = 8, :closed = 1,
		    :x1 = "x.icon.cx + x.icon.r*(1 + x.w1)", :y1 = "x.icon.cy",
		    :x2 = "x.icon.cx + 0.70711*x.icon.r*(1 + x.w2)", :y2 = "x.icon.cy - 0.70711*x.icon.r*(1 + x.w2)",
		    :x3 = "x.icon.cx", :y3 = "x.icon.cy - x.icon.r*(1 + x.w3)",
		    :x4 = "x.icon.cx - 0.70711*x.icon.r*(1 + x.w4)", :y4 = "x.icon.cy - 0.70711*x.icon.r*(1 + x.w4)",
		    :x5 = "x.icon.cx - x.icon.r*(1 + x.w5)", :y5 = "x.icon.cy",
		    :x6 = "x.icon.cx - 0.70711*x.icon.r*(1 + x.w6)", :y6 = "x.icon.cy + 0.70711*x.icon.r*(1 + x.w6)",
		    :x7 = "x.icon.cx", :y7 = "x.icon.cy + x.icon.r*(1 + x.w7)",
		    :x8 = "x.icon.cx + 0.70711*x.icon.r*(1 + x.w8)", :y8 = "x.icon.cy + 0.70711*x.icon.r*(1 + x.w8)",
		    :fill = [ :alpha, "primary", 0.2 ], :stroke = "neutral", :strokeWidth = 1.5 ] ],
		# A RANGE ON AN UNKNOWN IS WHERE IT STARTS, NOT WHERE IT MAY GO. The
		# spline's points are derived from the wobbles, the on-canvas rule
		# reaches those points, and so the solver moved the wobbles with
		# nothing holding them: the first blobs grew tendrils twice the
		# canvas. A wobble is BOUNDED in the energy here, as every other
		# quantity with a range must be.
		[ :ensure, "inRange", [ "x.w1", -0.12, 0.12 ] ], [ :ensure, "inRange", [ "x.w2", -0.12, 0.12 ] ],
		[ :ensure, "inRange", [ "x.w3", -0.12, 0.12 ] ], [ :ensure, "inRange", [ "x.w4", -0.12, 0.12 ] ],
		[ :ensure, "inRange", [ "x.w5", -0.12, 0.12 ] ], [ :ensure, "inRange", [ "x.w6", -0.12, 0.12 ] ],
		[ :ensure, "inRange", [ "x.w7", -0.12, 0.12 ] ], [ :ensure, "inRange", [ "x.w8", -0.12, 0.12 ] ],
		[ :ensure, "greaterThan", [ "x.icon.r", 30 ] ],
		[ :ensure, "contains", [ "x.icon", "x.text", "0.12*x.icon.r + 4" ] ],
		[ :encourage, "sameCenter", [ "x.text", "x.icon" ] ],
		[ :layer, "x.text", :above, "x.blob" ] ])
	_o_.ForAllWhere("Set x; Set y", "Subset(x, y)", [
		# padded by the most either wobble can reach toward the other
		[ :ensure, "contains", [ "y.icon", "x.icon", "0.12*(x.icon.r + y.icon.r) + 6" ] ],
		[ :ensure, "disjoint", [ "y.text", "x.icon", "0.12*x.icon.r + 8" ] ],
		[ :layer, "x.blob", :above, "y.blob" ] ])
	_o_.ForAllWhere("Set x; Set y", "Disjoint(x, y)", [
		[ :ensure, "disjoint", [ "x.icon", "y.icon", "0.12*(x.icon.r + y.icon.r) + 4" ] ] ])
	_o_.ForAllWhere("Set x; Set y", "Intersecting(x, y)", [
		[ :ensure, "overlapping", [ "x.icon", "y.icon", "0.12*(x.icon.r + y.icon.r) + 10" ] ],
		[ :ensure, "disjoint", [ "y.text", "x.icon", "0.12*x.icon.r" ] ],
		[ :ensure, "disjoint", [ "x.text", "y.icon", "0.12*y.icon.r" ] ] ])
	return _o_

# SETS IN 2.5D -- Penrose's, and the seven-set tree's FOURTH reading after
# disks, a tree and blobs. The diagram is SOLVED as disks, exactly as the
# Euler style solves it, and DRAWN as their image under one affine map:
# y flattened to 0.55 about a horizontal axis. An affine map preserves
# containment and disjointness, so every relation the disks satisfied the
# ellipses satisfy too, with no ellipse ever entering a constraint. A
# shadow under each disk carries the depth.
func StzEuler25DStyle()
	_o_ = new stzMathStyle()
	_o_.SetCanvas(800, 700)
	_o_.ForAll("Set x", [
		[ :shape, "x.icon", :circle, [ :hidden = 1 ] ],
		[ :shape, "x.text", :text, [ :fill = [ :on, "x.disk" ] ] ],
		[ :shape, "x.shadow", :ellipse, [
		    :cx = "x.icon.cx + 6", :cy = "350 + 0.55*(x.icon.cy - 350) + 9",
		    :rx = "x.icon.r", :ry = "0.55*x.icon.r", :fill = [ :alpha, "neutral", 0.15 ] ] ],
		[ :shape, "x.disk", :ellipse, [
		    :cx = "x.icon.cx", :cy = "350 + 0.55*(x.icon.cy - 350)",
		    :rx = "x.icon.r", :ry = "0.55*x.icon.r",
		    :fill = [ :alpha, "primary", 0.23 ], :stroke = "neutral", :strokeWidth = 1.5 ] ],
		# the name at the flattened centre; the disk large enough that the
		# name, which is NOT flattened, still fits the ellipse's short axis
		[ :override, "x.text.cx", "x.icon.cx" ],
		[ :override, "x.text.cy", "350 + 0.55*(x.icon.cy - 350)" ],
		# a box the name would need in disk space, for the rules to hold
		# other disks off it
		[ :shape, "x.lbox", :rect, [ :cx = "x.icon.cx", :cy = "x.icon.cy",
		    :w = "x.text.w + 10", :h = "x.text.h / 0.55 + 10", :hidden = 1 ] ],
		[ :ensure, "greaterThan", [ "x.icon.r", "x.text.h + 16" ] ],
		[ :ensure, "greaterThan", [ "x.icon.r", 30 ] ],
		[ :layer, "x.disk", :above, "x.shadow" ], [ :layer, "x.text", :above, "x.disk" ] ])
	_o_.ForAllWhere("Set x; Set y", "Subset(x, y)", [
		[ :ensure, "contains", [ "y.icon", "x.icon", 8 ] ],
		[ :ensure, "disjoint", [ "y.lbox", "x.icon", 4 ] ],
		[ :layer, "x.shadow", :above, "y.disk" ], [ :layer, "x.disk", :above, "y.disk" ] ])
	_o_.ForAllWhere("Set x; Set y", "Disjoint(x, y)", [
		[ :ensure, "disjoint", [ "x.icon", "y.icon", 6 ] ] ])
	_o_.ForAllWhere("Set x; Set y", "Intersecting(x, y)", [
		[ :ensure, "overlapping", [ "x.icon", "y.icon", 20 ] ],
		[ :ensure, "disjoint", [ "y.lbox", "x.icon", 0 ] ],
		[ :ensure, "disjoint", [ "x.lbox", "y.icon", 0 ] ] ])
	return _o_

# ELLIPSE RAYS -- Penrose's, and Byrne's kill for a conic. An ellipse and
# its two foci; each ray leaves one focus, meets the curve at a point the
# solver chooses, and continues to the other focus. The substance says
# none of the optics. The reflection law -- the ray in and the ray out make
# the same angle with the tangent -- and the string property -- the two
# legs sum to the major axis -- are read back from the solved picture.
func StzConicDomain()
	_o_ = new stzMathDomain("conic")
	_o_.AddType("Ellipse")
	_o_.AddType("Ray")
	_o_.AddFunction("RayOf", [ "Ellipse" ], "Ray")
	return _o_

func StzEllipseRaysStyle()
	_o_ = new stzMathStyle()
	_o_.SetCanvas(720, 520)
	_o_.ForAll("Ellipse e", [
		[ :shape, "e.icon", :ellipse, [ :cx = 360, :cy = 255, :rx = 250, :ry = 150,
		                                :fill = [ :alpha, "primary", 0.08 ], :stroke = "neutral", :strokeWidth = 2 ] ],
		# the foci: c = sqrt(rx^2 - ry^2) either side of the centre
		[ :field, "e.c", "sqrt(e.icon.rx^2 - e.icon.ry^2)" ],
		[ :shape, "e.f1", :circle, [ :cx = "e.icon.cx - e.c", :cy = "e.icon.cy", :r = 5, :fill = "primary" ] ],
		[ :shape, "e.f2", :circle, [ :cx = "e.icon.cx + e.c", :cy = "e.icon.cy", :r = 5, :fill = "primary" ] ],
		[ :layer, "e.f1", :above, "e.icon" ], [ :layer, "e.f2", :above, "e.icon" ] ])
	_o_.ForAllWhere("Ray r; Ellipse e", "r := RayOf(e)", [
		# where the ray meets the curve is the solver's: one parameter,
		# bounded in the energy and not only at its start
		[ :unknown, "r.t", 0.2, 6.1 ],
		[ :ensure, "inRange", [ "r.t", 0.05, 6.25 ] ],
		[ :shape, "r.hit", :circle, [ :cx = "e.icon.cx + e.icon.rx*cos(r.t)",
		                              :cy = "e.icon.cy + e.icon.ry*sin(r.t)",
		                              :r = 3.5, :fill = "neutral" ] ],
		# the hit stays off the major vertices, where a ray's two legs would
		# lie along the axis and over each other
		[ :ensure, "greaterThan", [ "abs(sin(r.t))", 0.3 ] ],
		# the full legs, hidden, and the drawn legs stopping short of both
		# foci: six heads on one focus made a blot
		[ :shape, "r.l1", :line, [ :x1 = "e.f1.cx", :y1 = "e.f1.cy", :x2 = "r.hit.cx", :y2 = "r.hit.cy", :hidden = 1 ] ],
		[ :shape, "r.l2", :line, [ :x1 = "r.hit.cx", :y1 = "r.hit.cy", :x2 = "e.f2.cx", :y2 = "e.f2.cy", :hidden = 1 ] ],
		[ :shape, "r.leg1", :line, [ :x1 = "e.f1.cx + 9*ux(r.l1)", :y1 = "e.f1.cy + 9*uy(r.l1)",
		                             :x2 = "r.hit.cx", :y2 = "r.hit.cy",
		                             :stroke = "primary", :strokeWidth = 1.5, :arrow = "end" ] ],
		[ :shape, "r.leg2", :line, [ :x1 = "r.hit.cx", :y1 = "r.hit.cy",
		                             :x2 = "e.f2.cx - 14*ux(r.l2)", :y2 = "e.f2.cy - 14*uy(r.l2)",
		                             :stroke = "neutral", :strokeWidth = 1.5, :arrow = "end" ] ],
		[ :layer, "r.leg1", :above, "e.icon" ], [ :layer, "r.leg2", :above, "e.icon" ],
		[ :layer, "r.hit", :above, "r.leg1" ], [ :layer, "r.hit", :above, "r.leg2" ],
		[ :layer, "e.f1", :above, "r.leg1" ], [ :layer, "e.f2", :above, "r.leg2" ] ])
	# the rays spread around the curve rather than bunching
	_o_.ForAll("Ray r; Ray s", [
		[ :encourage, "notTooClose", [ "r.hit", "s.hit", 4 ] ] ])
	return _o_

#---------------------------------------------------------------------#
#  ONE GATE (DN8c): the visual contract over a MATH picture, as rules   #
#---------------------------------------------------------------------#
#
# The graph plane judges its pictures by scoped rules -- each states the
# subjects it governs, separately from what it asserts -- run by one
# governance over a corpus, and the notation catalogue is that corpus.
# These are the same contract's rules for a picture the SOLVER made:
# names off ink, names off names, a point's dot above the figure, nothing
# off the paper. The diagram's own constraints are not restated here: a
# math diagram already speaks the finding shape through Violations(),
# and the one gate ingests those beside these.
#
# The subject keys are spelled as the plastic rules spell theirs --
# "text:A.text", "pair:A.text|B.text", "dot:B.icon", "shape:q1.arc" --
# so the governance can tell two rules reaching for one subject.

# every drawn shape's ink as segments: [ x1, y1, x2, y2, cOwner, cPath ]
# A NAME AS A HASH-LIST KEY (DN8f). Ring's hash list looks a string key up
# in constant time -- measured: thirty thousand keys, twelve milliseconds
# for thirty thousand lookups -- and it FOLDS CASE, so "A.icon" and
# "a.icon" would be one key. The positions of the capitals are appended
# and the two names stay apart. Every index this plane keeps is a plain
# list member, copied with its object the way Ring copies everything, so
# a copy never shares a stale table with its original.
func _MdKey(pc)
	_c_ = "" + pc
	_m_ = "|"
	_n_ = len(_c_)
	for _i_ = 1 to _n_
		_a_ = ascii(_c_[_i_])
		if _a_ >= 65 and _a_ <= 90  _m_ += ("" + _i_ + ",")  ok
	next
	return _c_ + _m_

func _MrInk(poDg)
	_a_ = []
	_ac_ = poDg.Shapes()
	for _i_ = 1 to len(_ac_)
		_cP_ = _ac_[_i_]
		if poDg.IsHidden(_cP_)  loop  ok
		_s_ = poDg.ShapeOf(_cP_)
		_cO_ = poDg.ShapeOwnerOf(_cP_)
		_k_ = _s_[:kind]
		if _k_ = "line"
			_a_ + [ _s_[:x1], _s_[:y1], _s_[:x2], _s_[:y2], _cO_, _cP_ ]
			# AN ARROWHEAD IS INK. It is painted at draw time from the line's
			# end, as a filled triangle the width of the stroke -- so it was
			# never a shape, and a name sitting on it passed every rule
			# until the author marked it. The same triangle the painter
			# draws is what the rule reads.
			_cAr_ = "" + poDg.PropOf(_cP_, "arrow", "")
			_nSw_ = poDg.PropOf(_cP_, "strokeWidth", 1)
			if _cAr_ = "end" or _cAr_ = "both"
				_MrAddPolyline(_a_, _MrHead(_s_[:x1], _s_[:y1], _s_[:x2], _s_[:y2], _nSw_), TRUE, _cO_, _cP_)
			ok
			if _cAr_ = "start" or _cAr_ = "both"
				_MrAddPolyline(_a_, _MrHead(_s_[:x2], _s_[:y2], _s_[:x1], _s_[:y1], _nSw_), TRUE, _cO_, _cP_)
			ok
		but _k_ = "curve"
			_MrAddPolyline(_a_, poDg.CurvePointsOf(_cP_), FALSE, _cO_, _cP_)
		but _k_ = "spline"
			_MrAddPolyline(_a_, poDg.SplinePointsOf(_cP_), _s_[:closed] = 1, _cO_, _cP_)
		but _k_ = "poly"
			_MrAddPolyline(_a_, _s_[:points], TRUE, _cO_, _cP_)
		but _k_ = "circle"
			# a dot is a point, not ink a name must avoid; a disk's rim is
			if _s_[:r] > 6
				_MrAddPolyline(_a_, _MrRim(_s_[:cx], _s_[:cy], _s_[:r], _s_[:r]), TRUE, _cO_, _cP_)
			ok
		but _k_ = "ellipse"
			_MrAddPolyline(_a_, _MrRim(_s_[:cx], _s_[:cy], _s_[:rx], _s_[:ry]), TRUE, _cO_, _cP_)
		but _k_ = "rect"
			_hw_ = _s_[:w] / 2  _hh_ = _s_[:h] / 2
			_MrAddPolyline(_a_, [ _s_[:cx] - _hw_, _s_[:cy] - _hh_, _s_[:cx] + _hw_, _s_[:cy] - _hh_,
			                       _s_[:cx] + _hw_, _s_[:cy] + _hh_, _s_[:cx] - _hw_, _s_[:cy] + _hh_ ],
			                TRUE, _cO_, _cP_)
		ok
	next
	return _a_

func _MrAddPolyline(paInk, paP, pbClosed, pcOwner, pcPath)
	_n_ = len(paP) / 2
	if _n_ < 2  return  ok
	_m_ = _n_ - 1
	if pbClosed  _m_ = _n_  ok
	for _i_ = 1 to _m_
		_j_ = _i_ + 1
		if _j_ > _n_  _j_ = 1  ok
		paInk + [ paP[2*_i_-1], paP[2*_i_], paP[2*_j_-1], paP[2*_j_], pcOwner, pcPath ]
	next

# the head's triangle, exactly as _DrawHead lays it: tip at the end,
# length 8 + 2.5 sw, half-width 3.5 + 1.2 sw
func _MrHead(px1, py1, px2, py2, pnSw)
	_dx_ = px2 - px1  _dy_ = py2 - py1
	_L_ = sqrt(_dx_ * _dx_ + _dy_ * _dy_)
	if _L_ < 0.001  return []  ok
	_ux_ = _dx_ / _L_  _uy_ = _dy_ / _L_
	_nLen_ = 8 + 2.5 * pnSw
	_nHalf_ = 3.5 + 1.2 * pnSw
	_bx_ = px2 - _nLen_ * _ux_  _by_ = py2 - _nLen_ * _uy_
	return [ px2, py2, _bx_ - _nHalf_ * _uy_, _by_ + _nHalf_ * _ux_,
	         _bx_ + _nHalf_ * _uy_, _by_ - _nHalf_ * _ux_ ]

func _MrRim(pnCx, pnCy, pnRx, pnRy)
	_a_ = []
	for _k_ = 0 to 23
		_t_ = 6.28318530717959 * _k_ / 24
		_a_ + (pnCx + pnRx * cos(_t_))
		_a_ + (pnCy + pnRy * sin(_t_))
	next
	return _a_

# the signed distance from a text's box to a segment, exact for the box:
# positive is clear, negative is overlap
func _MrBoxGap(paBox, paSeg)
	_dx_ = paSeg[3] - paSeg[1]  _dy_ = paSeg[4] - paSeg[2]
	_L_ = _dx_ * _dx_ + _dy_ * _dy_
	_t_ = 0
	if _L_ > 0.000001
		_t_ = ((paBox[1] - paSeg[1]) * _dx_ + (paBox[2] - paSeg[2]) * _dy_) / _L_
		if _t_ < 0  _t_ = 0  ok
		if _t_ > 1  _t_ = 1  ok
	ok
	_qx_ = fabs(paSeg[1] + _t_ * _dx_ - paBox[1]) - paBox[3] / 2
	_qy_ = fabs(paSeg[2] + _t_ * _dy_ - paBox[2]) - paBox[4] / 2
	_mx_ = _qx_  if _qy_ > _mx_  _mx_ = _qy_  ok
	_ax_ = _qx_  if _ax_ < 0  _ax_ = 0  ok
	_ay_ = _qy_  if _ay_ < 0  _ay_ = 0  ok
	_sd_ = sqrt(_ax_ * _ax_ + _ay_ * _ay_)
	if _mx_ < 0  _sd_ += _mx_  ok
	return _sd_

# the names that are drawn: non-empty, not hidden
func _MrTexts(poDg)
	_a_ = []
	_ac_ = poDg.Shapes()
	for _i_ = 1 to len(_ac_)
		if poDg.ShapeOf(_ac_[_i_])[:kind] != "text"  loop  ok
		if poDg.IsHidden(_ac_[_i_])  loop  ok
		if "" + poDg.PropOf(_ac_[_i_], "string", "") = ""  loop  ok
		_a_ + _ac_[_i_]
	next
	return _a_

func _MrBoxOf(poDg, pcText)
	_s_ = poDg.ShapeOf(pcText)
	return [ _s_[:cx], _s_[:cy], _s_[:w], _s_[:h] ]

# is (x, y) inside a closed polygon? ray casting, even-odd
func _MrPointIn(pnX, pnY, paPoly)
	_n_ = len(paPoly) / 2
	_bIn_ = FALSE
	_j_ = _n_
	for _i_ = 1 to _n_
		_xi_ = paPoly[2*_i_-1]  _yi_ = paPoly[2*_i_]
		_xj_ = paPoly[2*_j_-1]  _yj_ = paPoly[2*_j_]
		if ((_yi_ > pnY) != (_yj_ > pnY)) and
		   (pnX < (_xj_ - _xi_) * (pnY - _yi_) / (_yj_ - _yi_ + 0.000001) + _xi_)
			_bIn_ = NOT _bIn_
		ok
		_j_ = _i_
	next
	return _bIn_

# the filled region of a shape as a polygon, or [] for one that has none
func _MrRegion(poDg, pcPath)
	_s_ = poDg.ShapeOf(pcPath)
	_k_ = _s_[:kind]
	# the RESOLVED fill: a fill may be a rule, and a rule is a list
	if "" + poDg.FillOf(pcPath) = ""  return []  ok
	if _k_ = "poly"  return _s_[:points]  ok
	if _k_ = "spline" and _s_[:closed] = 1  return _s_[:points]  ok
	if _k_ = "circle"  return _MrRim(_s_[:cx], _s_[:cy], _s_[:r], _s_[:r])  ok
	if _k_ = "ellipse"  return _MrRim(_s_[:cx], _s_[:cy], _s_[:rx], _s_[:ry])  ok
	if _k_ = "rect"
		_hw_ = _s_[:w] / 2  _hh_ = _s_[:h] / 2
		return [ _s_[:cx] - _hw_, _s_[:cy] - _hh_, _s_[:cx] + _hw_, _s_[:cy] - _hh_,
		         _s_[:cx] + _hw_, _s_[:cy] + _hh_, _s_[:cx] - _hw_, _s_[:cy] + _hh_ ]
	ok
	return []

# the extent of a drawn shape: [ xmin, ymin, xmax, ymax ]
func _MrExtent(poDg, pcPath)
	_s_ = poDg.ShapeOf(pcPath)
	_k_ = _s_[:kind]
	_aP_ = []
	if _k_ = "line"
		_aP_ = [ _s_[:x1], _s_[:y1], _s_[:x2], _s_[:y2] ]
	but _k_ = "curve"
		_aP_ = poDg.CurvePointsOf(pcPath)
	but _k_ = "spline"
		_aP_ = _s_[:points]
	but _k_ = "poly"
		_aP_ = _s_[:points]
	but _k_ = "circle"
		_aP_ = [ _s_[:cx] - _s_[:r], _s_[:cy] - _s_[:r], _s_[:cx] + _s_[:r], _s_[:cy] + _s_[:r] ]
	but _k_ = "ellipse"
		_aP_ = [ _s_[:cx] - _s_[:rx], _s_[:cy] - _s_[:ry], _s_[:cx] + _s_[:rx], _s_[:cy] + _s_[:ry] ]
	but _k_ = "rect" or _k_ = "text"
		_aP_ = [ _s_[:cx] - _s_[:w] / 2, _s_[:cy] - _s_[:h] / 2, _s_[:cx] + _s_[:w] / 2, _s_[:cy] + _s_[:h] / 2 ]
	else
		return []
	ok
	if len(_aP_) < 2  return []  ok
	_e_ = [ _aP_[1], _aP_[2], _aP_[1], _aP_[2] ]
	for _i_ = 1 to len(_aP_) / 2
		if _aP_[2*_i_-1] < _e_[1]  _e_[1] = _aP_[2*_i_-1]  ok
		if _aP_[2*_i_] < _e_[2]  _e_[2] = _aP_[2*_i_]  ok
		if _aP_[2*_i_-1] > _e_[3]  _e_[3] = _aP_[2*_i_-1]  ok
		if _aP_[2*_i_] > _e_[4]  _e_[4] = _aP_[2*_i_]  ok
	next
	return _e_

# THE RULES, each with the subjects it governs and the subjects it must not.
func StzMathRuleSet()
	_ao_ = []

	_o1_ = StzPlasticRule("name_off_ink")
	_o1_.SetClaim("a name's box clears every stroke that is not its own object's")
	_o1_.SetOrder(10)
	_o1_.SetReads([ "text.box", "ink" ])
	_o1_.SetScope(func(oDg) {
		_r_ = []
		_ac_ = _MrTexts(oDg)
		for _i_ = 1 to len(_ac_)  _r_ + ("text:" + _ac_[_i_])  next
		return _r_
	})
	_o1_.SetCounter(func(oDg) {
		# an empty name, or a hidden one, is not a name a reader sees
		_r_ = []
		_ac_ = oDg.Shapes()
		for _i_ = 1 to len(_ac_)
			if oDg.ShapeOf(_ac_[_i_])[:kind] != "text"  loop  ok
			if oDg.IsHidden(_ac_[_i_]) or "" + oDg.PropOf(_ac_[_i_], "string", "") = ""
				_r_ + ("text:" + _ac_[_i_])
			ok
		next
		return _r_
	})
	_o1_.SetClaimCheck(func(oDg, cSub) {
		_cT_ = StzStringSection(cSub, 6, len(cSub))
		_aB_ = _MrBoxOf(oDg, _cT_)
		_cO_ = oDg.ShapeOwnerOf(_cT_)
		_aI_ = oDg.Ink()
		for _i_ = 1 to len(_aI_)
			if _aI_[_i_][5] = _cO_  loop  ok
			_g_ = _MrBoxGap(_aB_, _aI_[_i_])
			if _g_ < 0.5
				return [ FALSE, "'" + _cT_ + "' is " + _g_ + "px from the ink of '" +
					_aI_[_i_][6] + "'" ]
			ok
		next
		return [ TRUE, "" ]
	})
	_ao_ + _o1_

	_o2_ = StzPlasticRule("name_off_name")
	_o2_.SetClaim("no two names overlap")
	_o2_.SetOrder(11)
	_o2_.SetReads([ "text.box" ])
	_o2_.SetScope(func(oDg) {
		_r_ = []
		_ac_ = _MrTexts(oDg)
		for _i_ = 1 to len(_ac_)
			for _j_ = _i_ + 1 to len(_ac_)
				_r_ + ("pair:" + _ac_[_i_] + "|" + _ac_[_j_])
			next
		next
		return _r_
	})
	_o2_.SetCounter(func(oDg) {
		# a pair with an empty or hidden name is no pair a reader sees
		_r_ = []
		_ac_ = oDg.Shapes()
		_acT_ = _MrTexts(oDg)
		for _i_ = 1 to len(_ac_)
			if oDg.ShapeOf(_ac_[_i_])[:kind] != "text"  loop  ok
			if oDg.IsHidden(_ac_[_i_]) or "" + oDg.PropOf(_ac_[_i_], "string", "") = ""
				for _j_ = 1 to len(_acT_)
					_r_ + ("pair:" + _ac_[_i_] + "|" + _acT_[_j_])
				next
			ok
		next
		return _r_
	})
	_o2_.SetClaimCheck(func(oDg, cSub) {
		_c_ = StzStringSection(cSub, 6, len(cSub))
		_ac_ = StzSplit(_c_, "|")
		_a_ = _MrBoxOf(oDg, _ac_[1])
		_b_ = _MrBoxOf(oDg, _ac_[2])
		_ox_ = (_a_[3] + _b_[3]) / 2 - fabs(_a_[1] - _b_[1])
		_oy_ = (_a_[4] + _b_[4]) / 2 - fabs(_a_[2] - _b_[2])
		if _ox_ > 0 and _oy_ > 0
			return [ FALSE, "'" + _ac_[1] + "' and '" + _ac_[2] + "' overlap by " +
				_ox_ + " x " + _oy_ + "px" ]
		ok
		return [ TRUE, "" ]
	})
	_ao_ + _o2_

	_o3_ = StzPlasticRule("dot_above_figure")
	_o3_.SetClaim("a point's dot is painted after every filled region that covers it")
	_o3_.SetOrder(20)
	_o3_.SetReads([ "draw.order", "region" ])
	_o3_.SetScope(func(oDg) {
		_r_ = []
		_ac_ = oDg.Shapes()
		for _i_ = 1 to len(_ac_)
			_s_ = oDg.ShapeOf(_ac_[_i_])
			if _s_[:kind] = "circle" and _s_[:r] <= 6 and NOT oDg.IsHidden(_ac_[_i_])
				_r_ + ("dot:" + _ac_[_i_])
			ok
		next
		return _r_
	})
	_o3_.SetCounter(func(oDg) {
		_r_ = []
		_ac_ = oDg.Shapes()
		for _i_ = 1 to len(_ac_)
			_s_ = oDg.ShapeOf(_ac_[_i_])
			if _s_[:kind] = "circle" and _s_[:r] > 6  _r_ + ("dot:" + _ac_[_i_])  ok
		next
		return _r_
	})
	_o3_.SetClaimCheck(func(oDg, cSub) {
		_cD_ = StzStringSection(cSub, 5, len(cSub))
		_s_ = oDg.ShapeOf(_cD_)
		_nD_ = oDg.DrawIndexOf(_cD_)
		_ac_ = oDg.Shapes()
		for _i_ = 1 to len(_ac_)
			if _ac_[_i_] = _cD_ or oDg.IsHidden(_ac_[_i_])  loop  ok
			if oDg.DrawIndexOf(_ac_[_i_]) < _nD_  loop  ok
			_aR_ = _MrRegion(oDg, _ac_[_i_])
			if len(_aR_) < 6  loop  ok
			if _MrPointIn(_s_[:cx], _s_[:cy], _aR_)
				return [ FALSE, "'" + _cD_ + "' is painted under '" + _ac_[_i_] + "'" ]
			ok
		next
		return [ TRUE, "" ]
	})
	_ao_ + _o3_

	_o4_ = StzPlasticRule("on_paper")
	_o4_.SetClaim("every drawn shape lies inside the paper")
	_o4_.SetOrder(30)
	_o4_.SetReads([ "extent" ])
	_o4_.SetScope(func(oDg) {
		_r_ = []
		_ac_ = oDg.Shapes()
		for _i_ = 1 to len(_ac_)
			if oDg.IsHidden(_ac_[_i_])  loop  ok
			if len(_MrExtent(oDg, _ac_[_i_])) = 4  _r_ + ("shape:" + _ac_[_i_])  ok
		next
		return _r_
	})
	_o4_.SetCounter(func(oDg) {
		_r_ = []
		_ac_ = oDg.Shapes()
		for _i_ = 1 to len(_ac_)
			if oDg.IsHidden(_ac_[_i_])  _r_ + ("shape:" + _ac_[_i_])  ok
		next
		return _r_
	})
	_o4_.SetClaimCheck(func(oDg, cSub) {
		_cP_ = StzStringSection(cSub, 7, len(cSub))
		_e_ = _MrExtent(oDg, _cP_)
		if _e_[1] < -0.5 or _e_[2] < -0.5 or _e_[3] > oDg.CanvasWidth() + 0.5 or
		   _e_[4] > oDg.CanvasHeight() + 0.5
			return [ FALSE, "'" + _cP_ + "' spans " + floor(_e_[1]) + "," + floor(_e_[2]) +
				" to " + floor(_e_[3]) + "," + floor(_e_[4]) + " on a paper of " +
				oDg.CanvasWidth() + " x " + oDg.CanvasHeight() ]
		ok
		return [ TRUE, "" ]
	})
	_ao_ + _o4_

	return _ao_

func StzMathGovernanceOf(pcName)
	_o_ = StzRuleGovernance(pcName)
	_ao_ = StzMathRuleSet()
	for _i_ = 1 to len(_ao_)
		_o_.AddRule(_ao_[_i_])
	next
	return _o_

# ONE GATE OVER EVERY PICTURE. Each picture goes to the governance its
# class belongs to -- a notation picture to the plastic rules, a math
# picture to the rules above -- and a math picture's own constraints,
# which it already reports in the finding shape, are ingested beside.
# One report, grouped by subject, errors first; and one line saying how
# many pictures were judged, because a gate that reports zero findings
# over zero pictures is the condition a silent gate hides in.
func StzCheckPictures(paPictures)
	_oRep_ = new stzRuleReport("pictures")
	_oPl_ = StzPlasticGovernanceOf("notation")
	_oMa_ = StzMathGovernanceOf("math")
	_nN_ = 0  _nM_ = 0
	for _i_ = 1 to len(paPictures)
		_cN_ = "" + paPictures[_i_][1]
		_o_ = paPictures[_i_][2]
		if NOT isObject(_o_)  loop  ok
		_cC_ = StzLower(classname(_o_))
		if _cC_ = "stzmathdiagram"
			_oMa_.AddPicture(_cN_, _o_)
			_oRep_.Ingest(_MrTagged(_o_.Violations(), _cN_))
			_nM_++
		else
			_oPl_.AddPicture(_cN_, _o_)
			_nN_++
		ok
	next
	if _nN_ > 0  _oRep_.Ingest(_oPl_.CheckPictures())  ok
	if _nM_ > 0  _oRep_.Ingest(_oMa_.CheckPictures())  ok
	? "pictures judged: " + (_nN_ + _nM_) + " (" + _nN_ + " notation, " + _nM_ +
	  " mathematical) -- findings: " + _oRep_.NumberOfFindings()
	return _oRep_

# a diagram's violations, with the picture's name in front of the where
func _MrTagged(paF, pcName)
	_a_ = []
	for _i_ = 1 to len(paF)
		_f_ = paF[_i_]
		_a_ + [ :rule = _f_[:rule], :subject = _f_[:subject],
		        :where = pcName + " / " + _f_[:where], :severity = _f_[:severity],
		        :message = _f_[:message] ]
	next
	return _a_

# A GRAPH IS A SUBSTANCE (DN8a) -- the way back, and the way IN for a graph
# that was never a substance. A node made by ToGraph carries its type,
# its true name, its data and its unary predicates, and an edge carries
# its kind; the domain re-checks every declaration, assertion and
# definition as it always did. A FOREIGN graph -- an org chart, a plain
# stzGraph -- has none of those marks, so the caller says what its nodes
# and edges are: [ :nodeType = "Vertex", :edgeConstructor = "Arc" ] makes
# every node a Vertex and every edge an Arc object, and
# [ :edgePredicate = "Covers" ] makes every edge an assertion instead.
# Node labels become the substance's labels, so an org chart's titles are
# what a Style draws.
func StzSubstanceFromGraph(poGraph, poDomain, paOpts)
	if NOT isObject(poGraph) or NOT isObject(poDomain)
		stzraise("StzSubstanceFromGraph: give a graph and a domain.")
	ok
	_cNodeType_ = ""  _cEdgePred_ = ""  _cEdgeCtor_ = ""  _cPfx_ = "e"
	if isList(paOpts)
		if HasKey(paOpts, "nodeType")  _cNodeType_ = "" + paOpts[:nodeType]  ok
		if HasKey(paOpts, "edgePredicate")  _cEdgePred_ = "" + paOpts[:edgePredicate]  ok
		if HasKey(paOpts, "edgeConstructor")  _cEdgeCtor_ = "" + paOpts[:edgeConstructor]  ok
		if HasKey(paOpts, "edgePrefix")  _cPfx_ = "" + paOpts[:edgePrefix]  ok
	ok
	_oS_ = new stzMathSubstance(poDomain)
	_aN_ = poGraph.Nodes()
	_aE_ = poGraph.Edges()
	# the true name of every node id
	_aName_ = []
	for _i_ = 1 to len(_aN_)
		_aP_ = _aN_[_i_][:properties]
		_cN_ = _aN_[_i_][:id]
		if isList(_aP_) and HasKey(_aP_, "name")  _cN_ = "" + _aP_[:name]  ok
		_aName_ + [ _aN_[_i_][:id], _cN_ ]
	next
	# nodes that a definition edge makes: declared by Define, not here
	_acDefined_ = []
	for _i_ = 1 to len(_aE_)
		_aP_ = _aE_[_i_][:properties]
		if isList(_aP_) and HasKey(_aP_, "kind") and "" + _aP_[:kind] = "definition"
			_acDefined_ + _aE_[_i_][:from]
		ok
	next
	# 1. plain objects
	for _i_ = 1 to len(_aN_)
		_aP_ = _aN_[_i_][:properties]
		_cId_ = _aN_[_i_][:id]
		_cKind_ = ""
		if isList(_aP_) and HasKey(_aP_, "kind")  _cKind_ = "" + _aP_[:kind]  ok
		if _cKind_ = "relation"  loop  ok
		if _StzInList(_acDefined_, _cId_)  loop  ok
		# a node's own :type wins when the DOMAIN knows it; a foreign graph's
		# :type -- an org chart's "box" -- is the drawing's word, not a
		# domain's, and yields to the caller's :nodeType
		_cT_ = _cNodeType_
		if isList(_aP_) and HasKey(_aP_, "type") and poDomain.HasType("" + _aP_[:type])
			_cT_ = "" + _aP_[:type]
		ok
		if _cT_ = ""
			stzraise("StzSubstanceFromGraph: node '" + _cId_ + "' names no type the '" +
				poDomain.Name_() + "' domain has, and no :nodeType was given.")
		ok
		_cN_ = _StzNameOf(_aName_, _cId_)
		_oS_.Declare(_cT_, _cN_)
		_StzNodeIntoSubstance(_oS_, _cN_, _aN_[_i_])
	next
	# 2. definitions, in an order where every argument exists
	_aDefs_ = []
	for _i_ = 1 to len(_aE_)
		_aP_ = _aE_[_i_][:properties]
		if isList(_aP_) and HasKey(_aP_, "kind") and "" + _aP_[:kind] = "definition"
			_aDefs_ + [ _aE_[_i_][:from], "" + _aP_[:function], _aP_[:position], _aE_[_i_][:to] ]
		ok
	next
	_acDone_ = []
	_nGuard_ = 0
	while len(_acDone_) < len(_acDefined_)
		_nGuard_++
		if _nGuard_ > 64
			stzraise("StzSubstanceFromGraph: a definition's arguments never all exist -- " +
				"the definitions form a cycle.")
		ok
		for _k_ = 1 to len(_acDefined_)
			_cU_ = _acDefined_[_k_]
			if _StzInList(_acDone_, _cU_)  loop  ok
			_cF_ = ""  _aArgs_ = []  _n_ = 0
			for _i_ = 1 to len(_aDefs_)
				if _aDefs_[_i_][1] = _cU_
					_cF_ = _aDefs_[_i_][2]
					if _aDefs_[_i_][3] > _n_  _n_ = _aDefs_[_i_][3]  ok
				ok
			next
			for _p_ = 1 to _n_
				_aArgs_ + ""
			next
			for _i_ = 1 to len(_aDefs_)
				if _aDefs_[_i_][1] = _cU_
					_aArgs_[_aDefs_[_i_][3]] = _StzNameOf(_aName_, _aDefs_[_i_][4])
				ok
			next
			_bReady_ = TRUE
			for _p_ = 1 to _n_
				if _aArgs_[_p_] = "" or NOT _oS_.HasObject(_aArgs_[_p_])  _bReady_ = FALSE  ok
			next
			if NOT _bReady_  loop  ok
			_cN_ = _StzNameOf(_aName_, _cU_)
			_oS_.Define(_cN_, _cF_, _aArgs_)
			_StzNodeIntoSubstance(_oS_, _cN_, poGraph.Node(_cU_))
			_acDone_ + _cU_
		next
	end
	# 3. the edges that are relations, constructors, or foreign
	_nE_ = 0
	for _i_ = 1 to len(_aE_)
		_aP_ = _aE_[_i_][:properties]
		_cKind_ = ""
		if isList(_aP_) and HasKey(_aP_, "kind")  _cKind_ = "" + _aP_[:kind]  ok
		_cA_ = _StzNameOf(_aName_, _aE_[_i_][:from])
		_cB_ = _StzNameOf(_aName_, _aE_[_i_][:to])
		if _cKind_ = "predicate"
			_oS_.Assert("" + _aP_[:predicate], [ _cA_, _cB_ ])
		but _cKind_ = "constructor"
			_cU_ = "" + _aP_[:object]
			_oS_.Define(_cU_, "" + _aP_[:constructor], [ _cA_, _cB_ ])
			if _aE_[_i_][:label] != ""  _oS_.Label(_cU_, _aE_[_i_][:label])  ok
			_StzPropsIntoSubstance(_oS_, _cU_, _aP_)
		but _cKind_ = "definition" or _cKind_ = "argument"
			# handled in 2 and 4
		else
			if _cEdgePred_ != ""
				_oS_.Assert(_cEdgePred_, [ _cA_, _cB_ ])
			but _cEdgeCtor_ != ""
				_nE_++
				_cU_ = _cPfx_ + _nE_
				_oS_.Define(_cU_, _cEdgeCtor_, [ _cA_, _cB_ ])
				_oS_.Label(_cU_, "" + _aE_[_i_][:label])
			else
				stzraise("StzSubstanceFromGraph: the edge '" + _cA_ + "' -> '" + _cB_ +
					"' says what it is to no one -- give :edgePredicate or :edgeConstructor.")
			ok
		ok
	next
	# 4. reified relations: a node whose argument edges carry positions
	for _i_ = 1 to len(_aN_)
		_aP_ = _aN_[_i_][:properties]
		if NOT (isList(_aP_) and HasKey(_aP_, "kind") and "" + _aP_[:kind] = "relation")  loop  ok
		_cR_ = _aN_[_i_][:id]
		_n_ = 0
		for _k_ = 1 to len(_aE_)
			if _aE_[_k_][:from] = _cR_ and _aE_[_k_][:properties][:position] > _n_
				_n_ = _aE_[_k_][:properties][:position]
			ok
		next
		_aArgs_ = []
		for _p_ = 1 to _n_
			_aArgs_ + ""
		next
		for _k_ = 1 to len(_aE_)
			if _aE_[_k_][:from] = _cR_
				_aArgs_[_aE_[_k_][:properties][:position]] = _StzNameOf(_aName_, _aE_[_k_][:to])
			ok
		next
		_oS_.Assert("" + _aP_[:predicate], _aArgs_)
	next
	return _oS_

func _StzNameOf(paMap, pcId)
	for _i_ = 1 to len(paMap)
		if paMap[_i_][1] = pcId  return paMap[_i_][2]  ok
	next
	return pcId

func _StzInList(pac, pc)
	for _i_ = 1 to len(pac)
		if "" + pac[_i_] = "" + pc  return TRUE  ok
	next
	return FALSE

# a node's label, data and unary predicates onto a substance object
func _StzNodeIntoSubstance(poS, pcName, paNode)
	if paNode[:label] != ""  poS.Label(pcName, paNode[:label])  ok
	_StzPropsIntoSubstance(poS, pcName, paNode[:properties])

func _StzPropsIntoSubstance(poS, pcName, paProps)
	if NOT isList(paProps)  return  ok
	if HasKey(paProps, "data") and isList(paProps[:data])
		_aD_ = paProps[:data]
		for _i_ = 1 to len(_aD_)
			poS.SetData(pcName, _aD_[_i_][1], _aD_[_i_][2])
		next
	ok
	if HasKey(paProps, "unary") and isList(paProps[:unary])
		_aU_ = paProps[:unary]
		for _i_ = 1 to len(_aU_)
			poS.Assert("" + _aU_[_i_], [ pcName ])
		next
	ok

# TABLES -- Penrose's quaternion table and its matrix product. A cell IS
# its row, its column and its value, and those are NUMBERS on the object;
# the diagram has nothing to solve, and its colour is a rule over the
# number. The domain has no predicate: the data is the content.
func StzTableDomain()
	_o_ = new stzMathDomain("table")
	_o_.AddType("Cell")
	_o_.AddType("Head")
	_o_.AddType("Glyph")
	# a glyph held inside a cell -- a formula inside a notation's icon
	_o_.AddPredicate("Inside", [ "Glyph", "Cell" ])
	return _o_

# A NOTATION'S ICONS AS POLYGONS, AND A FORMULA HELD INSIDE ONE (DN8e). A
# cell is an icon's rectangle, read from a rendered diagram of the graph
# plane and carried as data; its name sits at its centre; a glyph that a
# substance says is Inside a cell is SOLVED into it by the polygon's own
# edges, and off the icon's name. This is the join the plan named: a
# DRAKON icon becomes something a math rule can hold a label in.
func StzIconLabelStyle()
	_o_ = new stzMathStyle()
	_o_.SetCanvas(520, 760)
	_o_.ForAll("Cell c", [
		[ :shape, "c.icon", :poly, [ :n = 4,
		    :x1 = "c.x", :y1 = "c.y", :x2 = "c.x + c.w", :y2 = "c.y",
		    :x3 = "c.x + c.w", :y3 = "c.y + c.h", :x4 = "c.x", :y4 = "c.y + c.h",
		    :fill = [ :alpha, "primary", 0.08 ], :stroke = "neutral", :strokeWidth = 1.5 ] ],
		[ :shape, "c.text", :text, [ :size = 15, :fill = [ :on, "c.icon" ] ] ],
		[ :override, "c.text.cx", "c.x + c.w / 2" ],
		[ :override, "c.text.cy", "c.y + 14" ],
		[ :layer, "c.text", :above, "c.icon" ] ])
	_o_.ForAll("Glyph g", [
		[ :shape, "g.text", :text, [ :size = 19, :fill = "primary" ] ] ])
	_o_.ForAllWhere("Glyph g; Cell c", "Inside(g, c)", [
		[ :ensure, "contains", [ "c.icon", "g.text", 6 ] ],
		[ :ensure, "disjoint", [ "g.text", "c.text", 4 ] ],
		[ :layer, "g.text", :above, "c.icon" ] ])
	return _o_

# The multiplication table of the quaternion group: eight elements, each
# cell filled by WHICH element its product is, from a palette indexed by
# the cell's datum.
func StzQuaternionTableStyle()
	_o_ = new stzMathStyle()
	_o_.SetCanvas(620, 620)
	_o_.ForAll("Cell c", [
		[ :shape, "c.icon", :rect, [ :cx = "90 + (c.col - 0.5)*62", :cy = "90 + (c.row - 0.5)*62",
		    :w = 60, :h = 60,
		    :fill = [ :palette, "c.p", [ "#ececf2", "#e07b72", "#7fc48a", "#7d9ce0",
		                                  "#8a8a99", "#a8342b", "#2f7a3c", "#2a4fa8" ] ],
		    :stroke = "background", :strokeWidth = 2 ] ],
		[ :shape, "c.text", :text, [ :fill = [ :on, "c.icon" ] ] ],
		[ :override, "c.text.cx", "c.icon.cx" ], [ :override, "c.text.cy", "c.icon.cy" ],
		[ :layer, "c.text", :above, "c.icon" ] ])
	_o_.ForAll("Head h", [
		[ :shape, "h.text", :text, [ :fill = [ :on, "paper" ] ] ],
		[ :override, "h.text.cx", "90 + (h.col - 0.5)*62" ],
		[ :override, "h.text.cy", "90 + (h.row - 0.5)*62" ] ])
	return _o_

# A heat map: each cell's fill on a ramp from cool to hot by its datum,
# already scaled to [0, 1] by the substance that knows the range.
func StzHeatmapStyle()
	_o_ = new stzMathStyle()
	_o_.SetCanvas(880, 380)
	_o_.ForAll("Cell c", [
		[ :shape, "c.icon", :rect, [ :cx = "c.x0 + (c.col - 0.5)*54", :cy = "c.y0 + (c.row - 0.5)*54",
		    :w = 52, :h = 52,
		    :fill = [ :ramp, "c.t", 0, 1, "background", "primary" ],
		    :stroke = "background", :strokeWidth = 2 ] ],
		# the digits SWITCH from dark to white past two thirds of the ramp
		# rather than fading with it -- a fade left the middle of the range
		# pale on pink
		[ :shape, "c.text", :text, [ :fill = [ :on, "c.icon" ] ] ],
		[ :override, "c.text.cx", "c.icon.cx" ], [ :override, "c.text.cy", "c.icon.cy" ],
		[ :layer, "c.text", :above, "c.icon" ] ])
	_o_.ForAll("Glyph g", [
		[ :shape, "g.text", :text, [ :fill = [ :on, "paper" ], :size = 30 ] ],
		[ :override, "g.text.cx", "g.x" ], [ :override, "g.text.cy", "g.y" ] ])
	_o_.ForAll("Head h", [
		[ :shape, "h.text", :text, [ :fill = "neutral", :size = 16 ] ],
		[ :override, "h.text.cx", "h.x" ], [ :override, "h.text.cy", "h.y" ] ])
	return _o_

# A CLOUD OF DOTS -- the gallery's chaos game, its Brownian walks, its
# envelopes: content made by iteration in Ring, held as objects with data,
# drawn with nothing to solve.
func StzDotDomain()
	_o_ = new stzMathDomain("dots")
	_o_.AddType("Dot")
	_o_.AddType("Ring")
	# a Step joins two dots -- a random walk is its steps, each a
	# definition the matcher enumerates once
	_o_.AddType("Step")
	_o_.AddConstructor("Step", [ "Dot", "Dot" ])
	return _o_

func StzDotStyle()
	_o_ = new stzMathStyle()
	_o_.SetCanvas(640, 600)
	_o_.ForAll("Dot d", [
		[ :shape, "d.icon", :circle, [ :cx = "d.x", :cy = "d.y", :r = 1.4, :fill = "primary" ] ] ])
	_o_.ForAll("Ring c", [
		[ :shape, "c.icon", :circle, [ :cx = "c.x", :cy = "c.y", :r = "c.r",
		                               :stroke = [ :alpha, "primary", 0.35 ], :strokeWidth = 1 ] ] ])
	# a step is a line from dot to dot, coloured by which walk it is on --
	# a palette read off the step's datum
	_o_.ForAllWhere("Step s; Dot a; Dot b", "s := Step(a, b)", [
		[ :shape, "s.icon", :line, [ :x1 = "a.x", :y1 = "a.y", :x2 = "b.x", :y2 = "b.y",
		                             :stroke = [ :palette, "s.w", [ "primary", "#C8443C", "#2B8A5E" ] ],
		                             :strokeWidth = 1.2 ] ] ])
	return _o_

# A PATH THROUGH POINTS -- Penrose's Catmull-Rom example. Six points in an
# order the constructor fixes, and the spline that interpolates them.
func StzPathDomain()
	_o_ = new stzMathDomain("path")
	_o_.AddType("Point")
	_o_.AddType("Spline")
	# a FUNCTION, not a constructor: a constructor returns the type of its
	# own name, and Through returns a Spline
	_o_.AddFunction("Through", [ "Point", "Point", "Point", "Point", "Point", "Point" ], "Spline")
	return _o_

# ...each point a dot with its name, consecutive points a comfortable
# stride apart and never turning too sharply, and the curve through them.
func StzCatmullStyle()
	_o_ = new stzMathStyle()
	_o_.SetCanvas(720, 480)
	_o_.SetMargin(30)
	_o_.ForAll("Point p", [
		[ :shape, "p.icon", :circle, [ :r = 5, :fill = "primary" ] ],
		[ :shape, "p.text", :text, [ :fill = [ :on, "paper" ] ] ],
		[ :ensure, "disjoint", [ "p.text", "p.icon", 4 ] ],
		[ :ensure, "lessThan", [ "dist(p.text, p.icon)", "24 + p.text.w / 2" ] ],
		[ :encourage, "near", [ "p.text", "p.icon", 16 ] ] ])
	_o_.ForAll("Point p; Point q", [
		[ :ensure, "disjoint", [ "p.icon", "q.icon", 50 ] ],
		[ :ensure, "disjoint", [ "p.text", "q.icon", 8 ] ],
		[ :ensure, "disjoint", [ "p.text", "q.text", 4 ] ] ])
	_o_.ForAllWhere("Spline s; Point a; Point b; Point c; Point d; Point e; Point f",
	                "s := Through(a, b, c, d, e, f)", [
		# the chords, hidden, so the stride and the turning can be spoken of
		[ :shape, "s.c1", :line, [ :x1 = "a.icon.cx", :y1 = "a.icon.cy", :x2 = "b.icon.cx", :y2 = "b.icon.cy", :hidden = 1 ] ],
		[ :shape, "s.c2", :line, [ :x1 = "b.icon.cx", :y1 = "b.icon.cy", :x2 = "c.icon.cx", :y2 = "c.icon.cy", :hidden = 1 ] ],
		[ :shape, "s.c3", :line, [ :x1 = "c.icon.cx", :y1 = "c.icon.cy", :x2 = "d.icon.cx", :y2 = "d.icon.cy", :hidden = 1 ] ],
		[ :shape, "s.c4", :line, [ :x1 = "d.icon.cx", :y1 = "d.icon.cy", :x2 = "e.icon.cx", :y2 = "e.icon.cy", :hidden = 1 ] ],
		[ :shape, "s.c5", :line, [ :x1 = "e.icon.cx", :y1 = "e.icon.cy", :x2 = "f.icon.cx", :y2 = "f.icon.cy", :hidden = 1 ] ],
		[ :ensure, "inRange", [ "len(s.c1)", 90, 150 ] ], [ :ensure, "inRange", [ "len(s.c2)", 90, 150 ] ],
		[ :ensure, "inRange", [ "len(s.c3)", 90, 150 ] ], [ :ensure, "inRange", [ "len(s.c4)", 90, 150 ] ],
		[ :ensure, "inRange", [ "len(s.c5)", 90, 150 ] ],
		# no turn sharper than about seventy degrees between chords
		[ :ensure, "greaterThan", [ "dot(s.c1, s.c2) / (len(s.c1) * len(s.c2))", 0.35 ] ],
		[ :ensure, "greaterThan", [ "dot(s.c2, s.c3) / (len(s.c2) * len(s.c3))", 0.35 ] ],
		[ :ensure, "greaterThan", [ "dot(s.c3, s.c4) / (len(s.c3) * len(s.c4))", 0.35 ] ],
		[ :ensure, "greaterThan", [ "dot(s.c4, s.c5) / (len(s.c4) * len(s.c5))", 0.35 ] ],
		# and it reads left to right
		[ :ensure, "greaterThan", [ "f.icon.cx", "a.icon.cx + 300" ] ],
		[ :shape, "s.icon", :spline, [ :n = 6,
		    :x1 = "a.icon.cx", :y1 = "a.icon.cy", :x2 = "b.icon.cx", :y2 = "b.icon.cy",
		    :x3 = "c.icon.cx", :y3 = "c.icon.cy", :x4 = "d.icon.cx", :y4 = "d.icon.cy",
		    :x5 = "e.icon.cx", :y5 = "e.icon.cy", :x6 = "f.icon.cx", :y6 = "f.icon.cy",
		    :stroke = "neutral", :strokeWidth = 2.5 ] ],
		[ :layer, "a.icon", :above, "s.icon" ], [ :layer, "b.icon", :above, "s.icon" ],
		[ :layer, "c.icon", :above, "s.icon" ], [ :layer, "d.icon", :above, "s.icon" ],
		[ :layer, "e.icon", :above, "s.icon" ], [ :layer, "f.icon", :above, "s.icon" ] ])
	# and every name off every chord -- thirty rows, built rather than
	# written, because a selector cannot bind "any point" alongside the six
	# the spline already binds: the matcher keeps its variables distinct
	_aRows_ = []
	for _cP_ in [ "a", "b", "c", "d", "e", "f" ]
		for _k_ = 1 to 5
			_aRows_ + [ :ensure, "disjoint", [ _cP_ + ".text", "s.c" + _k_, 9 ] ]
		next
	next
	_o_.ForAllWhere("Spline s; Point a; Point b; Point c; Point d; Point e; Point f",
	                "s := Through(a, b, c, d, e, f)", _aRows_)
	return _o_

# GRAPHS -- the largest family in Penrose's own gallery (Hamiltonian cycle,
# dodecahedral, hypercube, network with one-way links, hexagonal lattice,
# hypergraph, Cayley graph). An edge and an arc are OBJECTS for the reason
# a Segment and a Cover are: a rule mints one shape per match.
func StzGraphDomain()
	_o_ = new stzMathDomain("graph")
	_o_.AddType("Vertex")
	_o_.AddType("Edge")
	_o_.AddType("Arc")
	_o_.AddConstructor("Edge", [ "Vertex", "Vertex" ])
	_o_.AddConstructor("Arc", [ "Vertex", "Vertex" ])
	_o_.AddPredicate("Highlighted", [ "Edge" ])
	return _o_

# ...drawn as a node-link picture, after Penrose's simple-graph style: a
# dot per vertex, a line per edge, an arrow per arc; every pair of vertices
# pushes apart; and -- the rule that buys most of the readability -- a
# vertex is held off every edge IT IS NOT AN END OF. That last selector
# needs no predicate: the matcher binds distinct objects to distinct
# variables, so "Vertex v; Edge e; Vertex a; Vertex b where e := Edge(a, b)"
# already means v is neither a nor b.
func StzGraphStyle()
	_cHid_ = 0
	_o_ = new stzMathStyle()
	_o_.SetCanvas(720, 640)
	_o_.SetMargin(36)
	_o_.StartTrying([ :planar, :hierarchical, :force, :random ], "Vertex", "icon", [ "Edge", "Arc" ])
	_o_.SolveLabelsAfter()
	_o_.ForAll("Vertex v", [
		[ :shape, "v.icon", :circle, [ :r = 9, :fill = "neutral",
		                               :stroke = "background", :strokeWidth = 1.5 ] ],
		[ :shape, "v.text", :text, [ :fill = [ :on, "paper" ] ] ],
		# a name is SOLVED here, not placed: on a graph the ink around a
		# vertex is its edges, and which side is free is not known until
		# the edges are -- so the name is held off its own dot and, below,
		# off every edge and arc in the picture
		[ :ensure, "disjoint", [ "v.text", "v.icon", 3 ] ],
		# A LEASH. A name that finds no room by its own dot must be a
		# VIOLATION and never a relocation: without this the cube's inner
		# names were placed beside the outer dots, lawfully, and read as
		# the wrong labels.
		[ :ensure, "lessThan", [ "dist(v.text, v.icon)", "28 + v.text.w / 2" ] ],
		[ :encourage, "near", [ "v.text", "v.icon", 15 ] ],
		# a weak pull to the middle -- a sixty-fourth, see the Hasse style
		[ :encourage, "equal", [ "v.icon.cx / 8", 45 ] ],
		[ :encourage, "equal", [ "v.icon.cy / 8", 40 ] ] ])
	_o_.ForAll("Vertex u; Vertex v", [
		[ :ensure, "disjoint", [ "u.icon", "v.icon", 26 ] ],
		# a name stays well clear of every OTHER dot -- three pixels from a
		# stranger's dot reads as that dot's name, and did
		[ :ensure, "disjoint", [ "u.text", "v.icon", 12 ] ],
		[ :ensure, "disjoint", [ "u.text", "v.text", 3 ] ],
		[ :encourage, "notTooClose", [ "u.icon", "v.icon", 2 ] ] ])
	_o_.ForAll("Vertex v; Edge e", [
		[ :ensure, "disjoint", [ "v.text", "e.icon", 4 ] ] ])
	# an arc carries a HEAD, 3.5 + 1.2*sw either side of its line and
	# 8 + 2.5*sw long: a name clears the head, not the line
	_o_.ForAll("Vertex v; Arc e", [
		[ :ensure, "disjoint", [ "v.text", "e.icon", 10 ] ] ])
	# NO TWO EDGES CROSS, where the graph allows it -- AS A PREFERENCE. The
	# selector binds six DISTINCT objects, so it reaches exactly the pairs
	# of edges that share no vertex; adjacent edges meet at their vertex by
	# right and are never asked about. It is encouraged rather than
	# ensured on measurement: as a hard rule it left 25 constraints open on
	# the cube from a random start and 2 on a seven-vertex network, because
	# a local method does not find its way out of a crossing it started in.
	# As a preference it steers, and the seed does the rest.
	_o_.ForAllWhere("Edge e; Edge f; Vertex a; Vertex b; Vertex c; Vertex d",
	                "e := Edge(a, b); f := Edge(c, d)", [
		[ :ensure, "notCrossing", [ "e.icon", "f.icon", 4 ] ] ])
	_o_.ForAllWhere("Arc e; Arc f; Vertex a; Vertex b; Vertex c; Vertex d",
	                "e := Arc(a, b); f := Arc(c, d)", [
		[ :ensure, "notCrossing", [ "e.icon", "f.icon", 4 ] ] ])
	_o_.ForAllWhere("Edge e; Vertex a; Vertex b", "e := Edge(a, b)", [
		[ :shape, "e.icon", :line, [ :x1 = "a.icon.cx", :y1 = "a.icon.cy",
		                             :x2 = "b.icon.cx", :y2 = "b.icon.cy",
		                             :stroke = "muted", :strokeWidth = 2, :hidden = _cHid_ ] ],
		[ :ensure, "inRange", [ "len(e.icon)", 90, 190 ] ],
		[ :layer, "a.icon", :above, "e.icon" ], [ :layer, "b.icon", :above, "e.icon" ] ])
	# a highlighted edge is the same edge, re-minted heavier and red -- the
	# specialisation idiom, so the general rule need not know about it
	_o_.ForAllWhere("Edge e; Vertex a; Vertex b", "e := Edge(a, b); Highlighted(e)", [
		[ :delete, "e.icon" ],
		[ :shape, "e.icon", :line, [ :x1 = "a.icon.cx", :y1 = "a.icon.cy",
		                             :x2 = "b.icon.cx", :y2 = "b.icon.cy",
		                             :stroke = "primary", :strokeWidth = 4, :hidden = _cHid_ ] ] ])
	_o_.ForAllWhere("Vertex v; Edge e; Vertex a; Vertex b", "e := Edge(a, b)", [
		[ :ensure, "disjoint", [ "v.icon", "e.icon", 6 ] ] ])
	_o_.ForAllWhere("Arc e; Vertex a; Vertex b", "e := Arc(a, b)", [
		[ :shape, "e.line", :line, [ :x1 = "a.icon.cx", :y1 = "a.icon.cy",
		                             :x2 = "b.icon.cx", :y2 = "b.icon.cy", :hidden = 1 ] ],
		[ :shape, "e.icon", :line, [
		    :x1 = "a.icon.cx + 12*ux(e.line)", :y1 = "a.icon.cy + 12*uy(e.line)",
		    :x2 = "b.icon.cx - 12*ux(e.line)", :y2 = "b.icon.cy - 12*uy(e.line)",
		    :stroke = "neutral", :strokeWidth = 2, :arrow = "end" ] ],
		[ :ensure, "inRange", [ "len(e.line)", 90, 210 ] ] ])
	_o_.ForAllWhere("Vertex v; Arc e; Vertex a; Vertex b", "e := Arc(a, b)", [
		[ :ensure, "disjoint", [ "v.icon", "e.icon", 6 ] ] ])
	return _o_

# THE SAME STYLE WITH CURVED EDGES -- Penrose's curved graph. Every rule is
# the spring style's, built by the same function so the two cannot drift:
# the straight edge stays, hidden, as the segment the rules speak to, and a
# spline through its ends and a point bulged off its middle is drawn.
func StzCurvedGraphStyle()
	return _StzSpringStyleBuild(TRUE)

# THE SAME DOMAIN UNDER SOFT TERMS -- a spring embedder. Every hard rule
# of the node-link style is a PREFERENCE here: an edge wants one length, a
# vertex wants off every edge, and nothing can fail. This exists because
# the hard style stops being satisfiable on a graph of twenty vertices from
# a random start -- fifty-one constraints open on the dodecahedron -- and
# a lawful hairball is worth less than an honest best effort.
func StzSpringGraphStyle()
	return _StzSpringStyleBuild(FALSE)

func _StzSpringStyleBuild(pbCurved)
	_cHid_ = 0
	if pbCurved  _cHid_ = 1  ok
	_o_ = new stzMathStyle()
	_o_.SetCanvas(720, 640)
	_o_.SetMargin(36)
	_o_.StartTrying([ :planar, :hierarchical, :force, :random ], "Vertex", "icon", [ "Edge", "Arc" ])
	# names are solved AFTER the shapes, against them frozen: they may not
	# pull on a vertex, and they may not sit on an edge
	_o_.SolveLabelsAfter()
	_o_.ForAll("Vertex v", [
		[ :shape, "v.icon", :circle, [ :r = 8, :fill = "neutral",
		                               :stroke = "background", :strokeWidth = 1.5 ] ],
		[ :shape, "v.text", :text, [ :fill = [ :on, "paper" ] ] ],
		[ :ensure, "disjoint", [ "v.text", "v.icon", 3 ] ],
		[ :ensure, "lessThan", [ "dist(v.text, v.icon)", "28 + v.text.w / 2" ] ],
		[ :encourage, "near", [ "v.text", "v.icon", 15 ] ],
		[ :encourage, "equal", [ "v.icon.cx / 8", 45 ] ],
		[ :encourage, "equal", [ "v.icon.cy / 8", 40 ] ] ])
	_o_.ForAll("Vertex u; Vertex v", [
		[ :ensure, "disjoint", [ "u.icon", "v.icon", 10 ] ],
		[ :ensure, "disjoint", [ "u.text", "v.icon", 12 ] ],
		[ :ensure, "disjoint", [ "u.text", "v.text", 3 ] ],
		# gentler than the hard style's: the crossing rule holds the picture
		# planar now, so the repulsion no longer has to, and a strong one
		# only flattened the outer face onto the margin
		[ :encourage, "notTooClose", [ "u.icon", "v.icon", 3 ] ] ])
	# a name avoids what is DRAWN: the straight edge when it is drawn, and
	# the arc's two half-chords when the arc is
	if NOT pbCurved
		_o_.ForAll("Vertex v; Edge e", [
			[ :ensure, "disjoint", [ "v.text", "e.icon", 4 ] ] ])
	ok
	_o_.ForAllWhere("Edge e; Vertex a; Vertex b", "e := Edge(a, b)", [
		[ :shape, "e.icon", :line, [ :x1 = "a.icon.cx", :y1 = "a.icon.cy",
		                             :x2 = "b.icon.cx", :y2 = "b.icon.cy",
		                             :stroke = "muted", :strokeWidth = 2, :hidden = _cHid_ ] ],
		# 140px: the target sets the INTERIOR, and a cube's inner square at
		# 108 had no room for four names with their clearances
		[ :encourage, "equal", [ "len(e.icon) / 4", 35 ] ],
		[ :layer, "a.icon", :above, "e.icon" ], [ :layer, "b.icon", :above, "e.icon" ] ])
	_o_.ForAllWhere("Edge e; Vertex a; Vertex b", "e := Edge(a, b); Highlighted(e)", [
		[ :delete, "e.icon" ],
		[ :shape, "e.icon", :line, [ :x1 = "a.icon.cx", :y1 = "a.icon.cy",
		                             :x2 = "b.icon.cx", :y2 = "b.icon.cy",
		                             :stroke = "primary", :strokeWidth = 4, :hidden = _cHid_ ] ] ])
	if pbCurved
		# the straight edge stays, hidden, as the segment the rules speak to;
		# a spline through its ends and a point bulged off its middle is drawn
		_o_.ForAllWhere("Edge e; Vertex a; Vertex b", "e := Edge(a, b)", [
			[ :field, "e.bx", "midx(e.icon) + 0.08*len(e.icon)*nx(e.icon)" ],
			[ :field, "e.by", "midy(e.icon) + 0.08*len(e.icon)*ny(e.icon)" ],
			[ :shape, "e.arc", :spline, [ :n = 3,
			    :x1 = "a.icon.cx", :y1 = "a.icon.cy", :x2 = "e.bx", :y2 = "e.by",
			    :x3 = "b.icon.cx", :y3 = "b.icon.cy",
			    :stroke = "muted", :strokeWidth = 2 ] ],
			# the arc's own two half-chords, hidden: a rule cannot see a
			# spline, but it can see the polygon the spline was drawn through,
			# and a name held off both halves is held off the arc
			[ :shape, "e.h1", :line, [ :x1 = "a.icon.cx", :y1 = "a.icon.cy",
			                           :x2 = "e.bx", :y2 = "e.by", :hidden = 1 ] ],
			[ :shape, "e.h2", :line, [ :x1 = "e.bx", :y1 = "e.by",
			                           :x2 = "b.icon.cx", :y2 = "b.icon.cy", :hidden = 1 ] ],
			[ :layer, "a.icon", :above, "e.arc" ], [ :layer, "b.icon", :above, "e.arc" ] ])
		_o_.ForAll("Vertex v; Edge e", [
			[ :ensure, "disjoint", [ "v.text", "e.h1", 4 ] ],
			[ :ensure, "disjoint", [ "v.text", "e.h2", 4 ] ] ])
		_o_.ForAllWhere("Edge e; Vertex a; Vertex b", "e := Edge(a, b); Highlighted(e)", [
			[ :delete, "e.arc" ],
			[ :shape, "e.arc", :spline, [ :n = 3,
			    :x1 = "a.icon.cx", :y1 = "a.icon.cy", :x2 = "e.bx", :y2 = "e.by",
			    :x3 = "b.icon.cx", :y3 = "b.icon.cy",
			    :stroke = "primary", :strokeWidth = 4 ] ] ])
	ok
	_o_.ForAllWhere("Vertex v; Edge e; Vertex a; Vertex b", "e := Edge(a, b)", [
		# thirty, not ten: a vertex close to an edge leaves its NAME no room,
		# and the name stage cannot move the vertex
		[ :encourage, "disjoint", [ "v.icon", "e.icon", 30 ] ] ])
	_o_.ForAllWhere("Edge e; Edge f; Vertex a; Vertex b; Vertex c; Vertex d",
	                "e := Edge(a, b); f := Edge(c, d)", [
		[ :ensure, "notCrossing", [ "e.icon", "f.icon", 4 ] ] ])
	return _o_

# THE SAME GRAPH AS BOXES AND ARROWS -- Penrose's computer-architecture
# diagram. A vertex is its name in a box sized to the name; an arc stops
# at the box's EDGE, which is not a fixed radius: the half-extent of a box
# along a direction is the smaller of hw/|ux| and hh/|uy|.
func StzBoxArrowStyle()
	_o_ = new stzMathStyle()
	_o_.SetCanvas(760, 520)
	_o_.SetMargin(24)
	_o_.StartTrying([ :hierarchical, :planar, :random ], "Vertex", "text", [ "Arc" ])
	_o_.ForAll("Vertex v", [
		[ :shape, "v.text", :text, [ :fill = [ :on, "v.icon" ] ] ],
		[ :shape, "v.icon", :rect, [ :cx = "v.text.cx", :cy = "v.text.cy",
		                             :w = "v.text.w + 30", :h = "v.text.h + 12",
		                             :fill = [ :alpha, "primary", 0.08 ], :stroke = "neutral", :strokeWidth = 1.5 ] ],
		[ :encourage, "equal", [ "v.text.cx / 8", 47.5 ] ],
		[ :encourage, "equal", [ "v.text.cy / 8", 32.5 ] ],
		[ :layer, "v.text", :above, "v.icon" ] ])
	_o_.ForAll("Vertex u; Vertex v", [
		[ :ensure, "disjoint", [ "u.icon", "v.icon", 34 ] ],
		[ :encourage, "notTooClose", [ "u.icon", "v.icon", 2 ] ] ])
	_o_.ForAllWhere("Arc e; Vertex a; Vertex b", "e := Arc(a, b)", [
		[ :shape, "e.line", :line, [ :x1 = "a.text.cx", :y1 = "a.text.cy",
		                             :x2 = "b.text.cx", :y2 = "b.text.cy", :hidden = 1 ] ],
		[ :field, "e.ta", "min((a.icon.w / 2) / (abs(ux(e.line)) + 0.0001), (a.icon.h / 2) / (abs(uy(e.line)) + 0.0001))" ],
		[ :field, "e.tb", "min((b.icon.w / 2) / (abs(ux(e.line)) + 0.0001), (b.icon.h / 2) / (abs(uy(e.line)) + 0.0001))" ],
		[ :shape, "e.icon", :line, [
		    :x1 = "a.text.cx + (e.ta + 3)*ux(e.line)", :y1 = "a.text.cy + (e.ta + 3)*uy(e.line)",
		    :x2 = "b.text.cx - (e.tb + 3)*ux(e.line)", :y2 = "b.text.cy - (e.tb + 3)*uy(e.line)",
		    :stroke = "neutral", :strokeWidth = 2, :arrow = "end" ] ],
		[ :ensure, "greaterThan", [ "len(e.line)", 140 ] ],
		# an arc reads left to right when it can
		[ :encourage, "leftwards", [ "a.icon", "b.icon", 120 ] ] ])
	_o_.ForAllWhere("Vertex v; Arc e; Vertex a; Vertex b", "e := Arc(a, b)", [
		[ :ensure, "disjoint", [ "v.icon", "e.icon", 8 ] ] ])
	return _o_

# A WORD CLOUD is the Minkowski separation of DN7d with nothing else in the
# picture: every word is a box, every pair of boxes is apart, and every
# word wants the middle. The sizes come from the substance's own judgement
# of what matters -- Large and Medium, the rest small.
func StzWordDomain()
	_o_ = new stzMathDomain("words")
	_o_.AddType("Word")
	_o_.AddPredicate("Large", [ "Word" ])
	_o_.AddPredicate("Medium", [ "Word" ])
	return _o_

func StzWordCloudStyle()
	_o_ = new stzMathStyle()
	_o_.SetCanvas(720, 480)
	_o_.ForAll("Word w", [
		[ :shape, "w.text", :text, [ :size = 17, :fill = "neutral" ] ] ])
	_o_.ForAllWhere("Word w", "Medium(w)", [
		[ :delete, "w.text" ],
		[ :shape, "w.text", :text, [ :size = 27, :fill = [ :on, "paper" ] ] ] ])
	_o_.ForAllWhere("Word w", "Large(w)", [
		[ :delete, "w.text" ],
		[ :shape, "w.text", :text, [ :size = 46, :fill = "primary" ] ] ])
	_o_.ForAll("Word w", [
		[ :encourage, "equal", [ "w.text.cx / 4", 90 ] ],
		[ :encourage, "equal", [ "w.text.cy / 4", 60 ] ] ])
	_o_.ForAll("Word v; Word w", [
		[ :ensure, "disjoint", [ "v.text", "w.text", 6 ] ] ])
	return _o_

# THALES, and the kill Byrne's figure taught. The substance says three
# things: B and C are on the circle, BC passes through its centre, and A is
# on the circle too. IT NEVER SAYS THE ANGLE AT A IS RIGHT. The solver is
# free to put A anywhere on the arc, and every place it can put A gives a
# right angle -- so the mark this style draws is a claim about the picture
# that the picture was never asked to satisfy, and the guard measures it
# back out of the solved coordinates.
func StzThalesStyle()
	_o_ = new stzMathStyle()
	_o_.SetCanvas(620, 560)
	_o_.ForAll("Circle k", [
		[ :shape, "k.icon", :circle, [ :fill = [ :alpha, "primary", 0.08 ], :stroke = "muted",
		                               :strokeWidth = 2 ] ],
		[ :ensure, "greaterThan", [ "k.icon.r", 160 ] ],
		[ :ensure, "lessThan", [ "k.icon.r", 210 ] ] ])
	_o_.ForAll("Point p", [
		[ :shape, "p.icon", :circle, [ :r = 4, :fill = "neutral" ] ],
		[ :shape, "p.text", :text, [ :fill = [ :on, "paper" ] ] ],
		[ :ensure, "disjoint", [ "p.text", "p.icon", 5 ] ],
		[ :encourage, "near", [ "p.text", "p.icon", 20 ] ] ])
	_o_.ForAllWhere("Point p; Circle k", "OnCircle(p, k)", [
		[ :ensure, "equal", [ "dist(p.icon, k.icon)", "k.icon.r" ] ],
		# the name sits OUTSIDE the rim: disjoint from the disk itself,
		# which for a point ON the rim can only mean outward
		[ :ensure, "disjoint", [ "p.text", "k.icon", 7 ] ],
		[ :layer, "p.icon", :above, "k.icon" ] ])
	_o_.ForAllWhere("Segment s; Point p; Point q", "s := Segment(p, q)", [
		[ :shape, "s.icon", :line, [ :x1 = "p.icon.cx", :y1 = "p.icon.cy",
		                             :x2 = "q.icon.cx", :y2 = "q.icon.cy",
		                             :stroke = "neutral", :strokeWidth = 2 ] ],
		[ :ensure, "disjoint", [ "p.text", "s.icon", 3 ] ],
		[ :ensure, "disjoint", [ "q.text", "s.icon", 3 ] ] ])
	_o_.ForAllWhere("Segment s; Circle k", "Diameter(s, k)", [
		[ :ensure, "equal", [ "midx(s.icon)", "k.icon.cx" ] ],
		[ :ensure, "equal", [ "midy(s.icon)", "k.icon.cy" ] ] ])
	_o_.ForAllWhere("Triangle t; Point p; Point q; Point r", "t := Triangle(p, q, r)", [
		[ :shape, "t.face", :poly, [ :n = 3,
		    :x1 = "p.icon.cx", :y1 = "p.icon.cy", :x2 = "q.icon.cx", :y2 = "q.icon.cy",
		    :x3 = "r.icon.cx", :y3 = "r.icon.cy",
		    :fill = [ :alpha, "primary", 0.25 ], :stroke = "neutral", :strokeWidth = 2 ] ],
		[ :layer, "p.icon", :above, "t.face" ], [ :layer, "q.icon", :above, "t.face" ],
		[ :layer, "r.icon", :above, "t.face" ] ])
	# THE MARK the theorem earns: the angle at the apex, drawn because
	# Thales says it is right, never because a constraint made it so.
	_o_.ForAllWhere("Angle a; Point p; Point q; Point r", "a := InteriorAngle(p, q, r)", [
		[ :shape, "a.arm1", :line, [ :x1 = "q.icon.cx", :y1 = "q.icon.cy",
		                             :x2 = "p.icon.cx", :y2 = "p.icon.cy", :hidden = 1 ] ],
		[ :shape, "a.arm2", :line, [ :x1 = "q.icon.cx", :y1 = "q.icon.cy",
		                             :x2 = "r.icon.cx", :y2 = "r.icon.cy", :hidden = 1 ] ],
		[ :shape, "a.mark1", :line, [
			:x1 = "q.icon.cx + 15*ux(a.arm1)", :y1 = "q.icon.cy + 15*uy(a.arm1)",
			:x2 = "q.icon.cx + 15*ux(a.arm1) + 15*ux(a.arm2)",
			:y2 = "q.icon.cy + 15*uy(a.arm1) + 15*uy(a.arm2)",
			:stroke = "neutral", :strokeWidth = 1.5 ] ],
		[ :shape, "a.mark2", :line, [
			:x1 = "q.icon.cx + 15*ux(a.arm2)", :y1 = "q.icon.cy + 15*uy(a.arm2)",
			:x2 = "q.icon.cx + 15*ux(a.arm1) + 15*ux(a.arm2)",
			:y2 = "q.icon.cy + 15*uy(a.arm1) + 15*uy(a.arm2)",
			:stroke = "neutral", :strokeWidth = 1.5 ] ] ])
	return _o_

# ORDER THEORY. A partial order is not a picture of anything -- it has no
# coordinates to be faithful to -- so a Hasse diagram is pure LAYOUT: the
# only rule is that x sits above y when x covers y, and everything else is
# there to make it readable. That makes it the opposite end of the engine
# from Byrne, where every coordinate was forced.
#
# A covering is an OBJECT here, not a predicate, for the same reason a
# Segment is: a rule mints one shape per match, and an element covers
# several others, so the edge needs a name of its own to be minted under.
func StzOrderDomain()
	_o_ = new stzMathDomain("order")
	_o_.AddType("Element")
	_o_.AddType("Cover")
	_o_.AddConstructor("Cover", [ "Element", "Element" ])
	_o_.AddSymmetricPredicate("SameRank", [ "Element", "Element" ])
	return _o_

# ...drawn as Hasse drew it: a node per element, a line for each covering,
# the greater end higher. Same rank shares a row, a child pulls toward the
# average of its parents, and every pair pushes apart.
func StzHasseStyle()
	_o_ = new stzMathStyle()
	_o_.SetCanvas(700, 620)
	_o_.SetMargin(40)
	# a Hasse diagram is a hierarchical layout: greater above lesser, rows
	# by rank, crossings minimised by the graph plane's own sweep -- and
	# no seed chosen
	_o_.StartTrying([ :hierarchical, :planar, :random ], "Element", "icon", [ "Cover" ])
	_o_.ForAll("Element x", [
		[ :shape, "x.icon", :circle, [ :r = 24, :fill = "background",
		                               :stroke = "neutral", :strokeWidth = 2 ] ],
		[ :shape, "x.text", :text, [ :fill = [ :on, "x.icon" ] ] ],
		# the name IS the node, so it is placed and not solved
		[ :override, "x.text.cx", "x.icon.cx" ],
		[ :override, "x.text.cy", "x.icon.cy" ],
		[ :ensure, "contains", [ "x.icon", "x.text", 3 ] ],
		[ :layer, "x.text", :above, "x.icon" ] ])
	_o_.ForAll("Element x; Element y", [
		[ :ensure, "disjoint", [ "x.icon", "y.icon", 26 ] ],
		[ :encourage, "notTooClose", [ "x.icon", "y.icon", 4 ] ] ])
	# A WEAK PULL TOWARD THE MIDDLE COLUMN, and weak is the whole point: at
	# the range where two nodes are nearly touching, the repulsion above is
	# an order of magnitude stronger, so this gathers the drawing without
	# ever flattening it. Dividing inside the argument is what buys that --
	# the energy is squared, so a divisor of eight is a weight of a
	# sixty-fourth.
	_o_.ForAll("Element x", [
		[ :encourage, "equal", [ "x.icon.cx / 8", 43.75 ] ] ])
	_o_.ForAllWhere("Element x; Element y", "SameRank(x, y)", [
		[ :ensure, "equal", [ "x.icon.cy", "y.icon.cy" ] ] ])
	_o_.ForAllWhere("Cover c; Element x; Element y", "c := Cover(x, y)", [
		# the centre line, hidden, and the drawn edge stopping at both rims:
		# an edge run to the centre hides under the node by painting order
		# alone, and the one gate found its ink under every name
		[ :shape, "c.line", :line, [ :x1 = "x.icon.cx", :y1 = "x.icon.cy",
		                             :x2 = "y.icon.cx", :y2 = "y.icon.cy", :hidden = 1 ] ],
		[ :shape, "c.icon", :line, [
		    :x1 = "x.icon.cx + 24*ux(c.line)", :y1 = "x.icon.cy + 24*uy(c.line)",
		    :x2 = "y.icon.cx - 24*ux(c.line)", :y2 = "y.icon.cy - 24*uy(c.line)",
		    :stroke = "muted", :strokeWidth = 2 ] ],
		# x covers y, so x is the higher of the two -- by a clear row
		[ :ensure, "greaterThan", [ "y.icon.cy", "x.icon.cy + 88" ] ],
		[ :ensure, "lessThan", [ "y.icon.cy", "x.icon.cy + 132" ] ],
		# and a covering pair leans toward the same column
		[ :encourage, "equal", [ "x.icon.cx", "y.icon.cx" ] ],
		[ :layer, "x.icon", :above, "c.icon" ],
		[ :layer, "y.icon", :above, "c.icon" ] ])
	return _o_

# CATEGORY THEORY. The diagram IS the mathematics here -- a commuting
# square is not an illustration of an equation, it is how the equation is
# written -- so this style is the one place where the LAYOUT carries the
# content and the coordinates carry none.
func StzCategoryDomain()
	_o_ = new stzMathDomain("category")
	_o_.AddType("Object")
	_o_.AddType("Arrow")
	_o_.AddConstructor("Arrow", [ "Object", "Object" ])
	_o_.AddFunction("compose", [ "Arrow", "Arrow" ], "Arrow")
	_o_.AddPredicate("CommutingSquare", [ "Object", "Object", "Object", "Object" ])
	_o_.AddPredicate("CommutingTriangle", [ "Object", "Object", "Object" ])
	return _o_

# An object is its name; an arrow runs between two names, stopping clear of
# both, and wears its own name beside its middle. A commuting cell gets the
# turning mark in the space it encloses.
func StzCommutativeStyle()
	_o_ = new stzMathStyle()
	_o_.SetCanvas(660, 560)
	_o_.ForAll("Object a", [
		[ :shape, "a.text", :text, [ :fill = [ :on, "paper" ] ] ],
		[ :shape, "a.bounds", :circle, [ :cx = "a.text.cx", :cy = "a.text.cy",
		                                 :r = 26, :hidden = 1 ] ] ])
	_o_.ForAllWhere("Arrow f; Object a; Object b", "f := Arrow(a, b)", [
		[ :shape, "f.line", :line, [ :x1 = "a.text.cx", :y1 = "a.text.cy",
		                             :x2 = "b.text.cx", :y2 = "b.text.cy", :hidden = 1 ] ],
		[ :shape, "f.icon", :line, [
		    :x1 = "a.text.cx + 26*ux(f.line)", :y1 = "a.text.cy + 26*uy(f.line)",
		    :x2 = "b.text.cx - 26*ux(f.line)", :y2 = "b.text.cy - 26*uy(f.line)",
		    :stroke = "neutral", :strokeWidth = 2, :arrow = "end" ] ],
		[ :shape, "f.text", :text, [ :fill = "primary" ] ],
		# the arrow's name sits off its middle, on the side the arrow turns
		# away from -- placed, so it costs the solver nothing
		[ :override, "f.text.cx", "midx(f.icon) + 15*nx(f.icon)" ],
		[ :override, "f.text.cy", "midy(f.icon) + 15*ny(f.icon)" ],
		[ :ensure, "greaterThan", [ "len(f.line)", 150 ] ] ])
	_o_.ForAllWhere("Object a; Object b; Object c; Object d",
	                "CommutingSquare(a, b, c, d)", [
		# a b       the square is read left to right and top to bottom, so
		# c d       the style says exactly that and the solver does the rest
		[ :ensure, "equal", [ "a.text.cy", "b.text.cy" ] ],
		[ :ensure, "equal", [ "c.text.cy", "d.text.cy" ] ],
		[ :ensure, "equal", [ "a.text.cx", "c.text.cx" ] ],
		[ :ensure, "equal", [ "b.text.cx", "d.text.cx" ] ],
		[ :ensure, "greaterThan", [ "b.text.cx", "a.text.cx + 250" ] ],
		[ :ensure, "greaterThan", [ "c.text.cy", "a.text.cy + 210" ] ],
		# and the cell sits in the middle of the paper: nothing else in this
		# style has any opinion about where, so without this the square is
		# lawful anywhere the margins allow
		[ :encourage, "equal", [ "(a.text.cx + b.text.cx) / 2", 330 ] ],
		[ :encourage, "equal", [ "(a.text.cy + c.text.cy) / 2", 280 ] ] ])
	_o_.ForAllWhere("Object a; Object b; Object c",
	                "CommutingTriangle(a, b, c)", [
		[ :ensure, "equal", [ "a.text.cy", "b.text.cy" ] ],
		[ :ensure, "greaterThan", [ "b.text.cx", "a.text.cx + 250" ] ],
		[ :ensure, "greaterThan", [ "c.text.cy", "a.text.cy + 200" ] ],
		[ :ensure, "equal", [ "c.text.cx", "(a.text.cx + b.text.cx) / 2" ] ],
		[ :encourage, "equal", [ "(a.text.cx + b.text.cx) / 2", 330 ] ],
		[ :encourage, "equal", [ "(a.text.cy + c.text.cy) / 2", 280 ] ] ])
	return _o_

# OLIVER BYRNE'S EUCLID I.47 (1847), the plane's version of the most drawn
# proof there is: three squares on the sides of a right triangle, the
# altitude from the right angle continued through the square on the
# hypotenuse, and the two rectangles it cuts there -- each equal in area to
# the square on the leg beside it, and coloured to say so.
#
# EVERY PIECE OF THAT FIGURE IS DERIVED FROM THE THREE POINTS. The solver
# owns six numbers (three points on the page); the squares, the foot of the
# altitude and the two rectangles are expressions over them, so the picture
# cannot come apart -- and Euclid's equality is never asserted anywhere. It
# is a CONSEQUENCE the guard reads back out of the solved coordinates.
#
# The outward normal of the hypotenuse is written as the direction from the
# right-angle vertex to the foot of its own altitude. That is a unit vector
# pointing out of the triangle by construction, so the squares stand on the
# correct side of every edge without a sign test anywhere.
func StzByrneStyle()
	_o_ = new stzMathStyle()
	_o_.SetCanvas(760, 700)
	# the areas are labels, and a label held inside a square must not move
	# the triangle the square stands on: the shapes solve first, the labels
	# after, against frozen squares -- where a polygon's long expressions are
	# arithmetic on numbers
	_o_.SolveLabelsAfter()
	# A name here is PLACED, never solved -- so it carries no constraint of
	# its own into the energy. That is deliberate: the placement below
	# divides by a root of a dot product, and the moment such an expression
	# also became the argument of a disjoint() and a near(), the tape grew
	# past what the solver could work with.
	_o_.ForAll("Point p", [
		[ :shape, "p.icon", :circle, [ :r = 3.5, :fill = "neutral" ] ],
		[ :shape, "p.text", :text, [ :fill = [ :on, "paper" ] ] ] ])
	# ANY triangle is an outline, with its names set outward from the middle...
	_o_.ForAllWhere("Triangle t; Point p; Point q; Point r", "t := Triangle(p, q, r)", [
		[ :shape, "t.icon", :poly, [ :n = 3,
		    :x1 = "p.icon.cx", :y1 = "p.icon.cy", :x2 = "q.icon.cx", :y2 = "q.icon.cy",
		    :x3 = "r.icon.cx", :y3 = "r.icon.cy",
		    :stroke = "neutral", :strokeWidth = 2 ] ],
		[ :field, "t.ox", "(p.icon.cx + q.icon.cx + r.icon.cx) / 3" ],
		[ :field, "t.oy", "(p.icon.cy + q.icon.cy + r.icon.cy) / 3" ],
		[ :field, "t.dp", "sqrt((p.icon.cx - t.ox)^2 + (p.icon.cy - t.oy)^2 + 0.000001)" ],
		[ :field, "t.dq", "sqrt((q.icon.cx - t.ox)^2 + (q.icon.cy - t.oy)^2 + 0.000001)" ],
		[ :field, "t.dr", "sqrt((r.icon.cx - t.ox)^2 + (r.icon.cy - t.oy)^2 + 0.000001)" ],
		[ :override, "p.text.cx", "p.icon.cx + 26*(p.icon.cx - t.ox)/t.dp" ],
		[ :override, "p.text.cy", "p.icon.cy + 26*(p.icon.cy - t.oy)/t.dp" ],
		[ :override, "q.text.cx", "q.icon.cx + 26*(q.icon.cx - t.ox)/t.dq" ],
		[ :override, "q.text.cy", "q.icon.cy + 26*(q.icon.cy - t.oy)/t.dq" ],
		[ :override, "r.text.cx", "r.icon.cx + 26*(r.icon.cx - t.ox)/t.dr" ],
		[ :override, "r.text.cy", "r.icon.cy + 26*(r.icon.cy - t.oy)/t.dr" ] ])
	# ...and a RIGHT triangle is Byrne's figure instead. This is Penrose's
	# specialisation idiom: the general rule drew an icon, and the special
	# rule DELETES it before drawing its own.
	_o_.ForAllWhere("Triangle t; Point p; Point q; Point r; Angle a",
	                "t := Triangle(p, q, r); a := InteriorAngle(q, p, r); Right(a)", [
		[ :delete, "t.icon" ],
		# the two legs out of the right angle, and their units
		[ :field, "t.abx", "q.icon.cx - p.icon.cx" ], [ :field, "t.aby", "q.icon.cy - p.icon.cy" ],
		[ :field, "t.acx", "r.icon.cx - p.icon.cx" ], [ :field, "t.acy", "r.icon.cy - p.icon.cy" ],
		[ :field, "t.lab", "sqrt(t.abx^2 + t.aby^2 + 0.000001)" ],
		[ :field, "t.lac", "sqrt(t.acx^2 + t.acy^2 + 0.000001)" ],
		[ :field, "t.ubx", "t.abx / t.lab" ], [ :field, "t.uby", "t.aby / t.lab" ],
		[ :field, "t.ucx", "t.acx / t.lac" ], [ :field, "t.ucy", "t.acy / t.lac" ],
		# THE HYPOTENUSE AND THE OUTWARD NORMAL. The normal is the one thing
		# here that needs a SIDE chosen, and the shallow way to choose it is
		# the signed area: Z = (B-A) x (C-B) is positive on one winding and
		# negative on the other, and because the angle at A is right its
		# magnitude is exactly lab*lac -- so Z/(lab*lac) IS the sign, with
		# no sign function and no branch. Turning BC a quarter turn and
		# multiplying by it gives a unit normal that always points away
		# from A.
		#
		# Writing it this way rather than as the direction to the altitude's
		# foot matters for a reason that has nothing to do with elegance:
		# the foot costs a division, two subtractions and a square root of
		# its own, and every expression built on it inherits all of that.
		# When the names below came to divide by a root of a dot product OF
		# this normal, the tape went from 243ms to 202 SECONDS and the
		# picture stopped converging.
		[ :field, "t.bcx", "r.icon.cx - q.icon.cx" ], [ :field, "t.bcy", "r.icon.cy - q.icon.cy" ],
		[ :field, "t.lbc", "sqrt(t.bcx^2 + t.bcy^2 + 0.000001)" ],
		[ :field, "t.zz", "(t.abx*t.bcy - t.aby*t.bcx) / (t.lab*t.lac*t.lbc)" ],
		[ :field, "t.wx", "t.bcy * t.zz" ], [ :field, "t.wy", "0 - t.bcx * t.zz" ],
		# the altitude's length is lab*lac/lbc, so its foot needs no
		# projection either
		[ :field, "t.lh", "t.lab*t.lac / t.lbc" ],
		[ :field, "t.fx", "p.icon.cx + t.lh*t.wx" ], [ :field, "t.fy", "p.icon.cy + t.lh*t.wy" ],
		[ :field, "t.gx", "t.fx + t.lbc*t.wx" ], [ :field, "t.gy", "t.fy + t.lbc*t.wy" ],
		# THE SQUARE ON THE HYPOTENUSE, and the two rectangles the altitude
		# cuts it into -- each coloured like the leg square it equals
		[ :shape, "t.sqbc", :poly, [ :n = 4,
		    :x1 = "q.icon.cx", :y1 = "q.icon.cy", :x2 = "r.icon.cx", :y2 = "r.icon.cy",
		    :x3 = "r.icon.cx + t.lbc*t.wx", :y3 = "r.icon.cy + t.lbc*t.wy",
		    :x4 = "q.icon.cx + t.lbc*t.wx", :y4 = "q.icon.cy + t.lbc*t.wy",
		    :fill = "#f2ecdd", :stroke = "neutral", :strokeWidth = 1.5 ] ],
		[ :shape, "t.rect1", :poly, [ :n = 4,
		    :x1 = "q.icon.cx", :y1 = "q.icon.cy", :x2 = "t.fx", :y2 = "t.fy",
		    :x3 = "t.gx", :y3 = "t.gy",
		    :x4 = "q.icon.cx + t.lbc*t.wx", :y4 = "q.icon.cy + t.lbc*t.wy",
		    :fill = "#c8443c", :stroke = "neutral", :strokeWidth = 1.5 ] ],
		[ :shape, "t.rect2", :poly, [ :n = 4,
		    :x1 = "t.fx", :y1 = "t.fy", :x2 = "r.icon.cx", :y2 = "r.icon.cy",
		    :x3 = "r.icon.cx + t.lbc*t.wx", :y3 = "r.icon.cy + t.lbc*t.wy",
		    :x4 = "t.gx", :y4 = "t.gy",
		    :fill = "#2f5f98", :stroke = "neutral", :strokeWidth = 1.5 ] ],
		# THE SQUARES ON THE LEGS. Because the angle at p is right, the
		# square on one leg stands along the OTHER leg's direction, reversed
		# -- so no normal has to be computed for either of them.
		[ :shape, "t.sqab", :poly, [ :n = 4,
		    :x1 = "p.icon.cx", :y1 = "p.icon.cy", :x2 = "q.icon.cx", :y2 = "q.icon.cy",
		    :x3 = "q.icon.cx - t.lab*t.ucx", :y3 = "q.icon.cy - t.lab*t.ucy",
		    :x4 = "p.icon.cx - t.lab*t.ucx", :y4 = "p.icon.cy - t.lab*t.ucy",
		    :fill = "#c8443c", :stroke = "neutral", :strokeWidth = 1.5 ] ],
		[ :shape, "t.sqac", :poly, [ :n = 4,
		    :x1 = "p.icon.cx", :y1 = "p.icon.cy", :x2 = "r.icon.cx", :y2 = "r.icon.cy",
		    :x3 = "r.icon.cx - t.lac*t.ubx", :y3 = "r.icon.cy - t.lac*t.uby",
		    :x4 = "p.icon.cx - t.lac*t.ubx", :y4 = "p.icon.cy - t.lac*t.uby",
		    :fill = "#2f5f98", :stroke = "neutral", :strokeWidth = 1.5 ] ],
		# the triangle itself, and the altitude continued to the far side
		[ :shape, "t.face", :poly, [ :n = 3,
		    :x1 = "p.icon.cx", :y1 = "p.icon.cy", :x2 = "q.icon.cx", :y2 = "q.icon.cy",
		    :x3 = "r.icon.cx", :y3 = "r.icon.cy",
		    :fill = "#e8b93b", :stroke = "neutral", :strokeWidth = 1.5 ] ],
		[ :shape, "t.alt", :line, [ :x1 = "p.icon.cx", :y1 = "p.icon.cy",
		    :x2 = "t.gx", :y2 = "t.gy", :stroke = "neutral", :strokeWidth = 1.5 ] ],
		# THE RIGHT ANGLE, MARKED WITH ITS CORNER ON THE ALTITUDE. A mark
		# with two EQUAL arms has its corner on the angle's bisector -- and
		# the altitude from a right angle is not its bisector unless the
		# legs are equal, so a square mark would sit a few pixels off the
		# line drawn through it, which reads as a slip.
		#
		# The corner is therefore put ON the altitude, at A + 21*w, and the
		# arms are what that costs: the legs are perpendicular, so (ub, uc)
		# is an orthonormal basis and w decomposes exactly as
		# (w.ub)ub + (w.uc)uc. Each arm is that component -- the two are
		# equal only when the triangle is isosceles, which is the same fact
		# stated the other way round.
		[ :field, "t.k1", "21*(t.wx*t.ubx + t.wy*t.uby)" ],
		[ :field, "t.k2", "21*(t.wx*t.ucx + t.wy*t.ucy)" ],
		[ :field, "t.kx", "p.icon.cx + 21*t.wx" ], [ :field, "t.ky", "p.icon.cy + 21*t.wy" ],
		[ :shape, "t.mark1", :line, [
		    :x1 = "p.icon.cx + t.k1*t.ubx", :y1 = "p.icon.cy + t.k1*t.uby",
		    :x2 = "t.kx", :y2 = "t.ky", :stroke = "neutral", :strokeWidth = 1.5 ] ],
		[ :shape, "t.mark2", :line, [
		    :x1 = "p.icon.cx + t.k2*t.ucx", :y1 = "p.icon.cy + t.k2*t.ucy",
		    :x2 = "t.kx", :y2 = "t.ky", :stroke = "neutral", :strokeWidth = 1.5 ] ],
		# EVERY NAME THE SAME DISTANCE FROM THE INK. A polygon is derived, so
		# no constraint can speak to one -- but the EDGES that make the notch
		# a name sits in are two segments, and a segment can be constrained.
		# Each vertex gets the two outer sides of the squares meeting there,
		# hidden, and its name is held off both by the SAME clearance.
		#
		# Placing each name a fixed distance from its POINT instead, which is
		# what this rule did first, gives an equal radius and an UNEQUAL gap:
		# the notch at the right angle is a quarter turn where the other two
		# are far wider, so the same radius buries A's name and leaves B's
		# and C's adrift. The eye reads the gap, never the radius.
		# Each vertex has ONE free notch, bounded by the outer sides of the
		# two squares meeting there. The name goes along that notch's
		# BISECTOR, and how far along is what makes the gaps equal: at a
		# notch of half-angle t the perpendicular clearance is d*sin(t), so
		# d carries a 1/sin(t) and a wide notch takes its name less far out
		# than a narrow one. The right angle's notch is a quarter turn and
		# the other two are half a turn less their angle, so the three
		# differ by a third -- which is exactly the error a fixed radius
		# makes, and it is worst at A, where the picture is busiest.
		#
		# AND IT CLOSES. For unit wall directions e1 and e2 with c = e1.e2,
		# the offset  K * (e1 + e2) / sqrt(1 - c^2)  lands at perpendicular
		# distance EXACTLY K from both walls, whatever the notch's angle:
		# |e1 + e2| is sqrt(2 + 2c), the half-angle's sine is
		# sqrt((1 - c)/2), and their product is sqrt(2)/sqrt(2). One
		# expression for all three vertices, no trigonometry, no bisector
		# normalised by hand -- and at the right angle c is zero, so the
		# name simply goes 22*sqrt(2) up the diagonal.
		# AND THE BISECTOR IS STILL NOT IT, because the eye measures the
		# LETTER, not its centre. A box reaches further along its diagonal
		# than along its sides, so equal centre-clearance leaves unequal
		# gaps -- and the bite differs per WALL, not per notch, so no single
		# correction along the bisector can fix both at once.
		#
		# Solve both walls instead. Write the name's centre as V + a*e1 +
		# b*e2 over the two wall directions: its distance to the wall along
		# e1 is b*sqrt(1-c^2) and to the wall along e2 is a*sqrt(1-c^2),
		# with c = e1.e2. Ask each of those to be 9 plus the box's reach in
		# THAT wall's own normal direction -- |nx|*w/2 + |ny|*h/2, the
		# support function, exact for an axis-aligned box -- and a and b
		# fall out with no iteration. At the right angle c is zero, the two
		# normals are the legs themselves, and it collapses to nine pixels
		# plus a half-width and a half-height.
		[ :field, "t.cb", "0 - t.ucx*t.wx - t.ucy*t.wy" ],
		[ :field, "t.cc", "0 - t.ubx*t.wx - t.uby*t.wy" ],
		[ :field, "t.aa", "9 + (abs(t.ucx)*p.text.w + abs(t.ucy)*p.text.h) / 2" ],
		[ :field, "t.ab", "9 + (abs(t.ubx)*p.text.w + abs(t.uby)*p.text.h) / 2" ],
		[ :field, "t.sb", "sqrt(1 - t.cb^2 + 0.000001)" ],
		[ :field, "t.sc", "sqrt(1 - t.cc^2 + 0.000001)" ],
		[ :field, "t.n1bx", "(t.wx + t.cb*t.ucx) / t.sb" ],
		[ :field, "t.n1by", "(t.wy + t.cb*t.ucy) / t.sb" ],
		[ :field, "t.n2bx", "(0 - t.ucx - t.cb*t.wx) / t.sb" ],
		[ :field, "t.n2by", "(0 - t.ucy - t.cb*t.wy) / t.sb" ],
		[ :field, "t.n1cx", "(t.wx + t.cc*t.ubx) / t.sc" ],
		[ :field, "t.n1cy", "(t.wy + t.cc*t.uby) / t.sc" ],
		[ :field, "t.n2cx", "(0 - t.ubx - t.cc*t.wx) / t.sc" ],
		[ :field, "t.n2cy", "(0 - t.uby - t.cc*t.wy) / t.sc" ],
		[ :field, "t.ba", "(9 + (abs(t.n2bx)*q.text.w + abs(t.n2by)*q.text.h) / 2) / t.sb" ],
		[ :field, "t.bb", "(9 + (abs(t.n1bx)*q.text.w + abs(t.n1by)*q.text.h) / 2) / t.sb" ],
		[ :field, "t.ca", "(9 + (abs(t.n2cx)*r.text.w + abs(t.n2cy)*r.text.h) / 2) / t.sc" ],
		[ :field, "t.cbb", "(9 + (abs(t.n1cx)*r.text.w + abs(t.n1cy)*r.text.h) / 2) / t.sc" ],
		[ :override, "p.text.cx", "p.icon.cx - t.aa*t.ucx - t.ab*t.ubx" ],
		[ :override, "p.text.cy", "p.icon.cy - t.aa*t.ucy - t.ab*t.uby" ],
		[ :override, "q.text.cx", "q.icon.cx - t.ba*t.ucx + t.bb*t.wx" ],
		[ :override, "q.text.cy", "q.icon.cy - t.ba*t.ucy + t.bb*t.wy" ],
		[ :override, "r.text.cx", "r.icon.cx - t.ca*t.ubx + t.cbb*t.wx" ],
		[ :override, "r.text.cy", "r.icon.cy - t.ca*t.uby + t.cbb*t.wy" ],
		# THE ANGLE IS RIGHT, the legs are a decent size and visibly
		# unequal, and the hypotenuse lies flat with its square below it
		[ :ensure, "equal", [ "(t.abx*t.acx + t.aby*t.acy) / (t.lab*t.lac)", 0 ] ],
		[ :ensure, "greaterThan", [ "t.lab", 105 ] ], [ :ensure, "lessThan", [ "t.lab", 165 ] ],
		[ :ensure, "greaterThan", [ "t.lac", "t.lab + 35" ] ],
		[ :ensure, "lessThan", [ "t.lac", 235 ] ],
		[ :ensure, "greaterThan", [ "t.wy", 0.9994 ] ],
		[ :layer, "t.sqbc", :above, "t.face" ],
		[ :layer, "t.rect1", :above, "t.sqbc" ], [ :layer, "t.rect2", :above, "t.sqbc" ],
		[ :layer, "t.alt", :above, "t.rect1" ], [ :layer, "t.alt", :above, "t.rect2" ],
		# THE AREAS, SOLVED INSIDE THEIR SQUARES (DN8e). A square here is
		# rotated, so its bounding box would put a name outside the square
		# while calling it inside; the polygon's own edges hold each name
		# by its four corners, and the hypotenuse's label keeps off the
		# altitude that divides its square.
		# each area's colour is the best on whatever is UNDER it: c2 sits on
		# the hypotenuse's square, whose base is painted over by the two
		# rectangles, and the reader sees the rectangle, not the base
		[ :shape, "t.la", :text, [ :string = "a2", :fill = [ :on, "under" ] ] ],
		[ :shape, "t.lb", :text, [ :string = "b2", :fill = [ :on, "under" ] ] ],
		[ :shape, "t.lc", :text, [ :string = "c2", :fill = [ :on, "under" ] ] ],
		[ :ensure, "contains", [ "t.sqab", "t.la", 10 ] ],
		[ :ensure, "contains", [ "t.sqac", "t.lb", 10 ] ],
		[ :ensure, "contains", [ "t.sqbc", "t.lc", 10 ] ],
		[ :ensure, "disjoint", [ "t.lc", "t.alt", 8 ] ],
		# and each area's label wants its square's middle -- a hidden dot at
		# the mean of two opposite corners, which is a polygon's centre
		[ :shape, "t.ca", :circle, [ :cx = "(t.sqab.x1 + t.sqab.x3) / 2", :cy = "(t.sqab.y1 + t.sqab.y3) / 2", :r = 1, :hidden = 1 ] ],
		[ :shape, "t.cb", :circle, [ :cx = "(t.sqac.x1 + t.sqac.x3) / 2", :cy = "(t.sqac.y1 + t.sqac.y3) / 2", :r = 1, :hidden = 1 ] ],
		[ :shape, "t.cc", :circle, [ :cx = "(t.sqbc.x1 + t.sqbc.x3) / 2", :cy = "(t.sqbc.y1 + t.sqbc.y3) / 2", :r = 1, :hidden = 1 ] ],
		[ :encourage, "near", [ "t.la", "t.ca", 0 ] ],
		[ :encourage, "near", [ "t.lb", "t.cb", 0 ] ],
		[ :encourage, "near", [ "t.lc", "t.cc", 0 ] ],
		[ :layer, "t.la", :above, "t.sqab" ], [ :layer, "t.lb", :above, "t.sqac" ],
		[ :layer, "t.lc", :above, "t.sqbc" ],
		[ :layer, "t.mark1", :above, "t.face" ], [ :layer, "t.mark2", :above, "t.face" ],
		# A VERTEX GOES ABOVE THE LAST THING DRAWN, not above one of them.
		# Layering is a partial order relaxed to a depth per shape, so
		# naming the hypotenuse square left the dots at the SAME depth as
		# the two rectangles standing on it -- and a tie is broken by which
		# shape was minted first, which the points always are. Both dots
		# came out half-buried. Naming the altitude, which everything else
		# is already under, puts them on top of all of it.
		[ :layer, "p.icon", :above, "t.alt" ], [ :layer, "q.icon", :above, "t.alt" ],
		[ :layer, "r.icon", :above, "t.alt" ] ])
	return _o_

# The functions a rule may name, and what each expects. Penrose's names,
# because the convention exists and a second one would be a second
# thing to learn.
#   contains(a, b, pad)       b inside a, by pad          ensure
#   disjoint(a, b, pad)       a and b apart, by pad        ensure
#   overlapping(a, b, ov)     a and b meet, by ov          ensure
#   touching(a, b, pad)       a and b touch                ensure
#   lessThan(x, y, pad)       x + pad < y                  ensure
#   greaterThan(x, y, pad)    x > y + pad                  ensure
#   equal(x, y)               x = y                        both
#   inRange(x, lo, hi)                                     ensure
#   sameCenter(a, b) / near(a, b, off)                     encourage
#   minimal(x) / maximal(x)                                encourage
#   notTooClose(a, b, weight)                              encourage
#   above/below/leftwards/rightwards(a, b, off)            encourage
# A scalar argument is a number, a path ("x.icon.r"), or an EXPRESSION
# over paths and the computed functions ("len(s.icon)", "dot(u.arrow,
# v.arrow) / (len(u.arrow) * len(v.arrow))").
func StzMathLayoutFnList()
	return "contains, disjoint, notCrossing, overlapping, touching, lessThan, " +
	       "greaterThan, equal, inRange, sameCenter, near, minimal, " +
	       "maximal, notTooClose, above, below, leftwards, rightwards"

func StzMathLayoutFnExists(pcName)
	_c_ = StzLower(ring_trim("" + pcName))
	_ac_ = StzSplit(StzLower(StzMathLayoutFnList()), ", ")
	_n_ = len(_ac_)
	for _i_ = 1 to _n_
		if _ac_[_i_] = _c_  return TRUE  ok
	next
	return FALSE

# The computations an expression may call over SHAPES.
func StzMathComputedFnList()
	return "dist, len, dot, cross, midx, midy, ux, uy, nx, ny"

#---------------------------------------------------------------------#
#  THE DOMAIN                                                          #
#---------------------------------------------------------------------#

class stzMathDomain from stzObject

	@cName = ""
	@aTypes = []        # [ [ cType, cSuper ] ] -- cSuper "" at the root
	@aPredicates = []   # [ [ cName, acArgTypes, bSymmetric ] ]
	@aFunctions = []    # [ [ cName, acArgTypes, cOutType ] ]

	def init(pcName)
		@cName = StzLower(ring_trim("" + pcName))

	def Name_()
		return @cName

	#-- types --------------------------------------------------------------

	def AddType(pcType)
		_c_ = ring_trim("" + pcType)
		if _c_ = ""
			stzraise("stzMathDomain.AddType: a type needs a name.")
		ok
		if This.HasType(_c_)
			stzraise("stzMathDomain.AddType: '" + _c_ + "' is declared twice.")
		ok
		@aTypes + [ _c_, "" ]
		return This

		def AddTypeQ(pcType)
			return This.AddType(pcType)

	# "Hydrogen <: Atom": wherever an Atom is expected, a Hydrogen matches.
	def AddSubtype(pcType, pcSuper)
		_s_ = ring_trim("" + pcSuper)
		if NOT This.HasType(_s_)
			stzraise("stzMathDomain.AddSubtype: '" + _s_ + "' is not a type " +
				"of this domain -- declare it first.")
		ok
		This.AddType(pcType)
		@aTypes[len(@aTypes)][2] = _s_
		return This

		def AddSubtypeQ(pcType, pcSuper)
			return This.AddSubtype(pcType, pcSuper)

	def HasType(pcType)
		_c_ = StzLower(ring_trim("" + pcType))
		_n_ = len(@aTypes)
		for _i_ = 1 to _n_
			if StzLower(@aTypes[_i_][1]) = _c_  return TRUE  ok
		next
		return FALSE

	def Types()
		_a_ = []
		_n_ = len(@aTypes)
		for _i_ = 1 to _n_
			_a_ + @aTypes[_i_][1]
		next
		return _a_

	# TRUE when an object of pcActual may stand where pcWanted is asked
	# for -- the same type, or a subtype of it, at any depth.
	def TypeMatches(pcActual, pcWanted)
		_a_ = StzLower(ring_trim("" + pcActual))
		_w_ = StzLower(ring_trim("" + pcWanted))
		_nGuard_ = 0
		while _a_ != "" and _nGuard_ < 64
			_nGuard_++
			if _a_ = _w_  return TRUE  ok
			_a_ = StzLower(This._SuperOf(_a_))
		end
		return FALSE

	def _SuperOf(pcType)
		_c_ = StzLower(ring_trim("" + pcType))
		_n_ = len(@aTypes)
		for _i_ = 1 to _n_
			if StzLower(@aTypes[_i_][1]) = _c_  return @aTypes[_i_][2]  ok
		next
		return ""

	#-- predicates -----------------------------------------------------------

	def AddPredicate(pcName, pacArgTypes)
		return This._AddPredicate(pcName, pacArgTypes, 0)

		def AddPredicateQ(pcName, pacArgTypes)
			return This.AddPredicate(pcName, pacArgTypes)

	# Symmetric: Disjoint(A, B) IS Disjoint(B, A). Penrose restricts this
	# to binary predicates over one type, and so does this.
	def AddSymmetricPredicate(pcName, pacArgTypes)
		if NOT isList(pacArgTypes) or len(pacArgTypes) != 2
			stzraise("stzMathDomain.AddSymmetricPredicate: a symmetric " +
				"predicate takes exactly two arguments.")
		ok
		if StzLower("" + pacArgTypes[1]) != StzLower("" + pacArgTypes[2])
			stzraise("stzMathDomain.AddSymmetricPredicate: both arguments " +
				"must be the same type -- the order is what symmetry erases.")
		ok
		return This._AddPredicate(pcName, pacArgTypes, 1)

		def AddSymmetricPredicateQ(pcName, pacArgTypes)
			return This.AddSymmetricPredicate(pcName, pacArgTypes)

	def _AddPredicate(pcName, pacArgTypes, pbSym)
		_c_ = ring_trim("" + pcName)
		if _c_ = ""
			stzraise("stzMathDomain.AddPredicate: a predicate needs a name.")
		ok
		if This.HasPredicate(_c_)
			stzraise("stzMathDomain.AddPredicate: '" + _c_ + "' is declared twice.")
		ok
		_ac_ = []
		if isString(pacArgTypes)  _ac_ + pacArgTypes  else  _ac_ = pacArgTypes  ok
		_n_ = len(_ac_)
		for _i_ = 1 to _n_
			if NOT This.HasType(_ac_[_i_])
				stzraise("stzMathDomain.AddPredicate: '" + _c_ + "' names the " +
					"type '" + _ac_[_i_] + "', which this domain does not have.")
			ok
		next
		@aPredicates + [ _c_, _ac_, pbSym ]
		return This

	def HasPredicate(pcName)
		return len(This._Predicate(pcName)) > 0

	def _Predicate(pcName)
		_c_ = StzLower(ring_trim("" + pcName))
		_n_ = len(@aPredicates)
		for _i_ = 1 to _n_
			if StzLower(@aPredicates[_i_][1]) = _c_  return @aPredicates[_i_]  ok
		next
		return []

	def PredicateArity(pcName)
		_p_ = This._Predicate(pcName)
		if len(_p_) = 0  return -1  ok
		return len(_p_[2])

	def IsSymmetric(pcName)
		_p_ = This._Predicate(pcName)
		if len(_p_) = 0  return FALSE  ok
		return _p_[3] = 1

	def Predicates()
		_a_ = []
		_n_ = len(@aPredicates)
		for _i_ = 1 to _n_
			_a_ + @aPredicates[_i_][1]
		next
		return _a_

	#-- functions and constructors -----------------------------------------

	def AddFunction(pcName, pacArgTypes, pcOutType)
		_c_ = ring_trim("" + pcName)
		if _c_ = ""
			stzraise("stzMathDomain.AddFunction: a function needs a name.")
		ok
		if NOT This.HasType(pcOutType)
			stzraise("stzMathDomain.AddFunction: '" + _c_ + "' returns '" +
				pcOutType + "', which this domain does not have.")
		ok
		if This.HasFunction(_c_)
			stzraise("stzMathDomain.AddFunction: '" + _c_ + "' is declared twice.")
		ok
		_ac_ = []
		if isString(pacArgTypes)  _ac_ + pacArgTypes  else  _ac_ = pacArgTypes  ok
		_n_ = len(_ac_)
		for _i_ = 1 to _n_
			if NOT This.HasType(_ac_[_i_])
				stzraise("stzMathDomain.AddFunction: '" + _c_ + "' takes a '" +
					_ac_[_i_] + "', which this domain does not have.")
			ok
		next
		@aFunctions + [ _c_, _ac_, ring_trim("" + pcOutType) ]
		return This

		def AddFunctionQ(pcName, pacArgTypes, pcOutType)
			return This.AddFunction(pcName, pacArgTypes, pcOutType)

		# a constructor is a function whose name is its output type
		def AddConstructor(pcName, pacArgTypes)
			return This.AddFunction(pcName, pacArgTypes, pcName)

	def HasFunction(pcName)
		return len(This._Function(pcName)) > 0

	def _Function(pcName)
		_c_ = StzLower(ring_trim("" + pcName))
		_n_ = len(@aFunctions)
		for _i_ = 1 to _n_
			if StzLower(@aFunctions[_i_][1]) = _c_  return @aFunctions[_i_]  ok
		next
		return []

	def FunctionOutputType(pcName)
		_f_ = This._Function(pcName)
		if len(_f_) = 0  return ""  ok
		return _f_[3]

	def FunctionArity(pcName)
		_f_ = This._Function(pcName)
		if len(_f_) = 0  return -1  ok
		return len(_f_[2])

#---------------------------------------------------------------------#
#  THE SUBSTANCE                                                       #
#---------------------------------------------------------------------#

class stzMathSubstance from stzObject

	@oDomain = NULL
	@aObjects = []      # [ [ cName, cType ] ]
	@aRelations = []    # [ [ cPredicate, acArgs ] ]
	@aDefinitions = []  # [ [ cName, cFunction, acArgs ] ]
	@aLabels = []       # [ [ cName, cLabel ] ]
	@aData = []         # [ [ cName, cKey, nValue ] ]
	@bAutoLabel = 0
	# INDEXES (DN8f): name -> position, so five thousand objects cost five
	# thousand lookups and not twelve million comparisons
	@aObjIdx = []       # _MdKey(cName) -> index in @aObjects
	@aDataIdx = []      # _MdKey(cName | cKey) -> index in @aData
	@aDefIdx = []       # _MdKey(cName) -> index in @aDefinitions

	def init(poDomain)
		if NOT isObject(poDomain)
			stzraise("stzMathSubstance: give the domain this content is " +
				"written in -- an stzMathDomain.")
		ok
		@oDomain = poDomain

	def DomainQ()
		return @oDomain

	#-- objects ------------------------------------------------------------

	def Declare(pcType, pcName)
		_t_ = ring_trim("" + pcType)
		_n_ = ring_trim("" + pcName)
		if NOT @oDomain.HasType(_t_)
			stzraise("stzMathSubstance.Declare: '" + _t_ + "' is not a type " +
				"of the '" + @oDomain.Name_() + "' domain.")
		ok
		if _n_ = ""
			stzraise("stzMathSubstance.Declare: an object needs a name.")
		ok
		# A NAME IS THE HEAD OF EVERY PATH WRITTEN ABOUT THE OBJECT -- "A.icon.cx"
		# -- and the Style's expression language reads a leading digit as a
		# number, so "000.icon.cx" loses its head and fails three layers
		# down with a message about "icon.cx". Refuse it here, where the
		# name is, with the rule spelled out.
		_k_ = ascii(_n_[1])
		if NOT ((_k_ >= 65 and _k_ <= 90) or (_k_ >= 97 and _k_ <= 122) or _k_ = 95)
			stzraise("stzMathSubstance.Declare: '" + _n_ + "' cannot be an object's " +
				"name -- a name starts with a letter or an underscore, because " +
				"it heads every path a Style writes about the object.")
		ok
		for _i_ = 2 to len(_n_)
			_k_ = ascii(_n_[_i_])
			if NOT ((_k_ >= 48 and _k_ <= 57) or (_k_ >= 65 and _k_ <= 90) or
			        (_k_ >= 97 and _k_ <= 122) or _k_ = 95)
				stzraise("stzMathSubstance.Declare: '" + _n_ + "' cannot be an object's " +
					"name -- after the first letter, only letters, digits and " +
					"underscores.")
			ok
		next
		if This.HasObject(_n_)
			stzraise("stzMathSubstance.Declare: '" + _n_ + "' is declared twice.")
		ok
		@aObjects + [ _n_, _t_ ]
		@aObjIdx[_MdKey(_n_)] = len(@aObjects)
		return This

		def DeclareQ(pcType, pcName)
			return This.Declare(pcType, pcName)

	# "Set A, B, C"
	def DeclareAll(pcType, pacNames)
		_n_ = len(pacNames)
		for _i_ = 1 to _n_
			This.Declare(pcType, pacNames[_i_])
		next
		return This

		def DeclareAllQ(pcType, pacNames)
			return This.DeclareAll(pcType, pacNames)

	def HasObject(pcName)
		return This.TypeOf(pcName) != ""

	def TypeOf(pcName)
		_i_ = @aObjIdx[_MdKey(ring_trim("" + pcName))]
		if isNumber(_i_)  return @aObjects[_i_][2]  ok
		return ""

	def Objects()
		return @aObjects

	def ObjectNames()
		_a_ = []
		_n_ = len(@aObjects)
		for _i_ = 1 to _n_
			_a_ + @aObjects[_i_][1]
		next
		return _a_

	def ObjectsOfType(pcType)
		_a_ = []
		_n_ = len(@aObjects)
		for _i_ = 1 to _n_
			if @oDomain.TypeMatches(@aObjects[_i_][2], pcType)
				_a_ + @aObjects[_i_][1]
			ok
		next
		return _a_

	#-- relations ------------------------------------------------------------

	# Assert("Subset", [ "B", "A" ]) -- typechecked against the domain,
	# because a relation over the wrong kind of object is a statement about
	# nothing, and the earlier it is refused the nearer the refusal is to
	# the line that made it.
	def Assert(pcPredicate, pacArgs)
		_p_ = ring_trim("" + pcPredicate)
		if NOT @oDomain.HasPredicate(_p_)
			stzraise("stzMathSubstance.Assert: '" + _p_ + "' is not a " +
				"predicate of the '" + @oDomain.Name_() + "' domain.")
		ok
		_ac_ = []
		if isString(pacArgs)  _ac_ + pacArgs  else  _ac_ = pacArgs  ok
		_nWant_ = @oDomain.PredicateArity(_p_)
		if len(_ac_) != _nWant_
			stzraise("stzMathSubstance.Assert: '" + _p_ + "' takes " + _nWant_ +
				" argument(s), not " + len(_ac_) + ".")
		ok
		_aTypes_ = @oDomain._Predicate(_p_)[2]
		_n_ = len(_ac_)
		for _i_ = 1 to _n_
			_cT_ = This.TypeOf(_ac_[_i_])
			if _cT_ = ""
				stzraise("stzMathSubstance.Assert: '" + _ac_[_i_] + "' is not a " +
					"declared object.")
			ok
			if NOT @oDomain.TypeMatches(_cT_, _aTypes_[_i_])
				stzraise("stzMathSubstance.Assert: argument " + _i_ + " of '" +
					_p_ + "' must be a " + _aTypes_[_i_] + "; '" + _ac_[_i_] +
					"' is a " + _cT_ + ".")
			ok
		next
		@aRelations + [ _p_, _ac_ ]
		return This

		def AssertQ(pcPredicate, pacArgs)
			return This.Assert(pcPredicate, pacArgs)

	def Relations()
		return @aRelations

	# Does the substance state pcPredicate over exactly these objects?
	# Order matters unless the domain declared the predicate symmetric.
	def Holds(pcPredicate, pacArgs)
		_p_ = StzLower(ring_trim("" + pcPredicate))
		_bSym_ = @oDomain.IsSymmetric(_p_)
		_n_ = len(@aRelations)
		for _i_ = 1 to _n_
			if StzLower(@aRelations[_i_][1]) != _p_  loop  ok
			if This._SameArgs(@aRelations[_i_][2], pacArgs)  return TRUE  ok
			if _bSym_ and len(pacArgs) = 2 and
			   This._SameArgs(@aRelations[_i_][2], [ pacArgs[2], pacArgs[1] ])
				return TRUE
			ok
		next
		return FALSE

	def _SameArgs(pa, pb)
		if len(pa) != len(pb)  return FALSE  ok
		_n_ = len(pa)
		for _i_ = 1 to _n_
			if "" + pa[_i_] != "" + pb[_i_]  return FALSE  ok
		next
		return TRUE

	#-- function applications ------------------------------------------------

	# Define("u", "addV", [ "v", "w" ]): u is declared as the function's
	# output type and remembered as its result. Typechecked like Assert.
	def Define(pcName, pcFunction, pacArgs)
		_f_ = ring_trim("" + pcFunction)
		if NOT @oDomain.HasFunction(_f_)
			stzraise("stzMathSubstance.Define: '" + _f_ + "' is not a " +
				"function of the '" + @oDomain.Name_() + "' domain.")
		ok
		_ac_ = []
		if isString(pacArgs)  _ac_ + pacArgs  else  _ac_ = pacArgs  ok
		_nWant_ = @oDomain.FunctionArity(_f_)
		if len(_ac_) != _nWant_
			stzraise("stzMathSubstance.Define: '" + _f_ + "' takes " + _nWant_ +
				" argument(s), not " + len(_ac_) + ".")
		ok
		_aTypes_ = @oDomain._Function(_f_)[2]
		_n_ = len(_ac_)
		for _i_ = 1 to _n_
			_cT_ = This.TypeOf(_ac_[_i_])
			if _cT_ = ""
				stzraise("stzMathSubstance.Define: '" + _ac_[_i_] + "' is not a " +
					"declared object.")
			ok
			if NOT @oDomain.TypeMatches(_cT_, _aTypes_[_i_])
				stzraise("stzMathSubstance.Define: argument " + _i_ + " of '" +
					_f_ + "' must be a " + _aTypes_[_i_] + "; '" + _ac_[_i_] +
					"' is a " + _cT_ + ".")
			ok
		next
		This.Declare(@oDomain.FunctionOutputType(_f_), pcName)
		@aDefinitions + [ ring_trim("" + pcName), _f_, _ac_ ]
		@aDefIdx[_MdKey(ring_trim("" + pcName))] = len(@aDefinitions)
		return This

		def DefineQ(pcName, pcFunction, pacArgs)
			return This.Define(pcName, pcFunction, pacArgs)

	def Definitions()
		return @aDefinitions

	#-- data ------------------------------------------------------------------

	# A NUMBER ON AN OBJECT. Penrose's Substance carries no numbers, and for
	# a set or a point that is right: the content is the relation, not the
	# coordinate. A table is different -- a cell IS its row, its column and
	# its value -- and a heatmap is nothing but numbers. SetData puts one
	# on an object under a key; any Style expression reads it as "x.key",
	# to drive a position or, through a colour rule, a fill.
	def SetData(pcName, pcKey, pnValue)
		_c_ = This._DeclaredName(pcName)
		_k_ = ring_trim("" + pcKey)
		if _k_ = "" or NOT This._IsIdentifier(_k_)
			stzraise("stzMathSubstance.SetData: '" + _k_ + "' is not a key -- a " +
				"letter or underscore, then letters, digits and underscores.")
		ok
		if NOT isNumber(pnValue)
			stzraise("stzMathSubstance.SetData: the value under '" + _k_ + "' on '" +
				_c_ + "' must be a number.")
		ok
		_i_ = @aDataIdx[_MdKey(_c_ + "|" + _k_)]
		if isNumber(_i_)
			@aData[_i_][3] = pnValue
			return This
		ok
		@aData + [ _c_, _k_, pnValue ]
		@aDataIdx[_MdKey(_c_ + "|" + _k_)] = len(@aData)
		return This

		def SetDataQ(pcName, pcKey, pnValue)
			return This.SetData(pcName, pcKey, pnValue)

	# CONTENT GENERATORS (DN8f). Iteration was never a Style's job: a chaos
	# game, an envelope of circles, a random walk are thousands of OBJECTS
	# with data, and a substance may hold them. DeclareMany makes n named
	# objects at once; SetDataFrom puts a list of numbers on them, one
	# each, under a key.
	def DeclareMany(pcType, pcPrefix, pnCount)
		for _i_ = 1 to pnCount
			This.Declare(pcType, "" + pcPrefix + _i_)
		next
		return This

		def DeclareManyQ(pcType, pcPrefix, pnCount)
			return This.DeclareMany(pcType, pcPrefix, pnCount)

	def SetDataFrom(pcPrefix, pcKey, paValues)
		_n_ = len(paValues)
		for _i_ = 1 to _n_
			This.SetData("" + pcPrefix + _i_, pcKey, paValues[_i_])
		next
		return This

		def SetDataFromQ(pcPrefix, pcKey, paValues)
			return This.SetDataFrom(pcPrefix, pcKey, paValues)

	def HasData(pcName, pcKey)
		_c_ = ring_trim("" + pcName)
		_k_ = ring_trim("" + pcKey)
		return isNumber(@aDataIdx[_MdKey(_c_ + "|" + _k_)])

	def DataOf(pcName, pcKey)
		_c_ = ring_trim("" + pcName)
		_k_ = ring_trim("" + pcKey)
		_i_ = @aDataIdx[_MdKey(_c_ + "|" + _k_)]
		if isNumber(_i_)  return @aData[_i_][3]  ok
		stzraise("stzMathSubstance.DataOf: '" + _c_ + "' carries no '" + _k_ + "'.")

	#-- a substance is a graph (DN8a) ------------------------------------------

	# EVERY OBJECT A NODE, EVERY RELATION AN EDGE -- and where an edge will
	# not do, a node. stzGraph is a SIMPLE graph: no parallel edges, one
	# self-loop at most, and its refusal names the remedy, "model the second
	# relation as its own node". So a binary relation becomes a direct edge
	# when the pair is free, and is REIFIED as a relation node with one
	# edge per argument whenever a direct edge would be parallel -- exactly
	# as a relation of three or more arguments must be anyway. A definition
	# u := f(a, b) is edges from u to each argument, carrying the function
	# and the position, unless f is among the constructors the caller asks
	# to PROJECT, in which case the object u is not a node at all but the
	# edge a -> b itself: that is how a graph-domain substance becomes the
	# plain graph the layouts want. Nothing is lost either way: a graph made
	# here goes back through StzSubstanceFromGraph to the same substance.
	#
	# stzGraph folds node ids to lower case, and a substance's names are
	# case-sensitive (DN7b). The true name rides as a node property, and two
	# names that differ only by case are refused here, with the reason.
	def ToGraph()
		return This.ToGraphXT([])

	def ToGraphXT(paOpts)
		_acProj_ = []
		if isList(paOpts) and HasKey(paOpts, "projectConstructors")
			if isString(paOpts[:projectConstructors])
				_acProj_ + paOpts[:projectConstructors]
			else
				_acProj_ = paOpts[:projectConstructors]
			ok
		ok
		_nO_ = len(@aObjects)
		for _i_ = 1 to _nO_
			for _j_ = _i_ + 1 to _nO_
				if @aObjects[_i_][1] != @aObjects[_j_][1] and
				   StzLower(@aObjects[_i_][1]) = StzLower(@aObjects[_j_][1])
					stzraise("stzMathSubstance.ToGraph: '" + @aObjects[_i_][1] + "' and '" +
						@aObjects[_j_][1] + "' differ only by case, and stzGraph folds " +
						"node ids to lower case -- they would be one node.")
				ok
			next
		next
		# the objects a projected constructor defines are edges, not nodes
		_acAsEdge_ = []
		_nD_ = len(@aDefinitions)
		for _d_ = 1 to _nD_
			if This._InList(_acProj_, @aDefinitions[_d_][2]) and len(@aDefinitions[_d_][3]) = 2
				_acAsEdge_ + @aDefinitions[_d_][1]
			ok
		next
		_oG_ = new stzGraph("substance")
		for _i_ = 1 to _nO_
			_cN_ = @aObjects[_i_][1]
			if This._InList(_acAsEdge_, _cN_)  loop  ok
			_oG_.AddNodeXTT(_cN_, This.LabelOf(_cN_), This._NodeProps(_cN_, @aObjects[_i_][2]))
		next
		# relations: an edge when the pair is free, a node otherwise
		_nR_ = len(@aRelations)
		_nRel_ = 0
		for _r_ = 1 to _nR_
			_cP_ = @aRelations[_r_][1]
			_ac_ = @aRelations[_r_][2]
			if len(_ac_) = 1  loop  ok
			_bDirect_ = (len(_ac_) = 2 and NOT This._InList(_acAsEdge_, _ac_[1]) and
			             NOT This._InList(_acAsEdge_, _ac_[2]) and
			             NOT _oG_.EdgeExists(_ac_[1], _ac_[2]))
			if _bDirect_ and @oDomain.IsSymmetric(_cP_) and _oG_.EdgeExists(_ac_[2], _ac_[1])
				_bDirect_ = FALSE
			ok
			if _bDirect_
				_oG_.AddEdgeXTT(_ac_[1], _ac_[2], _cP_, [ :kind = "predicate", :predicate = _cP_ ])
			else
				_nRel_++
				_cR_ = "rel_" + StzLower(_cP_) + "_" + _nRel_
				_oG_.AddNodeXTT(_cR_, "", [ :kind = "relation", :type = "_relation", :predicate = _cP_ ])
				for _k_ = 1 to len(_ac_)
					if This._InList(_acAsEdge_, _ac_[_k_]) or _oG_.EdgeExists(_cR_, _ac_[_k_])
						stzraise("stzMathSubstance.ToGraph: " + _cP_ + "(" + This._Join(_ac_) +
							") cannot be drawn as a graph -- an argument repeats, or is " +
							"an object projected to an edge.")
					ok
					_oG_.AddEdgeXTT(_cR_, _ac_[_k_], _cP_, [ :kind = "argument", :position = _k_ ])
				next
			ok
		next
		# definitions: projected to an edge, or edges to each argument
		for _d_ = 1 to _nD_
			_cU_ = @aDefinitions[_d_][1]
			_cF_ = @aDefinitions[_d_][2]
			_ac_ = @aDefinitions[_d_][3]
			if This._InList(_acAsEdge_, _cU_)
				if _oG_.EdgeExists(_ac_[1], _ac_[2])
					stzraise("stzMathSubstance.ToGraph: '" + _cU_ + "' := " + _cF_ + "(" +
						This._Join(_ac_) + ") cannot be projected -- an edge from '" +
						_ac_[1] + "' to '" + _ac_[2] + "' is already taken.")
				ok
				_aP_ = This._NodeProps(_cU_, This.TypeOf(_cU_))
				_aP_ + [ "kind", "constructor" ]
				_aP_ + [ "constructor", _cF_ ]
				_aP_ + [ "object", _cU_ ]
				_oG_.AddEdgeXTT(_ac_[1], _ac_[2], This.LabelOf(_cU_), _aP_)
				loop
			ok
			for _k_ = 1 to len(_ac_)
				if This._InList(_acAsEdge_, _ac_[_k_]) or _oG_.EdgeExists(_cU_, _ac_[_k_])
					stzraise("stzMathSubstance.ToGraph: '" + _cU_ + "' := " + _cF_ + "(" +
						This._Join(_ac_) + ") cannot be drawn as a graph -- an argument " +
						"repeats, or is an object projected to an edge.")
				ok
				_oG_.AddEdgeXTT(_cU_, _ac_[_k_], _cF_,
					[ :kind = "definition", :function = _cF_, :position = _k_ ])
			next
		next
		return _oG_

	# the type, the true name, the data and the unary predicates of an object
	def _NodeProps(pcName, pcType)
		_a_ = []
		_a_ + [ "type", pcType ]
		_a_ + [ "name", pcName ]
		_aD_ = []
		for _i_ = 1 to len(@aData)
			if @aData[_i_][1] = pcName  _aD_ + [ @aData[_i_][2], @aData[_i_][3] ]  ok
		next
		_a_ + [ "data", _aD_ ]
		_aU_ = []
		for _i_ = 1 to len(@aRelations)
			if len(@aRelations[_i_][2]) = 1 and @aRelations[_i_][2][1] = pcName
				_aU_ + @aRelations[_i_][1]
			ok
		next
		_a_ + [ "unary", _aU_ ]
		return _a_

	def _InList(pac, pc)
		for _i_ = 1 to len(pac)
			if "" + pac[_i_] = "" + pc  return TRUE  ok
		next
		return FALSE

	def _Join(pac)
		_c_ = ""
		for _i_ = 1 to len(pac)
			if _i_ > 1  _c_ += ", "  ok
			_c_ += "" + pac[_i_]
		next
		return _c_

	def _IsIdentifier(pc)
		_k_ = ascii(pc[1])
		if NOT ((_k_ >= 65 and _k_ <= 90) or (_k_ >= 97 and _k_ <= 122) or _k_ = 95)
			return FALSE
		ok
		for _i_ = 2 to len(pc)
			_k_ = ascii(pc[_i_])
			if NOT ((_k_ >= 48 and _k_ <= 57) or (_k_ >= 65 and _k_ <= 90) or
			        (_k_ >= 97 and _k_ <= 122) or _k_ = 95)
				return FALSE
			ok
		next
		return TRUE

	# Is pcName defined as pcFunction over exactly these objects, in order?
	def IsDefinedAs(pcName, pcFunction, pacArgs)
		_c_ = ring_trim("" + pcName)
		_f_ = StzLower(ring_trim("" + pcFunction))
		# a name is defined once -- Define declares it, and a second
		# declaration is refused -- so its definition is one indexed entry
		_i_ = @aDefIdx[_MdKey(_c_)]
		if NOT isNumber(_i_)  return FALSE  ok
		return StzLower(@aDefinitions[_i_][2]) = _f_ and
		       This._SameArgs(@aDefinitions[_i_][3], pacArgs)

	#-- labels -----------------------------------------------------------------

	def Label(pcName, pcLabel)
		if NOT This.HasObject(pcName)
			stzraise("stzMathSubstance.Label: '" + pcName + "' is not a " +
				"declared object.")
		ok
		@aLabels + [ ring_trim("" + pcName), "" + pcLabel ]
		return This

		def LabelQ(pcName, pcLabel)
			return This.Label(pcName, pcLabel)

	def AutoLabelAll()
		@bAutoLabel = 1
		return This

	# The label an object carries: the one given, else its own name when
	# AutoLabel is on, else "".
	def LabelOf(pcName)
		_c_ = ring_trim("" + pcName)
		_n_ = len(@aLabels)
		for _i_ = 1 to _n_
			if @aLabels[_i_][1] = _c_  return @aLabels[_i_][2]  ok
		next
		if @bAutoLabel = 1  return This._DeclaredName(pcName)  ok
		return ""

	def _DeclaredName(pcName)
		_i_ = @aObjIdx[_MdKey(ring_trim("" + pcName))]
		if isNumber(_i_)  return @aObjects[_i_][1]  ok
		return ""

#---------------------------------------------------------------------#
#  THE STYLE                                                           #
#---------------------------------------------------------------------#

class stzMathStyle from stzObject

	@nW = 800
	@nH = 700
	@aRules = []        # [ [ cSelector, cWhere, aRows ] ]
	@aPlanarStart = []  # [ cType, cShape, [ cCtor, ... ] ] when asked for
	@aStarts = []       # the start modes, in the order tried
	@nMargin = 0
	@bLabelsAfter = FALSE
	@cTheme = ""        # the theme a role resolves in; "" is the light one

	def init()

	def SetCanvas(pnW, pnH)
		@nW = pnW
		@nH = pnH
		return This

		def SetCanvasQ(pnW, pnH)
			return This.SetCanvas(pnW, pnH)

	def CanvasWidth()
		return @nW

	def CanvasHeight()
		return @nH

	# ForAll("Set x", rows) -- rows are DATA. Each row is one of:
	#   [ :shape,     "x.icon", :circle | :rect | :text | :line | :curve |
	#                          :poly | :mark, [ props ] ]
	#   [ :delete,    "x.icon" ]              unmint a shape an earlier rule made
	#   [ :unknown,   "p.sx", lo, hi ]        a variable the solver owns
	#   [ :field,     "U.ox", number | "expression" ]
	#   [ :override,  "u.arrow.x2", number | "expression" ]
	#   [ :ensure,    "fn", [ args ] ]        a constraint
	#   [ :encourage, "fn", [ args ] ]        an objective
	#   [ :layer,     "x.text", :above | :below, "x.icon" ]
	# A property or argument is a number, a path ("x.icon.r"), or an
	# expression over paths ("U.ox + 14*ux(u.arrow)").
	def ForAll(pcSelector, paRows)
		return This.ForAllWhere(pcSelector, "", paRows)

		def ForAllQ(pcSelector, paRows)
			return This.ForAll(pcSelector, paRows)

	def ForAllWhere(pcSelector, pcWhere, paRows)
		_cS_ = ring_trim("" + pcSelector)
		if _cS_ = ""
			stzraise("stzMathStyle.ForAll: a rule needs a selector, like " +
				"'Set x' or 'Set x; Set y'.")
		ok
		if NOT isList(paRows)
			stzraise("stzMathStyle.ForAll: the rule body is a list of rows.")
		ok
		_n_ = len(paRows)
		for _i_ = 1 to _n_
			This._CheckRow(paRows[_i_], _i_)
		next
		@aRules + [ _cS_, ring_trim("" + pcWhere), paRows ]
		return This

		def ForAllWhereQ(pcSelector, pcWhere, paRows)
			return This.ForAllWhere(pcSelector, pcWhere, paRows)

	def _CheckRow(paRow, pnAt)
		if NOT isList(paRow) or len(paRow) < 2
			stzraise("stzMathStyle: row " + pnAt + " is not a rule row.")
		ok
		_k_ = "" + paRow[1]
		# PENROSE'S DELETE, and the only row that is two long: a rule
		# specialising an earlier one unmints the general icon before
		# drawing its own.
		if _k_ = "delete"
			if len(paRow) != 2 or NOT isString(paRow[2])
				stzraise("stzMathStyle: a delete row is [ :delete, path ] -- the " +
					"shape an earlier rule minted, and nothing else.")
			ok
			return
		ok
		if len(paRow) < 3
			stzraise("stzMathStyle: row " + pnAt + " is not a rule row.")
		ok
		if _k_ = "shape"
			_kind_ = "" + paRow[3]
			if _kind_ != "circle" and _kind_ != "rect" and _kind_ != "text" and
			   _kind_ != "line" and _kind_ != "curve" and _kind_ != "poly" and
			   _kind_ != "mark" and _kind_ != "spline" and _kind_ != "ellipse"
				stzraise("stzMathStyle: '" + _kind_ + "' is not a shape DN7 " +
					"draws -- circle, rect, text, line, curve, poly, mark, spline or ellipse.")
			ok
		but _k_ = "unknown"
			if NOT isString(paRow[2]) or NOT isNumber(paRow[3]) or len(paRow) < 4 or
			   NOT isNumber(paRow[4])
				stzraise("stzMathStyle: an unknown row is [ :unknown, path, lo, hi ] -- " +
					"a variable the solver owns, started somewhere in [lo, hi].")
			ok
		but _k_ = "field" or _k_ = "override"
			if NOT isString(paRow[2]) or NOT (isNumber(paRow[3]) or isString(paRow[3]))
				stzraise("stzMathStyle: a " + _k_ + " row is [ :" + _k_ +
					", path, number or expression ].")
			ok
		but _k_ = "ensure" or _k_ = "encourage"
			if NOT isString(paRow[2]) or NOT isList(paRow[3])
				stzraise("stzMathStyle: an " + _k_ + " row is [ :" + _k_ +
					", fn, [ args ] ] -- fn a layout function's name.")
			ok
			if NOT StzMathLayoutFnExists(paRow[2])
				stzraise("stzMathStyle: '" + paRow[2] + "' is not a layout " +
					"function -- the catalogue is " + StzMathLayoutFnList() + ".")
			ok
		but _k_ = "layer"
			if len(paRow) < 4
				stzraise("stzMathStyle: a layer row is [ :layer, path, :above|:below, path ].")
			ok
		else
			stzraise("stzMathStyle: '" + _k_ + "' is not a rule verb -- shape, " +
				"unknown, field, override, ensure, encourage or layer.")
		ok

	def Rules()
		return @aRules

	# A PLANAR START. The solver never leaves the basin it starts in -- DN7f
	# measured 84 crossing terms holding 10,138 energy units at convergence
	# that no weight could spend -- so the start is where planarity is
	# decided. A style that draws a graph declares which objects are its
	# vertices, which shape's centre carries them, and which constructors
	# are its edges; the diagram then seeds those centres by Tutte's
	# embedding rather than at random. Everything else in the picture still
	# starts where it always did.
	def StartPlanar(pcType, pcShape, pacCtors)
		return This.StartTrying([ :planar ], pcType, pcShape, pacCtors)

	# LAYOUTS AS STARTS (DN8b). The graph plane's own engines -- hierarchical,
	# ring, force, mesh, sequence -- computed on the graph the substance's
	# vertices and edges make, and overlaid as the solver's start. The planar
	# start is one of them. StartTrying names SEVERAL: the solver takes them
	# in order, and the first that ends lawful is the picture -- so the seed
	# is no longer what decides whether a lattice crosses.
	def StartLayout(pcMode, pcType, pcShape, pacCtors)
		return This.StartTrying([ pcMode ], pcType, pcShape, pacCtors)

	def StartTrying(pacModes, pcType, pcShape, pacCtors)
		_ac_ = []
		if isString(pacCtors)  _ac_ + pacCtors  else  _ac_ = pacCtors  ok
		@aPlanarStart = [ ring_trim("" + pcType), ring_trim("" + pcShape), _ac_ ]
		@aStarts = []
		_am_ = pacModes
		if NOT isList(_am_)  _am_ = [ _am_ ]  ok
		for _i_ = 1 to len(_am_)
			_m_ = StzLower("" + _am_[_i_])
			if _m_ != "planar" and _m_ != "hierarchical" and _m_ != "ring" and
			   _m_ != "force" and _m_ != "mesh" and _m_ != "sequence" and _m_ != "random"
				stzraise("stzMathStyle: '" + _am_[_i_] + "' is not a start -- planar, " +
					"hierarchical, ring, force, mesh, sequence or random.")
			ok
			@aStarts + _m_
		next
		return This

	# the starts to try, in order; empty means one random start
	def Starts()
		return @aStarts

		def StartPlanarQ(pcType, pcShape, pacCtors)
			return This.StartPlanar(pcType, pcShape, pacCtors)

	def ClearPlanarStart()
		@aPlanarStart = []
		@aStarts = []
		return This

	def PlanarStart()
		return @aPlanarStart

	# A MARGIN inside the paper. The on-canvas rule holds every shape inside
	# the canvas exactly, and a style whose vertices repel one another
	# pushes them onto that line: the dodecahedron came out with its outer
	# face touching all four edges. A margin moves the line in.
	def SetMargin(pnPx)
		@nMargin = pnPx
		return This

		def SetMarginQ(pnPx)
			return This.SetMargin(pnPx)

	def Margin()
		return @nMargin

	# COLOUR AS MEANING (DN8d). A style writes ROLES -- :primary for the one
	# accent, :neutral for ink, :muted for secondary ink, :background for
	# the paper -- and the theme decides what each is. A theme is named
	# here; the diagram resolves every role through it at draw time, and
	# a text with no colour of its own takes the best of black and white
	# on what it sits on, measured. Content colours -- Byrne's plate, the
	# quaternion table's eight -- stay the style's own data.
	def SetTheme(pcName)
		@cTheme = StzLower(ring_trim("" + pcName))
		return This

		def SetThemeQ(pcName)
			return This.SetTheme(pcName)

	def Theme()
		if @cTheme = ""  return "light"  ok
		return @cTheme

	# LABELS AFTER SHAPES. The joint first stage lets a name's constraints
	# move the shapes -- which an Euler diagram needs, since a set must be
	# large enough for its name, and which a graph must NOT have: a name
	# held off an edge pulls on the edge's endpoints, and at a high penalty
	# weight eight names threw a planar cube away to make room for
	# themselves. Under this, the first stage sees no label term at all,
	# and the names find their room against frozen shapes.
	def SolveLabelsAfter()
		@bLabelsAfter = TRUE
		return This

		def SolveLabelsAfterQ()
			return This.SolveLabelsAfter()

	def LabelsAfter()
		return @bLabelsAfter

#---------------------------------------------------------------------#
#  THE DIAGRAM -- compile, solve, draw                                  #
#---------------------------------------------------------------------#

class stzMathDiagram from stzObject

	@oDomain = NULL
	@oSubstance = NULL
	@oStyle = NULL
	@oFont = NULL
	@nFontSize = 24
	@nSeed = 1

	# the compiled problem
	@aShapes = []       # [ [ cPath, cKind, aProps, cOwner ] ]
	@acUnknown = []     # tape names, in order: u1, u2, ...
	@aUnknownOf = []    # [ [ cName, nIndex ] ]
	@aValue = []        # current value per unknown
	@bLabelVar = []     # 1 when the unknown belongs to a text shape
	@aInitRange = []    # [ [ cName, nLo, nHi ] ] -- where a :unknown starts
	@aConst = []        # [ [ cName, nValue ] ]       -- fixed by the style
	@aDerived = []      # [ [ cName, cExprRaw ] ]     -- computed from others
	@aConstraints = []  # [ [ cFn, cG, cWhere, bLabelStage ] ]
	@aObjectives = []   # [ [ cFn, cE, cWhere, bLabelStage ] ]
	@aLayers = []       # [ [ cAbove, cBelow ] ]
	@aTextSize = []     # [ [ cPath, nW, nAsc, nDesc ] ]
	@nExpandDepth = 0
	@nMatchCandidates = 0
	@bPlanarStarted = FALSE
	@acOuterFace = []
	@nStartsTried = 0
	@cStartUsed = "random"
	@nAdvisoryUnmet = 0
	@aVCache = []       # _MdKey(cName) -> nValue -- what _V last answered
	@aInkCache = []     # the drawn ink as segments, once per solve
	@bInkCached = FALSE
	# INDEXES (DN8f): every name-keyed table above has a hash list beside
	# it, rebuilt by _Reindex when a table is replaced wholesale
	@aShapeIdx = []     # _MdKey(cPath) -> index in @aShapes
	@aConstIdx = []     # _MdKey(cName) -> index in @aConst
	@aDerivedIdx = []   # _MdKey(cName) -> index in @aDerived
	@aUnknownIdx = []   # _MdKey(cName) -> tape index
	@aTextIdx = []      # _MdKey(cPath) -> index in @aTextSize
	@aDrawOrder = []    # the relaxed drawing order, once per compile
	@bDrawOrdered = FALSE
	@aRoleCache = []    # theme|role -> resolved hex, cleared by Touch
	@aStaticViolations = []  # on-canvas checked in Ring on geometry no tape moves
	@nNumDecimals = -1  # Ring's decimals() setting, read once

	# the solve
	@bLaidOut = 0
	@nRounds = 0
	@nEvaluations = 0
	@nEnergy = 0
	@nLayoutMs = 0
	@aViolations = []
	@aViolTapes = []
	@cWhy = "not laid out yet"

	def init(poDomain, poSubstance, poStyle)
		if NOT isObject(poDomain) or NOT isObject(poSubstance) or
		   NOT isObject(poStyle)
			stzraise("stzMathDiagram: give a domain, a substance and a style.")
		ok
		@oDomain = poDomain
		@oSubstance = poSubstance
		@oStyle = poStyle

	#-- knobs ------------------------------------------------------------------

	def SetFont(poFont, pnSize)
		@oFont = poFont
		@nFontSize = pnSize
		@bLaidOut = 0
		return This

		def SetFontQ(poFont, pnSize)
			return This.SetFont(poFont, pnSize)

	# Penrose's "variation": the same string, the same picture. Any text
	# folds to a seed; a number is used as it is. SeedRandom refuses a
	# seed at or above 1,999,999,999, so the fold stays under it.
	def SetVariation(pVariation)
		if isNumber(pVariation)
			@nSeed = (floor(fabs(pVariation)) % 1999999000) + 1
		else
			_c_ = "" + pVariation
			_n_ = 7
			_m_ = len(_c_)
			for _i_ = 1 to _m_
				_n_ = (_n_ * 31 + ascii(_c_[_i_])) % 1999999000
			next
			@nSeed = _n_ + 1
		ok
		@bLaidOut = 0
		return This

		def SetVariationQ(pVariation)
			return This.SetVariation(pVariation)

	#-- the answer -------------------------------------------------------------

	def Layout()
		if @bLaidOut = 1  return This  ok
		_nT0_ = StzEngineWatchTimestampMs()
		This._Compile()
		This._Solve()
		@nLayoutMs = StzEngineWatchTimestampMs() - _nT0_
		@bLaidOut = 1
		return This

		def LayoutQ()
			return This.Layout()

	def IsFeasible()
		This.Layout()
		return This.Violation() <= 0.01

	# The largest constraint violation, in pixels. Zero is a lawful picture.
	def Violation()
		This.Layout()
		return This._MaxViolation()

	# Every constraint with its violation, in the house rule shape so a
	# CI gate can ingest it: a contradictory substance is a FINDING, not a
	# crash -- Penrose's Fig. 2, a logically inconsistent program that
	# "fails gracefully, providing visual intuition for why".
	def Violations()
		This.Layout()
		_a_ = []
		_n_ = len(@aViolations)
		for _i_ = 1 to _n_
			if @aViolations[_i_][3] > 0.01
				_a_ + [ :rule = "unsatisfied_" + @aViolations[_i_][1],
				        :subject = :diagram, :where = @aViolations[_i_][2],
				        :severity = :warning,
				        :message = "the picture could not satisfy " +
				          @aViolations[_i_][1] + " at " + @aViolations[_i_][2] +
				          " -- it is violated by " + @aViolations[_i_][3] + "px" ]
			ok
		next
		return _a_

	def Energy()
		This.Layout()
		return @nEnergy

	def Rounds()
		This.Layout()
		return @nRounds

	def Evaluations()
		This.Layout()
		return @nEvaluations

	def LayoutMs()
		This.Layout()
		return @nLayoutMs

	def NumberOfUnknowns()
		This.Layout()
		return len(@acUnknown)

	def NumberOfConstraints()
		This.Layout()
		return len(@aConstraints)

	def Why()
		This.Layout()
		return @cWhy

	# the paper, and what a shape is beyond its geometry -- for the rules
	# that judge a picture rather than solve it (DN8c)
	def CanvasWidth()   return @oStyle.CanvasWidth()
	def CanvasHeight()  return @oStyle.CanvasHeight()

	def ShapeOwnerOf(pcPath)
		This.Layout()
		_i_ = This._ShapeIndex(pcPath)
		if _i_ = 0  return ""  ok
		return @aShapes[_i_][4]

	def IsHidden(pcPath)
		This.Layout()
		_i_ = This._ShapeIndex(pcPath)
		if _i_ = 0  return TRUE  ok
		return This._Prop(@aShapes[_i_][3], "hidden", 0) = 1

	def PropOf(pcPath, pcKey, pDefault)
		This.Layout()
		_i_ = This._ShapeIndex(pcPath)
		if _i_ = 0  return pDefault  ok
		return This._Prop(@aShapes[_i_][3], pcKey, pDefault)

	# The solved geometry of one shape: [ :kind, :cx, :cy, :r ] for a circle,
	# [ :kind, :cx, :cy, :w, :h ] for a rect or text, [ :kind, :x1, :y1,
	# :x2, :y2 ] for a line.
	def ShapeOf(pcPath)
		This.Layout()
		_i_ = This._ShapeIndex(pcPath)
		if _i_ = 0  return []  ok
		_s_ = @aShapes[_i_]
		_cP_ = _s_[1]
		if _s_[2] = "circle"
			return [ :kind = "circle", :cx = This._V(_cP_ + ".cx"),
			         :cy = This._V(_cP_ + ".cy"), :r = This._V(_cP_ + ".r") ]
		but _s_[2] = "ellipse"
			return [ :kind = "ellipse", :cx = This._V(_cP_ + ".cx"),
			         :cy = This._V(_cP_ + ".cy"), :rx = This._V(_cP_ + ".rx"),
			         :ry = This._V(_cP_ + ".ry") ]
		but _s_[2] = "line"
			return [ :kind = "line", :x1 = This._V(_cP_ + ".x1"),
			         :y1 = This._V(_cP_ + ".y1"), :x2 = This._V(_cP_ + ".x2"),
			         :y2 = This._V(_cP_ + ".y2") ]
		but _s_[2] = "poly"
			return [ :kind = "poly", :n = This._Prop(_s_[3], "n", 0),
			         :points = This.PolygonOf(_cP_) ]
		but _s_[2] = "spline"
			return [ :kind = "spline", :n = This._Prop(_s_[3], "n", 0),
			         :closed = This._Prop(_s_[3], "closed", 0),
			         :controls = This.PolygonOf(_cP_), :points = This.SplinePointsOf(_cP_) ]
		but _s_[2] = "mark"
			return [ :kind = "mark", :mark = "" + This._Prop(_s_[3], "mark", ""),
			         :strokes = This.MarkStrokesOf(_cP_) ]
		but _s_[2] = "curve"
			return [ :kind = "curve", :x1 = This._V(_cP_ + ".x1"),
			         :y1 = This._V(_cP_ + ".y1"), :z1 = This._V(_cP_ + ".z1"),
			         :x2 = This._V(_cP_ + ".x2"), :y2 = This._V(_cP_ + ".y2"),
			         :z2 = This._V(_cP_ + ".z2") ]
		ok
		return [ :kind = _s_[2], :cx = This._V(_cP_ + ".cx"),
		         :cy = This._V(_cP_ + ".cy"), :w = This._V(_cP_ + ".w"),
		         :h = This._V(_cP_ + ".h") ]

	# The solved value of any name: an unknown, a constant, a field, a
	# derived property -- "u.arrow.x2", "U.ox".
	def ValueOf(pcName)
		This.Layout()
		return This._V(pcName)

	def Shapes()
		This.Layout()
		_a_ = []
		_n_ = len(@aShapes)
		for _i_ = 1 to _n_
			_a_ + @aShapes[_i_][1]
		next
		return _a_

	def NumberOfShapes()
		This.Layout()
		return len(@aShapes)

	# Where a shape falls in the drawing order: 1 is painted first and so
	# sits at the back. A shape that must not be buried has to come out
	# with a HIGHER index than everything that could cover it, and that is
	# a fact about the picture worth asserting rather than eyeballing --
	# layering is a partial order, and the depths it relaxes to are not
	# obvious from reading the rules.
	def DrawIndexOf(pcPath)
		This.Layout()
		_i_ = This._ShapeIndex(pcPath)
		if _i_ = 0  return 0  ok
		_aO_ = This._DrawOrderOnce()
		for _k_ = 1 to len(_aO_)
			if _aO_[_k_] = _i_  return _k_  ok
		next
		return 0

	# A polygon's vertices, or a spline's control points, in order:
	# [ x1, y1, x2, y2, ... ].
	def PolygonOf(pcPath)
		This.Layout()
		_i_ = This._ShapeIndex(pcPath)
		if _i_ = 0 or (@aShapes[_i_][2] != "poly" and @aShapes[_i_][2] != "spline")
			return []
		ok
		_a_ = []
		_n_ = This._Prop(@aShapes[_i_][3], "n", 0)
		for _v_ = 1 to _n_
			_a_ + This._V(pcPath + ".x" + _v_)
			_a_ + This._V(pcPath + ".y" + _v_)
		next
		return _a_

	# The polyline a spline is drawn as, in px -- the control points are in
	# PolygonOf. CATMULL-ROM, CENTRIPETAL: for each span P1-P2 the four
	# points P0..P3 are blended with knots spaced by the square root of the
	# chord, which is the parametrisation that never cusps or loops between
	# two points however they are spaced (Yuksel, Schaefer, Keyser 2011). An
	# open spline doubles its end points so the curve reaches them; a closed
	# one wraps. Twelve samples per span.
	def SplinePointsOf(pcPath)
		This.Layout()
		_i_ = This._ShapeIndex(pcPath)
		if _i_ = 0 or @aShapes[_i_][2] != "spline"  return []  ok
		_aP_ = This._SplineControls(pcPath, @aShapes[_i_][3])
		_bClosed_ = (This._Prop(@aShapes[_i_][3], "closed", 0) = 1)
		_nS_ = This._Prop(@aShapes[_i_][3], "samples", 12)
		return This._CatmullRom(_aP_, _bClosed_, _nS_)

	def _SplineControls(pcPath, paProps)
		_a_ = []
		_n_ = This._Prop(paProps, "n", 0)
		for _v_ = 1 to _n_
			_a_ + [ This._V(pcPath + ".x" + _v_), This._V(pcPath + ".y" + _v_) ]
		next
		return _a_

	def _CatmullRom(paP, pbClosed, pnSamples)
		_n_ = len(paP)
		if _n_ < 2  return []  ok
		_out_ = []
		_nSpans_ = _n_ - 1
		if pbClosed  _nSpans_ = _n_  ok
		for _s_ = 1 to _nSpans_
			_p0_ = This._SplineAt(paP, _s_ - 1, pbClosed)
			_p1_ = This._SplineAt(paP, _s_, pbClosed)
			_p2_ = This._SplineAt(paP, _s_ + 1, pbClosed)
			_p3_ = This._SplineAt(paP, _s_ + 2, pbClosed)
			_t0_ = 0
			_t1_ = _t0_ + sqrt(This._Chord(_p0_, _p1_)) + 0.000001
			_t2_ = _t1_ + sqrt(This._Chord(_p1_, _p2_)) + 0.000001
			_t3_ = _t2_ + sqrt(This._Chord(_p2_, _p3_)) + 0.000001
			_nLast_ = pnSamples - 1
			if _s_ = _nSpans_  _nLast_ = pnSamples  ok
			for _k_ = 0 to _nLast_
				_t_ = _t1_ + (_t2_ - _t1_) * _k_ / pnSamples
				_a1_ = This._Lerp(_p0_, _p1_, (_t_ - _t0_) / (_t1_ - _t0_))
				_a2_ = This._Lerp(_p1_, _p2_, (_t_ - _t1_) / (_t2_ - _t1_))
				_a3_ = This._Lerp(_p2_, _p3_, (_t_ - _t2_) / (_t3_ - _t2_))
				_b1_ = This._Lerp(_a1_, _a2_, (_t_ - _t0_) / (_t2_ - _t0_))
				_b2_ = This._Lerp(_a2_, _a3_, (_t_ - _t1_) / (_t3_ - _t1_))
				_c_ = This._Lerp(_b1_, _b2_, (_t_ - _t1_) / (_t2_ - _t1_))
				_out_ + _c_[1]
				_out_ + _c_[2]
			next
		next
		return _out_

	# the control point at index i, wrapping when closed and clamping to
	# the ends when open
	def _SplineAt(paP, pnI, pbClosed)
		_n_ = len(paP)
		_i_ = pnI
		if pbClosed
			while _i_ < 1  _i_ += _n_  end
			while _i_ > _n_  _i_ -= _n_  end
		else
			if _i_ < 1  _i_ = 1  ok
			if _i_ > _n_  _i_ = _n_  ok
		ok
		return paP[_i_]

	def _Chord(pa, pb)
		return sqrt(pow(pa[1] - pb[1], 2) + pow(pa[2] - pb[2], 2))

	def _Lerp(pa, pb, pt)
		return [ pa[1] + (pb[1] - pa[1]) * pt, pa[2] + (pb[2] - pa[2]) * pt ]

	# The polyline a geodesic is drawn as: [ x1, y1, x2, y2, ... ] in px.
	def CurvePointsOf(pcPath)
		This.Layout()
		_i_ = This._ShapeIndex(pcPath)
		if _i_ = 0 or @aShapes[_i_][2] != "curve"  return []  ok
		return This._CurvePoints(pcPath,
			"" + This._Prop(@aShapes[_i_][3], "curve", "greatarc"))

	# The strokes a mark is drawn as: a list of polylines, each flat in px.
	def MarkStrokesOf(pcPath)
		This.Layout()
		_i_ = This._ShapeIndex(pcPath)
		if _i_ = 0 or @aShapes[_i_][2] != "mark"  return []  ok
		return This._MarkStrokes(pcPath, @aShapes[_i_][3])

	#-- drawing ------------------------------------------------------------------

	def ToCanvas()
		This.Layout()
		_oC_ = new stzCanvas(@oStyle.CanvasWidth(), @oStyle.CanvasHeight())
		_oC_.SetBackground(This.Background())
		if isObject(@oFont)  _oC_.SetFont(@oFont, @nFontSize)  ok
		_aOrder_ = This._DrawOrderOnce()
		_n_ = len(_aOrder_)
		for _k_ = 1 to _n_
			_s_ = @aShapes[_aOrder_[_k_]]
			if This._Prop(_s_[3], "hidden", 0) = 1  loop  ok
			This._DrawShape(_oC_, _s_)
		next
		_oC_.ClearSvgIdent()
		return _oC_

	def ToSVG()
		return This.ToCanvas().ToSVG()

	def ToPNG(pcPath)
		return This.ToCanvas().ToPNG(pcPath)

	def _DrawShape(poC, paShape)
		_cP_ = paShape[1]
		_cKind_ = paShape[2]
		_aProps_ = paShape[3]
		_cOwner_ = paShape[4]
		# the id/class channel: the OBJECT's name, the shape kind and the
		# object's type, so a consumer binds to #A or .set as it likes
		poC.SetSvgIdent(StzSvgNameOf(This._SvgIdOf(_cP_), "m_", []),
			StzTrim(_cKind_ + " " + StzSvgNameOf(
				StzLower(@oSubstance.TypeOf(_cOwner_)), "t_", []) +
				" el_" + StzSvgNameOf(_cOwner_, "o_", [])))
		_cFill_ = This._ColourFor(_cP_, This._Prop(_aProps_, "fill", ""))
		_cStroke_ = This._ColourFor(_cP_, This._Prop(_aProps_, "stroke", ""))
		_nSw_ = This._Prop(_aProps_, "strokeWidth", 1)
		if _cKind_ = "circle"
			if _cFill_ != ""  poC.Fill(_cFill_)  else  poC.Fill("#00000000")  ok
			poC.AddCircle(This._V(_cP_ + ".cx"), This._V(_cP_ + ".cy"),
				This._V(_cP_ + ".r"))
			if _cFill_ != ""  poC.Fill(_cFill_)  ok
			if _cStroke_ != ""  poC.Stroke(_cStroke_, _nSw_)  ok
		but _cKind_ = "rect"
			_w_ = This._V(_cP_ + ".w")
			_h_ = This._V(_cP_ + ".h")
			if _cFill_ != ""  poC.Fill(_cFill_)  else  poC.Fill("#00000000")  ok
			poC.AddRect(This._V(_cP_ + ".cx") - _w_ / 2,
				This._V(_cP_ + ".cy") - _h_ / 2, _w_, _h_)
			if _cFill_ != ""  poC.Fill(_cFill_)  ok
			if _cStroke_ != ""  poC.Stroke(_cStroke_, _nSw_)  ok
		but _cKind_ = "ellipse"
			if _cFill_ != ""  poC.Fill(_cFill_)  else  poC.Fill("#00000000")  ok
			poC.AddEllipse(This._V(_cP_ + ".cx"), This._V(_cP_ + ".cy"),
				This._V(_cP_ + ".rx"), This._V(_cP_ + ".ry"))
			if _cFill_ != ""  poC.Fill(_cFill_)  ok
			if _cStroke_ != ""  poC.Stroke(_cStroke_, _nSw_)  ok
		but _cKind_ = "line"
			_x1_ = This._V(_cP_ + ".x1")  _y1_ = This._V(_cP_ + ".y1")
			_x2_ = This._V(_cP_ + ".x2")  _y2_ = This._V(_cP_ + ".y2")
			if _cStroke_ = ""  _cStroke_ = "black"  ok
			poC.AddLine(_x1_, _y1_, _x2_, _y2_)
			poC.Stroke(_cStroke_, _nSw_)
			_cArrow_ = "" + This._Prop(_aProps_, "arrow", "")
			if _cArrow_ = "end" or _cArrow_ = "both"
				This._DrawHead(poC, _x1_, _y1_, _x2_, _y2_, _cStroke_, _nSw_)
			ok
			if _cArrow_ = "start" or _cArrow_ = "both"
				This._DrawHead(poC, _x2_, _y2_, _x1_, _y1_, _cStroke_, _nSw_)
			ok
		but _cKind_ = "curve"
			if _cStroke_ = ""  _cStroke_ = "black"  ok
			_aPts_ = This._CurvePoints(_cP_, "" + This._Prop(_aProps_, "curve", "greatarc"))
			if len(_aPts_) >= 4
				poC.AddPolyline(_aPts_)
				poC.Stroke(_cStroke_, _nSw_)
			ok
		but _cKind_ = "poly"
			_aPts_ = This.PolygonOf(_cP_)
			if len(_aPts_) >= 6
				if _cFill_ != ""  poC.Fill(_cFill_)  else  poC.Fill("#00000000")  ok
				poC.AddPolygon(_aPts_)
				if _cFill_ != ""  poC.Fill(_cFill_)  ok
				if _cStroke_ != ""  poC.Stroke(_cStroke_, _nSw_)  ok
			ok
		but _cKind_ = "spline"
			_aPts_ = This.SplinePointsOf(_cP_)
			if len(_aPts_) >= 4
				if This._Prop(_aProps_, "closed", 0) = 1
					if _cFill_ != ""  poC.Fill(_cFill_)  else  poC.Fill("#00000000")  ok
					poC.AddPolygon(_aPts_)
					if _cFill_ != ""  poC.Fill(_cFill_)  ok
					if _cStroke_ != ""  poC.Stroke(_cStroke_, _nSw_)  ok
				else
					if _cStroke_ = ""  _cStroke_ = "black"  ok
					poC.AddPolyline(_aPts_)
					poC.Stroke(_cStroke_, _nSw_)
				ok
			ok
		but _cKind_ = "mark"
			if _cStroke_ = ""  _cStroke_ = "#333333"  ok
			_aSt_ = This._MarkStrokes(_cP_, _aProps_)
			for _k_ = 1 to len(_aSt_)
				if len(_aSt_[_k_]) >= 4
					poC.AddPolyline(_aSt_[_k_])
					poC.Stroke(_cStroke_, _nSw_)
				ok
			next
		but _cKind_ = "text"
			if NOT isObject(@oFont)  return  ok
			_cT_ = This._Prop(_aProps_, "string", "")
			if _cT_ = ""  return  ok
			_aM_ = This._TextSize(_cP_)
			# centred on (cx, cy): the baseline sits below the centre by half
			# the ink height, measured from the font rather than guessed
			_x_ = This._V(_cP_ + ".cx") - _aM_[1] / 2
			_y_ = This._V(_cP_ + ".cy") + (_aM_[2] - _aM_[3]) / 2
			poC.SetFont(@oFont, This._Prop(_aProps_, "size", @nFontSize))
			poC.AddText(_cT_, _x_, _y_)
			# a name given no colour takes the best of black and white on
			# the paper, measured -- never a literal black
			if _cFill_ != ""  poC.Fill(_cFill_)  else  poC.Fill(StzBestTextOn(This.Background())[1])  ok
		ok

	# A GEODESIC, sampled: on the sphere by slerp between the two unit
	# vectors, projected orthographically; in the Poincare disk as the arc
	# of the circle through both points orthogonal to the rim -- a
	# diameter when the points are collinear with the centre. Drawn here,
	# at the solved values, because no constraint ever needs the arc's
	# interior: length, angle and equality are all statements about the
	# endpoints, and that is what kept acos and atan2 off the tape.
	def _CurvePoints(pcPath, pcCurve)
		_x1_ = This._V(pcPath + ".x1")  _y1_ = This._V(pcPath + ".y1")
		_x2_ = This._V(pcPath + ".x2")  _y2_ = This._V(pcPath + ".y2")
		_cx_ = This._V(pcPath + ".cx")  _cy_ = This._V(pcPath + ".cy")
		_R_ = This._V(pcPath + ".r")
		_a_ = []
		_N_ = 28
		if pcCurve = "greatarc"
			_z1_ = This._V(pcPath + ".z1")  _z2_ = This._V(pcPath + ".z2")
			_n1_ = sqrt(pow(_x1_, 2) + pow(_y1_, 2) + pow(_z1_, 2))
			_n2_ = sqrt(pow(_x2_, 2) + pow(_y2_, 2) + pow(_z2_, 2))
			if _n1_ < 0.000001 or _n2_ < 0.000001  return []  ok
			_x1_ /= _n1_  _y1_ /= _n1_  _z1_ /= _n1_
			_x2_ /= _n2_  _y2_ /= _n2_  _z2_ /= _n2_
			_d_ = _x1_ * _x2_ + _y1_ * _y2_ + _z1_ * _z2_
			if _d_ > 1  _d_ = 1  ok
			if _d_ < -1  _d_ = -1  ok
			_w_ = acos(_d_)
			if _w_ < 0.000001  return []  ok
			for _i_ = 0 to _N_
				_t_ = _i_ / _N_
				_ka_ = sin((1 - _t_) * _w_) / sin(_w_)
				_kb_ = sin(_t_ * _w_) / sin(_w_)
				_a_ + (_cx_ + _R_ * (_ka_ * _x1_ + _kb_ * _x2_))
				_a_ + (_cy_ - _R_ * (_ka_ * _y1_ + _kb_ * _y2_))
			next
			return _a_
		ok
		# poincare: the circle through a and b with c.a = (1+|a|^2)/2 and
		# c.b = (1+|b|^2)/2 -- the orthogonality condition, solved 2 x 2
		_D_ = _x1_ * _y2_ - _y1_ * _x2_
		if fabs(_D_) < 0.0001
			_a_ + (_cx_ + _R_ * _x1_)  _a_ + (_cy_ - _R_ * _y1_)
			_a_ + (_cx_ + _R_ * _x2_)  _a_ + (_cy_ - _R_ * _y2_)
			return _a_
		ok
		_ka_ = (1 + pow(_x1_, 2) + pow(_y1_, 2)) / 2
		_kb_ = (1 + pow(_x2_, 2) + pow(_y2_, 2)) / 2
		_ccx_ = (_ka_ * _y2_ - _kb_ * _y1_) / _D_
		_ccy_ = (_x1_ * _kb_ - _x2_ * _ka_) / _D_
		_rho_ = sqrt(pow(_x1_ - _ccx_, 2) + pow(_y1_ - _ccy_, 2))
		_al_ = atan2(_y1_ - _ccy_, _x1_ - _ccx_)
		_be_ = atan2(_y2_ - _ccy_, _x2_ - _ccx_)
		_dl_ = _be_ - _al_
		while _dl_ > 3.14159265358979  _dl_ -= 6.28318530717959  end
		while _dl_ < -3.14159265358979  _dl_ += 6.28318530717959  end
		for _i_ = 0 to _N_
			_th_ = _al_ + _dl_ * _i_ / _N_
			_a_ + (_cx_ + _R_ * (_ccx_ + _rho_ * cos(_th_)))
			_a_ + (_cy_ - _R_ * (_ccy_ + _rho_ * sin(_th_)))
		next
		return _a_

	# A MARK BENT TO ITS GEOMETRY. A right-angle mark is a small square at
	# the vertex and a tick is a short stroke across a side -- but WHERE the
	# square's feet sit and WHICH WAY the tick points are statements about
	# the geodesics, and on a sphere or in a disk the geodesic leaves the
	# vertex in a different direction from the chord. So each foot is walked
	# a fixed screen distance ALONG THE ARC ITSELF -- rotated about the
	# great circle's pole, or about the orthogonal circle's centre -- and
	# lands exactly on the drawn curve. A mark built on the chords would
	# miss the arc by more than its own width, which is what the guard
	# checks by measuring the feet against the drawn polyline.
	#
	# The corner is then P + Q - V in screen coordinates. On the sphere that
	# is a projection of a true spherical square to within a fraction of a
	# pixel at this size; in the Poincare disk the model is CONFORMAL, so
	# the angle it draws is exactly the hyperbolic angle.
	def _MarkStrokes(pcPath, paProps)
		_cM_ = StzLower("" + This._Prop(paProps, "mark", "rightangle"))
		_cG_ = StzLower("" + This._Prop(paProps, "curve", "greatarc"))
		_nSz_ = This._Prop(paProps, "size", 15)
		_nTk_ = This._Prop(paProps, "ticks", 1)
		_ccx_ = This._V(pcPath + ".cx")
		_ccy_ = This._V(pcPath + ".cy")
		_R_ = This._V(pcPath + ".r")
		if _R_ < 0.001  return []  ok
		_p1_ = [ This._V(pcPath + ".x1"), This._V(pcPath + ".y1"), This._V(pcPath + ".z1") ]
		_p2_ = [ This._V(pcPath + ".x2"), This._V(pcPath + ".y2"), This._V(pcPath + ".z2") ]
		_p3_ = [ This._V(pcPath + ".x3"), This._V(pcPath + ".y3"), This._V(pcPath + ".z3") ]
		if _cG_ = "greatarc"
			if _cM_ = "tick"
				_aM_ = This._SphereMid(_p1_, _p2_)
				if len(_aM_) = 0  return []  ok
				return This._MarkTicks(_ccx_ + _R_ * _aM_[1], _ccy_ - _R_ * _aM_[2],
					_aM_[4], 0 - _aM_[5], _nSz_, _nTk_)
			ok
			_aP_ = This._SphereFoot(_p1_, _p2_, _nSz_ / _R_)
			_aQ_ = This._SphereFoot(_p1_, _p3_, _nSz_ / _R_)
			if len(_aP_) = 0 or len(_aQ_) = 0  return []  ok
			_aV_ = This._Norm3(_p1_)
			if len(_aV_) = 0  return []  ok
			return This._MarkCorner(
				_ccx_ + _R_ * _aV_[1], _ccy_ - _R_ * _aV_[2],
				_ccx_ + _R_ * _aP_[1], _ccy_ - _R_ * _aP_[2],
				_ccx_ + _R_ * _aQ_[1], _ccy_ - _R_ * _aQ_[2])
		ok
		if _cM_ = "tick"
			_aM_ = This._DiskMid(_p1_, _p2_)
			if len(_aM_) = 0  return []  ok
			return This._MarkTicks(_ccx_ + _R_ * _aM_[1], _ccy_ - _R_ * _aM_[2],
				_aM_[3], 0 - _aM_[4], _nSz_, _nTk_)
		ok
		_aP_ = This._DiskFoot(_p1_, _p2_, _nSz_ / _R_)
		_aQ_ = This._DiskFoot(_p1_, _p3_, _nSz_ / _R_)
		if len(_aP_) = 0 or len(_aQ_) = 0  return []  ok
		return This._MarkCorner(
			_ccx_ + _R_ * _p1_[1], _ccy_ - _R_ * _p1_[2],
			_ccx_ + _R_ * _aP_[1], _ccy_ - _R_ * _aP_[2],
			_ccx_ + _R_ * _aQ_[1], _ccy_ - _R_ * _aQ_[2])

	# the two arms of a corner, in screen px: P -> (P + Q - V) -> Q
	def _MarkCorner(pvx, pvy, ppx, ppy, pqx, pqy)
		_rx_ = ppx + pqx - pvx
		_ry_ = ppy + pqy - pvy
		return [ [ ppx, ppy, _rx_, _ry_ ], [ _rx_, _ry_, pqx, pqy ] ]

	# n strokes across the curve at (px, py), the curve running along
	# (pdx, pdy) -- a unit screen direction. Two ticks say "these two are
	# equal" without saying it twice.
	def _MarkTicks(px, py, pdx, pdy, pnSize, pnCount)
		_L_ = sqrt(pow(pdx, 2) + pow(pdy, 2))
		if _L_ < 0.000001  return []  ok
		_ux_ = pdx / _L_
		_uy_ = pdy / _L_
		_nx_ = 0 - _uy_
		_ny_ = _ux_
		_h_ = pnSize / 2
		_a_ = []
		_n_ = pnCount
		if _n_ < 1  _n_ = 1  ok
		for _k_ = 1 to _n_
			_o_ = (_k_ - (_n_ + 1) / 2) * 5
			_bx_ = px + _o_ * _ux_
			_by_ = py + _o_ * _uy_
			_a_ + [ _bx_ - _h_ * _nx_, _by_ - _h_ * _ny_,
			        _bx_ + _h_ * _nx_, _by_ + _h_ * _ny_ ]
		next
		return _a_

	def _Norm3(pa)
		_n_ = sqrt(pow(pa[1], 2) + pow(pa[2], 2) + pow(pa[3], 2))
		if _n_ < 0.000001  return []  ok
		return [ pa[1] / _n_, pa[2] / _n_, pa[3] / _n_ ]

	# the point at arc-distance pnEps from V along the great circle to A:
	# cos(e)V + sin(e)T for the unit tangent T -- exactly on the drawn arc
	def _SphereFoot(paV, paA, pnEps)
		_v_ = This._Norm3(paV)
		_a_ = This._Norm3(paA)
		if len(_v_) = 0 or len(_a_) = 0  return []  ok
		_d_ = _v_[1] * _a_[1] + _v_[2] * _a_[2] + _v_[3] * _a_[3]
		_t_ = This._Norm3([ _a_[1] - _d_ * _v_[1], _a_[2] - _d_ * _v_[2],
		                    _a_[3] - _d_ * _v_[3] ])
		if len(_t_) = 0  return []  ok
		_c_ = cos(pnEps)
		_s_ = sin(pnEps)
		return [ _c_ * _v_[1] + _s_ * _t_[1], _c_ * _v_[2] + _s_ * _t_[2],
		         _c_ * _v_[3] + _s_ * _t_[3] ]

	# the great circle's midpoint between A and B, and its unit tangent
	# there: [ mx, my, mz, tx, ty ] -- the tangent's first two components
	# are what the orthographic projection draws
	def _SphereMid(paA, paB)
		_a_ = This._Norm3(paA)
		_b_ = This._Norm3(paB)
		if len(_a_) = 0 or len(_b_) = 0  return []  ok
		_m_ = This._Norm3([ _a_[1] + _b_[1], _a_[2] + _b_[2], _a_[3] + _b_[3] ])
		if len(_m_) = 0  return []  ok
		_d_ = _m_[1] * _b_[1] + _m_[2] * _b_[2] + _m_[3] * _b_[3]
		_t_ = This._Norm3([ _b_[1] - _d_ * _m_[1], _b_[2] - _d_ * _m_[2],
		                    _b_[3] - _d_ * _m_[3] ])
		if len(_t_) = 0  return []  ok
		return [ _m_[1], _m_[2], _m_[3], _t_[1], _t_[2] ]

	# The centre of the geodesic through A and B -- the circle orthogonal to
	# the rim: [ cx, cy ], or [] when the two are collinear with the origin
	# and the geodesic is a diameter.
	def _DiskCentre(paA, paB)
		_D_ = paA[1] * paB[2] - paA[2] * paB[1]
		if fabs(_D_) < 0.000001  return []  ok
		_ka_ = (1 + pow(paA[1], 2) + pow(paA[2], 2)) / 2
		_kb_ = (1 + pow(paB[1], 2) + pow(paB[2], 2)) / 2
		return [ (_ka_ * paB[2] - _kb_ * paA[2]) / _D_,
		         (paA[1] * _kb_ - paB[1] * _ka_) / _D_ ]

	# the point at model-distance pnEps from V along the geodesic toward A,
	# reached by ROTATING about the geodesic's centre so it lands on the arc
	def _DiskFoot(paV, paA, pnEps)
		_c_ = This._DiskCentre(paV, paA)
		if len(_c_) = 0
			_dx_ = paA[1] - paV[1]
			_dy_ = paA[2] - paV[2]
			_L_ = sqrt(pow(_dx_, 2) + pow(_dy_, 2))
			if _L_ < 0.000001  return []  ok
			return [ paV[1] + pnEps * _dx_ / _L_, paV[2] + pnEps * _dy_ / _L_ ]
		ok
		_rx_ = paV[1] - _c_[1]
		_ry_ = paV[2] - _c_[2]
		_rho_ = sqrt(pow(_rx_, 2) + pow(_ry_, 2))
		if _rho_ < 0.000001  return []  ok
		_al_ = atan2(_ry_, _rx_)
		_be_ = atan2(paA[2] - _c_[2], paA[1] - _c_[1])
		_dl_ = _be_ - _al_
		while _dl_ > 3.14159265358979  _dl_ -= 6.28318530717959  end
		while _dl_ < -3.14159265358979  _dl_ += 6.28318530717959  end
		_s_ = 1
		if _dl_ < 0  _s_ = -1  ok
		_th_ = _al_ + _s_ * pnEps / _rho_
		return [ _c_[1] + _rho_ * cos(_th_), _c_[2] + _rho_ * sin(_th_) ]

	# the middle of the drawn geodesic between A and B, and its unit
	# tangent there: [ mx, my, tx, ty ]
	def _DiskMid(paA, paB)
		_c_ = This._DiskCentre(paA, paB)
		if len(_c_) = 0
			_dx_ = paB[1] - paA[1]
			_dy_ = paB[2] - paA[2]
			_L_ = sqrt(pow(_dx_, 2) + pow(_dy_, 2))
			if _L_ < 0.000001  return []  ok
			return [ (paA[1] + paB[1]) / 2, (paA[2] + paB[2]) / 2,
			         _dx_ / _L_, _dy_ / _L_ ]
		ok
		_al_ = atan2(paA[2] - _c_[2], paA[1] - _c_[1])
		_be_ = atan2(paB[2] - _c_[2], paB[1] - _c_[1])
		_rho_ = sqrt(pow(paA[1] - _c_[1], 2) + pow(paA[2] - _c_[2], 2))
		_dl_ = _be_ - _al_
		while _dl_ > 3.14159265358979  _dl_ -= 6.28318530717959  end
		while _dl_ < -3.14159265358979  _dl_ += 6.28318530717959  end
		_th_ = _al_ + _dl_ / 2
		_s_ = 1
		if _dl_ < 0  _s_ = -1  ok
		return [ _c_[1] + _rho_ * cos(_th_), _c_[2] + _rho_ * sin(_th_),
		         0 - _s_ * sin(_th_), _s_ * cos(_th_) ]

	# An arrowhead: a filled triangle whose tip is the line's end, scaled
	# with the stroke so a thick arrow wears a bigger head.
	def _DrawHead(poC, px1, py1, px2, py2, pcColor, pnSw)
		_dx_ = px2 - px1
		_dy_ = py2 - py1
		_L_ = sqrt(pow(_dx_, 2) + pow(_dy_, 2))
		if _L_ < 0.001  return  ok
		_ux_ = _dx_ / _L_
		_uy_ = _dy_ / _L_
		_nLen_ = 8 + 2.5 * pnSw
		_nHalf_ = 3.5 + 1.2 * pnSw
		_bx_ = px2 - _nLen_ * _ux_
		_by_ = py2 - _nLen_ * _uy_
		poC.Fill(pcColor)
		poC.AddPolygon([ px2, py2,
			_bx_ - _nHalf_ * _uy_, _by_ + _nHalf_ * _ux_,
			_bx_ + _nHalf_ * _uy_, _by_ - _nHalf_ * _ux_ ])
		poC.Fill(pcColor)

	# The colour a shape is drawn with, after its rule is resolved: what the
	# guard reads, and what a consumer of the SVG gets.
	def FillOf(pcPath)
		This.Layout()
		_i_ = This._ShapeIndex(pcPath)
		if _i_ = 0  return ""  ok
		return This._ColourFor(pcPath, This._Prop(@aShapes[_i_][3], "fill", ""))

	def StrokeOf(pcPath)
		This.Layout()
		_i_ = This._ShapeIndex(pcPath)
		if _i_ = 0  return ""  ok
		return This._ColourFor(pcPath, This._Prop(@aShapes[_i_][3], "stroke", ""))

	# A COLOUR FOR A GIVEN SHAPE: the one rule that needs to know WHICH
	# shape is asking is [ :on, "under" ] -- the best of black and white on
	# whatever is painted beneath this shape's centre, the TOPMOST filled
	# region that contains it, composited over the paper. Byrne's c2 sits on
	# the square of the hypotenuse, and the square's pale base is painted
	# over by two coloured rectangles; "on the square" measured against the
	# base and answered black, on a red the reader saw. Under is the fill
	# the reader sees, whichever shape put it there.
	def _ColourFor(pcPath, pSpec)
		if isList(pSpec) and len(pSpec) >= 2 and StzLower("" + pSpec[1]) = "on" and
		   StzLower("" + pSpec[2]) = "under"
			return StzBestTextOn(This._UnderOf(pcPath))[1]
		ok
		return This._Colour(pSpec)

	# what is painted beneath a shape's centre: the topmost filled region
	# holding it, over the paper; the paper when none does
	def _UnderOf(pcPath)
		_s_ = This.ShapeOf(pcPath)
		if len(_s_) = 0 or NOT HasKey(_s_, "cx")  return This.Background()  ok
		_cBg_ = This.Background()
		_nTop_ = -1
		_ac_ = This.Shapes()
		for _i_ = 1 to len(_ac_)
			_cQ_ = _ac_[_i_]
			if _cQ_ = pcPath or This.IsHidden(_cQ_)  loop  ok
			_k_ = This._KindOf(_cQ_)
			if _k_ = "text" or _k_ = "line" or _k_ = "curve" or _k_ = "mark"  loop  ok
			_cF_ = This.FillOf(_cQ_)
			if _cF_ = ""  loop  ok
			_aR_ = _MrRegion(This, _cQ_)
			if len(_aR_) < 6  loop  ok
			if _MrPointIn(_s_[:cx], _s_[:cy], _aR_) and This.DrawIndexOf(_cQ_) > _nTop_
				_nTop_ = This.DrawIndexOf(_cQ_)
				_cBg_ = This._Opaque(_cF_, This.Background())
			ok
		next
		return _cBg_

	# A COLOUR FROM A NUMBER. A string is a colour already. A ramp maps an
	# expression's value from [lo, hi] onto the straight line between two
	# colours, clamped at both ends; a palette rounds it to an index into a
	# list, clamped likewise. The value is read at the solved point through
	# the same tape a position is, so a fill can follow a coordinate as
	# easily as a datum.
	def _Colour(pSpec)
		if NOT isList(pSpec)  return This._RoleColour(pSpec)  ok
		if len(pSpec) < 2  return ""  ok
		_k_ = StzLower("" + pSpec[1])
		# [ :alpha, colour, a ]: any colour, role or hex, at an opacity --
		# a surface is the accent at a fifth over whatever the paper is,
		# which is what keeps a fill right under a dark theme
		if _k_ = "alpha"
			if len(pSpec) < 3
				stzraise("stzMathDiagram: an alpha colour is [ :alpha, colour, opacity ].")
			ok
			return This._WithAlpha(This._Colour(pSpec[2]), pSpec[3])
		ok
		# [ :on, path ]: the best of black and white on that shape's fill,
		# measured; [ :on, "paper" ]: on the theme's background
		if _k_ = "on"
			_cBg_ = This.Background()
			if StzLower("" + pSpec[2]) != "paper"
				_cF_ = This.FillOf("" + pSpec[2])
				if _cF_ != ""  _cBg_ = This._Opaque(_cF_, _cBg_)  ok
			ok
			return StzBestTextOn(_cBg_)[1]
		ok
		_v_ = This._EvalExpr(This._Sym(pSpec[2]))
		if NOT isNumber(_v_)  _v_ = 0  ok
		if _k_ = "ramp"
			if len(pSpec) < 6
				stzraise("stzMathDiagram: a ramp is [ :ramp, expr, lo, hi, colourA, colourB ].")
			ok
			_lo_ = pSpec[3]  _hi_ = pSpec[4]
			_t_ = 0
			if _hi_ != _lo_  _t_ = (_v_ - _lo_) / (_hi_ - _lo_)  ok
			if _t_ < 0  _t_ = 0  ok
			if _t_ > 1  _t_ = 1  ok
			return This._LerpHex(This._RoleColour("" + pSpec[5]), This._RoleColour("" + pSpec[6]), _t_)
		but _k_ = "palette"
			if len(pSpec) < 3 or NOT isList(pSpec[3]) or len(pSpec[3]) = 0
				stzraise("stzMathDiagram: a palette is [ :palette, expr, [ colours ] ].")
			ok
			_n_ = len(pSpec[3])
			_i_ = floor(_v_ + 0.5)
			if _i_ < 1  _i_ = 1  ok
			if _i_ > _n_  _i_ = _n_  ok
			return This._RoleColour("" + pSpec[3][_i_])
		ok
		stzraise("stzMathDiagram: '" + pSpec[1] + "' is not a colour rule -- ramp, palette, alpha or on.")

	# a role -- primary, success, warning, danger, info, muted, neutral,
	# background -- resolves through the style's theme; anything else is
	# handed on as it is, and the canvas resolves names and hex
	def _RoleColour(pc)
		if NOT isString(pc)  return pc  ok
		_c_ = StzLower(ring_trim(pc))
		if _c_ = ""  return ""  ok
		# a role is asked once per shape per draw -- five thousand times a
		# picture -- and answers the same hex until the theme changes, which
		# Touch() announces (DN8f)
		_k_ = _MdKey(@oStyle.Theme() + "|" + _c_)
		_h_ = @aRoleCache[_k_]
		if isString(_h_) and _h_ != ""  return _h_  ok
		_ac_ = StzThemeRoles()
		for _i_ = 1 to len(_ac_)
			if StzLower("" + _ac_[_i_]) = _c_
				_e_ = StzThemeColor(@oStyle.Theme(), _c_)
				if _e_ = ""  return pc  ok
				_h_ = StzResolveColor(_e_)
				@aRoleCache[_k_] = _h_
				return _h_
			ok
		next
		return pc

	# the paper's colour: the theme's background
	def Background()
		return This._RoleColour("background")

	def _WithAlpha(pcColour, pnA)
		_c_ = "" + pcColour
		if StzLeft(_c_, 1) != "#"  _c_ = StzResolveColor(_c_)  ok
		if len(_c_) >= 9  _c_ = StzLeft(_c_, 7)  ok
		_a_ = floor(pnA * 255 + 0.5)
		if _a_ < 0  _a_ = 0  ok
		if _a_ > 255  _a_ = 255  ok
		_h_ = hex(_a_)
		if len(_h_) < 2  _h_ = "0" + _h_  ok
		return StzUpper(_c_ + _h_)

	# a translucent fill composited over the paper, so contrast is measured
	# against what is actually seen
	def _Opaque(pcFill, pcBg)
		_c_ = "" + pcFill
		if StzLeft(_c_, 1) != "#"  _c_ = StzResolveColor(_c_)  ok
		if len(_c_) < 9  return _c_  ok
		_a_ = dec(StzStringSection(_c_, 8, 9)) / 255
		return This._LerpHex(pcBg, StzLeft(_c_, 7), _a_)

	# "#rrggbb" to "#rrggbb", t of the way from A to B, per channel
	# IN OKLAB, IN THE ENGINE. The first ramp interpolated in sRGB, and equal
	# steps in sRGB are not equal perceived steps: the colour plan measured
	# a ramp that zigzags in lightness. The engine's mix walks a straight
	# line in Oklab and clamps to gamut, so the ramp is even by
	# construction; this is the same conversion C1 built for the shades.
	def _LerpHex(pcA, pcB, pt)
		_a_ = This._HexRGB(pcA)
		_b_ = This._HexRGB(pcB)
		_t_ = pt
		if _t_ < 0  _t_ = 0  ok
		if _t_ > 1  _t_ = 1  ok
		_n_ = StzEngineColorMixOklab(_a_[1] * 65536 + _a_[2] * 256 + _a_[3],
		                             _b_[1] * 65536 + _b_[2] * 256 + _b_[3], _t_)
		# in the palette's case, upper, so a mixed colour and a resolved
		# role compare equal as strings when they are one colour
		_c_ = "#"
		for _v_ in [ floor(_n_ / 65536) % 256, floor(_n_ / 256) % 256, _n_ % 256 ]
			_h_ = hex(_v_)
			if len(_h_) < 2  _h_ = "0" + _h_  ok
			_c_ += _h_
		next
		return StzUpper(_c_)

	def _HexRGB(pc)
		_c_ = "" + pc
		if StzLeft(_c_, 1) = "#"  _c_ = StzStringSection(_c_, 2, len(_c_))  ok
		if len(_c_) < 6
			stzraise("stzMathDiagram: '" + pc + "' is not a #rrggbb colour.")
		ok
		return [ dec(StzStringSection(_c_, 1, 2)), dec(StzStringSection(_c_, 3, 4)),
		         dec(StzStringSection(_c_, 5, 6)) ]

	def _SvgIdOf(pcPath)
		# "A.icon" -> "A" for the shape called icon, "A_text" otherwise
		_ac_ = StzSplit(pcPath, ".")
		if len(_ac_) < 2  return pcPath  ok
		if _ac_[2] = "icon"  return _ac_[1]  ok
		return _ac_[1] + "_" + _ac_[2]

	# Layering as Penrose does it: "x.text above x.icon" is a partial order,
	# resolved to a z per shape by relaxation. Ties keep creation order,
	# and text rides above everything unlayered, as a reader expects.
	# the order is a fact of the compile; asked once per shape by the
	# under rule, it is relaxed once and kept
	def _DrawOrderOnce()
		if NOT @bDrawOrdered
			@aDrawOrder = This._DrawOrder()
			@bDrawOrdered = TRUE
		ok
		return @aDrawOrder

	def _DrawOrder()
		_n_ = len(@aShapes)
		_aZ_ = []
		for _i_ = 1 to _n_
			_aZ_ + 0
		next
		_nL_ = len(@aLayers)
		for _pass_ = 1 to 16
			_bMoved_ = FALSE
			for _k_ = 1 to _nL_
				_a_ = This._ShapeIndex(@aLayers[_k_][1])
				_b_ = This._ShapeIndex(@aLayers[_k_][2])
				if _a_ = 0 or _b_ = 0  loop  ok
				if _aZ_[_a_] <= _aZ_[_b_]
					_aZ_[_a_] = _aZ_[_b_] + 1
					_bMoved_ = TRUE
				ok
			next
			if NOT _bMoved_  exit  ok
		next
		for _i_ = 1 to _n_
			if @aShapes[_i_][2] = "text"  _aZ_[_i_] += 1000  ok
		next
		_aOrder_ = []
		for _i_ = 1 to _n_
			_aOrder_ + _i_
		next
		for _i_ = 2 to _n_
			_v_ = _aOrder_[_i_]
			_j_ = _i_ - 1
			while _j_ >= 1 and _aZ_[_aOrder_[_j_]] > _aZ_[_v_]
				_aOrder_[_j_ + 1] = _aOrder_[_j_]
				_j_--
			end
			_aOrder_[_j_ + 1] = _v_
		next
		return _aOrder_

	#-- COMPILE: selectors match, rules fire, unknowns and terms accumulate --

	def _Compile()
		@nMatchCandidates = 0
		@aShapes = []  @acUnknown = []  @aUnknownOf = []  @aValue = []
		@bLabelVar = []  @aConst = []  @aDerived = []  @aInitRange = []
		@aConstraints = []  @aObjectives = []  @aLayers = []  @aTextSize = []
		This._Reindex()
		@bDrawOrdered = FALSE
		@aRoleCache = []
		@aStaticViolations = []
		_aRules_ = @oStyle.Rules()
		_n_ = len(_aRules_)
		# TWO PASSES: shapes, fields and overrides first, then the terms.
		# A rule may constrain a shape another rule mints later, and an
		# override may rewrite an unknown a term already referenced --
		# Penrose resolves the whole graph before optimising, and so does
		# this, by firing every rule twice with a different half live.
		_aFired_ = []
		for _i_ = 1 to _n_
			_aVars_ = This._ParseSelector(_aRules_[_i_][1])
			_aWhere_ = This._ParseWhere(_aRules_[_i_][2])
			_aMatches_ = This._Match(_aVars_, _aWhere_)
			_aFired_ + [ _aVars_, _aMatches_ ]
			_m_ = len(_aMatches_)
			for _k_ = 1 to _m_
				This._Fire(_aRules_[_i_][3], _aVars_, _aMatches_[_k_],
					_aRules_[_i_][1] + " where " + _aRules_[_i_][2], 1)
			next
		next
		for _i_ = 1 to _n_
			_aVars_ = _aFired_[_i_][1]
			_aMatches_ = _aFired_[_i_][2]
			_m_ = len(_aMatches_)
			for _k_ = 1 to _m_
				This._Fire(_aRules_[_i_][3], _aVars_, _aMatches_[_k_],
					_aRules_[_i_][1] + " where " + _aRules_[_i_][2], 2)
			next
		next
		# every shape stays on the paper -- Penrose's ensureOnCanvas default
		_nS_ = len(@aShapes)
		for _i_ = 1 to _nS_
			This._AddOnCanvas(@aShapes[_i_])
		next

	# "Set x; Set y" -> [ [ "Set", "x", "" ], ... ]; "Set `A`" -> a literal,
	# [ "Set", "`A`", "A" ], which matches only the object named A.
	def _ParseSelector(pcSelector)
		_a_ = []
		_ac_ = StzSplit(pcSelector, ";")
		_n_ = len(_ac_)
		for _i_ = 1 to _n_
			_c_ = ring_trim(_ac_[_i_])
			if _c_ = ""  loop  ok
			_ap_ = StzSplit(_c_, " ")
			_aq_ = []
			for _j_ = 1 to len(_ap_)
				if ring_trim(_ap_[_j_]) != ""  _aq_ + ring_trim(_ap_[_j_])  ok
			next
			if len(_aq_) != 2
				stzraise("stzMathStyle: '" + _c_ + "' is not 'Type var'.")
			ok
			if NOT @oDomain.HasType(_aq_[1])
				stzraise("stzMathStyle: the selector names the type '" + _aq_[1] +
					"', which the '" + @oDomain.Name_() + "' domain does not have.")
			ok
			_cLit_ = ""
			_cV_ = _aq_[2]
			if StzLeft(_cV_, 1) = "`"
				_cLit_ = StzStringSection(_cV_, 2, len(_cV_) - 1)
				if StzRight(_cV_, 1) != "`" or _cLit_ = ""
					stzraise("stzMathStyle: '" + _cV_ + "' -- a literal name is " +
						"written between backticks, like `A`.")
				ok
			ok
			_a_ + [ _aq_[1], _cV_, _cLit_ ]
		next
		return _a_

	# "Subset(x, y); u := addV(v, w)" ->
	#   [ [ "pred", "Subset", [ "x", "y" ] ], [ "def", "addV", [ "v", "w" ], "u" ] ]
	def _ParseWhere(pcWhere)
		_a_ = []
		_c_ = ring_trim("" + pcWhere)
		if _c_ = ""  return _a_  ok
		_ac_ = StzSplit(_c_, ";")
		_n_ = len(_ac_)
		for _i_ = 1 to _n_
			_r_ = ring_trim(_ac_[_i_])
			if _r_ = ""  loop  ok
			_cTarget_ = ""
			_nDef_ = StzFindFirst(":=", _r_)
			if _nDef_ > 0
				_cTarget_ = ring_trim(StzLeft(_r_, _nDef_ - 1))
				_r_ = ring_trim(StzStringSection(_r_, _nDef_ + 2, len(_r_)))
			ok
			_nO_ = StzFindFirst("(", _r_)
			_nC_ = StzFindFirst(")", _r_)
			if _nO_ < 2 or _nC_ <= _nO_
				stzraise("stzMathStyle: '" + _r_ + "' is not 'Predicate(a, b)' or " +
					"'u := Function(a, b)'.")
			ok
			_cP_ = ring_trim(StzLeft(_r_, _nO_ - 1))
			_cArgs_ = StzStringSection(_r_, _nO_ + 1, _nC_ - 1)
			_aArgs_ = []
			_ap_ = StzSplit(_cArgs_, ",")
			for _j_ = 1 to len(_ap_)
				if ring_trim(_ap_[_j_]) != ""  _aArgs_ + ring_trim(_ap_[_j_])  ok
			next
			if _cTarget_ != ""
				if NOT @oDomain.HasFunction(_cP_)
					stzraise("stzMathStyle: '" + _cP_ + "' is not a function of the '" +
						@oDomain.Name_() + "' domain.")
				ok
				_a_ + [ "def", _cP_, _aArgs_, _cTarget_ ]
			else
				if NOT @oDomain.HasPredicate(_cP_)
					stzraise("stzMathStyle: '" + _cP_ + "' is not a predicate of the '" +
						@oDomain.Name_() + "' domain.")
				ok
				_a_ + [ "pred", _cP_, _aArgs_, "" ]
			ok
		next
		return _a_

	# Every injective assignment of substance objects to the selector's
	# variables (subtype-aware, a literal binding only its own object)
	# under which every where-relation holds -- then deduplicated by the
	# SET of objects matched, so a symmetric predicate fires a rule once
	# per pair and not once per ordering.
	def _Match(paVars, paWhere)
		_aOut_ = []
		_nV_ = len(paVars)
		_aCands_ = []
		for _i_ = 1 to _nV_
			if paVars[_i_][3] != ""
				_cLit_ = paVars[_i_][3]
				_cT_ = @oSubstance.TypeOf(_cLit_)
				if _cT_ = "" or NOT @oDomain.TypeMatches(_cT_, paVars[_i_][1])
					_aCands_ + []
				else
					_aCands_ + [ _cLit_ ]
				ok
			else
				_aCands_ + @oSubstance.ObjectsOfType(paVars[_i_][1])
			ok
		next
		if _nV_ = 0  return _aOut_  ok
		for _i_ = 1 to _nV_
			if len(_aCands_[_i_]) = 0  return _aOut_  ok
		next
		# membership of a candidate list is asked once per binding, and a
		# binding is made once per definition per variable: at two
		# thousand steps that was twelve million comparisons, and is now
		# a hash-list lookup each (DN8f)
		_aCandIdx_ = []
		for _i_ = 1 to _nV_
			_aK_ = []
			for _c_ = 1 to len(_aCands_[_i_])
				_aK_[_MdKey(_aCands_[_i_][_c_])] = 1
			next
			_aCandIdx_ + _aK_
		next
		# DRIVE THE ENUMERATION FROM THE DEFINITIONS, NOT THE PRODUCT. A
		# clause "e := Edge(a, b)" used to be a FILTER over every binding of
		# e, a and b -- 30 x 20 x 20 of them on the dodecahedral graph, and
		# with one more variable in the selector, 240,000 candidates each
		# tested against the substance. It is a GENERATOR: the substance
		# holds thirty definitions of Edge, and each one binds e, a and b in
		# a single step. The same graph now enumerates 600 candidates, and
		# the compile that was eighteen seconds is under one.
		_aParts_ = []
		_aBlank_ = []
		for _i_ = 1 to _nV_
			_aBlank_ + ""
		next
		_aParts_ + _aBlank_
		_aDefs_ = @oSubstance.Definitions()
		_nD_ = len(_aDefs_)
		_nW_ = len(paWhere)
		for _w_ = 1 to _nW_
			if paWhere[_w_][1] != "def"  loop  ok
			_nT_ = This._VarIndex(paVars, paWhere[_w_][4])
			_aAI_ = []
			for _k_ = 1 to len(paWhere[_w_][3])
				_aAI_ + This._VarIndex(paVars, paWhere[_w_][3][_k_])
			next
			_cF_ = StzLower(paWhere[_w_][2])
			_aNew_ = []
			for _p_ = 1 to len(_aParts_)
				for _d_ = 1 to _nD_
					if StzLower(_aDefs_[_d_][2]) != _cF_ or
					   len(_aDefs_[_d_][3]) != len(_aAI_)
						loop
					ok
					_aQ_ = This._BindVar(_aParts_[_p_], _nT_, _aDefs_[_d_][1], _aCandIdx_)
					if len(_aQ_) = 0  loop  ok
					for _k_ = 1 to len(_aAI_)
						if len(_aQ_) = 0  exit  ok
						_aQ_ = This._BindVar(_aQ_, _aAI_[_k_], _aDefs_[_d_][3][_k_], _aCandIdx_)
					next
					if len(_aQ_) > 0  _aNew_ + _aQ_  ok
				next
			next
			_aParts_ = _aNew_
			if len(_aParts_) = 0  return _aOut_  ok
		next
		# whatever is still free ranges over its candidates
		for _i_ = 1 to _nV_
			_aNew_ = []
			for _p_ = 1 to len(_aParts_)
				if _aParts_[_p_][_i_] != ""
					_aNew_ + _aParts_[_p_]
					loop
				ok
				for _c_ = 1 to len(_aCands_[_i_])
					_aQ_ = This._BindVar(_aParts_[_p_], _i_, _aCands_[_i_][_c_], _aCandIdx_)
					if len(_aQ_) > 0  _aNew_ + _aQ_  ok
				next
			next
			_aParts_ = _aNew_
			if len(_aParts_) > 400000
				stzraise("stzMathStyle: the selector binds more than 400,000 ways -- " +
					"narrow it with a where-clause.")
			ok
		next
		# then the relations that are not definitions, and the dedup
		for _p_ = 1 to len(_aParts_)
			_aAsg_ = _aParts_[_p_]
			if This._WhereHolds(paVars, _aAsg_, paWhere) and
			   NOT This._Seen(_aOut_, _aAsg_, paWhere)
				_aOut_ + _aAsg_
			ok
		next
		return _aOut_

	def _VarIndex(paVars, pcVar)
		_c_ = ring_trim("" + pcVar)
		for _i_ = 1 to len(paVars)
			if paVars[_i_][2] = _c_  return _i_  ok
		next
		stzraise("stzMathStyle: '" + pcVar + "' is not a variable of the selector.")

	# bind variable pnI of a partial assignment to pcObj: refused when the
	# slot already holds another object, when pcObj is not a candidate for
	# that variable (wrong type, or a literal naming something else), or
	# when another variable already holds pcObj -- the injectivity the
	# matcher has always promised. Returns the new partial, or [].
	def _BindVar(paPart, pnI, pcObj, paCandIdx)
		if paPart[pnI] != ""
			if paPart[pnI] = pcObj  return paPart  ok
			return []
		ok
		if NOT isNumber(paCandIdx[pnI][_MdKey(pcObj)])  return []  ok
		_n_ = len(paPart)
		for _j_ = 1 to _n_
			if paPart[_j_] = pcObj  return []  ok
		next
		_aQ_ = []
		for _j_ = 1 to _n_
			_aQ_ + paPart[_j_]
		next
		_aQ_[pnI] = pcObj
		# every candidate the matcher ever builds is counted, so the cost of
		# matching is a NUMBER a guard can hold, not a clock
		@nMatchCandidates++
		return _aQ_

	# how many candidate bindings the last compile enumerated
	def MatchCandidates()
		This.Layout()
		return @nMatchCandidates

	def _WhereHolds(paVars, paAsg, paWhere)
		_n_ = len(paWhere)
		for _i_ = 1 to _n_
			_aArgs_ = []
			_m_ = len(paWhere[_i_][3])
			for _j_ = 1 to _m_
				_aArgs_ + This._Bound(paVars, paAsg, paWhere[_i_][3][_j_])
			next
			if paWhere[_i_][1] = "pred"
				if NOT @oSubstance.Holds(paWhere[_i_][2], _aArgs_)  return FALSE  ok
			else
				_cT_ = This._Bound(paVars, paAsg, paWhere[_i_][4])
				if NOT @oSubstance.IsDefinedAs(_cT_, paWhere[_i_][2], _aArgs_)
					return FALSE
				ok
			ok
		next
		return TRUE

	# A match repeats an earlier one when every where-relation is a
	# symmetric predicate and the same objects are bound: (A,B) and (B,A)
	# are one match of Disjoint, not two.
	def _Seen(paOut, paAsg, paWhere)
		if len(paWhere) = 0  return FALSE  ok
		for _i_ = 1 to len(paWhere)
			if paWhere[_i_][1] != "pred" or NOT @oDomain.IsSymmetric(paWhere[_i_][2])
				return FALSE
			ok
		next
		_n_ = len(paOut)
		for _i_ = 1 to _n_
			if This._SameSet(paOut[_i_], paAsg)  return TRUE  ok
		next
		return FALSE

	def _SameSet(pa, pb)
		if len(pa) != len(pb)  return FALSE  ok
		for _i_ = 1 to len(pa)
			_b_ = FALSE
			for _j_ = 1 to len(pb)
				if "" + pa[_i_] = "" + pb[_j_]  _b_ = TRUE  ok
			next
			if NOT _b_  return FALSE  ok
		next
		return TRUE

	def _Bound(paVars, paAsg, pcVar)
		_c_ = ring_trim("" + pcVar)
		_n_ = len(paVars)
		for _i_ = 1 to _n_
			if paVars[_i_][2] = _c_  return paAsg[_i_]  ok
		next
		stzraise("stzMathStyle: '" + pcVar + "' is not a variable of the selector.")

	# One rule, one match, one pass: pass 1 mints shapes, fields and
	# overrides; pass 2 records constraints, objectives and layers.
	def _Fire(paRows, paVars, paAsg, pcWhere, pnPass)
		_n_ = len(paRows)
		for _i_ = 1 to _n_
			_r_ = paRows[_i_]
			_k_ = "" + _r_[1]
			if pnPass = 1
				if _k_ = "shape"
					This._MintShape(This._ResolvePath(_r_[2], paVars, paAsg), "" + _r_[3],
						This._ResolveProps(_r_[4], paVars, paAsg),
						This._OwnerOf(_r_[2], paVars, paAsg))
				but _k_ = "delete"
					This._DeleteShape(This._ResolvePath(_r_[2], paVars, paAsg))
				but _k_ = "unknown"
					_cU_ = This._ResolvePath(_r_[2], paVars, paAsg)
					if This._UnknownIndex(_cU_) = 0 and NOT This._HasConst(_cU_) and
					   NOT This._HasDerived(_cU_)
						This._Unknown(_cU_, 0)
						@aInitRange + [ _cU_, _r_[3], _r_[4] ]
					ok
				but _k_ = "field"
					This._SetField(This._ResolvePath(_r_[2], paVars, paAsg),
						This._ResolveValue(_r_[3], paVars, paAsg))
				but _k_ = "override"
					This._Override(This._ResolvePath(_r_[2], paVars, paAsg),
						This._ResolveValue(_r_[3], paVars, paAsg))
				ok
			else
				if _k_ = "ensure" or _k_ = "encourage"
					_aArgs_ = []
					for _j_ = 1 to len(_r_[3])
						_aArgs_ + This._ResolveValue(_r_[3][_j_], paVars, paAsg)
					next
					This._AddTerm(_k_, "" + _r_[2], _aArgs_, pcWhere)
				but _k_ = "layer"
					_a_ = This._ResolvePath("" + _r_[2], paVars, paAsg)
					_b_ = This._ResolvePath("" + _r_[4], paVars, paAsg)
					if "" + _r_[3] = "above"
						@aLayers + [ _a_, _b_ ]
					else
						@aLayers + [ _b_, _a_ ]
					ok
				ok
			ok
		next

	# "x.icon.r" with x -> A  becomes "A.icon.r"
	def _ResolvePath(pcPath, paVars, paAsg)
		_ac_ = StzSplit("" + pcPath, ".")
		if len(_ac_) < 2
			stzraise("stzMathStyle: '" + pcPath + "' is not a path like 'x.icon'.")
		ok
		# "_.sphere": a GLOBAL path, bound to no selector variable -- the
		# one sphere every point sits on, minted once however many points
		# there are, because minting is idempotent by path
		_cObj_ = "_"
		if _ac_[1] != "_"  _cObj_ = This._Bound(paVars, paAsg, _ac_[1])  ok
		_c_ = _cObj_
		for _i_ = 2 to len(_ac_)
			_c_ += "." + _ac_[_i_]
		next
		return _c_

	# A value is a number (kept), or text: a path or an expression whose
	# path HEADS are selector variables, each rewritten to its object.
	def _ResolveValue(pValue, paVars, paAsg)
		if isNumber(pValue)  return pValue  ok
		return This._RewriteHeads("" + pValue, paVars, paAsg)

	def _ResolveProps(paProps, paVars, paAsg)
		if NOT isList(paProps)  return []  ok
		_a_ = []
		_n_ = len(paProps)
		for _i_ = 1 to _n_
			_p_ = paProps[_i_]
			if isList(_p_) and len(_p_) = 2 and This._IsGeometric("" + _p_[1])
				_a_ + [ "" + _p_[1], This._ResolveValue(_p_[2], paVars, paAsg) ]
			but isList(_p_) and len(_p_) = 2 and isList(_p_[2]) and len(_p_[2]) >= 2
				# A COLOUR RULE: [ :ramp, expr, lo, hi, cA, cB ] or
				# [ :palette, expr, [ colours ] ]. Its expression has the
				# selector's variables as heads like any other, and is
				# rewritten here; the rest rides through untouched.
				_spec_ = []
				_spec_ + ("" + _p_[2][1])
				_spec_ + This._ResolveValue(_p_[2][2], paVars, paAsg)
				for _k_ = 3 to len(_p_[2])
					_spec_ + _p_[2][_k_]
				next
				_a_ + [ "" + _p_[1], _spec_ ]
			else
				_a_ + _p_
			ok
		next
		return _a_

	# cx, cy, r, w, h -- and x, y or z followed by a vertex number, so a
	# polygon's x7 resolves the same way a line's x1 does.
	def _IsGeometric(pcKey)
		_k_ = StzLower(pcKey)
		if _k_ = "cx" or _k_ = "cy" or _k_ = "r" or _k_ = "w" or _k_ = "h" or
		   _k_ = "rx" or _k_ = "ry"
			return TRUE
		ok
		_n_ = len(_k_)
		if _n_ < 2  return FALSE  ok
		if _k_[1] != "x" and _k_[1] != "y" and _k_[1] != "z"  return FALSE  ok
		for _i_ = 2 to _n_
			_a_ = ascii(_k_[_i_])
			if _a_ < 48 or _a_ > 57  return FALSE  ok
		next
		return TRUE

	# Every identifier containing a dot has its head rewritten from the
	# selector variable to the object it is bound to. Identifiers without
	# a dot -- sqrt, len, ux -- pass through untouched.
	def _RewriteHeads(pcExpr, paVars, paAsg)
		_c_ = pcExpr
		_out_ = ""
		_n_ = len(_c_)
		_i_ = 1
		while _i_ <= _n_
			_ch_ = _c_[_i_]
			if This._IsIdentStart(_ch_)
				_j_ = _i_
				while _j_ <= _n_ and This._IsPathChar(_c_[_j_])
					_j_++
				end
				_tok_ = StzStringSection(_c_, _i_, _j_ - 1)
				if StzFindFirst(".", _tok_) > 0
					_out_ += This._ResolvePath(_tok_, paVars, paAsg)
				else
					_out_ += _tok_
				ok
				_i_ = _j_
			else
				_out_ += _ch_
				_i_++
			ok
		end
		return _out_

	def _OwnerOf(pcPath, paVars, paAsg)
		_ac_ = StzSplit("" + pcPath, ".")
		if _ac_[1] = "_"  return "_"  ok
		return This._Bound(paVars, paAsg, _ac_[1])

	# A shape is minted ONCE: "forall Set x" fires per object, and a later
	# rule may reference the same path without re-creating it. Each
	# geometric property is a CONSTANT (a number in the style), DERIVED (an
	# expression in the style) or an UNKNOWN (absent -- the solver's).
	def _MintShape(pcPath, pcKind, paProps, pcOwner)
		if This._ShapeIndex(pcPath) > 0  return  ok
		_aP_ = paProps
		if NOT isList(_aP_)  _aP_ = []  ok
		if pcKind = "text"
			# AN UNLABELLED OBJECT STILL OWNS ITS TEXT SHAPE, empty: the shape
			# exists with an empty string, measures 0 x 0, and draws nothing,
			# so a rule naming x.text is well-formed with or without a label.
			_cLbl_ = @oSubstance.LabelOf(pcOwner)
			_aP2_ = []
			for _i_ = 1 to len(_aP_)  _aP2_ + _aP_[_i_]  next
			# a two-element LITERAL, never `+ [ :string = x ]`: that form
			# nests a level and the property vanishes
			_aP2_ + [ "string", _cLbl_ ]
			_aP_ = _aP2_
		ok
		@aShapes + [ pcPath, pcKind, _aP_, pcOwner ]
		@aShapeIdx[_MdKey(pcPath)] = len(@aShapes)
		_acGeo_ = []
		if pcKind = "circle"
			_acGeo_ = [ "cx", "cy", "r" ]
		but pcKind = "rect"
			_acGeo_ = [ "cx", "cy", "w", "h" ]
		but pcKind = "ellipse"
			# axis-aligned: a centre and two radii. To a constraint it is its
			# bounding box -- exact for a label inside it, conservative for
			# everything else -- and the styles that use it keep their
			# reasoning on circles and DERIVE the ellipse
			_acGeo_ = [ "cx", "cy", "rx", "ry" ]
		but pcKind = "line"
			_acGeo_ = [ "x1", "y1", "x2", "y2" ]
		but pcKind = "curve"
			# a geodesic: its ends in the model's own coordinates, and the
			# projection it is drawn through. Nothing here is solved -- a
			# curve is DERIVED from its points, and constraints speak to
			# the points, never to the drawn arc.
			_acGeo_ = [ "x1", "y1", "z1", "x2", "y2", "z2", "cx", "cy", "r" ]
		but pcKind = "poly"
			# A POLYGON: n vertices, x1..xn and y1..yn. Byrne's squares are
			# every one of them DERIVED from the triangle's points, so the
			# solver owns the triangle and the figure follows.
			_nV_ = This._Prop(_aP_, "n", 0)
			if NOT isNumber(_nV_) or _nV_ < 3 or _nV_ > 24 or _nV_ != floor(_nV_)
				stzraise("stzMathDiagram: the polygon '" + pcPath + "' needs a " +
					"whole :n between 3 and 24 -- how many vertices it has.")
			ok
			for _v_ = 1 to _nV_
				_acGeo_ + ("x" + _v_)
				_acGeo_ + ("y" + _v_)
			next
		but pcKind = "spline"
			# A SPLINE through n control points, x1..xn and y1..yn, open or
			# closed, drawn by centripetal Catmull-Rom sampling at the solved
			# values. As with a curve and a polygon, nothing here is the
			# curve itself: a constraint speaks to the points, and a blob's
			# wobble is eight unknowns the solver owns.
			_nV_ = This._Prop(_aP_, "n", 0)
			if NOT isNumber(_nV_) or _nV_ < 2 or _nV_ > 64 or _nV_ != floor(_nV_)
				stzraise("stzMathDiagram: the spline '" + pcPath + "' needs a " +
					"whole :n between 2 and 64 -- how many control points it has.")
			ok
			for _v_ = 1 to _nV_
				_acGeo_ + ("x" + _v_)
				_acGeo_ + ("y" + _v_)
			next
		but pcKind = "mark"
			# A MARK BENT TO ITS GEOMETRY: the vertex and its two neighbours
			# in the MODEL's coordinates (a tick uses the first two as the
			# arc's ends), plus the projection. Like a curve, nothing here is
			# solved: a mark is read off the picture, never argued with.
			_acGeo_ = [ "x1", "y1", "z1", "x2", "y2", "z2", "x3", "y3", "z3",
			            "cx", "cy", "r" ]
		but pcKind = "text"
			_acGeo_ = [ "cx", "cy" ]
			# a text may carry its OWN size -- a word cloud is nothing else --
			# and is measured at that size, not the diagram's
			_aM_ = This._MeasureTextAt(This._Prop(_aP_, "string", ""),
				This._Prop(_aP_, "size", @nFontSize))
			@aTextSize + [ pcPath, _aM_[1], _aM_[2], _aM_[3] ]
			@aTextIdx[_MdKey(pcPath)] = len(@aTextSize)
		ok
		_bLbl_ = 0
		if pcKind = "text"  _bLbl_ = 1  ok
		_n_ = len(_acGeo_)
		for _i_ = 1 to _n_
			_cName_ = pcPath + "." + _acGeo_[_i_]
			_v_ = This._Prop(_aP_, _acGeo_[_i_], "")
			if isNumber(_v_)
				@aConst + [ _cName_, _v_ ]
				@aConstIdx[_MdKey(_cName_)] = len(@aConst)
			but isString(_v_) and ring_trim(_v_) != ""
				@aDerived + [ _cName_, _v_ ]
				@aDerivedIdx[_MdKey(_cName_)] = len(@aDerived)
			else
				This._Unknown(_cName_, _bLbl_)
			ok
		next

	# PENROSE'S DELETE. A rule that specialises another unmints the general
	# icon before drawing its own -- "delete t.icon" then draw the coloured
	# figure. The shape goes, and so do the names it owned: its constants,
	# its derived properties, its measured size, and its entries in the
	# name-to-variable map. The tape SLOTS stay allocated but referenced by
	# nothing, so they never move -- the same way an override leaves the
	# unknown it replaced. Layers naming a gone shape are skipped by
	# _DrawOrder, and a constraint naming one raises in pass 2, which is the
	# honest answer: the shape is not there to constrain.
	def _DeleteShape(pcPath)
		_c_ = "" + pcPath
		_i_ = This._ShapeIndex(_c_)
		if _i_ = 0
			stzraise("stzMathStyle: delete of '" + _c_ + "', which no rule " +
				"minted -- a delete unmints a shape that exists.")
		ok
		_a_ = []
		for _k_ = 1 to len(@aShapes)
			if _k_ != _i_  _a_ + @aShapes[_k_]  ok
		next
		@aShapes = _a_
		_cPfx_ = _c_ + "."
		_nPfx_ = len(_cPfx_)
		_b_ = []
		for _k_ = 1 to len(@aConst)
			if StzLeft(@aConst[_k_][1], _nPfx_) != _cPfx_  _b_ + @aConst[_k_]  ok
		next
		@aConst = _b_
		_d_ = []
		for _k_ = 1 to len(@aDerived)
			if StzLeft(@aDerived[_k_][1], _nPfx_) != _cPfx_  _d_ + @aDerived[_k_]  ok
		next
		@aDerived = _d_
		_u_ = []
		for _k_ = 1 to len(@aUnknownOf)
			if StzLeft(@aUnknownOf[_k_][1], _nPfx_) != _cPfx_  _u_ + @aUnknownOf[_k_]  ok
		next
		@aUnknownOf = _u_
		_t_ = []
		for _k_ = 1 to len(@aTextSize)
			if @aTextSize[_k_][1] != _c_  _t_ + @aTextSize[_k_]  ok
		next
		@aTextSize = _t_
		This._Reindex()

	def _SetField(pcName, pValue)
		if isNumber(pValue)
			This._DropName(pcName)
			@aConst + [ pcName, pValue ]
			@aConstIdx[_MdKey(pcName)] = len(@aConst)
		else
			This._DropName(pcName)
			@aDerived + [ pcName, "" + pValue ]
			@aDerivedIdx[_MdKey(pcName)] = len(@aDerived)
		ok

	# An override rewrites what a name MEANS. On an unknown it leaves the
	# slot in place -- a tape variable no expression references, so it
	# never moves -- and every reference to the name resolves to the
	# expression instead. On a constant or field it replaces the entry.
	def _Override(pcName, pValue)
		if This._UnknownIndex(pcName) = 0 and NOT This._HasConst(pcName) and
		   NOT This._HasDerived(pcName)
			stzraise("stzMathStyle: override of '" + pcName + "', which no rule " +
				"minted -- an override rewrites a property that exists.")
		ok
		This._SetField(pcName, pValue)

	def _DropName(pcName)
		_c_ = "" + pcName
		_a_ = []
		for _i_ = 1 to len(@aConst)
			if @aConst[_i_][1] != _c_  _a_ + @aConst[_i_]  ok
		next
		@aConst = _a_
		_b_ = []
		for _i_ = 1 to len(@aDerived)
			if @aDerived[_i_][1] != _c_  _b_ + @aDerived[_i_]  ok
		next
		@aDerived = _b_
		This._Reindex()

	# THE INDEXES, REBUILT FROM THE TABLES. Called whenever a table was
	# replaced rather than appended to -- a delete, a drop, the compile's
	# reset -- and cheap enough (one pass over each) to be the only rule
	# about them a reader has to hold.
	def _Reindex()
		@aShapeIdx = []
		for _i_ = 1 to len(@aShapes)
			@aShapeIdx[_MdKey(@aShapes[_i_][1])] = _i_
		next
		@aConstIdx = []
		for _i_ = 1 to len(@aConst)
			@aConstIdx[_MdKey(@aConst[_i_][1])] = _i_
		next
		@aDerivedIdx = []
		for _i_ = 1 to len(@aDerived)
			@aDerivedIdx[_MdKey(@aDerived[_i_][1])] = _i_
		next
		@aUnknownIdx = []
		for _i_ = 1 to len(@aUnknownOf)
			@aUnknownIdx[_MdKey(@aUnknownOf[_i_][1])] = @aUnknownOf[_i_][2]
		next
		@aTextIdx = []
		for _i_ = 1 to len(@aTextSize)
			@aTextIdx[_MdKey(@aTextSize[_i_][1])] = _i_
		next

	def _HasConst(pcName)
		return isNumber(@aConstIdx[_MdKey(pcName)])

	def _ConstOf(pcName)
		_i_ = @aConstIdx[_MdKey(pcName)]
		if isNumber(_i_)  return @aConst[_i_][2]  ok
		return 0

	def _HasDerived(pcName)
		return isNumber(@aDerivedIdx[_MdKey(pcName)])

	def _DerivedOf(pcName)
		_i_ = @aDerivedIdx[_MdKey(pcName)]
		if isNumber(_i_)  return @aDerived[_i_][2]  ok
		return ""

	def _Unknown(pcName, pbLabel)
		_i_ = len(@acUnknown) + 1
		@acUnknown + ("u" + _i_)
		@aUnknownOf + [ pcName, _i_ ]
		@aUnknownIdx[_MdKey(pcName)] = _i_
		@aValue + 0
		@bLabelVar + pbLabel

	def _UnknownIndex(pcName)
		_i_ = @aUnknownIdx[_MdKey(pcName)]
		if isNumber(_i_)  return _i_  ok
		return 0

	def _ShapeIndex(pcPath)
		_i_ = @aShapeIdx[_MdKey(pcPath)]
		if isNumber(_i_)  return _i_  ok
		return 0

	def _KindOf(pcPath)
		_i_ = This._ShapeIndex(pcPath)
		if _i_ = 0  return ""  ok
		return @aShapes[_i_][2]

	def _Prop(paProps, pcKey, pDefault)
		if NOT isList(paProps)  return pDefault  ok
		_n_ = len(paProps)
		for _i_ = 1 to _n_
			if isList(paProps[_i_]) and len(paProps[_i_]) = 2 and
			   StzLower("" + paProps[_i_][1]) = StzLower(pcKey)
				return paProps[_i_][2]
			ok
		next
		return pDefault

	# [ width, ascent, descent ] in px at the diagram's font. With no font
	# set, a label is a box of reasonable size, so the layout still runs.
	def _MeasureText(pcText)
		return This._MeasureTextAt(pcText, @nFontSize)

	def _MeasureTextAt(pcText, pnSize)
		if pcText = ""  return [ 0, 0, 0 ]  ok
		if isObject(@oFont)
			_w_ = @oFont.WidthOf(pcText, pnSize)
			_m_ = @oFont.MetricsOf(pcText, pnSize)
			return [ _w_, _m_[1], _m_[2] ]
		ok
		return [ 0.6 * pnSize * len(pcText), 0.75 * pnSize, 0.25 * pnSize ]

	def _TextSize(pcPath)
		_i_ = @aTextIdx[_MdKey(pcPath)]
		if isNumber(_i_)
			return [ @aTextSize[_i_][2], @aTextSize[_i_][3], @aTextSize[_i_][4] ]
		ok
		return [ 0, 0, 0 ]

	#-- SYMBOLS AND EXPRESSIONS: a name becomes tape text -----------------

	# The tape text for a name or a number: a derived name expands to its
	# expression (recursively, and a cycle is refused), a constant to its
	# value, an unknown to its tape variable, a text's size to the
	# measured number.
	def _Sym(pArg)
		if isNumber(pArg)  return This._Num(pArg)  ok
		_c_ = ring_trim("" + pArg)
		if This._HasDerived(_c_)
			@nExpandDepth++
			if @nExpandDepth > 24
				@nExpandDepth = 0
				stzraise("stzMathDiagram: '" + _c_ + "' is defined in terms of " +
					"itself, directly or through other derived properties.")
			ok
			_e_ = "(" + This._Expand(This._DerivedOf(_c_)) + ")"
			@nExpandDepth--
			return _e_
		ok
		if This._HasConst(_c_)  return This._Num(This._ConstOf(_c_))  ok
		_i_ = This._UnknownIndex(_c_)
		if _i_ > 0  return @acUnknown[_i_]  ok
		_ac_ = StzSplit(_c_, ".")
		if len(_ac_) = 3
			_cShape_ = _ac_[1] + "." + _ac_[2]
			if This._KindOf(_cShape_) = "text"
				_aM_ = This._TextSize(_cShape_)
				if _ac_[3] = "w"  return This._Num(_aM_[1])  ok
				if _ac_[3] = "h"  return This._Num(_aM_[2] + _aM_[3])  ok
			ok
		ok
		# a number the substance put on the object: "c.row", "c.v"
		if len(_ac_) = 2 and @oSubstance.HasData(_ac_[1], _ac_[2])
			return This._Num(@oSubstance.DataOf(_ac_[1], _ac_[2]))
		ok
		# a bare number written as text
		if This._LooksNumeric(_c_)  return _c_  ok
		# an expression rather than a name
		if StzFindFirst("(", _c_) > 0 or StzFindFirst("+", _c_) > 0 or
		   StzFindFirst("-", _c_) > 0 or StzFindFirst("*", _c_) > 0 or
		   StzFindFirst("/", _c_) > 0 or StzFindFirst(" ", _c_) > 0
			return "(" + This._Expand(_c_) + ")"
		ok
		stzraise("stzMathDiagram: '" + _c_ + "' is not an unknown, a constant, " +
			"a field, a derived property or a measured size of any shape a " +
			"rule minted.")

	def _LooksNumeric(pc)
		_n_ = len(pc)
		if _n_ = 0  return FALSE  ok
		for _i_ = 1 to _n_
			_k_ = ascii(pc[_i_])
			if NOT ((_k_ >= 48 and _k_ <= 57) or _k_ = 46 or _k_ = 45)  return FALSE  ok
		next
		return TRUE

	# An expression over paths and computed functions, rewritten into the
	# tape's language. Identifiers with a dot are names (resolved through
	# _Sym); an identifier followed by "(" is a computed function when it
	# is one of ours, and passes through when it is the tape's own.
	def _Expand(pcExpr)
		_c_ = "" + pcExpr
		_out_ = ""
		_n_ = len(_c_)
		_i_ = 1
		while _i_ <= _n_
			_ch_ = _c_[_i_]
			if This._IsIdentStart(_ch_)
				_j_ = _i_
				while _j_ <= _n_ and This._IsPathChar(_c_[_j_])
					_j_++
				end
				_tok_ = StzStringSection(_c_, _i_, _j_ - 1)
				# a call?
				_k_ = _j_
				while _k_ <= _n_ and _c_[_k_] = " "
					_k_++
				end
				if _k_ <= _n_ and _c_[_k_] = "(" and This._IsComputed(_tok_)
					_aArgs_ = This._CallArgs(_c_, _k_)
					_out_ += This._Computed(_tok_, _aArgs_[1])
					_i_ = _aArgs_[2]
					loop
				ok
				if StzFindFirst(".", _tok_) > 0
					_out_ += This._Sym(_tok_)
				else
					_out_ += _tok_
				ok
				_i_ = _j_
			else
				_out_ += _ch_
				_i_++
			ok
		end
		return _out_

	# The arguments of a call whose "(" is at pnOpen: [ [ arg, ... ], nAfter ]
	def _CallArgs(pcExpr, pnOpen)
		_a_ = []
		_depth_ = 0
		_cur_ = ""
		_n_ = len(pcExpr)
		_i_ = pnOpen
		while _i_ <= _n_
			_ch_ = pcExpr[_i_]
			if _ch_ = "("
				_depth_++
				if _depth_ > 1  _cur_ += _ch_  ok
			but _ch_ = ")"
				_depth_--
				if _depth_ = 0
					if ring_trim(_cur_) != ""  _a_ + ring_trim(_cur_)  ok
					return [ _a_, _i_ + 1 ]
				ok
				_cur_ += _ch_
			but _ch_ = "," and _depth_ = 1
				_a_ + ring_trim(_cur_)
				_cur_ = ""
			else
				_cur_ += _ch_
			ok
			_i_++
		end
		stzraise("stzMathDiagram: a parenthesis is not closed in '" + pcExpr + "'.")

	def _IsComputed(pcName)
		_c_ = StzLower(pcName)
		_ac_ = StzSplit(StzMathComputedFnList(), ", ")
		for _i_ = 1 to len(_ac_)
			if _ac_[_i_] = _c_  return TRUE  ok
		next
		return FALSE

	# The computations over shapes, each as tape text.
	def _Computed(pcFn, paArgs)
		_f_ = StzLower(pcFn)
		if _f_ = "dist"
			if len(paArgs) != 2  stzraise("stzMathDiagram: dist(a, b) takes two shapes.")  ok
			_a_ = This._Geo(paArgs[1])
			_b_ = This._Geo(paArgs[2])
			return This._Dist(_a_, _b_)
		ok
		if len(paArgs) < 1
			stzraise("stzMathDiagram: " + pcFn + "() takes a line.")
		ok
		_l_ = This._Geo(paArgs[1])
		if _l_[1] != "line"
			stzraise("stzMathDiagram: " + pcFn + "(" + paArgs[1] + ") -- '" +
				paArgs[1] + "' is not a line.")
		ok
		_dx_ = "(" + _l_[6] + "-" + _l_[4] + ")"
		_dy_ = "(" + _l_[7] + "-" + _l_[5] + ")"
		_len_ = "sqrt(" + _dx_ + "^2+" + _dy_ + "^2+0.000001)"
		if _f_ = "len"   return _len_  ok
		if _f_ = "midx"  return "((" + _l_[4] + "+" + _l_[6] + ")/2)"  ok
		if _f_ = "midy"  return "((" + _l_[5] + "+" + _l_[7] + ")/2)"  ok
		if _f_ = "ux"    return "(" + _dx_ + "/" + _len_ + ")"  ok
		if _f_ = "uy"    return "(" + _dy_ + "/" + _len_ + ")"  ok
		if _f_ = "nx"    return "(0-" + _dy_ + "/" + _len_ + ")"  ok
		if _f_ = "ny"    return "(" + _dx_ + "/" + _len_ + ")"  ok
		if len(paArgs) != 2
			stzraise("stzMathDiagram: " + pcFn + "(a, b) takes two lines.")
		ok
		_m_ = This._Geo(paArgs[2])
		if _m_[1] != "line"
			stzraise("stzMathDiagram: " + pcFn + "(" + paArgs[1] + ", " + paArgs[2] +
				") -- '" + paArgs[2] + "' is not a line.")
		ok
		_ex_ = "(" + _m_[6] + "-" + _m_[4] + ")"
		_ey_ = "(" + _m_[7] + "-" + _m_[5] + ")"
		if _f_ = "dot"    return "(" + _dx_ + "*" + _ex_ + "+" + _dy_ + "*" + _ey_ + ")"  ok
		if _f_ = "cross"  return "(" + _dx_ + "*" + _ey_ + "-" + _dy_ + "*" + _ex_ + ")"  ok
		stzraise("stzMathDiagram: '" + pcFn + "' is not a computed function.")

	def _IsIdentStart(pc)
		_n_ = ascii(pc)
		return (_n_ >= 65 and _n_ <= 90) or (_n_ >= 97 and _n_ <= 122) or _n_ = 95 or _n_ = 96

	def _IsPathChar(pc)
		_n_ = ascii(pc)
		return (_n_ >= 48 and _n_ <= 57) or (_n_ >= 65 and _n_ <= 90) or
		       (_n_ >= 97 and _n_ <= 122) or _n_ = 95 or _n_ = 46 or _n_ = 96

	def _IsIdent(pc)
		_n_ = ascii(pc)
		return (_n_ >= 48 and _n_ <= 57) or (_n_ >= 65 and _n_ <= 90) or
		       (_n_ >= 97 and _n_ <= 122) or _n_ = 95

	# Ring prints a number with as many decimals as `decimals()` allows, two
	# by default -- which would round every frozen coordinate. decimals()
	# SETS and returns nothing, and Ring has no getter, so the current
	# setting is read back by formatting a probe and counting its fraction
	# digits, then restored after the write.
	def _Num(pn)
		if @nNumDecimals < 0
			_cP_ = "" + (1 / 3)
			_nDot_ = StzFindFirst(".", _cP_)
			@nNumDecimals = 0
			if _nDot_ > 0  @nNumDecimals = len(_cP_) - _nDot_  ok
		ok
		decimals(12)
		_c_ = "" + pn
		decimals(@nNumDecimals)
		return _c_

	# circle: [ "circle", cx, cy, r ]   rect/text: [ "rect", cx, cy, w, h ]
	# line: [ "line", mx, my, x1, y1, x2, y2 ] -- its centre is its midpoint
	def _Geo(pcPath)
		_c_ = ring_trim("" + pcPath)
		_k_ = This._KindOf(_c_)
		if _k_ = ""
			stzraise("stzMathDiagram: '" + _c_ + "' is not a shape any rule minted.")
		ok
		if _k_ = "curve" or _k_ = "mark" or _k_ = "spline"
			stzraise("stzMathDiagram: '" + _c_ + "' is a " + _k_ + " -- it is " +
				"drawn from its points, and a constraint speaks to the points.")
		ok
		if _k_ = "poly"
			# A CONVEX POLYGON, as its vertices (DN8e). contains() and
			# disjoint() speak to it through the signed distance to its
			# edges' lines -- exact for a convex outline -- and its winding
			# is read off its own area, so either order of vertices works.
			_nV_ = This._Prop(@aShapes[This._ShapeIndex(_c_)][3], "n", 0)
			_aV_ = []
			for _v_ = 1 to _nV_
				_aV_ + This._Sym(_c_ + ".x" + _v_)
				_aV_ + This._Sym(_c_ + ".y" + _v_)
			next
			return [ "poly", _nV_, _aV_ ]
		ok
		if _k_ = "circle"
			return [ "circle", This._Sym(_c_ + ".cx"), This._Sym(_c_ + ".cy"),
			         This._Sym(_c_ + ".r") ]
		but _k_ = "ellipse"
			# its bounding box: twice each radius
			return [ "rect", This._Sym(_c_ + ".cx"), This._Sym(_c_ + ".cy"),
			         "(2*" + This._Sym(_c_ + ".rx") + ")", "(2*" + This._Sym(_c_ + ".ry") + ")" ]
		but _k_ = "line"
			_x1_ = This._Sym(_c_ + ".x1")  _y1_ = This._Sym(_c_ + ".y1")
			_x2_ = This._Sym(_c_ + ".x2")  _y2_ = This._Sym(_c_ + ".y2")
			return [ "line", "((" + _x1_ + "+" + _x2_ + ")/2)", "((" + _y1_ + "+" + _y2_ + ")/2)",
			         _x1_, _y1_, _x2_, _y2_ ]
		ok
		return [ "rect", This._Sym(_c_ + ".cx"), This._Sym(_c_ + ".cy"),
		         This._Sym(_c_ + ".w"), This._Sym(_c_ + ".h") ]

	def _Dist(pa, pb)
		return "sqrt((" + pa[2] + "-" + pb[2] + ")^2+(" + pa[3] + "-" + pb[3] + ")^2)"

	# half the diagonal of a rect: its bounding circle
	def _HalfDiag(pa)
		return "sqrt((" + pa[4] + ")^2+(" + pa[5] + ")^2)/2"

	# THE SIGNED DISTANCE FROM A POINT TO A BOX, exactly -- positive outside,
	# negative by the depth inside. This is what replaced the bounding circle
	# a label used to wear: a wide name like "ABCDE" has a bounding radius
	# far larger than the name is tall, so the picture pushed it away from
	# things it never touched, and the shortfall was worst exactly where a
	# label is widest.
	#
	# q = |offset| - halfExtents. Outside, some component of q is positive
	# and the distance is |max(q, 0)|; inside, every component is negative
	# and min(0, max(qx, qy)) is the penetration -- which is what keeps a
	# GRADIENT where the two overlap, so the solver can still push them
	# apart. Both branches are on the tape already: abs, min, max, sqrt.
	# THE SIGNED DISTANCE FROM A POINT TO A CONVEX POLYGON'S EDGES, inside
	# negative, as tape text: for each edge the signed distance to its
	# LINE, all turned by the polygon's own winding -- the sign of its
	# area over its magnitude, so a clockwise and an anticlockwise
	# polygon read the same -- and the largest of them. Inside a convex
	# polygon every edge is on one side, so the largest is the nearest
	# edge's distance, negative; outside, it is positive and at least the
	# distance to the nearest line. That is exact for containment, which
	# is what needs it, and a lower bound for separation, which the
	# segment gaps below make exact.
	def _PolySigned(paPoly, pcX, pcY)
		_n_ = paPoly[2]
		_aV_ = paPoly[3]
		_cA_ = ""
		for _i_ = 1 to _n_
			_j_ = _i_ + 1
			if _j_ > _n_  _j_ = 1  ok
			if _i_ > 1  _cA_ += "+"  ok
			_cA_ += "(" + _aV_[2*_i_-1] + "*" + _aV_[2*_j_] + "-" + _aV_[2*_j_-1] + "*" + _aV_[2*_i_] + ")"
		next
		_cSgn_ = "((" + _cA_ + ")/(abs(" + _cA_ + ")+0.001))"
		_cS_ = ""
		for _i_ = 1 to _n_
			_j_ = _i_ + 1
			if _j_ > _n_  _j_ = 1  ok
			_dx_ = "(" + _aV_[2*_j_-1] + "-" + _aV_[2*_i_-1] + ")"
			_dy_ = "(" + _aV_[2*_j_] + "-" + _aV_[2*_i_] + ")"
			_cross_ = "(" + _dx_ + "*(" + pcY + "-" + _aV_[2*_i_] + ")-" + _dy_ + "*(" + pcX + "-" + _aV_[2*_i_-1] + "))"
			_len_ = "sqrt(" + _dx_ + "^2+" + _dy_ + "^2+0.000001)"
			_d_ = "(0-" + _cSgn_ + "*" + _cross_ + "/" + _len_ + ")"
			if _i_ = 1
				_cS_ = _d_
			else
				_cS_ = "max(" + _cS_ + "," + _d_ + ")"
			ok
		next
		return _cS_

	# the smallest gap from a box to any edge of a polygon, each edge as a
	# segment through the same clamped projection a label-off-a-segment
	# uses -- exact for the box against the nearest point of the segment
	def _PolyBoxGap(paPoly, pcCx, pcCy, pcHw, pcHh)
		_n_ = paPoly[2]
		_aV_ = paPoly[3]
		_cG_ = ""
		for _i_ = 1 to _n_
			_j_ = _i_ + 1
			if _j_ > _n_  _j_ = 1  ok
			_x1_ = _aV_[2*_i_-1]  _y1_ = _aV_[2*_i_]
			_dx_ = "(" + _aV_[2*_j_-1] + "-" + _x1_ + ")"
			_dy_ = "(" + _aV_[2*_j_] + "-" + _y1_ + ")"
			_t_ = "max(0,min(1,((" + pcCx + "-" + _x1_ + ")*" + _dx_ + "+(" + pcCy + "-" + _y1_ + ")*" + _dy_ +
			      ")/(" + _dx_ + "^2+" + _dy_ + "^2+0.000001)))"
			_px_ = "(" + _x1_ + "+" + _t_ + "*" + _dx_ + ")"
			_py_ = "(" + _y1_ + "+" + _t_ + "*" + _dy_ + ")"
			_g_ = This._BoxSD(pcHw, pcHh, _px_ + "-" + pcCx, _py_ + "-" + pcCy)
			if _i_ = 1
				_cG_ = _g_
			else
				_cG_ = "min(" + _cG_ + "," + _g_ + ")"
			ok
		next
		return _cG_

	def _BoxSD(pcHw, pcHh, pcDx, pcDy)
		_qx_ = "(abs(" + pcDx + ")-" + pcHw + ")"
		_qy_ = "(abs(" + pcDy + ")-" + pcHh + ")"
		return "(sqrt(max(0," + _qx_ + ")^2+max(0," + _qy_ + ")^2)+min(0,max(" +
		       _qx_ + "," + _qy_ + ")))"

	def _IsLabelPath(pcPath)
		return This._KindOf(pcPath) = "text"

	# Does this argument refer to a text shape? (decides the label stage)
	def _MentionsLabel(pArg)
		if isNumber(pArg)  return FALSE  ok
		_c_ = "" + pArg
		_n_ = len(_c_)
		_i_ = 1
		while _i_ <= _n_
			if This._IsIdentStart(_c_[_i_])
				_j_ = _i_
				while _j_ <= _n_ and This._IsPathChar(_c_[_j_])
					_j_++
				end
				_tok_ = StzStringSection(_c_, _i_, _j_ - 1)
				_ac_ = StzSplit(_tok_, ".")
				if len(_ac_) >= 2 and This._IsLabelPath(_ac_[1] + "." + _ac_[2])
					# a label whose position is derived owns no variable
					if This._UnknownIndex(_ac_[1] + "." + _ac_[2] + ".cx") > 0 or
					   This._UnknownIndex(_ac_[1] + "." + _ac_[2] + ".cy") > 0
						return TRUE
					ok
				ok
				_i_ = _j_
			else
				_i_++
			ok
		end
		return FALSE

	# Does this argument refer to a text shape whose string is empty?
	def _MentionsEmptyText(pArg)
		if isNumber(pArg)  return FALSE  ok
		_c_ = "" + pArg
		_n_ = len(_c_)
		_i_ = 1
		while _i_ <= _n_
			if This._IsIdentStart(_c_[_i_])
				_j_ = _i_
				while _j_ <= _n_ and This._IsPathChar(_c_[_j_])
					_j_++
				end
				_ac_ = StzSplit(StzStringSection(_c_, _i_, _j_ - 1), ".")
				if len(_ac_) >= 2
					_cS_ = _ac_[1] + "." + _ac_[2]
					if This._KindOf(_cS_) = "text" and This._TextSize(_cS_)[1] = 0
						return TRUE
					ok
				ok
				_i_ = _j_
			else
				_i_++
			ok
		end
		return FALSE

	def _AddTerm(pcVerb, pcFn, paArgs, pcWhere)
		_f_ = StzLower(pcFn)
		_bLbl_ = FALSE
		for _i_ = 1 to len(paArgs)
			if This._MentionsLabel(paArgs[_i_])  _bLbl_ = TRUE  ok
			# AN EMPTY NAME CONSTRAINS NOTHING. An unlabelled object still owns
			# a text shape, so a rule naming x.text is well-formed -- but a
			# box of no size held off six hundred edges is six hundred tapes
			# and a label stage for nothing: the dodecahedron, whose vertices
			# have no names, spent 33 of its 38 seconds placing them.
			if This._MentionsEmptyText(paArgs[_i_])  return  ok
		next
		_cE_ = This._Energy(_f_, paArgs, pcVerb)
		_cW_ = pcWhere + " :: " + pcFn + "(" + This._ArgsText(paArgs) + ")"
		# the arguments ride along, so a start can read what a term is about
		if pcVerb = "ensure"
			@aConstraints + [ pcFn, _cE_, _cW_, _bLbl_, paArgs ]
		else
			@aObjectives + [ pcFn, _cE_, _cW_, _bLbl_, paArgs ]
		ok

	def _ArgsText(paArgs)
		_c_ = ""
		for _i_ = 1 to len(paArgs)
			if _i_ > 1  _c_ += ", "  ok
			_c_ += "" + paArgs[_i_]
		next
		return _c_

	def _Arg(paArgs, pn, pDefault)
		if len(paArgs) >= pn  return paArgs[pn]  ok
		return pDefault

	def _ShapeArg(paArgs, pn, pcFn)
		if len(paArgs) < pn
			stzraise("stzMathDiagram: " + pcFn + " needs " + pn + " shape argument(s).")
		ok
		return "" + paArgs[pn]

	# THE CATALOGUE, each as Penrose's own energy. For ensure, the value is
	# g with g > 0 meaning violated; for encourage, the energy itself. A
	# scalar argument is a number, a name, or an expression.
	def _Energy(pcFn, paArgs, pcVerb)
		if pcFn = "contains"
			_a_ = This._Geo(This._ShapeArg(paArgs, 1, pcFn))
			_b_ = This._Geo(This._ShapeArg(paArgs, 2, pcFn))
			_p_ = This._Sym(This._Arg(paArgs, 3, 0))
			if _a_[1] = "line" or _b_[1] = "line"
				stzraise("stzMathDiagram: contains() over a line is not defined.")
			ok
			if _b_[1] = "poly"
				stzraise("stzMathDiagram: contains(a, poly) is not defined -- a polygon " +
					"holds things; ask contains(poly, thing).")
			ok
			if _a_[1] = "poly"
				# a box is inside a convex polygon by pad when each of its four
				# corners is; a circle when its centre is, by pad plus r
				if _b_[1] = "circle"
					return "(" + This._PolySigned(_a_, _b_[2], _b_[3]) + ")+" + _b_[4] + "+" + _p_
				ok
				_hw_ = "(" + _b_[4] + ")/2"
				_hh_ = "(" + _b_[5] + ")/2"
				_c1_ = This._PolySigned(_a_, "(" + _b_[2] + "-" + _hw_ + ")", "(" + _b_[3] + "-" + _hh_ + ")")
				_c2_ = This._PolySigned(_a_, "(" + _b_[2] + "+" + _hw_ + ")", "(" + _b_[3] + "-" + _hh_ + ")")
				_c3_ = This._PolySigned(_a_, "(" + _b_[2] + "-" + _hw_ + ")", "(" + _b_[3] + "+" + _hh_ + ")")
				_c4_ = This._PolySigned(_a_, "(" + _b_[2] + "+" + _hw_ + ")", "(" + _b_[3] + "+" + _hh_ + ")")
				return "max(max(" + _c1_ + "," + _c2_ + "),max(" + _c3_ + "," + _c4_ + "))+" + _p_
			ok
			if _a_[1] = "circle" and _b_[1] = "circle"
				return This._Dist(_a_, _b_) + "-(" + _a_[4] + "-" + _b_[4] + "-" + _p_ + ")"
			but _a_[1] = "circle"
				_hw_ = "(" + _b_[4] + ")/2"
				_hh_ = "(" + _b_[5] + ")/2"
				_c1_ = "sqrt((" + _b_[2] + "-" + _hw_ + "-" + _a_[2] + ")^2+(" + _b_[3] + "-" + _hh_ + "-" + _a_[3] + ")^2)"
				_c2_ = "sqrt((" + _b_[2] + "+" + _hw_ + "-" + _a_[2] + ")^2+(" + _b_[3] + "-" + _hh_ + "-" + _a_[3] + ")^2)"
				_c3_ = "sqrt((" + _b_[2] + "-" + _hw_ + "-" + _a_[2] + ")^2+(" + _b_[3] + "+" + _hh_ + "-" + _a_[3] + ")^2)"
				_c4_ = "sqrt((" + _b_[2] + "+" + _hw_ + "-" + _a_[2] + ")^2+(" + _b_[3] + "+" + _hh_ + "-" + _a_[3] + ")^2)"
				return "max(max(" + _c1_ + "," + _c2_ + "),max(" + _c3_ + "," + _c4_ + "))-(" +
				       _a_[4] + "-" + _p_ + ")"
			but _b_[1] = "circle"
				_g1_ = "(" + _b_[2] + "-" + _b_[4] + "+" + _p_ + ")-(" + _a_[2] + "-(" + _a_[4] + ")/2)"
				_g2_ = "(" + _a_[2] + "+(" + _a_[4] + ")/2)-(" + _b_[2] + "+" + _b_[4] + "+" + _p_ + ")"
				_g3_ = "(" + _b_[3] + "-" + _b_[4] + "+" + _p_ + ")-(" + _a_[3] + "-(" + _a_[5] + ")/2)"
				_g4_ = "(" + _a_[3] + "+(" + _a_[5] + ")/2)-(" + _b_[3] + "+" + _b_[4] + "+" + _p_ + ")"
				return "-min(min(" + _g1_ + "," + _g2_ + "),min(" + _g3_ + "," + _g4_ + "))"
			else
				_g1_ = "(" + _b_[2] + "-(" + _b_[4] + ")/2)-(" + _a_[2] + "-(" + _a_[4] + ")/2)-" + _p_
				_g2_ = "(" + _a_[2] + "+(" + _a_[4] + ")/2)-(" + _b_[2] + "+(" + _b_[4] + ")/2)-" + _p_
				_g3_ = "(" + _b_[3] + "-(" + _b_[5] + ")/2)-(" + _a_[3] + "-(" + _a_[5] + ")/2)-" + _p_
				_g4_ = "(" + _a_[3] + "+(" + _a_[5] + ")/2)-(" + _b_[3] + "+(" + _b_[5] + ")/2)-" + _p_
				return "-min(min(" + _g1_ + "," + _g2_ + "),min(" + _g3_ + "," + _g4_ + "))"
			ok

		but pcFn = "disjoint"
			_a_ = This._Geo(This._ShapeArg(paArgs, 1, pcFn))
			_b_ = This._Geo(This._ShapeArg(paArgs, 2, pcFn))
			_p_ = This._Sym(This._Arg(paArgs, 3, 0))
			if _a_[1] = "line" and _b_[1] = "line"
				stzraise("stzMathDiagram: disjoint() between two lines is not defined.")
			ok
			if _a_[1] = "poly" and _b_[1] = "poly"
				stzraise("stzMathDiagram: disjoint() between two polygons is not defined -- " +
					"hold a point, a circle or a name off a polygon.")
			ok
			if _a_[1] = "poly" or _b_[1] = "poly"
				# A THING OFF A CONVEX POLYGON: its gap to the nearest edge is
				# at least pad, AND its centre is outside -- the second term is
				# what keeps a name that fell inside from reading as clear of
				# every edge
				_g_ = _a_
				_o_ = _b_
				if _b_[1] = "poly"  _g_ = _b_  _o_ = _a_  ok
				if _o_[1] = "line"
					stzraise("stzMathDiagram: disjoint(line, poly) is not defined.")
				ok
				_cIn_ = This._PolySigned(_g_, _o_[2], _o_[3])
				if _o_[1] = "circle"
					_cGap_ = This._PolyBoxGap(_g_, _o_[2], _o_[3], _o_[4], _o_[4])
				else
					_cGap_ = This._PolyBoxGap(_g_, _o_[2], _o_[3], "(" + _o_[4] + ")/2", "(" + _o_[5] + ")/2")
				ok
				return "max((" + _p_ + ")-" + _cGap_ + ",0-" + _cIn_ + ")"
			ok
			if _a_[1] = "line" or _b_[1] = "line"
				# A LABEL OFF A SEGMENT -- Penrose's disjoint(text, line). The
				# shape's bounding circle against the segment: g = r + pad -
				# distance from the centre to the nearest point of the segment,
				# with the nearest point found by clamping the projection to
				# [0, 1] -- min and max are on the tape, so this is one term.
				_l_ = _a_
				_s_ = _b_
				if _b_[1] = "line"
					_l_ = _b_
					_s_ = _a_
				ok
				_dx_ = "(" + _l_[6] + "-" + _l_[4] + ")"
				_dy_ = "(" + _l_[7] + "-" + _l_[5] + ")"
				_t_ = "max(0,min(1,((" + _s_[2] + "-" + _l_[4] + ")*" + _dx_ + "+(" +
				      _s_[3] + "-" + _l_[5] + ")*" + _dy_ + ")/(" + _dx_ + "^2+" + _dy_ +
				      "^2+0.000001)))"
				_px_ = "(" + _l_[4] + "+" + _t_ + "*" + _dx_ + ")"
				_py_ = "(" + _l_[5] + "+" + _t_ + "*" + _dy_ + ")"
				if _s_[1] = "rect"
					# THE BOX ITSELF, not a circle around it: the exact distance
					# from the nearest point of the segment to the label's box.
					return "(" + _p_ + ")-" + This._BoxSD("(" + _s_[4] + ")/2",
						"(" + _s_[5] + ")/2", _px_ + "-" + _s_[2], _py_ + "-" + _s_[3])
				ok
				_nd_ = "sqrt((" + _px_ + "-" + _s_[2] + ")^2+(" + _py_ + "-" + _s_[3] + ")^2)"
				return "(" + _s_[4] + "+" + _p_ + ")-" + _nd_
			ok
			if _a_[1] = "circle" and _b_[1] = "circle"
				return "(" + _a_[4] + "+" + _b_[4] + "+" + _p_ + ")-" + This._Dist(_a_, _b_)
			but _a_[1] = "rect" and _b_[1] = "rect"
				# MINKOWSKI: two boxes are apart by the distance from one
				# centre to the OTHER GROWN BY THE FIRST -- half-extents added,
				# which is what the Minkowski sum of two boxes is.
				return "(" + _p_ + ")-" + This._BoxSD(
					"((" + _a_[4] + "+" + _b_[4] + ")/2)", "((" + _a_[5] + "+" + _b_[5] + ")/2)",
					_b_[2] + "-" + _a_[2], _b_[3] + "-" + _a_[3])
			else
				# a box and a circle: the circle's centre against the box
				_r_ = _a_
				_o_ = _b_
				if _b_[1] = "rect"  _r_ = _b_  _o_ = _a_  ok
				return "(" + _o_[4] + "+" + _p_ + ")-" + This._BoxSD(
					"(" + _r_[4] + ")/2", "(" + _r_[5] + ")/2",
					_o_[2] + "-" + _r_[2], _o_[3] + "-" + _r_[3])
			ok

		but pcFn = "notcrossing"
			# TWO SEGMENTS THAT DO NOT MEET. Every graph picture before this
			# term was a lawful tangle, because nothing in the catalogue
			# spoke about two edges at once. Let s1, s2 be the signed
			# distances of Q's ends from P's line and s3, s4 those of P's
			# ends from Q's; the segments cross exactly when both products
			# s1*s2 and s3*s4 are negative. The violation is the smaller
			# magnitude, plus a margin, over a fixed scale -- zero everywhere
			# the segments are clear, so it costs nothing until needed.
			#
			# NOT A SQUARE ROOT. The first form rooted the product back to
			# pixels, and sqrt(x + eps) has slope 1/(2 sqrt(eps)) -- five
			# hundred -- at the instant a crossing begins: a cliff the line
			# search fell off on every round, and the penalty weight
			# multiplied it. A seven-vertex network that solved in two
			# seconds did not finish in ten minutes. A ramp has a bounded
			# slope; the picture cannot tell the difference.
			_a_ = This._Geo(This._ShapeArg(paArgs, 1, pcFn))
			_b_ = This._Geo(This._ShapeArg(paArgs, 2, pcFn))
			_p_ = This._Sym(This._Arg(paArgs, 3, 4))
			# and a WEIGHT, for the encourage form: at a typical 100px the
			# repulsion between two vertices is two thousand energy units
			# and a deep crossing about thirty, so unweighted it loses
			_w_ = This._Sym(This._Arg(paArgs, 4, 1))
			if _a_[1] != "line" or _b_[1] != "line"
				stzraise("stzMathDiagram: notCrossing(a, b) takes two lines.")
			ok
			_dpx_ = "(" + _a_[6] + "-" + _a_[4] + ")"
			_dpy_ = "(" + _a_[7] + "-" + _a_[5] + ")"
			_Lp_ = "sqrt(" + _dpx_ + "^2+" + _dpy_ + "^2+0.000001)"
			_s1_ = "((" + _dpx_ + "*(" + _b_[5] + "-" + _a_[5] + ")-" + _dpy_ + "*(" + _b_[4] + "-" + _a_[4] + "))/" + _Lp_ + ")"
			_s2_ = "((" + _dpx_ + "*(" + _b_[7] + "-" + _a_[5] + ")-" + _dpy_ + "*(" + _b_[6] + "-" + _a_[4] + "))/" + _Lp_ + ")"
			_dqx_ = "(" + _b_[6] + "-" + _b_[4] + ")"
			_dqy_ = "(" + _b_[7] + "-" + _b_[5] + ")"
			_Lq_ = "sqrt(" + _dqx_ + "^2+" + _dqy_ + "^2+0.000001)"
			_s3_ = "((" + _dqx_ + "*(" + _a_[5] + "-" + _b_[5] + ")-" + _dqy_ + "*(" + _a_[4] + "-" + _b_[4] + "))/" + _Lq_ + ")"
			_s4_ = "((" + _dqx_ + "*(" + _a_[7] + "-" + _b_[5] + ")-" + _dqy_ + "*(" + _a_[6] + "-" + _b_[4] + "))/" + _Lq_ + ")"
			return "(" + _w_ + ")*max(0,(" + _p_ + ")^2+min(0-" + _s1_ + "*" + _s2_ + ",0-" +
			       _s3_ + "*" + _s4_ + "))/50"

		but pcFn = "overlapping"
			_a_ = This._Geo(This._ShapeArg(paArgs, 1, pcFn))
			_b_ = This._Geo(This._ShapeArg(paArgs, 2, pcFn))
			_o_ = This._Sym(This._Arg(paArgs, 3, 0))
			_ra_ = _a_[4]
			if _a_[1] = "rect"  _ra_ = This._HalfDiag(_a_)  ok
			_rb_ = _b_[4]
			if _b_[1] = "rect"  _rb_ = This._HalfDiag(_b_)  ok
			return This._Dist(_a_, _b_) + "-(" + _ra_ + "+" + _rb_ + ")+" + _o_

		but pcFn = "touching"
			_a_ = This._Geo(This._ShapeArg(paArgs, 1, pcFn))
			_b_ = This._Geo(This._ShapeArg(paArgs, 2, pcFn))
			_p_ = This._Sym(This._Arg(paArgs, 3, 0))
			return "abs(" + This._Dist(_a_, _b_) + "-(" + _a_[4] + "+" + _b_[4] + ")-" + _p_ + ")"

		but pcFn = "lessthan"
			return "(" + This._Sym(paArgs[1]) + ")-(" + This._Sym(paArgs[2]) + ")+" +
			       This._Sym(This._Arg(paArgs, 3, 0))
		but pcFn = "greaterthan"
			return "(" + This._Sym(paArgs[2]) + ")-(" + This._Sym(paArgs[1]) + ")+" +
			       This._Sym(This._Arg(paArgs, 3, 0))
		but pcFn = "equal"
			if pcVerb = "ensure"
				return "abs((" + This._Sym(paArgs[1]) + ")-(" + This._Sym(paArgs[2]) + "))"
			ok
			return "((" + This._Sym(paArgs[1]) + ")-(" + This._Sym(paArgs[2]) + "))^2"
		but pcFn = "inrange"
			_x_ = This._Sym(paArgs[1])
			return "max(0,(" + _x_ + ")-(" + This._Sym(paArgs[3]) + "))+max(0,(" +
			       This._Sym(paArgs[2]) + ")-(" + _x_ + "))"

		but pcFn = "samecenter" or pcFn = "near"
			_a_ = This._Geo(This._ShapeArg(paArgs, 1, pcFn))
			_b_ = This._Geo(This._ShapeArg(paArgs, 2, pcFn))
			_o_ = This._Sym(This._Arg(paArgs, 3, 0))
			return "(" + _a_[2] + "-" + _b_[2] + ")^2+(" + _a_[3] + "-" + _b_[3] + ")^2-(" + _o_ + ")^2"
		but pcFn = "minimal"
			return "(" + This._Sym(paArgs[1]) + ")"
		but pcFn = "maximal"
			return "-(" + This._Sym(paArgs[1]) + ")"
		but pcFn = "nottooclose"
			_a_ = This._Geo(This._ShapeArg(paArgs, 1, pcFn))
			_b_ = This._Geo(This._ShapeArg(paArgs, 2, pcFn))
			# PENROSE'S SCALE, not a bare weight: its repulsion is weight x 10^7
			# over the squared distance. With the bare weight the tree style's
			# "align with your parent" preference won outright and every set
			# collapsed onto one vertical line; at Penrose's scale a sibling at
			# 50px repels with the same force the alignment pulls at 50px off.
			_w_ = This._Sym(This._Arg(paArgs, 3, 10))
			return "(" + _w_ + ")*10000000/((" + _a_[2] + "-" + _b_[2] + ")^2+(" + _a_[3] + "-" + _b_[3] + ")^2+0.000001)"
		but pcFn = "above" or pcFn = "below" or pcFn = "leftwards" or pcFn = "rightwards"
			_a_ = This._Geo(This._ShapeArg(paArgs, 1, pcFn))
			_b_ = This._Geo(This._ShapeArg(paArgs, 2, pcFn))
			_o_ = This._Sym(This._Arg(paArgs, 3, 100))
			# y grows DOWN on this canvas, so "a above b" is a.cy + off <= b.cy
			if pcFn = "above"
				return "max(0,(" + _a_[3] + ")+" + _o_ + "-(" + _b_[3] + "))^2"
			but pcFn = "below"
				return "max(0,(" + _b_[3] + ")+" + _o_ + "-(" + _a_[3] + "))^2"
			but pcFn = "leftwards"
				return "max(0,(" + _a_[2] + ")+" + _o_ + "-(" + _b_[2] + "))^2"
			else
				return "max(0,(" + _b_[2] + ")+" + _o_ + "-(" + _a_[2] + "))^2"
			ok
		ok
		stzraise("stzMathDiagram: '" + pcFn + "' is not a layout function.")

	def _AddOnCanvas(paShape)
		_cP_ = paShape[1]
		_k_ = paShape[2]
		# A curve and a mark are read off the points that made them, so the
		# points already carry the paper. A POLYGON does not: Byrne's squares
		# stand OUTSIDE the triangle, and it is the square's far corners that
		# run off the page, so every vertex is held on it.
		if _k_ = "curve" or _k_ = "mark"  return  ok
		# A SHAPE WHOSE EVERY COORDINATE IS A CONSTANT IS NOT THE SOLVER'S
		# TO HOLD ON THE PAPER, and a constraint on it would be a tape that
		# evaluates to a number -- five thousand dots minted twenty thousand
		# of them (DN8f). Each term below is kept only if it mentions an
		# unknown; a shape that keeps none is checked here, in Ring, once,
		# and a datum that put it off the paper is reported like any other
		# violation, because the content can be wrong where the solver
		# cannot help.
		if len(@acUnknown) = 0 or This._AllConst(paShape)
			This._StaticOnCanvas(paShape)
			return
		ok
		# the paper, less the style's margin on every side
		_nM_ = @oStyle.Margin()
		_M_ = This._Num(_nM_)
		_W_ = This._Num(@oStyle.CanvasWidth() - _nM_)
		_H_ = This._Num(@oStyle.CanvasHeight() - _nM_)
		# a polygon and a spline are held by their control points -- a
		# spline may still overshoot a little between two of them, which the
		# margin absorbs
		if _k_ = "poly" or _k_ = "spline"
			_cW2_ = "canvas :: onCanvas(" + _cP_ + ")"
			_nV_ = This._Prop(paShape[3], "n", 3)
			_nKept_ = 0
			for _v_ = 1 to _nV_
				_x_ = This._Sym(_cP_ + ".x" + _v_)
				_y_ = This._Sym(_cP_ + ".y" + _v_)
				if This._MentionsUnknown(_x_)
					@aConstraints + [ "onCanvas", _M_ + "-" + _x_, _cW2_, FALSE ]
					@aConstraints + [ "onCanvas", _x_ + "-" + _W_, _cW2_, FALSE ]
					_nKept_++
				ok
				if This._MentionsUnknown(_y_)
					@aConstraints + [ "onCanvas", _M_ + "-" + _y_, _cW2_, FALSE ]
					@aConstraints + [ "onCanvas", _y_ + "-" + _H_, _cW2_, FALSE ]
					_nKept_++
				ok
			next
			if _nKept_ = 0  This._StaticOnCanvas(paShape)  ok
			return
		ok
		_g_ = This._Geo(_cP_)
		_bLbl_ = FALSE
		if _k_ = "text"
			_bLbl_ = (This._UnknownIndex(_cP_ + ".cx") > 0 or This._UnknownIndex(_cP_ + ".cy") > 0)
		ok
		_cW_ = "canvas :: onCanvas(" + _cP_ + ")"
		if _k_ = "line"
			# both ends on the paper
			_nKept_ = 0
			for _e_ = 4 to 7
				if NOT This._MentionsUnknown(_g_[_e_])  loop  ok
				_lim_ = _W_
				if _e_ = 5 or _e_ = 7  _lim_ = _H_  ok
				@aConstraints + [ "onCanvas", _M_ + "-" + _g_[_e_], _cW_, _bLbl_ ]
				@aConstraints + [ "onCanvas", _g_[_e_] + "-" + _lim_, _cW_, _bLbl_ ]
				_nKept_++
			next
			if _nKept_ = 0  This._StaticOnCanvas(paShape)  ok
			return
		ok
		if _k_ = "circle"
			_hx_ = _g_[4]
			_hy_ = _g_[4]
		else
			_hx_ = "(" + _g_[4] + ")/2"
			_hy_ = "(" + _g_[5] + ")/2"
		ok
		_nKept_ = 0
		if This._MentionsUnknown(_g_[2]) or This._MentionsUnknown(_hx_)
			@aConstraints + [ "onCanvas", _M_ + "+" + _hx_ + "-" + _g_[2], _cW_, _bLbl_ ]
			@aConstraints + [ "onCanvas", _g_[2] + "+" + _hx_ + "-" + _W_, _cW_, _bLbl_ ]
			_nKept_++
		ok
		if This._MentionsUnknown(_g_[3]) or This._MentionsUnknown(_hy_)
			@aConstraints + [ "onCanvas", _M_ + "+" + _hy_ + "-" + _g_[3], _cW_, _bLbl_ ]
			@aConstraints + [ "onCanvas", _g_[3] + "+" + _hy_ + "-" + _H_, _cW_, _bLbl_ ]
			_nKept_++
		ok
		if _nKept_ = 0  This._StaticOnCanvas(paShape)  ok

	# THE ON-CANVAS CHECK FOR GEOMETRY NO TAPE MOVES: the shape's extent
	# is read as numbers and held to the paper less the margin; how far it
	# is out is recorded as a violation the readers report with the rest.
	# Only a breach is recorded -- five thousand satisfied entries would be
	# a list every reader walks for nothing.
	def _StaticOnCanvas(paShape)
		_cP_ = paShape[1]
		_k_ = paShape[2]
		_nM_ = @oStyle.Margin()
		_W_ = @oStyle.CanvasWidth() - _nM_
		_H_ = @oStyle.CanvasHeight() - _nM_
		_aX_ = []  _aY_ = []
		if _k_ = "poly" or _k_ = "spline"
			_nV_ = This._Prop(paShape[3], "n", 0)
			for _v_ = 1 to _nV_
				_aX_ + This._V(_cP_ + ".x" + _v_)
				_aY_ + This._V(_cP_ + ".y" + _v_)
			next
		but _k_ = "line"
			_aX_ + This._V(_cP_ + ".x1")  _aX_ + This._V(_cP_ + ".x2")
			_aY_ + This._V(_cP_ + ".y1")  _aY_ + This._V(_cP_ + ".y2")
		else
			_cx_ = This._V(_cP_ + ".cx")
			_cy_ = This._V(_cP_ + ".cy")
			if _k_ = "circle"
				_hx_ = This._V(_cP_ + ".r")
				_hy_ = _hx_
			but _k_ = "ellipse"
				_hx_ = This._V(_cP_ + ".rx")
				_hy_ = This._V(_cP_ + ".ry")
			but _k_ = "text"
				_aM_ = This._TextSize(_cP_)
				_hx_ = _aM_[1] / 2
				_hy_ = (_aM_[2] + _aM_[3]) / 2
			else
				_hx_ = This._V(_cP_ + ".w") / 2
				_hy_ = This._V(_cP_ + ".h") / 2
			ok
			_aX_ + (_cx_ - _hx_)  _aX_ + (_cx_ + _hx_)
			_aY_ + (_cy_ - _hy_)  _aY_ + (_cy_ + _hy_)
		ok
		_v_ = 0
		for _i_ = 1 to len(_aX_)
			if _nM_ - _aX_[_i_] > _v_  _v_ = _nM_ - _aX_[_i_]  ok
			if _aX_[_i_] - _W_ > _v_  _v_ = _aX_[_i_] - _W_  ok
		next
		for _i_ = 1 to len(_aY_)
			if _nM_ - _aY_[_i_] > _v_  _v_ = _nM_ - _aY_[_i_]  ok
			if _aY_[_i_] - _H_ > _v_  _v_ = _aY_[_i_] - _H_  ok
		next
		if _v_ > 0.01
			@aStaticViolations + [ "onCanvas", "canvas :: onCanvas(" + _cP_ + ")", _v_, FALSE ]
		ok

	# every geometric name of a shape is a constant -- nothing the solver
	# owns, nothing derived that could reach an unknown
	def _AllConst(paShape)
		_cP_ = paShape[1]
		_acG_ = This._GeoNames(paShape)
		for _i_ = 1 to len(_acG_)
			if NOT This._HasConst(_cP_ + "." + _acG_[_i_])  return FALSE  ok
		next
		return TRUE

	# the geometric property names a shape of this kind owns
	def _GeoNames(paShape)
		_k_ = paShape[2]
		if _k_ = "circle"  return [ "cx", "cy", "r" ]  ok
		if _k_ = "rect"  return [ "cx", "cy", "w", "h" ]  ok
		if _k_ = "ellipse"  return [ "cx", "cy", "rx", "ry" ]  ok
		if _k_ = "line"  return [ "x1", "y1", "x2", "y2" ]  ok
		if _k_ = "text"  return [ "cx", "cy" ]  ok
		if _k_ = "poly" or _k_ = "spline"
			_ac_ = []
			_nV_ = This._Prop(paShape[3], "n", 0)
			for _v_ = 1 to _nV_
				_ac_ + ("x" + _v_)
				_ac_ + ("y" + _v_)
			next
			return _ac_
		ok
		return []

	# does tape text mention a tape variable? A variable is u followed by
	# a digit, and no function on the tape has a u in its name -- sqrt,
	# abs, min, max, sin, cos, exp, log -- so the first u decides.
	def _MentionsUnknown(pcTape)
		_c_ = "" + pcTape
		_p_ = StzFindFirst("u", _c_)
		if _p_ = 0 or _p_ >= len(_c_)  return FALSE  ok
		_a_ = ascii(_c_[_p_ + 1])
		return _a_ >= 48 and _a_ <= 57

	#-- SOLVE: exterior point over the engine's L-BFGS, joint then labels --

	def _Solve()
		# with nothing to solve nothing moved, and what the compile already
		# read of the constants stays read
		if len(@acUnknown) > 0  @aVCache = []  ok
		@nRounds = 0
		@nEvaluations = 0
		@nEnergy = 0
		@aViolations = []
		_n_ = len(@acUnknown)
		if _n_ = 0
			@cWhy = "nothing to lay out -- no rule minted an unknown"
			This._CompileViolationTapes()
			This._ReadViolations()
			This._FreeViolationTapes()
			return
		ok
		_bAnyLabel_ = FALSE
		for _i_ = 1 to _n_
			if @bLabelVar[_i_] = 1  _bAnyLabel_ = TRUE  ok
		next
		This._CompileViolationTapes()
		# THE STARTS, IN ORDER, FIRST LAWFUL WINS. A style that names none
		# gets one random start, as before. The tapes are compiled once and
		# every start re-solves from its own overlay; how many were needed
		# is a reported figure, because a picture that took three starts
		# is a picture whose first two starts were wrong.
		_aStarts_ = @oStyle.Starts()
		if len(_aStarts_) = 0  _aStarts_ = [ "random" ]  ok
		# a named start the graph cannot give -- planar on a tree -- is
		# SKIPPED, not replaced by random, so the next named start is
		# offered; random is the last resort whether named or not
		_bRandom_ = FALSE
		for _s_ = 1 to len(_aStarts_)
			if _aStarts_[_s_] = "random"  _bRandom_ = TRUE  ok
		next
		if NOT _bRandom_  _aStarts_ + "random"  ok
		@nStartsTried = 0
		for _s_ = 1 to len(_aStarts_)
			This._Initialise(_aStarts_[_s_])
			if _aStarts_[_s_] != "random" and @cStartUsed = "random"  loop  ok
			@nStartsTried++
			This._SolveStage(0)
			if _bAnyLabel_ and (@oStyle.LabelsAfter() or This._StageViolation(1) > 0.01)
				This._SolveStage(1)
			ok
			This._ReadViolations()
			if This._MaxViolation() <= 0.01  exit  ok
		next
		This._FreeViolationTapes()
		@aVCache = []
		@bInkCached = FALSE
		_v_ = This._MaxViolation()
		if _v_ <= 0.01
			@cWhy = "every constraint is satisfied after " + @nRounds +
				" penalty round(s) and " + @nEvaluations + " evaluations"
			if @nAdvisoryUnmet > 0
				@cWhy += " -- from a " + @cStartUsed + " start, so the crossing rule was " +
					"advice, and " + @nAdvisoryUnmet + " crossing rule(s) are unmet"
			ok
		else
			@cWhy = "the picture is NOT lawful: the worst constraint is violated " +
				"by " + _v_ + "px after " + @nRounds + " round(s) -- the substance " +
				"may be contradictory, which is a finding rather than a failure"
		ok

	# Uniform over the canvas, as Penrose samples; radii and sizes from a
	# band that gives the solver room. Three draws, the one with the least
	# initial energy kept -- Penrose 4.2.1.
	# How many starts the last layout needed, and which one it kept. A
	# start the graph could not give -- a planar one on a tree, a layout
	# on a substance with no graph -- falls back to random and says so.
	def StartsTried()
		This.Layout()
		return @nStartsTried

	# Crossing rules left unmet when the start was not planar and the rule
	# was therefore advice: zero for a planar start, and for any picture
	# that has no crossing rule.
	def AdvisoryUnmet()
		This.Layout()
		return @nAdvisoryUnmet

	def StartUsed()
		This.Layout()
		return @cStartUsed

	def _Initialise(pcMode)
		_n_ = len(@acUnknown)
		_W_ = @oStyle.CanvasWidth()
		_H_ = @oStyle.CanvasHeight()
		_cE_ = This._EnergyText(0, 1000, TRUE)
		_p_ = ""
		if _cE_ != ""  _p_ = StzEngineGradCompile(_cE_, This._VarsText())  ok
		_aBest_ = []
		_nBest_ = 0
		# THE NAME OF EACH TAPE SLOT, looked up by slot and not by position:
		# after a delete the name map is SHORTER than the tape, because a
		# deleted shape's slots stay allocated and merely lose their names.
		# Indexing the map by slot walked off its end the first time a word
		# cloud re-minted a text at a larger size.
		_acBySlot_ = []
		for _i_ = 1 to _n_
			_acBySlot_ + ""
		next
		_m_ = len(@aUnknownOf)
		for _k_ = 1 to _m_
			_acBySlot_[@aUnknownOf[_k_][2]] = @aUnknownOf[_k_][1]
		next
		SeedRandom(@nSeed)
		# the planar positions, once, if the style asked for them and the
		# graph gives them: [ [ object, x, y ], ... ] or []
		_aPl_ = []
		_aDecl_ = @oStyle.PlanarStart()
		_cMode_ = StzLower("" + pcMode)
		if len(_aDecl_) = 3 and _cMode_ != "random"
			if _cMode_ = "planar"
				_aPl_ = This._PlanarPositions(_aDecl_[1], _aDecl_[3])
			else
				_aPl_ = This._LayoutPositions(_cMode_, _aDecl_[1], _aDecl_[3])
			ok
		ok
		@bPlanarStarted = (_cMode_ = "planar" and len(_aPl_) > 0)
		@cStartUsed = "random"
		if len(_aPl_) > 0  @cStartUsed = _cMode_  ok
		for _try_ = 1 to 3
			_aX_ = []
			for _i_ = 1 to _n_
				_cN_ = StzLower(_acBySlot_[_i_])
				_c3_ = StzRight(_cN_, 3)
				_aR_ = This._InitRangeOf(_acBySlot_[_i_])
				if len(_aR_) = 2
					_aX_ + (_aR_[1] + StzRandom01() * (_aR_[2] - _aR_[1]))
				but _c3_ = ".cx" or _c3_ = ".x1" or _c3_ = ".x2"
					_aX_ + (0.15 * _W_ + StzRandom01() * 0.7 * _W_)
				but _c3_ = ".cy" or _c3_ = ".y1" or _c3_ = ".y2"
					_aX_ + (0.15 * _H_ + StzRandom01() * 0.7 * _H_)
				but StzRight(_cN_, 2) = ".r"
					_aX_ + (30 + StzRandom01() * 90)
				else
					_aX_ + (40 + StzRandom01() * 120)
				ok
			next
			# A CONTAINED NAME STARTS AT ITS CONTAINER'S CENTRE. Started at
			# random, a formula that had to sit inside an icon and off the
			# icon's name stopped straddling the icon's edge: the only path to
			# the room below ran through the name's penalty, and a local
			# optimiser does not cross a hill. The same principle as the
			# planar start, for a label: choose the basin by structure.
			@aValue = _aX_
			@aVCache = []
			for _c_ = 1 to len(@aConstraints)
				if StzLower(@aConstraints[_c_][1]) != "contains" or len(@aConstraints[_c_]) < 5  loop  ok
				_aA_ = @aConstraints[_c_][5]
				if len(_aA_) < 2  loop  ok
				_cThing_ = "" + _aA_[2]
				# a NAME, and only a name: a shape started on its container's
				# centre is a subset drawn concentric with its superset, and
				# seven sets that begin on one point have no direction to
				# separate in -- the whole Euler family fell over on it
				if This._KindOf(_cThing_) != "text"  loop  ok
				_ix_ = This._UnknownIndex(_cThing_ + ".cx")
				_iy_ = This._UnknownIndex(_cThing_ + ".cy")
				if _ix_ = 0 or _iy_ = 0  loop  ok
				_aC_ = This._CentreOf("" + _aA_[1])
				if len(_aC_) = 2
					_aX_[_ix_] = _aC_[1]
					_aX_[_iy_] = _aC_[2]
				ok
			next
			@aVCache = []
			# overlay the planar start on the vertex centres -- and put each
			# vertex's name beside it, so the names begin where they belong
			_m_ = len(_aPl_)
			for _k_ = 1 to _m_
				_cO_ = _aPl_[_k_][1]
				_ix_ = This._UnknownIndex(_cO_ + "." + _aDecl_[2] + ".cx")
				_iy_ = This._UnknownIndex(_cO_ + "." + _aDecl_[2] + ".cy")
				if _ix_ > 0  _aX_[_ix_] = _aPl_[_k_][2]  ok
				if _iy_ > 0  _aX_[_iy_] = _aPl_[_k_][3]  ok
				if _aDecl_[2] != "text"
					# in a RANDOM direction: a name cannot cross an edge once
					# the stage runs, so which wedge it starts in is decided
					# here -- and the three tries above, which keep the lowest
					# initial energy, become a multi-start for the names
					_ix_ = This._UnknownIndex(_cO_ + ".text.cx")
					_iy_ = This._UnknownIndex(_cO_ + ".text.cy")
					_th_ = StzRandom01() * 6.28318530717959
					if _ix_ > 0  _aX_[_ix_] = _aPl_[_k_][2] + 24 * cos(_th_)  ok
					if _iy_ > 0  _aX_[_iy_] = _aPl_[_k_][3] + 24 * sin(_th_)  ok
				ok
			next
			_v_ = 0
			if _p_ != ""
				_r_ = StzEngineGradValueAt(_p_, _aX_)
				if isNumber(_r_)  _v_ = _r_  ok
			ok
			if _try_ = 1 or _v_ < _nBest_
				_nBest_ = _v_
				_aBest_ = _aX_
			ok
		next
		if _p_ != ""  StzEngineGradFree(_p_)  ok
		@aValue = _aBest_

	# Did the last layout begin from a planar embedding? False when the
	# style asked for none, and false when it asked and the graph could not
	# give one -- a tree, a path, anything Tutte collapses.
	def StartedPlanar()
		This.Layout()
		return @bPlanarStarted

	# The face the planar start was built on, as object names in cycle
	# order; empty when there was no planar start.
	def OuterFace()
		This.Layout()
		return @acOuterFace

	#-- A LAYOUT AS A START: the graph plane's engines on the substance --

	# The vertices of the named type and the edges its constructors define,
	# as a stzGraph the graph plane's canvas lays out in the mode asked
	# for; the positions come back in the canvas's frame, inside the
	# margin. Built directly from the substance rather than through
	# ToGraph, because a reified relation -- a SameRank between two
	# elements, say -- would otherwise become a node and a rank the layout
	# would honour, and a Hasse diagram's rows would bend to it. A drawing
	# that collapses two vertices within four pixels is refused, and the
	# next start stands.
	def _LayoutPositions(pcMode, pcType, pacCtors)
		_acV_ = @oSubstance.ObjectsOfType(pcType)
		_n_ = len(_acV_)
		if _n_ < 2  return []  ok
		_oG_ = new stzGraph("start")
		for _i_ = 1 to _n_
			_oG_.AddNodeXTT(_acV_[_i_], "", [ :name = _acV_[_i_] ])
		next
		_aDefs_ = @oSubstance.Definitions()
		_nE_ = 0
		for _d_ = 1 to len(_aDefs_)
			_bC_ = FALSE
			for _c_ = 1 to len(pacCtors)
				if StzLower("" + pacCtors[_c_]) = StzLower(_aDefs_[_d_][2])  _bC_ = TRUE  ok
			next
			if NOT _bC_ or len(_aDefs_[_d_][3]) != 2  loop  ok
			_a_ = _aDefs_[_d_][3][1]
			_b_ = _aDefs_[_d_][3][2]
			if StzLower(_a_) = StzLower(_b_)  loop  ok
			if NOT _oG_.NodeExists(_a_) or NOT _oG_.NodeExists(_b_)  loop  ok
			if _oG_.EdgeExists(_a_, _b_) or _oG_.EdgeExists(_b_, _a_)  loop  ok
			_oG_.AddEdge(_a_, _b_)
			_nE_++
		next
		if _nE_ = 0  return []  ok
		_nM_ = @oStyle.Margin()
		_W_ = @oStyle.CanvasWidth() - 2 * _nM_
		_H_ = @oStyle.CanvasHeight() - 2 * _nM_
		_oC_ = new stzGraphCanvas(_oG_, [ :Layout = pcMode, :Width = _W_, :Height = _H_ ])
		_aP_ = _oC_.Positions()
		_a_ = []
		for _i_ = 1 to len(_aP_)
			_cN_ = "" + _oG_.Node(_aP_[_i_][1])[:properties][:name]
			_a_ + [ _cN_, _nM_ + _aP_[_i_][2], _nM_ + _aP_[_i_][3] ]
		next
		for _i_ = 1 to len(_a_)
			for _j_ = _i_ + 1 to len(_a_)
				if pow(_a_[_i_][2] - _a_[_j_][2], 2) + pow(_a_[_i_][3] - _a_[_j_][3], 2) < 16
					return []
				ok
			next
		next
		return _a_

	#-- THE PLANAR START: Tutte's embedding from a face found by its shape --

	# TUTTE, 1963: fix the vertices of one face on a convex polygon and put
	# every other vertex at the barycentre of its neighbours, and for a
	# 3-connected planar graph the result is a planar drawing. The face is
	# found without a planarity test, from the property that characterises
	# it in such a graph: a cycle that is CHORDLESS and NON-SEPARATING. The
	# shortest such cycle through any edge is taken. The barycentres are
	# reached by relaxation -- four hundred sweeps of Gauss-Seidel on the
	# Laplacian with the face as its boundary -- which is exact enough for
	# a start and needs no linear algebra. A drawing that collapses (two
	# vertices closer than four pixels: a tree, a graph with a cut vertex)
	# is refused, and the random start stands.
	def _PlanarPositions(pcType, pacCtors)
		@acOuterFace = []
		_acV_ = @oSubstance.ObjectsOfType(pcType)
		_n_ = len(_acV_)
		if _n_ < 3  return []  ok
		_aAdj_ = []
		for _i_ = 1 to _n_
			_aAdj_ + []
		next
		_aDefs_ = @oSubstance.Definitions()
		for _d_ = 1 to len(_aDefs_)
			_bC_ = FALSE
			for _c_ = 1 to len(pacCtors)
				if StzLower("" + pacCtors[_c_]) = StzLower(_aDefs_[_d_][2])  _bC_ = TRUE  ok
			next
			if NOT _bC_ or len(_aDefs_[_d_][3]) != 2  loop  ok
			_u_ = This._IndexIn(_acV_, _aDefs_[_d_][3][1])
			_v_ = This._IndexIn(_acV_, _aDefs_[_d_][3][2])
			if _u_ = 0 or _v_ = 0 or _u_ = _v_  loop  ok
			if This._IndexIn(_aAdj_[_u_], _v_) = 0  _aAdj_[_u_] + _v_  ok
			if This._IndexIn(_aAdj_[_v_], _u_) = 0  _aAdj_[_v_] + _u_  ok
		next
		_aFace_ = This._OuterFace(_n_, _aAdj_)
		if len(_aFace_) < 3  return []  ok
		_W_ = @oStyle.CanvasWidth()
		_H_ = @oStyle.CanvasHeight()
		# the face at 36% of the paper's smaller side: room to breathe before
		# the margin, or the repulsion flattens the face onto it
		_R_ = 0.36 * _W_
		if _H_ < _W_  _R_ = 0.36 * _H_  ok
		_ax_ = []  _ay_ = []  _bFix_ = []
		for _i_ = 1 to _n_
			_ax_ + 0  _ay_ + 0  _bFix_ + FALSE
		next
		_m_ = len(_aFace_)
		for _k_ = 1 to _m_
			_th_ = 6.28318530717959 * (_k_ - 1) / _m_ - 1.5707963267949
			_ax_[_aFace_[_k_]] = _W_ / 2 + _R_ * cos(_th_)
			_ay_[_aFace_[_k_]] = _H_ / 2 + _R_ * sin(_th_)
			_bFix_[_aFace_[_k_]] = TRUE
		next
		# a vertex with no path to the face would relax to nothing: it is
		# placed at random and held there
		_aSeen_ = This._Reach(_n_, _aAdj_, _aFace_)
		for _i_ = 1 to _n_
			if NOT _aSeen_[_i_] and NOT _bFix_[_i_]
				_ax_[_i_] = 0.15 * _W_ + StzRandom01() * 0.7 * _W_
				_ay_[_i_] = 0.15 * _H_ + StzRandom01() * 0.7 * _H_
				_bFix_[_i_] = TRUE
			ok
		next
		for _i_ = 1 to _n_
			if NOT _bFix_[_i_]
				_ax_[_i_] = _W_ / 2
				_ay_[_i_] = _H_ / 2
			ok
		next
		for _sweep_ = 1 to 400
			for _i_ = 1 to _n_
				if _bFix_[_i_] or len(_aAdj_[_i_]) = 0  loop  ok
				_sx_ = 0  _sy_ = 0
				_d_ = len(_aAdj_[_i_])
				for _j_ = 1 to _d_
					_sx_ += _ax_[_aAdj_[_i_][_j_]]
					_sy_ += _ay_[_aAdj_[_i_][_j_]]
				next
				_ax_[_i_] = _sx_ / _d_
				_ay_[_i_] = _sy_ / _d_
			next
		next
		for _i_ = 1 to _n_
			for _j_ = _i_ + 1 to _n_
				if pow(_ax_[_i_] - _ax_[_j_], 2) + pow(_ay_[_i_] - _ay_[_j_], 2) < 16
					return []
				ok
			next
		next
		for _k_ = 1 to _m_
			@acOuterFace + _acV_[_aFace_[_k_]]
		next
		_a_ = []
		for _i_ = 1 to _n_
			_a_ + [ _acV_[_i_], _ax_[_i_], _ay_[_i_] ]
		next
		return _a_

	# The shortest cycle that is chordless and non-separating, as vertex
	# indices in order: through each edge (u, v), the shortest u-v path that
	# avoids the edge closes a cycle; the shortest of those that passes both
	# tests is the face.
	def _OuterFace(pnN, paAdj)
		_best_ = []
		for _u_ = 1 to pnN
			for _q_ = 1 to len(paAdj[_u_])
				_v_ = paAdj[_u_][_q_]
				if _v_ < _u_  loop  ok
				_aP_ = This._ShortestAvoiding(pnN, paAdj, _u_, _v_)
				if len(_aP_) < 3  loop  ok
				if len(_best_) > 0 and len(_aP_) >= len(_best_)  loop  ok
				if This._Chordless(_aP_, paAdj) and This._NonSeparating(pnN, paAdj, _aP_)
					_best_ = _aP_
				ok
			next
		next
		return _best_

	# breadth-first from u to v, never crossing the edge u-v directly
	def _ShortestAvoiding(pnN, paAdj, pnU, pnV)
		_aPrev_ = []
		for _i_ = 1 to pnN
			_aPrev_ + 0
		next
		_aPrev_[pnU] = -1
		_aQ_ = [ pnU ]
		_h_ = 1
		while _h_ <= len(_aQ_)
			_x_ = _aQ_[_h_]
			_h_++
			for _k_ = 1 to len(paAdj[_x_])
				_y_ = paAdj[_x_][_k_]
				if _x_ = pnU and _y_ = pnV  loop  ok
				if _aPrev_[_y_] != 0  loop  ok
				_aPrev_[_y_] = _x_
				if _y_ = pnV
					_aP_ = []
					_z_ = pnV
					while _z_ != -1
						_aP_ + _z_
						_z_ = _aPrev_[_z_]
					end
					return _aP_
				ok
				_aQ_ + _y_
			next
		end
		return []

	def _Chordless(paCyc, paAdj)
		_m_ = len(paCyc)
		for _i_ = 1 to _m_
			for _j_ = _i_ + 2 to _m_
				if _i_ = 1 and _j_ = _m_  loop  ok
				if This._IndexIn(paAdj[paCyc[_i_]], paCyc[_j_]) > 0  return FALSE  ok
			next
		next
		return TRUE

	# does the graph stay connected with the cycle's vertices removed?
	def _NonSeparating(pnN, paAdj, paCyc)
		_aOut_ = []
		for _i_ = 1 to pnN
			_aOut_ + (This._IndexIn(paCyc, _i_) > 0)
		next
		_s_ = 0
		for _i_ = 1 to pnN
			if NOT _aOut_[_i_]  _s_ = _i_  exit  ok
		next
		if _s_ = 0  return TRUE  ok
		_aSeen_ = []
		for _i_ = 1 to pnN
			_aSeen_ + FALSE
		next
		_aSeen_[_s_] = TRUE
		_aQ_ = [ _s_ ]
		_h_ = 1
		while _h_ <= len(_aQ_)
			_x_ = _aQ_[_h_]
			_h_++
			for _k_ = 1 to len(paAdj[_x_])
				_y_ = paAdj[_x_][_k_]
				if _aOut_[_y_] or _aSeen_[_y_]  loop  ok
				_aSeen_[_y_] = TRUE
				_aQ_ + _y_
			next
		end
		for _i_ = 1 to pnN
			if NOT _aOut_[_i_] and NOT _aSeen_[_i_]  return FALSE  ok
		next
		return TRUE

	# every vertex reachable from the face, the face included
	def _Reach(pnN, paAdj, paFace)
		_aSeen_ = []
		for _i_ = 1 to pnN
			_aSeen_ + FALSE
		next
		_aQ_ = []
		for _k_ = 1 to len(paFace)
			_aSeen_[paFace[_k_]] = TRUE
			_aQ_ + paFace[_k_]
		next
		_h_ = 1
		while _h_ <= len(_aQ_)
			_x_ = _aQ_[_h_]
			_h_++
			for _k_ = 1 to len(paAdj[_x_])
				_y_ = paAdj[_x_][_k_]
				if _aSeen_[_y_]  loop  ok
				_aSeen_[_y_] = TRUE
				_aQ_ + _y_
			next
		end
		return _aSeen_

	def _IndexIn(pa, pV)
		for _i_ = 1 to len(pa)
			if pa[_i_] = pV  return _i_  ok
		next
		return 0

	# the centre of a shape at the current values: a polygon's vertex mean,
	# or a circle's, rect's or ellipse's own centre; [] for a shape with none
	def _CentreOf(pcPath)
		_k_ = This._KindOf(pcPath)
		if _k_ = "poly"
			_n_ = This._Prop(@aShapes[This._ShapeIndex(pcPath)][3], "n", 0)
			if _n_ < 1  return []  ok
			_sx_ = 0  _sy_ = 0
			for _v_ = 1 to _n_
				_sx_ += This._V(pcPath + ".x" + _v_)
				_sy_ += This._V(pcPath + ".y" + _v_)
			next
			return [ _sx_ / _n_, _sy_ / _n_ ]
		ok
		if _k_ = "circle" or _k_ = "rect" or _k_ = "ellipse"
			return [ This._V(pcPath + ".cx"), This._V(pcPath + ".cy") ]
		ok
		return []

	def _InitRangeOf(pcName)
		_n_ = len(@aInitRange)
		for _i_ = 1 to _n_
			if @aInitRange[_i_][1] = pcName  return [ @aInitRange[_i_][2], @aInitRange[_i_][3] ]  ok
		next
		return []

	def _VarsText()
		_c_ = ""
		_n_ = len(@acUnknown)
		for _i_ = 1 to _n_
			if _i_ > 1  _c_ += ","  ok
			_c_ += @acUnknown[_i_]
		next
		return _c_

	# objective + lambda * sum of max(0, g)^2, over the terms of one stage.
	# In the label stage every shape unknown is FROZEN: substituted by its
	# value, so the tape differentiates only what may still move.
	def _EnergyText(pnStage, pnLambda, pbAll)
		_c_ = ""
		_n_ = len(@aObjectives)
		for _i_ = 1 to _n_
			if pbAll or (@aObjectives[_i_][4] = (pnStage = 1))
				if _c_ != ""  _c_ += "+"  ok
				_c_ += "(" + @aObjectives[_i_][2] + ")"
			ok
		next
		_cP_ = ""
		_m_ = len(@aConstraints)
		for _i_ = 1 to _m_
			if pbAll or (@aConstraints[_i_][4] = (pnStage = 1))
				# A CROSSING RULE IS A BARRIER, AND A BARRIER NEEDS YOU INSIDE
				# IT. From a planar start it forbids leaving and is never
				# violated; from a random start it is violated everywhere and
				# a local method cannot satisfy it (25 open on the cube). So
				# it is enforced when the picture began planar, and folded
				# into the objectives as advice when it did not.
				if This._IsAdvisory(_i_)
					if _c_ != ""  _c_ += "+"  ok
					_c_ += "(" + @aConstraints[_i_][2] + ")"
					loop
				ok
				if _cP_ != ""  _cP_ += "+"  ok
				_cP_ += "max(0," + @aConstraints[_i_][2] + ")^2"
			ok
		next
		if _cP_ != ""
			if _c_ != ""  _c_ += "+"  ok
			_c_ += This._Num(pnLambda) + "*(" + _cP_ + ")"
		ok
		if _c_ = ""  return ""  ok
		if pnStage = 1  _c_ = This._Frozen(_c_, 0)  ok
		return _c_

	# Replace every unknown of the OTHER stage by its current value -- IN
	# ONE PASS, with the output gathered in chunks. The first version
	# rewrote the whole energy text once per frozen variable, building each
	# rewrite a character at a time; Ring reallocates a string on every
	# append, so that was quadratic in the text and linear in the variables
	# on top. On a graph with a half-megabyte energy and sixteen frozen
	# variables the label stage took 706 seconds. This walks the text once,
	# recognises a tape symbol where it stands, and appends to a chunk that
	# is flushed to a list every four thousand characters.
	def _Frozen(pcExpr, pnWhich)
		_n_ = len(@acUnknown)
		_acVal_ = []
		for _i_ = 1 to _n_
			if @bLabelVar[_i_] = pnWhich
				_acVal_ + This._Num(@aValue[_i_])
			else
				_acVal_ + ""
			ok
		next
		_c_ = pcExpr
		_m_ = len(_c_)
		_aOut_ = []
		_chunk_ = ""
		_i_ = 1
		while _i_ <= _m_
			_ch_ = _c_[_i_]
			if _ch_ = "u" and _i_ < _m_ and This._IsDigit(_c_[_i_ + 1]) and
			   (_i_ = 1 or NOT This._IsIdent(_c_[_i_ - 1]))
				# the digits are gathered AS THE WALK PASSES THEM. A slice of
				# the energy text is O(position) -- the engine's own trap,
				# on record since the graph plane -- and thousands of slices
				# across a megabyte is minutes, which is how the first pass
				# form still hung on the curved cube
				_j_ = _i_ + 1
				_cNum_ = ""
				while _j_ <= _m_ and This._IsDigit(_c_[_j_])
					_cNum_ += _c_[_j_]
					_j_++
				end
				_k_ = 0 + _cNum_
				if _k_ >= 1 and _k_ <= _n_ and _acVal_[_k_] != ""
					_chunk_ += _acVal_[_k_]
				else
					_chunk_ += "u" + _cNum_
				ok
				_i_ = _j_
			else
				_chunk_ += _ch_
				_i_++
			ok
			if len(_chunk_) > 4000
				_aOut_ + _chunk_
				_chunk_ = ""
			ok
		end
		if _chunk_ != ""  _aOut_ + _chunk_  ok
		_r_ = ""
		for _q_ = 1 to len(_aOut_)
			_r_ += _aOut_[_q_]
		next
		return _r_

	def _IsDigit(pc)
		_n_ = ascii(pc)
		return _n_ >= 48 and _n_ <= 57

	# Whole-symbol replace: u1 but not u12 -- a symbol ends where a
	# non-alphanumeric byte begins.
	def _ReplaceSym(pcExpr, pcSym, pcWith)
		_c_ = pcExpr
		_out_ = ""
		_n_ = len(_c_)
		_m_ = len(pcSym)
		_i_ = 1
		while _i_ <= _n_
			_bHit_ = FALSE
			if _i_ + _m_ - 1 <= _n_ and StzStringSection(_c_, _i_, _i_ + _m_ - 1) = pcSym
				_bBefore_ = (_i_ = 1) or NOT This._IsIdent(_c_[_i_ - 1])
				_bAfter_ = (_i_ + _m_ > _n_) or NOT This._IsIdent(_c_[_i_ + _m_])
				if _bBefore_ and _bAfter_  _bHit_ = TRUE  ok
			ok
			if _bHit_
				_out_ += "(" + pcWith + ")"
				_i_ += _m_
			else
				_out_ += _c_[_i_]
				_i_++
			ok
		end
		return _out_

	# STAGE 0 IS A JOINT SOLVE. Shapes-first-then-labels is the staging the
	# Penrose blog demonstrates failing, and it failed here too: a circle
	# sized without knowing its text has no room for it, and the label
	# stage inherits an infeasible problem. Every unknown moves in stage 0;
	# stage 1 only POLISHES the labels against frozen shapes.
	def _SolveStage(pnStage)
		_nLam_ = 1000
		# A PLANAR START DESERVES A STRICT SOLVER FROM ROUND ONE. At the
		# usual opening weight the objectives outrank the rules, and the
		# repulsion between Tutte's cramped inner vertices pushed them
		# through edges before the vertex-off-edge rule could hold; later
		# rounds then enforced every rule inside the crossed basin they
		# inherited. Nine crossings on a cube that began with none.
		if @bPlanarStarted  _nLam_ = 100000  ok
		_bJoint_ = (pnStage = 0)
		_bAllTerms_ = _bJoint_
		_acNames_ = []
		if _bJoint_ and @oStyle.LabelsAfter()
			# the shapes alone, over the terms that name no label: a graph's
			# names must not pull on its vertices
			_bAllTerms_ = FALSE
			_acNames_ = This._StageVars(0)
		but _bJoint_
			for _i_ = 1 to len(@acUnknown)
				_acNames_ + _i_
			next
		else
			_acNames_ = This._StageVars(1)
		ok
		if len(_acNames_) = 0  return  ok
		_cNames_ = ""
		for _i_ = 1 to len(_acNames_)
			if _i_ > 1  _cNames_ += ","  ok
			_cNames_ += @acUnknown[_acNames_[_i_]]
		next
		for _round_ = 1 to 7
			@nRounds++
			_cE_ = This._EnergyText(pnStage, _nLam_, _bAllTerms_)
			if _cE_ = ""  return  ok
			_p_ = StzEngineGradCompile(_cE_, _cNames_)
			if _p_ = ""
				stzraise("stzMathDiagram: the engine refused the energy -- " +
					StzEngineGradWhy())
			ok
			_aX_ = []
			for _i_ = 1 to len(_acNames_)
				_aX_ + @aValue[_acNames_[_i_]]
			next
			_a_ = StzEngineMinimize(_p_, _aX_, 400, 0.000001)
			StzEngineGradFree(_p_)
			if NOT isList(_a_) or len(_a_) < 5
				stzraise("stzMathDiagram: the engine refused the minimisation.")
			ok
			for _i_ = 1 to len(_acNames_)
				@aValue[_acNames_[_i_]] = _a_[5 + _i_]
			next
			@nEvaluations += _a_[4]
			@nEnergy = _a_[2]
			This._ReadViolations()
			_v_ = 0
			if _bJoint_
				_v_ = This._MaxViolation()
			else
				_v_ = This._StageViolation(1)
			ok
			if _v_ <= 0.01  return  ok
			_nLam_ *= 10
		next

	def _StageVars(pnStage)
		_a_ = []
		_n_ = len(@acUnknown)
		for _i_ = 1 to _n_
			if @bLabelVar[_i_] = pnStage  _a_ + _i_  ok
		next
		return _a_

	def _StageViolation(pnStage)
		_m_ = 0
		_n_ = len(@aViolations)
		for _i_ = 1 to _n_
			if @aViolations[_i_][4] = (pnStage = 1) and @aViolations[_i_][3] > _m_
				_m_ = @aViolations[_i_][3]
			ok
		next
		return _m_

	# The worst violation already read. PRIVATE, and _Solve must use THIS:
	# the public Violation() calls Layout(), which is what is running.
	def _MaxViolation()
		_m_ = 0
		_n_ = len(@aViolations)
		for _i_ = 1 to _n_
			if @aViolations[_i_][3] > _m_  _m_ = @aViolations[_i_][3]  ok
		next
		return _m_

	# THE TAPES ARE COMPILED ONCE PER SOLVE. They never change between
	# rounds; recompiling them every round was most of the cost.
	def _CompileViolationTapes()
		This._FreeViolationTapes()
		_cNames_ = This._VarsText()
		_n_ = len(@aConstraints)
		for _i_ = 1 to _n_
			@aViolTapes + StzEngineGradCompile(@aConstraints[_i_][2], _cNames_)
		next

	def _FreeViolationTapes()
		_n_ = len(@aViolTapes)
		for _i_ = 1 to _n_
			if @aViolTapes[_i_] != ""  StzEngineGradFree(@aViolTapes[_i_])  ok
		next
		@aViolTapes = []

	# Every constraint's g at the current values -- read from the tape,
	# not re-derived here, so the number reported is the number solved.
	def _ReadViolations()
		if len(@aViolTapes) != len(@aConstraints)  This._CompileViolationTapes()  ok
		@aViolations = []
		@nAdvisoryUnmet = 0
		_n_ = len(@aConstraints)
		for _i_ = 1 to _n_
			_v_ = 0
			if @aViolTapes[_i_] != ""
				_r_ = StzEngineGradValueAt(@aViolTapes[_i_], @aValue)
				if isNumber(_r_)  _v_ = _r_  ok
			ok
			if _v_ < 0  _v_ = 0  ok
			# advice is not a violation -- but advice left unmet is COUNTED,
			# so a picture lawful from a random start still says how many
			# crossings it carries
			if This._IsAdvisory(_i_)
				if _v_ > 0.01  @nAdvisoryUnmet++  ok
				_v_ = 0
			ok
			@aViolations + [ @aConstraints[_i_][1], @aConstraints[_i_][3], _v_,
			                 @aConstraints[_i_][4] ]
		next
		# what the compile checked in Ring on geometry no tape moves
		for _i_ = 1 to len(@aStaticViolations)
			@aViolations + @aStaticViolations[_i_]
		next

	# A crossing rule counts only when the picture began planar; from a
	# random start it is advice the solver follows as far as it can.
	def _IsAdvisory(pnI)
		if @bPlanarStarted  return FALSE  ok
		return StzLower(@aConstraints[pnI][1]) = "notcrossing"

	# The value of a name: a derived one is EVALUATED through the tape at
	# the solved values, so drawing reads exactly what the solver solved.
	# A VALUE IS REMEMBERED UNTIL THE SOLVER RUNS AGAIN. Every read of a
	# derived name compiled a tape; the one gate, asking every name of
	# every shape of every picture, spent 101 seconds on 31 pictures --
	# 46,000 compiles on the quaternion table alone. Nothing here changes
	# between two solves, so the answer is kept; a solve forgets it, and
	# so does Touch(), for a guard that moves a value by hand.
	def _V(pcName)
		_k_ = _MdKey(pcName)
		_v_ = @aVCache[_k_]
		if isNumber(_v_)  return _v_  ok
		_v_ = This._VUncached(pcName)
		@aVCache[_k_] = _v_
		return _v_

	def Touch()
		@aVCache = []
		@aRoleCache = []
		@bInkCached = FALSE
		@bDrawOrdered = FALSE
		return This

	# Every drawn stroke as a segment, [ x1, y1, x2, y2, cOwner, cPath ] --
	# what a rule that judges the picture reads, once per solve
	def Ink()
		This.Layout()
		if NOT @bInkCached
			@aInkCache = _MrInk(This)
			@bInkCached = TRUE
		ok
		return @aInkCache

	def _VUncached(pcName)
		_c_ = "" + pcName
		_e_ = This._DerivedOf(_c_)
		if _e_ != ""
			# a coordinate that IS a datum -- ":cx = d.x" -- is read as the
			# datum, without expanding an expression to find a number in it
			_e_ = ring_trim(_e_)
			_ae_ = StzSplit(_e_, ".")
			if len(_ae_) = 2 and This._IsIdentifierText(_ae_[1]) and This._IsIdentifierText(_ae_[2]) and
			   @oSubstance.HasData(_ae_[1], _ae_[2])
				return @oSubstance.DataOf(_ae_[1], _ae_[2])
			ok
			_t_ = This._Sym(_c_)
			# a derived name that expands to a bare number -- a coordinate
			# read straight off the substance's data -- needs no tape: five
			# thousand engine compiles were the draw's whole cost (DN8f)
			_b_ = _t_
			while StzLeft(_b_, 1) = "(" and StzRight(_b_, 1) = ")"
				_b_ = StzStringSection(_b_, 2, len(_b_) - 1)
			end
			if This._LooksNumeric(_b_)  return 0 + _b_  ok
			return This._EvalExpr(_t_)
		ok
		if This._HasConst(_c_)  return This._ConstOf(_c_)  ok
		_i_ = This._UnknownIndex(_c_)
		if _i_ > 0  return @aValue[_i_]  ok
		_ac_ = StzSplit(_c_, ".")
		if len(_ac_) = 3
			_aM_ = This._TextSize(_ac_[1] + "." + _ac_[2])
			if _ac_[3] = "w"  return _aM_[1]  ok
			if _ac_[3] = "h"  return _aM_[2] + _aM_[3]  ok
		ok
		return 0

	# letters, digits and underscores, starting with a letter or underscore
	def _IsIdentifierText(pc)
		_n_ = len(pc)
		if _n_ = 0  return FALSE  ok
		for _i_ = 1 to _n_
			_a_ = ascii(pc[_i_])
			_bL_ = (_a_ >= 65 and _a_ <= 90) or (_a_ >= 97 and _a_ <= 122) or _a_ = 95
			if _i_ = 1 and NOT _bL_  return FALSE  ok
			if NOT (_bL_ or (_a_ >= 48 and _a_ <= 57))  return FALSE  ok
		next
		return TRUE

	def _EvalExpr(pcTape)
		if len(@acUnknown) = 0
			_p_ = StzEngineGradCompile(pcTape, "u0")
			_aX_ = [ 0 ]
		else
			_p_ = StzEngineGradCompile(pcTape, This._VarsText())
			_aX_ = @aValue
		ok
		if _p_ = ""
			stzraise("stzMathDiagram: the engine refused '" + pcTape + "' -- " +
				StzEngineGradWhy())
		ok
		_r_ = StzEngineGradValueAt(_p_, _aX_)
		StzEngineGradFree(_p_)
		if isNumber(_r_)  return _r_  ok
		return 0
