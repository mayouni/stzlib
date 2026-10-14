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

# Holds a constituency parse tree of a sentence: nested phrases (S, NP, VP, PP) over words tagged with their part of speech.
#
# Where the chunker of stzText gives flat phrases, this gives the nested structure. It is reached
# from a text, never built by hand in practice: ParseTreeQ() on a stzText returns the root, and
# ParseTreeWithQ takes your own phrase grammar. The tree answers its yield (Leaves, Text), its shape
# (Height, Children), the phrases of a kind (NounPhrases, VerbPhrases, PrepositionalPhrases,
# Phrases) and two renderings (ToBracket, ToTreeString). The tags come from the stzText tagger, so a
# Hebrew or Arabic sentence is tagged as plain nouns.
#
#   receiver   o1 = Q("The quick brown fox jumps over the lazy dog").TextQ().ParseTreeQ()
#   example    ? o1.Label()
#              #--> S
#              ? @@( o1.Children() )
#              #--> [ "NP", "VP" ]
#              ? @@( o1.NounPhrases() )
#              #--> [ "The quick brown fox", "the lazy dog" ]
#              ? o1.Height()
#              #--> 5
#              ? o1.Text()
#              #--> The quick brown fox jumps over the lazy dog
#   see        stzText
class stzParseTree from stzObject

	@cLabel = ""        # phrase label (NP/VP/PP/S) OR, on a leaf, the POS tag
	@cWord = ""         # the token, on a leaf only
	@aoChildren = []     # child stzParseTree nodes (empty on a leaf)

	# Builds one node of a parse tree with a label: a phrase label such as NP, VP, PP or S, or the part-of-speech tag on a leaf.
	#
	#   pcLabel    the phrase label or, on a leaf, the part-of-speech tag, such as NN
	#   returns    nothing; the node is built, empty and without children
	#   note       a number is accepted and turned into its text; by hand, a leaf is made with a tag
	#              and SetWord, a phrase with a label and AddChild
	#   see        SetWord, AddChild
	def init(pcLabel)
		@cLabel = "" + pcLabel
		@cWord = ""
		@aoChildren = []

	# Sets the word of a leaf node and returns the node, so calls chain.
	#
	#   pcWord     the token the leaf stands for
	#   returns    the same node
	#   note       the parser itself builds trees from the bottom up with it
	#   see        Word, AddChild
	#@ aka  -- construction (the parser builds bottom-up) ---------------------------
	def SetWord(pcWord)
		@cWord = "" + pcWord
		return This

	# Appends a node under this one as its last child and returns this node, so calls chain.
	#
	#   oNode      the stzParseTree to attach
	#   returns    the same node (the parent)
	#   note       Ring copies the child on appending, so changes made to the child object
	#              afterwards do not reach the tree
	#   see        SetWord, Children
	def AddChild(oNode)
		@aoChildren + oNode      # Ring copies on append -- fine, subtrees are
		return This             # finalized before they join their parent

	# Returns the label of the node: its phrase label, or the part-of-speech tag on a leaf.
	#
	#   returns    a text
	#   see        Word
	#@ aka  -- shape ----------------------------------------------------------------
	def Label()
		return @cLabel

	# Returns the word held by a leaf node; a phrase node holds none.
	#
	#   returns    a text; "" on a phrase node
	#   see        Label, Leaves
	def Word()
		return @cWord

	# TRUE if the node has no child, which is how a word-bearing node ends the tree.
	#
	#   returns    TRUE or FALSE
	#   note       a node just built with init is a leaf until a child is added
	#   see        NumberOfChildren
	def IsLeaf()
		return len(@aoChildren) = 0

	# The child nodes -- OBJECTS, hence Q.
	def ChildrenQ()
		return @aoChildren

	# Returns the labels of the direct children, left to right.
	#
	#   returns    a list of texts
	#   note       ChildrenQ answers the child nodes themselves, as objects
	#   see        ChildrenQ, NumberOfChildren
	#@ aka  ... and what they are, as data: the label each child carries.
	def Children()
		_acLabels_ = []
		_nLen_ = len(@aoChildren)
		for i = 1 to _nLen_
			_acLabels_ + @aoChildren[i].Label()
		end
		return _acLabels_

	# Returns how many direct children the node has.
	#
	#   returns    a number
	#   see        Children, IsLeaf
	def NumberOfChildren()
		return len(@aoChildren)

	# Returns the words at the ends of the tree, left to right, which is the sentence the tree spells.
	#
	#   returns    a list of texts
	#   see        Text, Word
	#@ aka  the terminal words, left to right (the tree's "yield")
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

	# Returns the words of the tree joined by single spaces.
	#
	#   returns    a text
	#   see        Leaves
	def Text()
		return JoinXT(This.Leaves(), " ")

	# Returns the number of levels from this node down to its deepest leaf, a lone leaf counting 1.
	#
	#   returns    a number
	#   see        NumberOfChildren
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

	# Returns every node of the tree, this one included, whose label equals the given one.
	#
	#   pcLabel    the phrase label to search for, in any case and with spaces around it ignored
	#   returns    a list of stzParseTree nodes; [ ] when none match
	#   note       the answer holds objects, not text; Phrases gives their words
	#   see        Phrases
	#@ aka  -- navigation -----------------------------------------------------------
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

	# Returns the words of every phrase of one kind, as texts, in tree order.
	#
	#   pcLabel    the phrase label to collect, such as NP or VP, in any case
	#   returns    a list of texts; [ ] when the label is absent
	#   note       a phrase that contains another of the same kind is listed beside it
	#   see        NounPhrases, VerbPhrases, PrepositionalPhrases
	#@ aka  the phrases of a kind, as strings (the chunker-style convenience)
	def Phrases(pcLabel)
		_aT_ = This.Subtrees(pcLabel)
		_a_ = []
		_n_ = len(_aT_)
		for _i_ = 1 to _n_
			_a_ + _aT_[_i_].Text()
		next
		return _a_

		# Returns the words of every noun phrase (NP) of the tree.
		#
		#   returns    a list of texts
		#   see        Phrases
		def NounPhrases()
			return This.Phrases("NP")

		# Returns the words of every verb phrase (VP) of the tree.
		#
		#   returns    a list of texts
		#   see        Phrases
		def VerbPhrases()
			return This.Phrases("VP")

		# Returns the words of every prepositional phrase (PP) of the tree.
		#
		#   returns    a list of texts
		#   see        Phrases
		def PrepositionalPhrases()
			return This.Phrases("PP")

	# Returns the tree in Penn Treebank bracket notation, with each leaf written word/TAG.
	#
	#   returns    a text on one line
	#   note       a node with no child and no word gives "/NP": only a leaf with a word prints as a
	#              leaf should
	#   see        ToTreeString
	#@ aka  -- rendering ------------------------------------------------------------
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

	# Returns the tree as indented lines, one node per line, two spaces per level.
	#
	#   returns    a text on several lines
	#   see        Show, ToBracket
	#@ aka  an indented, human-readable tree
	def ToTreeString()
		return This._Indent(0)

	# Prints the indented tree on the console.
	#
	#   returns    nothing
	#   see        ToTreeString
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
