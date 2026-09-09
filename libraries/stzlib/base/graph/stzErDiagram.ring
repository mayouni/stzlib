#=====================================================================#
#  STZERDIAGRAM -- DN15: an entity-relationship diagram is a schema   #
#  with a picture, and its rules are about KEYS                        #
#=====================================================================#
/*
	THE THIRD NEW DOMAIN, and the one whose first consumer is already in
	the estate: stzzql keeps schemas, and a schema is what this draws.

	It lives on the GRAPH plane beside the UML class diagram, its closest
	sibling: an entity is a box with a name band and a compartment of
	attributes -- the glyph the class diagram already draws -- and a
	relationship is a line between two entities whose ENDS carry the
	cardinality, in the crow's-foot notation every database tool speaks:
	a bar across the line for "one", three lines fanning into the entity
	for "many". A relation has no arrowhead at all; a schema has no
	direction the way a flow has, and a head would claim one.

	WHAT IT IS HERE:

	    NOTATION   "er": entity (a box with attributes), junction (the
	               same box, drawn for a many-to-many), note (a comment
	               that is NOT an entity -- the boundary every rule is
	               stood on). Open, like UML's, since a schema may carry
	               a kind this file does not know.

	    DIAGRAM    stzErDiagram from stzDiagram: AddEntity, AddKey,
	               AddAttribute, AddForeignKey, Relate(from, to, kind)
	               with kind one of :OneToMany, :ManyToOne, :OneToOne,
	               :ManyToMany. Attributes are shown prefixed PK and FK,
	               the way a schema reads them.

	    RULES      three, into the one report through GovernanceFindings
	               like the org chart's, each reading the diagram's own
	               projection onto a plain graph:

	               entity_has_key         every entity declares a primary
	                                      key
	               foreign_key_resolves   every foreign key names an
	                                      entity of this diagram
	               relation_backed_by_key a one-to-many is backed by a
	                                      foreign key on the many side, a
	                                      one-to-one by one on either, a
	                                      many-to-many by an entity holding
	                                      keys to both -- the junction

	               participation_matches_nullability
	                                      an end declared optional is backed
	                                      by a nullable foreign key, an end
	                                      declared mandatory by one that is
	                                      not

	    PARTICIPATION  RelateXT(from, to, kind, [ :from = :Optional,
	               :to = :Mandatory ]) says, per end, whether the entity at
	               that end must take part -- "an order always has a
	               customer" is Mandatory at the customer end, "a customer
	               may have no order" is Optional at the order end. Drawn
	               inside the cardinality as the crow's foot does: a second
	               bar for at-least-one, a ring for possibly-none. An end
	               that declares nothing draws nothing more. Where the
	               relation is backed by a foreign key, the declaration at
	               the key's target end is a claim about that column --
	               AddForeignKeyXT(..., [ :Nullable = 1 ]) -- and the fourth
	               rule holds the two to each other.

	WHAT IS SAID PLAINLY: weak entities, inheritance and Chen's diamonds
	are not here; participation at the MANY end says nothing a column can
	contradict and is drawn only. Days of the Gantt were numbers; the keys
	here are names, and a name is checked by name.
*/

# the two participations, as the words the author writes
func StzErParticipations()
	return [ "optional", "mandatory" ]

#---------------------------------------------------------------------#
#  THE NOTATION                                                        #
#---------------------------------------------------------------------#

func StzErNotation()
	_o_ = StzNotation("er")
	if _o_.Name_() = "er"  return _o_  ok
	_o_ = new stzNotation("er")
	# A SCHEMA READS ACROSS: the tables a reader traces first are the
	# ones a row travels between, and a left-to-right layout keeps the
	# attribute compartments tall and the relations short
	_o_.SetRankDir(:LeftToRight)
	_o_.SetSplines(:ortho)
	# NO ARROWHEADS. A relation carries its meaning at its ends, and a
	# head would claim a direction a schema does not have.
	_o_.SetEdgesDirected(0)
	_o_.AddKindXT("entity", "box", "white")
	_o_.AddKindXT("junction", "box", "white")
	_o_.AddKindXT("note", "note", "white")
	StzRegisterNotation(_o_)
	return _o_

# the four cardinalities, as the words the author writes
func StzErRelationKinds()
	return [ "onetomany", "manytoone", "onetoone", "manytomany" ]

#---------------------------------------------------------------------#
#  THE RULES                                                           #
#---------------------------------------------------------------------#

func StzErRuleSetQ()
	return new stzErRuleSet()

# TRUE when entity pcE holds a foreign key naming pcTarget
func _ErHasFkTo(oGraph, pcE, pcTarget)
	_aF_ = oGraph.NodeProperty(pcE, "fks")
	if NOT isList(_aF_)  return FALSE  ok
	for _i_ = 1 to len(_aF_)
		if StzLower("" + _aF_[_i_][2]) = StzLower("" + pcTarget)  return TRUE  ok
	next
	return FALSE

# the foreign-key row [ column, target, nullable ] of pcE naming pcTarget,
# or [] -- the reader for a rule that must know the column's nullability
func _ErFkTo(oGraph, pcE, pcTarget)
	_aF_ = oGraph.NodeProperty(pcE, "fks")
	if NOT isList(_aF_)  return []  ok
	for _i_ = 1 to len(_aF_)
		if StzLower("" + _aF_[_i_][2]) = StzLower("" + pcTarget)  return _aF_[_i_]  ok
	next
	return []

func _ErIsEntity(oGraph, pcId)
	return StzLower("" + oGraph.NodeProperty(pcId, "kind")) = "entity"

func _StzAddErRules(poSet)

	# ENTITY HAS KEY. A table without a primary key cannot be referred to,
	# and a diagram is a set of references.
	_o1_ = new stzErRule("entity_has_key")
	_o1_.SetSeverityQ("error")
	_o1_.SetMessageQ("every entity declares a primary key")
	_o1_.SetOrderQ(10)
	_o1_.SetReadsQ([ "node.keys" ])
	_o1_.GovernsQ(func oGraph {
		_r_ = []
		_a_ = oGraph.NodesIds()
		for _i_ = 1 to len(_a_)
			if _ErIsEntity(oGraph, _a_[_i_])  _r_ + ("entity:" + StzLower("" + _a_[_i_]))  ok
		next
		return _r_
	})
	# a note is a node and not an entity: it has no key and owes none
	_o1_.ExcludesQ(func oGraph {
		_r_ = []
		_a_ = oGraph.NodesIds()
		for _i_ = 1 to len(_a_)
			if NOT _ErIsEntity(oGraph, _a_[_i_])  _r_ + ("note:" + StzLower("" + _a_[_i_]))  ok
		next
		return _r_
	})
	_o1_.UseCheckerQ(func oGraph {
		_aOut_ = []
		_a_ = oGraph.NodesIds()
		for _i_ = 1 to len(_a_)
			if NOT _ErIsEntity(oGraph, _a_[_i_])  loop  ok
			_aK_ = oGraph.NodeProperty(_a_[_i_], "keys")
			if NOT isList(_aK_) or len(_aK_) = 0
				_aOut_ + [ :where = _a_[_i_], :message = "entity '" +
					oGraph.NodeProperty(_a_[_i_], "name") + "' has no primary key" ]
			ok
		next
		return _aOut_
	})
	poSet.AddRule(_o1_)

	# FOREIGN KEY RESOLVES. A foreign key names an entity; one that names
	# nothing in the diagram is a typo or a table that was never drawn.
	_o2_ = new stzErRule("foreign_key_resolves")
	_o2_.SetSeverityQ("error")
	_o2_.SetMessageQ("every foreign key names an entity of this diagram")
	_o2_.SetOrderQ(11)
	_o2_.SetReadsQ([ "node.fks" ])
	_o2_.GovernsQ(func oGraph {
		_r_ = []
		_a_ = oGraph.NodesIds()
		for _i_ = 1 to len(_a_)
			if NOT _ErIsEntity(oGraph, _a_[_i_])  loop  ok
			_aF_ = oGraph.NodeProperty(_a_[_i_], "fks")
			if isList(_aF_) and len(_aF_) > 0  _r_ + ("entity:" + StzLower("" + _a_[_i_]))  ok
		next
		return _r_
	})
	# an entity with no foreign key can resolve none: outside the rule,
	# not passing it -- and a note, which is not an entity at all
	_o2_.ExcludesQ(func oGraph {
		_r_ = []
		_a_ = oGraph.NodesIds()
		for _i_ = 1 to len(_a_)
			if NOT _ErIsEntity(oGraph, _a_[_i_])
				_r_ + ("note:" + StzLower("" + _a_[_i_]))
				loop
			ok
			_aF_ = oGraph.NodeProperty(_a_[_i_], "fks")
			if NOT isList(_aF_) or len(_aF_) = 0  _r_ + ("entity:" + StzLower("" + _a_[_i_]))  ok
		next
		return _r_
	})
	_o2_.UseCheckerQ(func oGraph {
		_aOut_ = []
		_a_ = oGraph.NodesIds()
		for _i_ = 1 to len(_a_)
			if NOT _ErIsEntity(oGraph, _a_[_i_])  loop  ok
			_aF_ = oGraph.NodeProperty(_a_[_i_], "fks")
			if NOT isList(_aF_)  loop  ok
			for _k_ = 1 to len(_aF_)
				_cT_ = "" + _aF_[_k_][2]
				if NOT oGraph.NodeExists(_cT_) or NOT _ErIsEntity(oGraph, _cT_)
					_aOut_ + [ :where = _a_[_i_], :message = "'" +
						oGraph.NodeProperty(_a_[_i_], "name") + "." + _aF_[_k_][1] +
						"' refers to '" + _cT_ + "', which is not an entity of this diagram" ]
				ok
			next
		next
		return _aOut_
	})
	poSet.AddRule(_o2_)

	# RELATION BACKED BY KEY. A line between two entities is a claim that
	# a key in one refers to the other; the schema must hold that key.
	_o3_ = new stzErRule("relation_backed_by_key")
	_o3_.SetSeverityQ("warning")
	_o3_.SetMessageQ("every relation is backed by a foreign key: on the many side, on either " +
		"side of a one-to-one, or on a junction for a many-to-many")
	_o3_.SetOrderQ(20)
	_o3_.SetReadsQ([ "edge.type", "node.fks" ])
	_o3_.GovernsQ(func oGraph {
		_r_ = []
		_aE_ = oGraph.Edges()
		for _i_ = 1 to len(_aE_)
			_r_ + ("relation:" + StzLower("" + _aE_[_i_][:from]) + ">" + StzLower("" + _aE_[_i_][:to]))
		next
		return _r_
	})
	# a node that is not an entity is joined by no relation this rule
	# reads; it is the boundary
	_o3_.ExcludesQ(func oGraph {
		_r_ = []
		_a_ = oGraph.NodesIds()
		for _i_ = 1 to len(_a_)
			if NOT _ErIsEntity(oGraph, _a_[_i_])  _r_ + ("note:" + StzLower("" + _a_[_i_]))  ok
		next
		return _r_
	})
	_o3_.UseCheckerQ(func oGraph {
		_aOut_ = []
		_aE_ = oGraph.Edges()
		for _i_ = 1 to len(_aE_)
			_cA_ = "" + _aE_[_i_][:from]
			_cB_ = "" + _aE_[_i_][:to]
			_cK_ = StzLower("" + oGraph.EdgeProperty(_cA_, _cB_, "type"))
			_cNa_ = "" + oGraph.NodeProperty(_cA_, "name")
			_cNb_ = "" + oGraph.NodeProperty(_cB_, "name")
			if _cK_ = "onetomany"
				if NOT _ErHasFkTo(oGraph, _cB_, _cA_)
					_aOut_ + [ :where = _cA_ + ">" + _cB_, :message = "'" + _cNb_ +
						"' is the many side of '" + _cNa_ + "' and holds no foreign key to it" ]
				ok
			but _cK_ = "manytoone"
				if NOT _ErHasFkTo(oGraph, _cA_, _cB_)
					_aOut_ + [ :where = _cA_ + ">" + _cB_, :message = "'" + _cNa_ +
						"' is the many side of '" + _cNb_ + "' and holds no foreign key to it" ]
				ok
			but _cK_ = "onetoone"
				if NOT _ErHasFkTo(oGraph, _cA_, _cB_) and NOT _ErHasFkTo(oGraph, _cB_, _cA_)
					_aOut_ + [ :where = _cA_ + ">" + _cB_, :message = "'" + _cNa_ + "' and '" +
						_cNb_ + "' are one to one and neither holds a foreign key to the other" ]
				ok
			but _cK_ = "manytomany"
				_bJ_ = FALSE
				_aN_ = oGraph.NodesIds()
				for _j_ = 1 to len(_aN_)
					if _ErHasFkTo(oGraph, _aN_[_j_], _cA_) and _ErHasFkTo(oGraph, _aN_[_j_], _cB_)
						_bJ_ = TRUE
					ok
				next
				if NOT _bJ_
					_aOut_ + [ :where = _cA_ + ">" + _cB_, :message = "'" + _cNa_ + "' and '" +
						_cNb_ + "' are many to many and no entity holds keys to both -- " +
						"a junction is owed" ]
				ok
			ok
		next
		return _aOut_
	})
	poSet.AddRule(_o3_)

	# PARTICIPATION MATCHES NULLABILITY. "An order always has a customer"
	# is a mark on a line and a NOT NULL on a column, and the two are one
	# claim made twice. Where a relation is backed by a foreign key, the
	# participation declared at the key's TARGET end is held to the
	# column: optional wants nullable, mandatory wants not.
	_o4_ = new stzErRule("participation_matches_nullability")
	_o4_.SetSeverityQ("warning")
	_o4_.SetMessageQ("participation declared at a foreign key's target end agrees with " +
		"the column's nullability")
	_o4_.SetOrderQ(30)
	_o4_.SetReadsQ([ "edge.type", "edge.frompart", "edge.topart", "node.fks" ])
	_o4_.GovernsQ(func oGraph {
		_r_ = []
		_aE_ = oGraph.Edges()
		for _i_ = 1 to len(_aE_)
			_aB_ = _ErParticipationBacking(oGraph, "" + _aE_[_i_][:from], "" + _aE_[_i_][:to])
			if len(_aB_) > 0
				_r_ + ("relation:" + StzLower("" + _aE_[_i_][:from]) + ">" + StzLower("" + _aE_[_i_][:to]))
			ok
		next
		return _r_
	})
	# THE BOUNDARY, in three parts: a relation that declares nothing at the
	# key's target end makes no claim to hold, a relation no key backs has
	# nothing to hold it to -- that one is relation_backed_by_key's -- and
	# a note, which no relation joins
	_o4_.ExcludesQ(func oGraph {
		_r_ = []
		_a_ = oGraph.NodesIds()
		for _i_ = 1 to len(_a_)
			if NOT _ErIsEntity(oGraph, _a_[_i_])  _r_ + ("note:" + StzLower("" + _a_[_i_]))  ok
		next
		_aE_ = oGraph.Edges()
		for _i_ = 1 to len(_aE_)
			_aB_ = _ErParticipationBacking(oGraph, "" + _aE_[_i_][:from], "" + _aE_[_i_][:to])
			if len(_aB_) = 0
				_r_ + ("relation:" + StzLower("" + _aE_[_i_][:from]) + ">" + StzLower("" + _aE_[_i_][:to]))
			ok
		next
		return _r_
	})
	_o4_.UseCheckerQ(func oGraph {
		_aOut_ = []
		_aE_ = oGraph.Edges()
		for _i_ = 1 to len(_aE_)
			_cA_ = "" + _aE_[_i_][:from]
			_cB_ = "" + _aE_[_i_][:to]
			_aB_ = _ErParticipationBacking(oGraph, _cA_, _cB_)
			if len(_aB_) = 0  loop  ok
			# [ holder, target, column, nullable, declared ]
			_cWant_ = "mandatory"
			if _aB_[4] = 1  _cWant_ = "optional"  ok
			if _aB_[5] = _cWant_  loop  ok
			_cNull_ = "is not nullable"
			if _aB_[4] = 1  _cNull_ = "is nullable"  ok
			_aOut_ + [ :where = _cA_ + ">" + _cB_, :message = "the '" +
				oGraph.NodeProperty(_aB_[2], "name") + "' end is declared " + _aB_[5] +
				" and the key behind it, '" + oGraph.NodeProperty(_aB_[1], "name") + "." +
				_aB_[3] + "', " + _cNull_ ]
		next
		return _aOut_
	})
	poSet.AddRule(_o4_)

# For a relation A>B: which foreign key backs it, and what participation is
# declared at that key's target end. [ holder, target, column, nullable,
# declared ], or [] when no key backs it or nothing is declared there.
# A one-to-many is backed on its many side; a one-to-one on whichever side
# holds the key; a many-to-many by no single column, so never here.
func _ErParticipationBacking(oGraph, pcA, pcB)
	_cK_ = StzLower("" + oGraph.EdgeProperty(pcA, pcB, "type"))
	_cPa_ = StzLower("" + oGraph.EdgeProperty(pcA, pcB, "frompart"))
	_cPb_ = StzLower("" + oGraph.EdgeProperty(pcA, pcB, "topart"))
	_cHold_ = ""  _cTgt_ = ""  _cDecl_ = ""
	if _cK_ = "onetomany"
		_cHold_ = pcB  _cTgt_ = pcA  _cDecl_ = _cPa_
	but _cK_ = "manytoone"
		_cHold_ = pcA  _cTgt_ = pcB  _cDecl_ = _cPb_
	but _cK_ = "onetoone"
		if len(_ErFkTo(oGraph, pcA, pcB)) > 0
			_cHold_ = pcA  _cTgt_ = pcB  _cDecl_ = _cPb_
		but len(_ErFkTo(oGraph, pcB, pcA)) > 0
			_cHold_ = pcB  _cTgt_ = pcA  _cDecl_ = _cPa_
		ok
	ok
	if _cHold_ = "" or _cDecl_ = ""  return []  ok
	_aF_ = _ErFkTo(oGraph, _cHold_, _cTgt_)
	if len(_aF_) = 0  return []  ok
	_nNull_ = 0
	if len(_aF_) >= 3 and _aF_[3] = 1  _nNull_ = 1  ok
	return [ _cHold_, _cTgt_, _aF_[1], _nNull_, _cDecl_ ]

# CLASSES LAST, FUNCTIONS FIRST: in a Ring file everything after the first
# `class` belongs to a class, so a func written below one becomes a method
# of it -- StzErRuleSetQ did, and _StzAddErRules was 'not defined' when the
# method that had swallowed it called it as a function.

#---------------------------------------------------------------------#
#  THE DIAGRAM                                                         #
#---------------------------------------------------------------------#

class stzErDiagram from stzDiagram

	# [ [ :id, :name, :attrs ] ] with attrs [ [ :name, :key, :fk ] ]
	@aEntities = []
	# [ [ :from, :to, :kind, :frompart, :topart ] ] -- a participation is
	# "optional", "mandatory" or "", the last meaning nothing was declared
	@aRelations = []
	@aNotes = []

	def init(pcTitle)
		super.init(pcTitle)
		# the notation declares its edges undirected: a relation carries
		# its meaning at its ENDS, and a head would claim a direction a
		# schema does not have
		This.SetNotation(StzErNotation())

	#-- entities and their attributes ----------------------------------

	def AddEntity(pcId, pcName)
		This._ErNoEntity(pcId)
		@aEntities + [ :id = "" + pcId, :name = "" + pcName, :attrs = [] ]
		This.AddNodeXTT(pcId, pcName, [ :type = "entity", :attributes = [] ])
		return This

		def AddEntityQ(pcId, pcName)
			return This.AddEntity(pcId, pcName)

	# a junction is an entity drawn for a many-to-many: it holds a
	# foreign key to each side
	def AddJunction(pcId, pcName)
		This._ErNoEntity(pcId)
		@aEntities + [ :id = "" + pcId, :name = "" + pcName, :attrs = [] ]
		This.AddNodeXTT(pcId, pcName, [ :type = "junction", :attributes = [] ])
		return This

	def AddNote(pcId, pcText)
		# parenthesised: `@aNotes + "" + pcId` is two appends, the first
		# of an empty string -- found as a phantom note in the rule graph
		@aNotes + ("" + pcId)
		This.AddNodeXTT(pcId, pcText, [ :type = "note" ])
		return This

	def AddKey(pcEntity, pcAttr)
		This._ErAddAttr(pcEntity, pcAttr, 1, "", 0)
		return This

	def AddAttribute(pcEntity, pcAttr)
		This._ErAddAttr(pcEntity, pcAttr, 0, "", 0)
		return This

	def AddForeignKey(pcEntity, pcAttr, pcTarget)
		This._ErAddAttr(pcEntity, pcAttr, 0, "" + pcTarget, 0)
		return This

	# AddForeignKeyXT(entity, column, target, [ :Nullable = 1 ]): a column
	# that may be empty -- the schema's word for "this row need not take
	# part", which is what an Optional participation at the target end says
	def AddForeignKeyXT(pcEntity, pcAttr, pcTarget, paOpt)
		_n_ = 0
		if isList(paOpt) and HasKey(paOpt, "nullable")
			if paOpt[:nullable] = 1  _n_ = 1  ok
		ok
		This._ErAddAttr(pcEntity, pcAttr, 0, "" + pcTarget, _n_)
		return This

	# a key that is also a reference -- what a junction's columns are: the
	# primary key of ProductTag is the pair (product_id, tag_id), and each
	# half names the entity it points at
	def AddKeyReferencing(pcEntity, pcAttr, pcTarget)
		This._ErAddAttr(pcEntity, pcAttr, 1, "" + pcTarget, 0)
		return This

	def _ErAddAttr(pcEntity, pcAttr, pnKey, pcFk, pnNull)
		_i_ = This._ErIndex(pcEntity)
		if _i_ = 0
			stzraise("stzErDiagram: '" + pcEntity + "' is not an entity of this diagram -- " +
				"add it first.")
		ok
		@aEntities[_i_][:attrs] + [ :name = "" + pcAttr, :key = pnKey, :fk = pcFk, :nullable = pnNull ]
		# the compartment reads as a schema does: PK first, then the
		# columns, a foreign key naming what it points at
		_ac_ = []
		_aA_ = @aEntities[_i_][:attrs]
		for _k_ = 1 to len(_aA_)
			if _aA_[_k_][:key] != 1  loop  ok
			if _aA_[_k_][:fk] != ""
				_ac_ + ("PK FK " + _aA_[_k_][:name] + " -> " + _aA_[_k_][:fk])
			else
				_ac_ + ("PK " + _aA_[_k_][:name])
			ok
		next
		for _k_ = 1 to len(_aA_)
			if _aA_[_k_][:key] = 1  loop  ok
			if _aA_[_k_][:fk] != ""
				_cFk_ = "FK " + _aA_[_k_][:name] + " -> " + _aA_[_k_][:fk]
				if _aA_[_k_][:nullable] = 1  _cFk_ += " (nullable)"  ok
				_ac_ + _cFk_
			else
				_ac_ + _aA_[_k_][:name]
			ok
		next
		This.SetNodeProperty(pcEntity, "attributes", _ac_)

	def _ErIndex(pcId)
		_c_ = StzLower("" + pcId)
		for _i_ = 1 to len(@aEntities)
			if StzLower(@aEntities[_i_][:id]) = _c_  return _i_  ok
		next
		return 0

	def _ErNoEntity(pcId)
		if This._ErIndex(pcId) > 0
			stzraise("stzErDiagram: '" + pcId + "' is already an entity of this diagram.")
		ok

	#-- relations -------------------------------------------------------

	# Relate(from, to, kind): kind is :OneToMany, :ManyToOne, :OneToOne or
	# :ManyToMany, read from the FROM side -- "Customer one to many Order"
	def Relate(pcFrom, pcTo, pcKind)
		return This.RelateXT(pcFrom, pcTo, pcKind, [])

	# RelateXT(from, to, kind, [ :from = :Optional | :Mandatory, :to = ... ]):
	# the participation of the entity at each end, "must it take part".
	# Read at the END it names, whatever the relation's kind: :to = :Optional
	# on Customer > Order says a customer may have no order.
	def RelateXT(pcFrom, pcTo, pcKind, paOpt)
		_cPa_ = This._ErParticipationWord(paOpt, "from")
		_cPb_ = This._ErParticipationWord(paOpt, "to")
		_k_ = StzLower(ring_trim("" + pcKind))
		_acK_ = StzErRelationKinds()
		_bK_ = 0
		for _i_ = 1 to len(_acK_)
			if _acK_[_i_] = _k_  _bK_ = 1  ok
		next
		if _bK_ = 0
			stzraise("stzErDiagram: '" + pcKind + "' is not a cardinality -- OneToMany, " +
				"ManyToOne, OneToOne or ManyToMany.")
		ok
		if This._ErIndex(pcFrom) = 0 or This._ErIndex(pcTo) = 0
			stzraise("stzErDiagram: a relation joins two entities of this diagram -- '" +
				pcFrom + "' to '" + pcTo + "'.")
		ok
		@aRelations + [ :from = "" + pcFrom, :to = "" + pcTo, :kind = _k_,
			:frompart = _cPa_, :topart = _cPb_ ]
		This.AddEdgeXTT(pcFrom, pcTo, "", [ :relation = _k_, :frompart = _cPa_, :topart = _cPb_ ])
		return This

		def RelateQ(pcFrom, pcTo, pcKind)
			return This.Relate(pcFrom, pcTo, pcKind)

		def RelateXTQ(pcFrom, pcTo, pcKind, paOpt)
			return This.RelateXT(pcFrom, pcTo, pcKind, paOpt)

	# the participation word for one end, "" when the end declares nothing,
	# refused by name when it is neither of the two
	def _ErParticipationWord(paOpt, pcEnd)
		if NOT isList(paOpt) or NOT HasKey(paOpt, pcEnd)  return ""  ok
		_w_ = StzLower(ring_trim("" + paOpt[pcEnd]))
		if _w_ = ""  return ""  ok
		_acW_ = StzErParticipations()
		for _i_ = 1 to len(_acW_)
			if _acW_[_i_] = _w_  return _w_  ok
		next
		stzraise("stzErDiagram: '" + paOpt[pcEnd] + "' is not a participation -- " +
			"Optional or Mandatory.")

	def Entities()
		return @aEntities

	def Relations()
		return @aRelations

	#-- the projection the rules read ------------------------------------

	def AsRuleGraph()
		_oG_ = new stzGraph("er-rules")
		for _i_ = 1 to len(@aEntities)
			_e_ = @aEntities[_i_]
			_oG_.AddNode(_e_[:id])
			_oG_.SetNodeProperty(_e_[:id], "kind", "entity")
			_oG_.SetNodeProperty(_e_[:id], "name", _e_[:name])
			_acK_ = []
			_aF_ = []
			for _k_ = 1 to len(_e_[:attrs])
				if _e_[:attrs][_k_][:key] = 1  _acK_ + _e_[:attrs][_k_][:name]  ok
				if _e_[:attrs][_k_][:fk] != ""
					_aF_ + [ _e_[:attrs][_k_][:name], _e_[:attrs][_k_][:fk], _e_[:attrs][_k_][:nullable] ]
				ok
			next
			_oG_.SetNodeProperty(_e_[:id], "keys", _acK_)
			_oG_.SetNodeProperty(_e_[:id], "fks", _aF_)
		next
		for _i_ = 1 to len(@aNotes)
			_oG_.AddNode(@aNotes[_i_])
			_oG_.SetNodeProperty(@aNotes[_i_], "kind", "note")
		next
		for _i_ = 1 to len(@aRelations)
			_r_ = @aRelations[_i_]
			if NOT _oG_.EdgeExists(_r_[:from], _r_[:to])
				_oG_.AddEdgeXTT(_r_[:from], _r_[:to], _r_[:kind], [ :type = _r_[:kind],
					:frompart = _r_[:frompart], :topart = _r_[:topart] ])
			ok
		next
		return _oG_

	def GovernanceFindings()
		return StzErRuleSetQ().Check(This.AsRuleGraph())

	def GovernanceIsSound()
		return len(This.GovernanceFindings()) = 0

	def CheckRules()
		return This.GovernanceFindings()

	def RulesAreSound()
		return This.GovernanceIsSound()

class stzErRule from stzGraphRule
	def init(pcName)
		super.init(pcName)
		This.SetDomainQ("er")

class stzErRuleSet from stzGraphRuleSet
	def init()
		super.init("er-governance")
		This.SetDomainQ("er")
		_StzAddErRules(This)
