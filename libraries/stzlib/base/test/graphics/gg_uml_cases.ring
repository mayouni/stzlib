load "../../stzBase.ring"

/*---------------------------------------------------------------------------
	UML CLASS DIAGRAMS -- DN4

	The domain with no model behind it. A class diagram IS a graph:
	classes are nodes, relationships are edges, and everything that makes
	it UML rather than a box-and-line drawing is NOTATION. So this whole
	domain is one profile over the one foundation, which is DN0's claim
	tested at its strongest.

	WHAT THE PICTURES ARE MEANT TO SHOW:

	  1. a hierarchy -- and the line is IDENTICAL in all three of
	     inheritance, composition and aggregation. The shape at its end
	     is the entire difference, which is why an adornment is not
	     decoration.
	  2. an interface and its implementors -- realization, drawn dashed
	     with the same hollow triangle, because "implements" is a kind of
	     "is a kind of" and UML says so with the same glyph.
	  3. a dependency -- dashed, and the only relationship here that says
	     nothing about structure. It says "this one breaks if that one
	     changes", which is a different KIND of claim.

	Run:  ring gg_uml_cases.ring
---------------------------------------------------------------------------*/

decimals(2)
FONT = new stzFont("C:/Windows/Fonts/segoeui.ttf")
OPT = [ :Font = FONT, :NodeWidth = 140, :NodeHeight = 52, :FontSize = 14 ]

? "=============================================================="
? " UML CLASS DIAGRAMS, UNDER THEIR OWN NOTATION"
? "=============================================================="

#-- 1. A SHAPE HIERARCHY ----------------------------------------------------
#   Three relationships, three meanings, one line. Shape is generalised
#   by Circle and Polygon; a Polygon is COMPOSED of Points, which die
#   with it; and Shape DEPENDS on Logger, which is not structure at all.
o1 = new stzDiagram("shapes")
o1.SetNotation(StzUmlNotation())
o1.AddNodeXTT("shape", "Shape", [ :type = "abstract",
	:attributes = [ "# origin : Point" ],
	:operations = [ "+ area() : Real", "+ move(Point)" ] ])
o1.AddNodeXTT("circle", "Circle", [ :type = "class",
	:attributes = [ "- radius : Real" ],
	:operations = [ "+ area() : Real" ] ])
o1.AddNodeXTT("poly", "Polygon", [ :type = "class",
	:attributes = [ "- vertices : Point[]" ],
	:operations = [ "+ area() : Real" ] ])
o1.AddNodeXTT("pt", "Point", [ :type = "datatype",
	:attributes = [ "- x : Real", "- y : Real" ] ])
o1.AddNodeXTT("log", "Logger", [ :type = "class",
	:operations = [ "+ log(String)" ] ])
o1.AddEdgeXTT("shape", "circle", "", [ :uml = :Inheritance ])
o1.AddEdgeXTT("shape", "poly", "", [ :uml = :Inheritance ])
o1.AddEdgeXTT("poly", "pt", "", [ :uml = :Composition ])
o1.AddEdgeXTT("shape", "log", "", [ :uml = :Dependency ])
o1.ToCanvasXT(OPT)
o1.LastCanvas().ToPNG("uml_1_shapes.png")
? "  1. a shape hierarchy   " + o1.LastCanvas().Width() + "x" +
  o1.LastCanvas().Height()

#-- 2. AN INTERFACE AND ITS IMPLEMENTORS ------------------------------------
#   Realization is drawn with the SAME hollow triangle as inheritance,
#   on a dashed line -- because "implements" is a kind of "is a kind of",
#   and the notation says the family with the glyph and the difference
#   with the stroke.
o2 = new stzDiagram("ports")
o2.SetNotation(StzUmlNotation())
o2.AddNodeXTT("store", "<<interface>> Store", [ :type = "interface",
	:operations = [ "+ put(Key, Value)", "+ get(Key) : Value" ] ])
o2.AddNodeXTT("mem", "MemoryStore", [ :type = "class",
	:attributes = [ "- map : Hash" ],
	:operations = [ "+ put(Key, Value)", "+ get(Key) : Value" ] ])
o2.AddNodeXTT("disk", "DiskStore", [ :type = "class",
	:attributes = [ "- path : String" ],
	:operations = [ "+ put(Key, Value)", "+ get(Key) : Value" ] ])
o2.AddNodeXTT("cache", "CacheStore", [ :type = "class",
	:operations = [ "+ put(Key, Value)", "+ get(Key) : Value" ] ])
o2.AddEdgeXTT("store", "mem", "", [ :uml = :Realization ])
o2.AddEdgeXTT("store", "disk", "", [ :uml = :Realization ])
o2.AddEdgeXTT("store", "cache", "", [ :uml = :Realization ])
o2.ToCanvasXT(OPT)
o2.LastCanvas().ToPNG("uml_2_interface.png")
? "  2. an interface        " + o2.LastCanvas().Width() + "x" +
  o2.LastCanvas().Height()

#-- 3. WHOLE AND PART, THE TWO KINDS ----------------------------------------
#   The one picture where the difference between the two diamonds is the
#   entire content. An Order OWNS its lines -- delete the order and they
#   are gone, so the diamond is filled. A Basket merely HOLDS products,
#   which outlive it, so the diamond is hollow. Same line, same
#   direction, opposite lifetimes.
o3 = new stzDiagram("orders")
o3.SetNotation(StzUmlNotation())
o3.AddNodeXTT("order", "Order", [ :type = "class",
	:attributes = [ "- placed : Date" ],
	:operations = [ "+ total() : Money" ] ])
o3.AddNodeXTT("line", "OrderLine", [ :type = "class",
	:attributes = [ "- qty : Int" ] ])
o3.AddNodeXTT("basket", "Basket", [ :type = "class",
	:operations = [ "+ add(Product)" ] ])
o3.AddNodeXTT("prod", "Product", [ :type = "class",
	:attributes = [ "- sku : String", "- price : Money" ] ])
o3.AddEdgeXTT("order", "line", "", [ :uml = :Composition ])
o3.AddEdgeXTT("basket", "prod", "", [ :uml = :Aggregation ])
o3.AddEdgeXTT("line", "prod", "", [ :uml = :Association ])
o3.ToCanvasXT(OPT)
o3.LastCanvas().ToPNG("uml_3_wholepart.png")
? "  3. whole and part      " + o3.LastCanvas().Width() + "x" +
  o3.LastCanvas().Height()

? ""
? "wrote uml_1..uml_3"
