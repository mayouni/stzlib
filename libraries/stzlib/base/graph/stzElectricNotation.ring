#==============================================================#
#  STZELECTRICNOTATION -- DN5, and the kill it was aimed at     #
#==============================================================#

/*--- THE KILL, MEASURED BEFORE BUILDING, AS THE PLAN REQUIRES.

	The plan aimed the plane's second-sharpest criterion here:

	    "a net is a HYPEREDGE (one wire, three pins), which the pair-edge
	     model must earn honestly -- junction nodes drawn as dots, or the
	     domain is faked. KILL: if nets cannot be modelled without lying
	     about the graph, the domain waits for the model to grow."

	IT DOES NOT FIRE, and the reason is that its premise is a statement
	about a DRAWING rather than about the domain. A net looks like a line
	on a schematic, so it is natural to reach for "edge" and then find
	that edges have two ends. But ask the domain's own formats what a net
	IS and none of them answers "a connection between two things":

	    SPICE      R1 n1 n2 1k
	               components NAME nets; a net is an identifier that
	               exists whether or not anything is attached to it

	    KiCad      (net (code 1) (name "GND")
	                 (node (ref R1) (pin 2))
	                 (node (ref C1) (pin 1))
	                 (node (ref U1) (pin 8)))
	               a net is an OBJECT with a name, a code, and a LIST of
	               nodes -- of any length

	    Verilog    wire [7:0] databus;
	               a net is DECLARED, with a type and a width, before
	               anything drives or reads it

	In every one of them a net is a first-class named thing that pins
	attach to. It has properties an edge cannot carry -- a name, a width,
	a class, a net type -- and it exists independently of its members. So
	modelling it as a NODE is not a workaround for a pair-edge graph; it
	is the model the domain already uses, and modelling it as an edge is
	what would have been the lie.

	The bipartite shape -- component --- net --- component -- is
	therefore faithful, and the KILL asks for exactly what falls out of
	it: junction nodes drawn as dots.

--- THE ONE THING THAT IS GENUINELY OWED, and it is a drawing rule.

	A schematic draws a junction dot only where THREE OR MORE wires meet.
	Two pins joined by one net are drawn as a plain line with no dot, and
	a dot there would state a branch that does not exist.

	So the model keeps every net as a node and the DRAWING elides the
	node when its degree is two, splicing its two edges into one wire.
	That is a rendering rule about a glyph, not a compromise in the
	graph: the net is still there, still named, still carrying its
	properties, and still answering every query. Only the dot is absent,
	because at degree two the dot would be false.

	Measured on the shipped pictures: the RC filter's four nets are two
	of degree 2 and two of degree 3, so both halves of the rule are
	exercised by the smallest useful circuit there is.

--- WHAT IT COST

	Five glyphs -- resistor, capacitor, ground, source, junction -- and
	they are the first in the table that are read as VALUES rather than
	as containers. A box with "R1" written in it is a thing called R1; a
	resistor symbol IS a resistance, and an engineer reads the component
	from the outline before reading the label. That is why this domain
	could not borrow from the other nine: no rectangle means resistor to
	anybody.
*/

func StzElectricNotation()
	_o_ = StzNotation("electric")
	if _o_.Name_() = "electric"  return _o_  ok
	_o_ = new stzNotation("electric")
	_o_.SetRankDir(:TopDown)
	_o_.SetSplines(:ortho)
	# A WIRE HAS NO DIRECTION. Current flows both ways along it depending
	# on the moment, and an arrowhead would state a direction the circuit
	# does not have.
	_o_.SetEdgesDirected(0)

	# COMPONENTS -- each read from its outline
	_o_.AddKindXT("resistor", "resistor", "white")
	_o_.AddKindXT("capacitor", "capacitor", "white")
	_o_.AddKindXT("inductor", "resistor", "white")
	_o_.AddKindXT("source", "source", "white")
	_o_.AddKindXT("ground", "ground", "white")
	_o_.AddKindXT("device", "box", "white")

	# A NET IS A NODE, and it is drawn as the dot a schematic draws at a
	# meeting of wires. Its size is a MARK's, not a cell's -- see
	# _NetIsSpliced for the degree-2 case, where no dot is drawn at all.
	_o_.AddKindXTT("net", "junction", "#333333", 0.16)

	StzRegisterNotation(_o_)
	return _o_

# THE NETS OF A CIRCUIT, with the pins each one joins. Answered from the
# graph rather than from a private table, so a net added by any route --
# the model, an import, a rule that derived one -- is a net this returns.
func StzCircuitNets(poDg)
	_r_ = []
	_aN_ = poDg.Nodes()
	_nN_ = len(_aN_)
	for _iN_ = 1 to _nN_
		if StzLower("" + poDg._NativeShapeOf(_aN_[_iN_])) != "junction"
			loop
		ok
		_id_ = StzLower("" + _aN_[_iN_][:id])
		_pins_ = []
		_aE_ = poDg.Edges()
		_nE_ = len(_aE_)
		for _iE_ = 1 to _nE_
			_f_ = StzLower("" + _aE_[_iE_][:from])
			_t_ = StzLower("" + _aE_[_iE_][:to])
			if _f_ = _id_ and _t_ != _id_  _pins_ + _t_  ok
			if _t_ = _id_ and _f_ != _id_  _pins_ + _f_  ok
		next
		_r_ + [ _id_, "" + _aN_[_iN_][:label], _pins_ ]
	next
	return _r_
