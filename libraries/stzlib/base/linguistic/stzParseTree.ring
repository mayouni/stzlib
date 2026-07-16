# R3 (the NLTK offensive, final row) -- stzParseTree: a CONSTITUENCY
# PARSE TREE. The chunker (stzText.Chunks) gives FLAT phrases; this gives
# the NESTED phrase structure a real parse is:
#
#   oT = Q("The quick brown fox jumps over the lazy dog").TextQ()
#   ? oT.ParseTree()
#   #--> (S (NP The/DT quick/JJ brown/JJ fox/NN)
#   #       (VP jumps/VBZ (PP over/IN (NP the/DT lazy/JJ dog/NN))))
#   oTree = oT.ParseTreeQ()                 # the object, to navigate
#   ? oTree.NounPhrases()                   #--> [ "The quick brown fox", "the lazy dog" ]
#   ? oTree.Height()                        #--> 5
#
# The parser is a CASCADED PHRASE GRAMMAR (stzText.ParseTreeWithQ): a list
# of [ label, tag-pattern ] rules applied in order; later rules may name
# phrase labels (NP/VP/PP) built by earlier ones, so structure NESTS. Same
# clean pattern grammar as the chunker (Penn tags + ? * + quantifiers,
# prefix tag-match so NN covers NNP and VB covers VBZ/VBD/...). This covers
# NLTK's RegexpParser cascade with trees, deterministically and embedded.

func StzParseTreeQ(pcLabel)
	return new stzParseTree(pcLabel)

class stzParseTree from stzObject

	@cLabel = ""        # phrase label (NP/VP/PP/S) OR, on a leaf, the POS tag
	@cWord = ""         # the token, on a leaf only
	@aoChildren = []     # child stzParseTree nodes (empty on a leaf)

	def init(pcLabel)
		@cLabel = "" + pcLabel
		@cWord = ""
		@aoChildren = []

	#-- construction (the parser builds bottom-up) ---------------------------

	def SetWord(pcWord)
		@cWord = "" + pcWord
		return This

	def AddChild(oNode)
		@aoChildren + oNode      # Ring copies on append -- fine, subtrees are
		return This             # finalized before they join their parent

	#-- shape ----------------------------------------------------------------

	def Label()
		return @cLabel

	def Word()
		return @cWord

	def IsLeaf()
		return len(@aoChildren) = 0

	# The child nodes -- OBJECTS, hence Q.
	def ChildrenQ()
		return @aoChildren

	# ... and what they are, as data: the label each child carries.
	def Children()
		_acLabels_ = []
		_nLen_ = len(@aoChildren)
		for i = 1 to _nLen_
			_acLabels_ + @aoChildren[i].Label()
		end
		return _acLabels_

	def NumberOfChildren()
		return len(@aoChildren)

	# the terminal words, left to right (the tree's "yield")
	def Leaves()
		if This.IsLeaf()
			if @cWord != ""
				return [ @cWord ]
			ok
			return []
		ok
		_a_ = []
		_n_ = len(@aoChildren)
		for _i_ = 1 to _n_
			_aC_ = @aoChildren[_i_].Leaves()
			_m_ = len(_aC_)
			for _j_ = 1 to _m_
				_a_ + _aC_[_j_]
			next
		next
		return _a_

	def Text()
		return JoinXT(This.Leaves(), " ")

	def Height()
		if This.IsLeaf()
			return 1
		ok
		_nMax_ = 0
		_n_ = len(@aoChildren)
		for _i_ = 1 to _n_
			_h_ = @aoChildren[_i_].Height()
			if _h_ > _nMax_
				_nMax_ = _h_
			ok
		next
		return 1 + _nMax_

	#-- navigation -----------------------------------------------------------

	# every subtree (self included) whose label equals pcLabel (phrase query)
	def Subtrees(pcLabel)
		_cL_ = StzUpper(ring_trim("" + pcLabel))
		_a_ = []
		if StzUpper(@cLabel) = _cL_
			_a_ + This
		ok
		_n_ = len(@aoChildren)
		for _i_ = 1 to _n_
			_aSub_ = @aoChildren[_i_].Subtrees(pcLabel)
			_m_ = len(_aSub_)
			for _j_ = 1 to _m_
				_a_ + _aSub_[_j_]
			next
		next
		return _a_

	# the phrases of a kind, as strings (the chunker-style convenience)
	def Phrases(pcLabel)
		_aT_ = This.Subtrees(pcLabel)
		_a_ = []
		_n_ = len(_aT_)
		for _i_ = 1 to _n_
			_a_ + _aT_[_i_].Text()
		next
		return _a_

		def NounPhrases()
			return This.Phrases("NP")

		def VerbPhrases()
			return This.Phrases("VP")

		def PrepositionalPhrases()
			return This.Phrases("PP")

	#-- rendering ------------------------------------------------------------

	# Penn Treebank bracket notation (leaves as word/TAG)
	def ToBracket()
		if This.IsLeaf()
			return @cWord + "/" + @cLabel
		ok
		_c_ = "(" + @cLabel
		_n_ = len(@aoChildren)
		for _i_ = 1 to _n_
			_c_ += " " + @aoChildren[_i_].ToBracket()
		next
		_c_ += ")"
		return _c_

		def Bracket()
			return This.ToBracket()

	# an indented, human-readable tree
	def ToTreeString()
		return This._Indent(0)

	def Show()
		? This.ToTreeString()

	def _Indent(nDepth)
		_cPad_ = ""
		for _i_ = 1 to nDepth
			_cPad_ += "  "
		next
		if This.IsLeaf()
			return _cPad_ + @cWord + "/" + @cLabel
		ok
		_c_ = _cPad_ + @cLabel
		_n_ = len(@aoChildren)
		for _i_ = 1 to _n_
			_c_ += nl + @aoChildren[_i_]._Indent(nDepth + 1)
		next
		return _c_
