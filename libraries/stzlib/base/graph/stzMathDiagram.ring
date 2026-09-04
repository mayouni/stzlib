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
		[ :shape, "x.icon", :circle, [ :fill = "#1a1ae633", :stroke = "black",
		                               :strokeWidth = 1 ] ],
		[ :shape, "x.text", :text, [ :fill = "black" ] ],
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
		[ :shape, "x.text", :text, [ :fill = "black" ] ],
		[ :shape, "x.bounds", :circle, [ :cx = "x.text.cx", :cy = "x.text.cy",
		                                 :r = 18, :hidden = 1 ] ] ])
	_o_.ForAll("Set x; Set y", [
		[ :encourage, "notTooClose", [ "x.bounds", "y.bounds", 5 ] ] ])
	_o_.ForAllWhere("Set x; Set y", "Subset(x, y)", [
		[ :shape, "x.link", :line, [ :x1 = "x.text.cx", :y1 = "x.text.cy",
		                             :x2 = "y.text.cx", :y2 = "y.text.cy", :hidden = 1 ] ],
		[ :shape, "x.arrow", :line, [
			:x1 = "x.text.cx + 18*ux(x.link)", :y1 = "x.text.cy + 18*uy(x.link)",
			:x2 = "y.text.cx - 18*ux(x.link)", :y2 = "y.text.cy - 18*uy(x.link)",
			:stroke = "black", :strokeWidth = 3, :arrow = "end" ] ],
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
		                            :fill = "#f4f4fa", :stroke = "#c8c8d8", :strokeWidth = 1 ] ],
		[ :shape, "U.xaxis", :line, [ :x1 = "U.ox - U.axis", :y1 = "U.oy",
		                              :x2 = "U.ox + U.axis", :y2 = "U.oy",
		                              :stroke = "#8a8a9a", :strokeWidth = 1.5, :arrow = "end" ] ],
		[ :shape, "U.yaxis", :line, [ :x1 = "U.ox", :y1 = "U.oy + U.axis",
		                              :x2 = "U.ox", :y2 = "U.oy - U.axis",
		                              :stroke = "#8a8a9a", :strokeWidth = 1.5, :arrow = "end" ] ],
		[ :shape, "U.text", :text, [ :cx = "U.ox - U.axis + 12", :cy = "U.oy - U.axis + 12",
		                             :fill = "#8a8a9a" ] ],
		[ :layer, "U.xaxis", :above, "U.box" ], [ :layer, "U.yaxis", :above, "U.box" ] ])
	_o_.ForAllWhere("Vector v; VectorSpace U", "In(v, U)", [
		[ :shape, "v.arrow", :line, [ :x1 = "U.ox", :y1 = "U.oy",
		                              :stroke = "#1f4fbf", :strokeWidth = 3, :arrow = "end" ] ],
		[ :shape, "v.text", :text, [ :cx = "U.ox + 1.16*(v.arrow.x2 - U.ox)",
		                             :cy = "U.oy + 1.16*(v.arrow.y2 - U.oy)",
		                             :fill = "#1f4fbf" ] ],
		[ :ensure, "greaterThan", [ "len(v.arrow)", 70 ] ],
		[ :ensure, "lessThan", [ "len(v.arrow)", "U.axis - 10" ] ],
		[ :layer, "v.arrow", :above, "U.xaxis" ], [ :layer, "v.arrow", :above, "U.yaxis" ] ])
	_o_.ForAllWhere("Vector u; Vector v; VectorSpace U",
	                "Orthogonal(u, v); In(u, U); In(v, U)", [
		[ :ensure, "equal", [ "dot(u.arrow, v.arrow) / (len(u.arrow) * len(v.arrow))", 0 ] ],
		[ :shape, "u.mark1", :line, [
			:x1 = "U.ox + 14*ux(u.arrow)", :y1 = "U.oy + 14*uy(u.arrow)",
			:x2 = "U.ox + 14*ux(u.arrow) + 14*ux(v.arrow)",
			:y2 = "U.oy + 14*uy(u.arrow) + 14*uy(v.arrow)", :stroke = "black", :strokeWidth = 1.5 ] ],
		[ :shape, "u.mark2", :line, [
			:x1 = "U.ox + 14*ux(v.arrow)", :y1 = "U.oy + 14*uy(v.arrow)",
			:x2 = "U.ox + 14*ux(u.arrow) + 14*ux(v.arrow)",
			:y2 = "U.oy + 14*uy(u.arrow) + 14*uy(v.arrow)", :stroke = "black", :strokeWidth = 1.5 ] ] ])
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
		                                :stroke = "#9fb4e0", :strokeWidth = 1.5 ] ],
		[ :shape, "u.slider2", :line, [ :x1 = "w.arrow.x2", :y1 = "w.arrow.y2",
		                                :x2 = "u.arrow.x2", :y2 = "u.arrow.y2",
		                                :stroke = "#9fb4e0", :strokeWidth = 1.5 ] ],
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
	return _o_

# ...drawn as Euclid drew: a point is a dot with its name beside it, a
# segment is the line between its points, an angle's vertex gets a mark
# when the angle is right, equal segments wear matching ticks.
func StzEuclideanStyle()
	_o_ = new stzMathStyle()
	_o_.SetCanvas(600, 520)
	_o_.ForAll("Point p", [
		[ :shape, "p.icon", :circle, [ :r = 4, :fill = "black" ] ],
		[ :shape, "p.text", :text, [ :fill = "black" ] ],
		[ :ensure, "disjoint", [ "p.text", "p.icon", 4 ] ],
		[ :encourage, "near", [ "p.text", "p.icon", 16 ] ] ])
	_o_.ForAllWhere("Segment s; Point p; Point q", "s := Segment(p, q)", [
		[ :shape, "s.icon", :line, [ :x1 = "p.icon.cx", :y1 = "p.icon.cy",
		                             :x2 = "q.icon.cx", :y2 = "q.icon.cy",
		                             :stroke = "#333333", :strokeWidth = 2 ] ],
		[ :ensure, "greaterThan", [ "len(s.icon)", 110 ] ],
		[ :ensure, "lessThan", [ "len(s.icon)", 380 ] ],
		# a name never sits on a line -- the plane's rule from the electric
		# domain, and Penrose's disjoint(text, segment)
		[ :ensure, "disjoint", [ "p.text", "s.icon", 2 ] ],
		[ :ensure, "disjoint", [ "q.text", "s.icon", 2 ] ],
		[ :layer, "p.icon", :above, "s.icon" ], [ :layer, "q.icon", :above, "s.icon" ] ])
	_o_.ForAllWhere("Triangle t; Point p; Point q; Point r", "t := Triangle(p, q, r)", [
		[ :shape, "t.pq", :line, [ :x1 = "p.icon.cx", :y1 = "p.icon.cy",
		                           :x2 = "q.icon.cx", :y2 = "q.icon.cy", :stroke = "#333333", :strokeWidth = 2 ] ],
		[ :shape, "t.qr", :line, [ :x1 = "q.icon.cx", :y1 = "q.icon.cy",
		                           :x2 = "r.icon.cx", :y2 = "r.icon.cy", :stroke = "#333333", :strokeWidth = 2 ] ],
		[ :shape, "t.pr", :line, [ :x1 = "p.icon.cx", :y1 = "p.icon.cy",
		                           :x2 = "r.icon.cx", :y2 = "r.icon.cy", :stroke = "#333333", :strokeWidth = 2 ] ],
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
		[ :shape, "a.mark1", :line, [
			:x1 = "q.icon.cx + 16*ux(a.arm1)", :y1 = "q.icon.cy + 16*uy(a.arm1)",
			:x2 = "q.icon.cx + 16*ux(a.arm1) + 16*ux(a.arm2)",
			:y2 = "q.icon.cy + 16*uy(a.arm1) + 16*uy(a.arm2)", :stroke = "#333333", :strokeWidth = 1.5 ] ],
		[ :shape, "a.mark2", :line, [
			:x1 = "q.icon.cx + 16*ux(a.arm2)", :y1 = "q.icon.cy + 16*uy(a.arm2)",
			:x2 = "q.icon.cx + 16*ux(a.arm1) + 16*ux(a.arm2)",
			:y2 = "q.icon.cy + 16*uy(a.arm1) + 16*uy(a.arm2)", :stroke = "#333333", :strokeWidth = 1.5 ] ] ])
	_o_.ForAllWhere("Segment s; Segment t", "EqualLength(s, t)", [
		[ :ensure, "equal", [ "len(s.icon)", "len(t.icon)" ] ],
		[ :shape, "s.tick", :line, [ :x1 = "midx(s.icon) - 7*nx(s.icon)", :y1 = "midy(s.icon) - 7*ny(s.icon)",
		                             :x2 = "midx(s.icon) + 7*nx(s.icon)", :y2 = "midy(s.icon) + 7*ny(s.icon)",
		                             :stroke = "#333333", :strokeWidth = 2 ] ],
		[ :shape, "t.tick", :line, [ :x1 = "midx(t.icon) - 7*nx(t.icon)", :y1 = "midy(t.icon) - 7*ny(t.icon)",
		                             :x2 = "midx(t.icon) + 7*nx(t.icon)", :y2 = "midy(t.icon) + 7*ny(t.icon)",
		                             :stroke = "#333333", :strokeWidth = 2 ] ] ])
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
		                                 :fill = "#f4f4fa", :stroke = "#c8c8d8", :strokeWidth = 1 ] ],
		[ :shape, "p.icon", :circle, [ :cx = "300 + 210*p.sx", :cy = "260 - 210*p.sy",
		                               :r = 4, :fill = "black" ] ],
		[ :shape, "p.text", :text, [ :fill = "black" ] ],
		[ :ensure, "equal", [ "100*(p.sx^2 + p.sy^2 + p.sz^2)", 100 ] ],
		[ :ensure, "greaterThan", [ "100*p.sz", 30 ] ],
		[ :ensure, "disjoint", [ "p.text", "p.icon", 4 ] ],
		[ :encourage, "near", [ "p.text", "p.icon", 16 ] ],
		[ :layer, "p.icon", :above, "_.sphere" ] ])
	_o_.ForAllWhere("Segment s; Point p; Point q", "s := Segment(p, q)", [
		[ :field, "s.cosd", "p.sx*q.sx + p.sy*q.sy + p.sz*q.sz" ],
		[ :shape, "s.icon", :curve, [ :curve = "greatarc",
		    :x1 = "p.sx", :y1 = "p.sy", :z1 = "p.sz", :x2 = "q.sx", :y2 = "q.sy", :z2 = "q.sz",
		    :cx = 300, :cy = 260, :r = 210, :stroke = "#333333", :strokeWidth = 2 ] ],
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
		    :stroke = "#333333", :strokeWidth = 2 ] ],
		[ :shape, "t.qr", :curve, [ :curve = "greatarc", :x1 = "q.sx", :y1 = "q.sy", :z1 = "q.sz",
		    :x2 = "r.sx", :y2 = "r.sy", :z2 = "r.sz", :cx = 300, :cy = 260, :r = 210,
		    :stroke = "#333333", :strokeWidth = 2 ] ],
		[ :shape, "t.pr", :curve, [ :curve = "greatarc", :x1 = "p.sx", :y1 = "p.sy", :z1 = "p.sz",
		    :x2 = "r.sx", :y2 = "r.sy", :z2 = "r.sz", :cx = 300, :cy = 260, :r = 210,
		    :stroke = "#333333", :strokeWidth = 2 ] ],
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
		[ :ensure, "equal", [ "100*(a.t1x*a.t2x + a.t1y*a.t2y + a.t1z*a.t2z) / (sqrt(a.t1x^2 + a.t1y^2 + a.t1z^2 + 0.000001) * sqrt(a.t2x^2 + a.t2y^2 + a.t2z^2 + 0.000001))", 0 ] ] ])
	_o_.ForAllWhere("Segment s; Segment t", "EqualLength(s, t)", [
		[ :ensure, "equal", [ "100*s.cosd", "100*t.cosd" ] ] ])
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
		                               :fill = "#f4f4fa", :stroke = "#c8c8d8", :strokeWidth = 1 ] ],
		[ :shape, "p.icon", :circle, [ :cx = "300 + 220*p.hx", :cy = "260 - 220*p.hy",
		                               :r = 4, :fill = "black" ] ],
		[ :shape, "p.text", :text, [ :fill = "black" ] ],
		[ :ensure, "lessThan", [ "100*(p.hx^2 + p.hy^2)", 64 ] ],
		[ :ensure, "disjoint", [ "p.text", "p.icon", 4 ] ],
		[ :encourage, "near", [ "p.text", "p.icon", 16 ] ],
		[ :layer, "p.icon", :above, "_.disk" ] ])
	_o_.ForAllWhere("Segment s; Point p; Point q", "s := Segment(p, q)", [
		[ :field, "s.delta", "((p.hx - q.hx)^2 + (p.hy - q.hy)^2) / ((1 - p.hx^2 - p.hy^2) * (1 - q.hx^2 - q.hy^2))" ],
		[ :shape, "s.icon", :curve, [ :curve = "poincare",
		    :x1 = "p.hx", :y1 = "p.hy", :z1 = 0, :x2 = "q.hx", :y2 = "q.hy", :z2 = 0,
		    :cx = 300, :cy = 260, :r = 220, :stroke = "#333333", :strokeWidth = 2 ] ],
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
		    :stroke = "#333333", :strokeWidth = 2 ] ],
		[ :shape, "t.qr", :curve, [ :curve = "poincare", :x1 = "q.hx", :y1 = "q.hy", :z1 = 0,
		    :x2 = "r.hx", :y2 = "r.hy", :z2 = 0, :cx = 300, :cy = 260, :r = 220,
		    :stroke = "#333333", :strokeWidth = 2 ] ],
		[ :shape, "t.pr", :curve, [ :curve = "poincare", :x1 = "p.hx", :y1 = "p.hy", :z1 = 0,
		    :x2 = "r.hx", :y2 = "r.hy", :z2 = 0, :cx = 300, :cy = 260, :r = 220,
		    :stroke = "#333333", :strokeWidth = 2 ] ],
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
		[ :ensure, "equal", [ "100*(a.v1x*a.v2x + a.v1y*a.v2y) / (sqrt(a.v1x^2 + a.v1y^2 + 0.000001) * sqrt(a.v2x^2 + a.v2y^2 + 0.000001))", 0 ] ] ])
	_o_.ForAllWhere("Segment s; Segment t", "EqualLength(s, t)", [
		[ :ensure, "equal", [ "100*s.delta", "100*t.delta" ] ] ])
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
	return "contains, disjoint, overlapping, touching, lessThan, " +
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
	@bAutoLabel = 0

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
		if This.HasObject(_n_)
			stzraise("stzMathSubstance.Declare: '" + _n_ + "' is declared twice.")
		ok
		@aObjects + [ _n_, _t_ ]
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
		_c_ = ring_trim("" + pcName)
		_n_ = len(@aObjects)
		for _i_ = 1 to _n_
			if @aObjects[_i_][1] = _c_  return @aObjects[_i_][2]  ok
		next
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
		return This

		def DefineQ(pcName, pcFunction, pacArgs)
			return This.Define(pcName, pcFunction, pacArgs)

	def Definitions()
		return @aDefinitions

	# Is pcName defined as pcFunction over exactly these objects, in order?
	def IsDefinedAs(pcName, pcFunction, pacArgs)
		_c_ = ring_trim("" + pcName)
		_f_ = StzLower(ring_trim("" + pcFunction))
		_n_ = len(@aDefinitions)
		for _i_ = 1 to _n_
			if @aDefinitions[_i_][1] = _c_ and
			   StzLower(@aDefinitions[_i_][2]) = _f_ and
			   This._SameArgs(@aDefinitions[_i_][3], pacArgs)
				return TRUE
			ok
		next
		return FALSE

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
		_c_ = ring_trim("" + pcName)
		_n_ = len(@aObjects)
		for _i_ = 1 to _n_
			if @aObjects[_i_][1] = _c_  return @aObjects[_i_][1]  ok
		next
		return ""

#---------------------------------------------------------------------#
#  THE STYLE                                                           #
#---------------------------------------------------------------------#

class stzMathStyle from stzObject

	@nW = 800
	@nH = 700
	@aRules = []        # [ [ cSelector, cWhere, aRows ] ]

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
	#   [ :shape,     "x.icon", :circle | :rect | :text | :line, [ props ] ]
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
		if NOT isList(paRow) or len(paRow) < 3
			stzraise("stzMathStyle: row " + pnAt + " is not a rule row.")
		ok
		_k_ = "" + paRow[1]
		if _k_ = "shape"
			_kind_ = "" + paRow[3]
			if _kind_ != "circle" and _kind_ != "rect" and _kind_ != "text" and
			   _kind_ != "line" and _kind_ != "curve"
				stzraise("stzMathStyle: '" + _kind_ + "' is not a shape DN7 " +
					"draws -- circle, rect, text, line or curve.")
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
		but _s_[2] = "line"
			return [ :kind = "line", :x1 = This._V(_cP_ + ".x1"),
			         :y1 = This._V(_cP_ + ".y1"), :x2 = This._V(_cP_ + ".x2"),
			         :y2 = This._V(_cP_ + ".y2") ]
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

	#-- drawing ------------------------------------------------------------------

	def ToCanvas()
		This.Layout()
		_oC_ = new stzCanvas(@oStyle.CanvasWidth(), @oStyle.CanvasHeight())
		_oC_.SetBackground("white")
		if isObject(@oFont)  _oC_.SetFont(@oFont, @nFontSize)  ok
		_aOrder_ = This._DrawOrder()
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
		_cFill_ = This._Prop(_aProps_, "fill", "")
		_cStroke_ = This._Prop(_aProps_, "stroke", "")
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
		but _cKind_ = "text"
			if NOT isObject(@oFont)  return  ok
			_cT_ = This._Prop(_aProps_, "string", "")
			if _cT_ = ""  return  ok
			_aM_ = This._TextSize(_cP_)
			# centred on (cx, cy): the baseline sits below the centre by half
			# the ink height, measured from the font rather than guessed
			_x_ = This._V(_cP_ + ".cx") - _aM_[1] / 2
			_y_ = This._V(_cP_ + ".cy") + (_aM_[2] - _aM_[3]) / 2
			poC.AddText(_cT_, _x_, _y_)
			if _cFill_ != ""  poC.Fill(_cFill_)  else  poC.Fill("black")  ok
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

	def _SvgIdOf(pcPath)
		# "A.icon" -> "A" for the shape called icon, "A_text" otherwise
		_ac_ = StzSplit(pcPath, ".")
		if len(_ac_) < 2  return pcPath  ok
		if _ac_[2] = "icon"  return _ac_[1]  ok
		return _ac_[1] + "_" + _ac_[2]

	# Layering as Penrose does it: "x.text above x.icon" is a partial order,
	# resolved to a z per shape by relaxation. Ties keep creation order,
	# and text rides above everything unlayered, as a reader expects.
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
		@aShapes = []  @acUnknown = []  @aUnknownOf = []  @aValue = []
		@bLabelVar = []  @aConst = []  @aDerived = []  @aInitRange = []
		@aConstraints = []  @aObjectives = []  @aLayers = []  @aTextSize = []
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
		_aIdx_ = []
		for _i_ = 1 to _nV_
			_aIdx_ + 1
		next
		if _nV_ = 0  return _aOut_  ok
		for _i_ = 1 to _nV_
			if len(_aCands_[_i_]) = 0  return _aOut_  ok
		next
		_nGuard_ = 0
		while TRUE
			_nGuard_++
			if _nGuard_ > 400000  exit  ok
			_aAsg_ = []
			_bInj_ = TRUE
			for _i_ = 1 to _nV_
				_cO_ = _aCands_[_i_][_aIdx_[_i_]]
				for _j_ = 1 to len(_aAsg_)
					if _aAsg_[_j_] = _cO_  _bInj_ = FALSE  ok
				next
				_aAsg_ + _cO_
			next
			if _bInj_ and This._WhereHolds(paVars, _aAsg_, paWhere) and
			   NOT This._Seen(_aOut_, _aAsg_, paWhere)
				_aOut_ + _aAsg_
			ok
			_k_ = _nV_
			while _k_ >= 1
				_aIdx_[_k_]++
				if _aIdx_[_k_] <= len(_aCands_[_k_])  exit  ok
				_aIdx_[_k_] = 1
				_k_--
			end
			if _k_ < 1  exit  ok
		end
		return _aOut_

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
			else
				_a_ + _p_
			ok
		next
		return _a_

	def _IsGeometric(pcKey)
		_k_ = StzLower(pcKey)
		return _k_ = "cx" or _k_ = "cy" or _k_ = "r" or _k_ = "w" or _k_ = "h" or
		       _k_ = "x1" or _k_ = "y1" or _k_ = "x2" or _k_ = "y2" or
		       _k_ = "z1" or _k_ = "z2"

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
		_acGeo_ = []
		if pcKind = "circle"
			_acGeo_ = [ "cx", "cy", "r" ]
		but pcKind = "rect"
			_acGeo_ = [ "cx", "cy", "w", "h" ]
		but pcKind = "line"
			_acGeo_ = [ "x1", "y1", "x2", "y2" ]
		but pcKind = "curve"
			# a geodesic: its ends in the model's own coordinates, and the
			# projection it is drawn through. Nothing here is solved -- a
			# curve is DERIVED from its points, and constraints speak to
			# the points, never to the drawn arc.
			_acGeo_ = [ "x1", "y1", "z1", "x2", "y2", "z2", "cx", "cy", "r" ]
		but pcKind = "text"
			_acGeo_ = [ "cx", "cy" ]
			_aM_ = This._MeasureText(This._Prop(_aP_, "string", ""))
			@aTextSize + [ pcPath, _aM_[1], _aM_[2], _aM_[3] ]
		ok
		_bLbl_ = 0
		if pcKind = "text"  _bLbl_ = 1  ok
		_n_ = len(_acGeo_)
		for _i_ = 1 to _n_
			_cName_ = pcPath + "." + _acGeo_[_i_]
			_v_ = This._Prop(_aP_, _acGeo_[_i_], "")
			if isNumber(_v_)
				@aConst + [ _cName_, _v_ ]
			but isString(_v_) and ring_trim(_v_) != ""
				@aDerived + [ _cName_, _v_ ]
			else
				This._Unknown(_cName_, _bLbl_)
			ok
		next

	def _SetField(pcName, pValue)
		if isNumber(pValue)
			This._DropName(pcName)
			@aConst + [ pcName, pValue ]
		else
			This._DropName(pcName)
			@aDerived + [ pcName, "" + pValue ]
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

	def _HasConst(pcName)
		_c_ = "" + pcName
		for _i_ = 1 to len(@aConst)
			if @aConst[_i_][1] = _c_  return TRUE  ok
		next
		return FALSE

	def _ConstOf(pcName)
		_c_ = "" + pcName
		for _i_ = 1 to len(@aConst)
			if @aConst[_i_][1] = _c_  return @aConst[_i_][2]  ok
		next
		return 0

	def _HasDerived(pcName)
		return This._DerivedOf(pcName) != ""

	def _DerivedOf(pcName)
		_c_ = "" + pcName
		for _i_ = 1 to len(@aDerived)
			if @aDerived[_i_][1] = _c_  return @aDerived[_i_][2]  ok
		next
		return ""

	def _Unknown(pcName, pbLabel)
		_i_ = len(@acUnknown) + 1
		@acUnknown + ("u" + _i_)
		@aUnknownOf + [ pcName, _i_ ]
		@aValue + 0
		@bLabelVar + pbLabel

	def _UnknownIndex(pcName)
		_c_ = "" + pcName
		_n_ = len(@aUnknownOf)
		for _i_ = 1 to _n_
			if @aUnknownOf[_i_][1] = _c_  return @aUnknownOf[_i_][2]  ok
		next
		return 0

	def _ShapeIndex(pcPath)
		_c_ = "" + pcPath
		_n_ = len(@aShapes)
		for _i_ = 1 to _n_
			if @aShapes[_i_][1] = _c_  return _i_  ok
		next
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
		if pcText = ""  return [ 0, 0, 0 ]  ok
		if isObject(@oFont)
			_w_ = @oFont.WidthOf(pcText, @nFontSize)
			_m_ = @oFont.MetricsOf(pcText, @nFontSize)
			return [ _w_, _m_[1], _m_[2] ]
		ok
		return [ 0.6 * @nFontSize * len(pcText), 0.75 * @nFontSize, 0.25 * @nFontSize ]

	def _TextSize(pcPath)
		_c_ = "" + pcPath
		_n_ = len(@aTextSize)
		for _i_ = 1 to _n_
			if @aTextSize[_i_][1] = _c_
				return [ @aTextSize[_i_][2], @aTextSize[_i_][3], @aTextSize[_i_][4] ]
			ok
		next
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
		_cP_ = "" + (1 / 3)
		_nDot_ = StzFindFirst(".", _cP_)
		_nD_ = 0
		if _nDot_ > 0  _nD_ = len(_cP_) - _nDot_  ok
		decimals(12)
		_c_ = "" + pn
		decimals(_nD_)
		return _c_

	# circle: [ "circle", cx, cy, r ]   rect/text: [ "rect", cx, cy, w, h ]
	# line: [ "line", mx, my, x1, y1, x2, y2 ] -- its centre is its midpoint
	def _Geo(pcPath)
		_c_ = ring_trim("" + pcPath)
		_k_ = This._KindOf(_c_)
		if _k_ = ""
			stzraise("stzMathDiagram: '" + _c_ + "' is not a shape any rule minted.")
		ok
		if _k_ = "curve"
			stzraise("stzMathDiagram: '" + _c_ + "' is a curve -- a geodesic is " +
				"drawn from its points, and a constraint speaks to the points.")
		ok
		if _k_ = "circle"
			return [ "circle", This._Sym(_c_ + ".cx"), This._Sym(_c_ + ".cy"),
			         This._Sym(_c_ + ".r") ]
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

	def _AddTerm(pcVerb, pcFn, paArgs, pcWhere)
		_f_ = StzLower(pcFn)
		_bLbl_ = FALSE
		for _i_ = 1 to len(paArgs)
			if This._MentionsLabel(paArgs[_i_])  _bLbl_ = TRUE  ok
		next
		_cE_ = This._Energy(_f_, paArgs, pcVerb)
		_cW_ = pcWhere + " :: " + pcFn + "(" + This._ArgsText(paArgs) + ")"
		if pcVerb = "ensure"
			@aConstraints + [ pcFn, _cE_, _cW_, _bLbl_ ]
		else
			@aObjectives + [ pcFn, _cE_, _cW_, _bLbl_ ]
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
				_r_ = _s_[4]
				if _s_[1] = "rect"  _r_ = This._HalfDiag(_s_)  ok
				_dx_ = "(" + _l_[6] + "-" + _l_[4] + ")"
				_dy_ = "(" + _l_[7] + "-" + _l_[5] + ")"
				_t_ = "max(0,min(1,((" + _s_[2] + "-" + _l_[4] + ")*" + _dx_ + "+(" +
				      _s_[3] + "-" + _l_[5] + ")*" + _dy_ + ")/(" + _dx_ + "^2+" + _dy_ +
				      "^2+0.000001)))"
				_nd_ = "sqrt((" + _l_[4] + "+" + _t_ + "*" + _dx_ + "-" + _s_[2] + ")^2+(" +
				       _l_[5] + "+" + _t_ + "*" + _dy_ + "-" + _s_[3] + ")^2)"
				return "(" + _r_ + "+" + _p_ + ")-" + _nd_
			ok
			if _a_[1] = "circle" and _b_[1] = "circle"
				return "(" + _a_[4] + "+" + _b_[4] + "+" + _p_ + ")-" + This._Dist(_a_, _b_)
			but _a_[1] = "rect" and _b_[1] = "rect"
				_ox_ = "((" + _a_[4] + "+" + _b_[4] + ")/2+" + _p_ + ")-abs(" + _a_[2] + "-" + _b_[2] + ")"
				_oy_ = "((" + _a_[5] + "+" + _b_[5] + ")/2+" + _p_ + ")-abs(" + _a_[3] + "-" + _b_[3] + ")"
				return "min(" + _ox_ + "," + _oy_ + ")"
			else
				_ra_ = _a_[4]
				if _a_[1] = "rect"  _ra_ = This._HalfDiag(_a_)  ok
				_rb_ = _b_[4]
				if _b_[1] = "rect"  _rb_ = This._HalfDiag(_b_)  ok
				return "(" + _ra_ + "+" + _rb_ + "+" + _p_ + ")-" + This._Dist(_a_, _b_)
			ok

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
		if _k_ = "curve"  return  ok
		_g_ = This._Geo(_cP_)
		_W_ = This._Num(@oStyle.CanvasWidth())
		_H_ = This._Num(@oStyle.CanvasHeight())
		_bLbl_ = FALSE
		if _k_ = "text"
			_bLbl_ = (This._UnknownIndex(_cP_ + ".cx") > 0 or This._UnknownIndex(_cP_ + ".cy") > 0)
		ok
		_cW_ = "canvas :: onCanvas(" + _cP_ + ")"
		if _k_ = "line"
			# both ends on the paper
			@aConstraints + [ "onCanvas", "0-" + _g_[4], _cW_, _bLbl_ ]
			@aConstraints + [ "onCanvas", _g_[4] + "-" + _W_, _cW_, _bLbl_ ]
			@aConstraints + [ "onCanvas", "0-" + _g_[5], _cW_, _bLbl_ ]
			@aConstraints + [ "onCanvas", _g_[5] + "-" + _H_, _cW_, _bLbl_ ]
			@aConstraints + [ "onCanvas", "0-" + _g_[6], _cW_, _bLbl_ ]
			@aConstraints + [ "onCanvas", _g_[6] + "-" + _W_, _cW_, _bLbl_ ]
			@aConstraints + [ "onCanvas", "0-" + _g_[7], _cW_, _bLbl_ ]
			@aConstraints + [ "onCanvas", _g_[7] + "-" + _H_, _cW_, _bLbl_ ]
			return
		ok
		if _k_ = "circle"
			_hx_ = _g_[4]
			_hy_ = _g_[4]
		else
			_hx_ = "(" + _g_[4] + ")/2"
			_hy_ = "(" + _g_[5] + ")/2"
		ok
		@aConstraints + [ "onCanvas", _hx_ + "-" + _g_[2], _cW_, _bLbl_ ]
		@aConstraints + [ "onCanvas", _g_[2] + "+" + _hx_ + "-" + _W_, _cW_, _bLbl_ ]
		@aConstraints + [ "onCanvas", _hy_ + "-" + _g_[3], _cW_, _bLbl_ ]
		@aConstraints + [ "onCanvas", _g_[3] + "+" + _hy_ + "-" + _H_, _cW_, _bLbl_ ]

	#-- SOLVE: exterior point over the engine's L-BFGS, joint then labels --

	def _Solve()
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
		This._Initialise()
		_bAnyLabel_ = FALSE
		for _i_ = 1 to _n_
			if @bLabelVar[_i_] = 1  _bAnyLabel_ = TRUE  ok
		next
		This._CompileViolationTapes()
		This._SolveStage(0)
		if _bAnyLabel_ and This._StageViolation(1) > 0.01  This._SolveStage(1)  ok
		This._ReadViolations()
		This._FreeViolationTapes()
		_v_ = This._MaxViolation()
		if _v_ <= 0.01
			@cWhy = "every constraint is satisfied after " + @nRounds +
				" penalty round(s) and " + @nEvaluations + " evaluations"
		else
			@cWhy = "the picture is NOT lawful: the worst constraint is violated " +
				"by " + _v_ + "px after " + @nRounds + " round(s) -- the substance " +
				"may be contradictory, which is a finding rather than a failure"
		ok

	# Uniform over the canvas, as Penrose samples; radii and sizes from a
	# band that gives the solver room. Three draws, the one with the least
	# initial energy kept -- Penrose 4.2.1.
	def _Initialise()
		_n_ = len(@acUnknown)
		_W_ = @oStyle.CanvasWidth()
		_H_ = @oStyle.CanvasHeight()
		_cE_ = This._EnergyText(0, 1000, TRUE)
		_p_ = ""
		if _cE_ != ""  _p_ = StzEngineGradCompile(_cE_, This._VarsText())  ok
		_aBest_ = []
		_nBest_ = 0
		SeedRandom(@nSeed)
		for _try_ = 1 to 3
			_aX_ = []
			for _i_ = 1 to _n_
				_cN_ = StzLower(@aUnknownOf[_i_][1])
				_c3_ = StzRight(_cN_, 3)
				_aR_ = This._InitRangeOf(@aUnknownOf[_i_][1])
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

	# Replace every unknown of the OTHER stage by its current value.
	def _Frozen(pcExpr, pnWhich)
		_c_ = pcExpr
		_n_ = len(@acUnknown)
		for _i_ = _n_ to 1 step -1
			if @bLabelVar[_i_] = pnWhich
				_c_ = This._ReplaceSym(_c_, @acUnknown[_i_], This._Num(@aValue[_i_]))
			ok
		next
		return _c_

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
		_bJoint_ = (pnStage = 0)
		_acNames_ = []
		if _bJoint_
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
			_cE_ = This._EnergyText(pnStage, _nLam_, _bJoint_)
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
		_n_ = len(@aConstraints)
		for _i_ = 1 to _n_
			_v_ = 0
			if @aViolTapes[_i_] != ""
				_r_ = StzEngineGradValueAt(@aViolTapes[_i_], @aValue)
				if isNumber(_r_)  _v_ = _r_  ok
			ok
			if _v_ < 0  _v_ = 0  ok
			@aViolations + [ @aConstraints[_i_][1], @aConstraints[_i_][3], _v_,
			                 @aConstraints[_i_][4] ]
		next

	# The value of a name: a derived one is EVALUATED through the tape at
	# the solved values, so drawing reads exactly what the solver solved.
	def _V(pcName)
		_c_ = "" + pcName
		if This._HasDerived(_c_)
			return This._EvalExpr(This._Sym(_c_))
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
