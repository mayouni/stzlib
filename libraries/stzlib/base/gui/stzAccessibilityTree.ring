#---------------------------------------------------------------------------#
#  STZACCESSIBILITYTREE -- what a screen reader reads, EMITTED not inferred. #
#---------------------------------------------------------------------------#
#
#     oT = new stzAccessibilityTree(oUiDocument, oPanel)
#     ? oT.NodeCount()
#     ? oT.NodeOf("confirm")            # role, name, description, bounds
#     ? oT.ToJSON()                     # the whole tree, as data
#     ? oT.ReadingOrder()               # what a reader would say, in order
#
# G4a of SOFTANZA_GUI_PLAN.md. The plan's §5 finding, in one sentence:
# **a browser INFERS an accessibility tree from markup; Softanza EMITS
# one from declared intent, which is strictly better information.**
#
# This is the half of accessibility that no library removes. AccessKit's
# platform adapters are 3,763 lines on Windows, 2,590 on macOS, 2,403 on
# Android; the survey's own accounting says the semantics tree is
# "comparable in size again" and is ours in every scenario -- with
# AccessKit, with a hand-written bridge, with a web mirror DOM, or with
# nothing. It is a precondition of all four and wasted work in none.
#
# WHERE EVERY FIELD COMES FROM, and why the format already had them:
#
#   id           the declaration's NAME. Stable by construction, because
#                a .panel name is stable -- which is exactly the "stable
#                IDs" problem the survey lists as part of the hard half,
#                solved by the format rather than by bookkeeping.
#   role         the ROLE field, from a closed vocabulary every platform
#                already knows. Defaulted honestly when absent.
#   name         LABEL, or the text's own CONTENT. What a reader SAYS.
#   description  the RATIONALE. The commons made it mandatory on every
#                declaration for its own reasons, and it turns out to be
#                a sentence per region saying why that region exists --
#                which is precisely what a description field wants, and
#                what no HTML document has.
#   bounds       from the LAID-OUT panel, so a magnifier and a
#                touch-exploration gesture land on the real rectangle.
#   focusable    FOCUSABLE, the same field that builds the tab ring, so
#                the reading order and the keyboard order cannot drift.
#   actions      what can be DONE here, which is Rule 104's requirement:
#                "what a screen reader can operate, an agent can operate."
#
# THERE IS NO FLAG TO TURN THIS OFF, and that is deliberate. The survey's
# second structural warning was that *every toolkit gates accessibility
# behind a performance flag, which is where users silently get nothing*.
# A tree is built on demand from data that already exists; there is
# nothing to gate and so nothing to forget to switch on.

func StzAccessibilityTreeQ(poDoc, poPanel)
	return new stzAccessibilityTree(poDoc, poPanel)

# Holds what a screen reader reads from a screen, emitted from the declared document and the laid-out panel and not inferred.
#
# A browser infers an accessibility tree from markup; this emits one from declared intent. Each
# declaration becomes a node with an id (its name), a role (the ROLE field, or window, label or
# group by default), a name (the LABEL, a text's content, or for a button and the like the text
# beneath it), a description (the RATIONALE), its bounds from the laid-out panel, whether a keyboard
# can reach it, and what can be done there. ToJSON gives the whole tree as data. There is no switch
# to turn it off. The document must be clean, and the tree needs the layout engine but no GPU and no
# window.
#
#   receiver   cDoc = 'DEFINE PANEL form ( SIZE [300, 200], DIRECTION column, CHILDREN [title,
#              ok_btn] ) RATIONALE "A tiny form."' + char(10) + 'DEFINE TEXT title ( CONTENT
#              "Transfer", SIZE 20, ROLE heading ) RATIONALE "What the form is for."' + char(10) +
#              'DEFINE BOX ok_btn ( HEIGHT 40, FOCUSABLE yes, ROLE button, CHILDREN [ok_text] )
#              RATIONALE "The act."' + char(10) + 'DEFINE TEXT ok_text ( CONTENT "Confirm", SIZE 16
#              ) RATIONALE "button label"' oU = new stzUiDocument(cDoc)
#              oU.UseFont("C:/Windows/Fonts/segoeui.ttf") oP = oU.ToPanel() oP.FocusOn("ok_btn") o1
#              = new stzAccessibilityTree(oU, oP)
#   example    ? o1.NodeCount()
#              #--> 4
#              ? o1.RoleOf("ok_btn")
#              #--> button
#              ? o1.NameOf("ok_btn")
#              #--> Confirm
#              ? o1.DescriptionOf("ok_btn")
#              #--> The act.
#              ? @@( o1.FocusableIds() )
#              #--> [ "ok_btn" ]
#              ? @@( o1.NodeOf("ok_btn")[:bounds] )
#              #--> [ 0, 24, 300, 40 ]
#              ? o1.ReadingOrder()[3]
#              #--> button "Confirm"
#   see        stzUiDocument, stzPanel, stzScreenReaderBridge
class stzAccessibilityTree from stzObject

	@oDoc = NULL
	@oPanel = NULL
	@aNodes = []       # flat, in reading order: see _Build

	# Builds the accessibility tree of a screen from its declared document and, if given, its laid-out panel.
	#
	#   poDoc      the stzUiDocument, which must be clean
	#   poPanel    the stzPanel made from it by ToPanel, or NULL when bounds and focus are not known
	#   returns    nothing; the tree is built when the object is made
	#   note       there is no flag to switch it off; with NULL for the panel every bounds is empty
	#              and no node is focused
	#   warning    a value that is not a document raises error stzAccessibilityTree: give an
	#              stzUiDocument; a document that is not clean raises error ... the document is not
	#              clean -- ask Report() why
	#   see        NodeOf, ToJSON
	def init(poDoc, poPanel)
		if NOT isObject(poDoc)
			StzRaise("stzAccessibilityTree: give an stzUiDocument.")
		ok
		if NOT poDoc.IsClean()
			StzRaise("stzAccessibilityTree: the document is not clean -- " +
				"ask Report() why. A tree built from a broken contract " +
				"would describe a screen nobody can see.")
		ok
		@oDoc = poDoc
		@oPanel = poPanel      # may be NULL: bounds are then unknown, and
		                       # the tree says so rather than inventing them
		This._Build()

	# Returns every node of the tree in reading order, depth first, in the order the author declared them.
	#
	#   returns    a list of hash lists with the keys id, role, name, description, bounds,
	#              focusable, focused, actions, depth and children
	#   note       the first node is the panel itself, as a window
	#   see        NodeOf, NodeCount
	#@ aka  -- the tree ------------------------------------------------------------
	def Nodes()
		return @aNodes

	# Returns how many nodes the tree holds.
	#
	#   returns    a number
	#   note       one node for each declaration, the panel included
	#   see        Nodes, HasNode
	def NodeCount()
		return len(@aNodes)

	# Returns one node by its id.
	#
	#   pcId       the name of the declaration, matched as written
	#   returns    a hash list with the keys id, role, name, description, bounds, focusable,
	#              focused, actions, depth and children; [ ] for an id the tree does not hold
	#   note       bounds is [ x, y, width, height ] from the laid-out panel, or [ ] when no panel
	#              was given; actions is focus and click for a focusable node and empty otherwise
	#   see        HasNode, RoleOf, Nodes
	#@ aka  One node by id: [ :id, :role, :name, :description, :bounds, :focusable, :focused, :actions, :depth, :children ]
	def NodeOf(pcId)
		_n_ = len(@aNodes)
		for _i_ = 1 to _n_
			if @aNodes[_i_][:id] = "" + pcId
				return @aNodes[_i_]
			ok
		next
		return []

	# TRUE if the tree holds a node with an id.
	#
	#   pcId       the name of the declaration, matched as written
	#   returns    TRUE or FALSE, as 1 or 0
	#   see        NodeOf, NodeCount
	def HasNode(pcId)
		return len(This.NodeOf(pcId)) > 0

	# Returns what a screen reader announces a node as.
	#
	#   pcId       the name of the declaration
	#   returns    the role as text such as button, heading or label; the panel is window, a text
	#              defaults to label and any other box to group; an empty text for an unknown id
	#   note       the role comes from the ROLE field of the declaration or from the style it uses
	#   see        NameOf, NodeOf
	def RoleOf(pcId)
		_a_ = This.NodeOf(pcId)
		if len(_a_) = 0
			return ""
		ok
		return _a_[:role]

	# Returns what a screen reader says for a node.
	#
	#   pcId       the name of the declaration
	#   returns    the name as text: the LABEL, else a text's own content, else for a button, link,
	#              heading, label, list item, tab, checkbox or radio the text of its descendants; an
	#              empty text for a window, group, textbox or unknown id
	#   note       name from content is gated by role, as ARIA gates it, so a window is not named
	#              after the whole screen
	#   see        RoleOf, DescriptionOf
	def NameOf(pcId)
		_a_ = This.NodeOf(pcId)
		if len(_a_) = 0
			return ""
		ok
		return _a_[:name]

	# Returns the sentence saying why a node exists, taken from the declaration's RATIONALE.
	#
	#   pcId       the name of the declaration
	#   returns    the description as text; an empty text for an unknown id
	#   note       every declaration carries a rationale, so every node has a description
	#   see        NameOf, RoleOf
	def DescriptionOf(pcId)
		_a_ = This.NodeOf(pcId)
		if len(_a_) = 0
			return ""
		ok
		return _a_[:description]

	# Returns the ids of the nodes a keyboard can reach, in reading order.
	#
	#   returns    a list of text; [ ] when none
	#   note       it comes from the same FOCUSABLE field that builds the tab ring, so reading order
	#              and keyboard order cannot drift
	#   see        ReadingOrder, NodeOf
	#@ aka  Every node that a keyboard can reach, in tree order. This must agree with the panel's tab ring: a reading order that disagrees with the keyboard order is how a screen-reader user and a keyboard user end up on different screens.
	def FocusableIds()
		_a_ = []
		_n_ = len(@aNodes)
		for _i_ = 1 to _n_
			if @aNodes[_i_][:focusable]
				_a_ + @aNodes[_i_][:id]
			ok
		next
		return _a_

	# Returns what a reader would announce, one line per node, as role and then the quoted name.
	#
	#   returns    a list of text such as button "Confirm"; a node with no name gives its role alone
	#   note       the lines follow the order of Nodes
	#   see        Nodes, NameOf
	#@ aka  What a reader would announce, in order: role, name and the description that the RATIONALE gave it for free.
	def ReadingOrder()
		_a_ = []
		_n_ = len(@aNodes)
		for _i_ = 1 to _n_
			_d_ = @aNodes[_i_]
			_c_ = _d_[:role]
			if _d_[:name] != ""
				_c_ += ' "' + _d_[:name] + '"'
			ok
			_a_ + _c_
		next
		return _a_

	# Returns the whole tree as JSON text, one object per node, for a tool or an agent to read.
	#
	#   returns    a JSON text; bounds is null when unknown, never a zero rectangle
	#   note       the children are stated explicitly, and depth stays so the flat list reads in
	#              order
	#   see        SaveTo, Nodes
	#@ aka  -- the tree as DATA ----------------------------------------------------
	def ToJSON()
		_c_ = "{" + char(10) + '  "nodes": [' + char(10)
		_n_ = len(@aNodes)
		for _i_ = 1 to _n_
			_d_ = @aNodes[_i_]
			_c_ += "    {"
			_c_ += '"id": ' + This._Q(_d_[:id]) + ", "
			_c_ += '"role": ' + This._Q(_d_[:role]) + ", "
			_c_ += '"name": ' + This._Q(_d_[:name]) + ", "
			_c_ += '"description": ' + This._Q(_d_[:description]) + ", "
			_c_ += '"depth": ' + _d_[:depth] + ", "
			_aB_ = _d_[:bounds]
			if len(_aB_) = 4
				_c_ += '"bounds": [' + _aB_[1] + ", " + _aB_[2] + ", " +
					_aB_[3] + ", " + _aB_[4] + "], "
			else
				# unknown is NULL, never a zero rectangle: a magnifier
				# told a thing is at 0,0 goes there
				_c_ += '"bounds": null, '
			ok
			_c_ += '"focusable": ' + This._B(_d_[:focusable]) + ", "
			_c_ += '"focused": ' + This._B(_d_[:focused]) + ", "
			_c_ += '"actions": ['
			_aA_ = _d_[:actions]
			_nA_ = len(_aA_)
			for _j_ = 1 to _nA_
				if _j_ > 1
					_c_ += ", "
				ok
				_c_ += This._Q(_aA_[_j_])
			next
			_c_ += "], "
			# CHILDREN, EXPLICIT. The list was always here; the JSON left
			# it out and published `depth` instead, which makes the tree
			# RECOVERABLE (a node's children are the following nodes at
			# depth+1) but not STATED. The first consumer that had to
			# build a real platform tree had to reconstruct it, and a
			# structure a reader must infer is one a reader can infer
			# wrongly. Rule 104 asks that what a screen reader can
			# operate an agent can operate -- an agent reading this
			# should not have to know the traversal order it was written
			# in. `depth` stays, because it is what makes the flat list
			# readable aloud in order.
			_c_ += '"children": ['
			_aC_ = _d_[:children]
			_nC_ = len(_aC_)
			for _j_ = 1 to _nC_
				if _j_ > 1
					_c_ += ", "
				ok
				_c_ += This._Q(_aC_[_j_])
			next
			_c_ += "]}"
			if _i_ < _n_
				_c_ += ","
			ok
			_c_ += char(10)
		next
		_c_ += "  ]" + char(10) + "}" + char(10)
		return _c_

	# Writes the tree as JSON to a file.
	#
	#   pcPath     the path of the file to write
	#   returns    nothing; the file is written
	#   note       an existing file is overwritten
	#   see        ToJSON
	def SaveTo(pcPath)
		write(pcPath, This.ToJSON())

	#-- building ------------------------------------------------------------

	def _Build()
		@aNodes = []
		_dP_ = @oDoc.PanelDecl()
		if len(_dP_) = 0
			return
		ok
		This._Visit(_dP_, 0)

	def _Visit(pDecl, pnDepth)
		_aKids_ = @oDoc._ChildrenOf(pDecl)
		_aKidIds_ = []
		_nK_ = len(_aKids_)
		for _i_ = 1 to _nK_
			_aKidIds_ + _aKids_[_i_]
		next

		@aNodes + [
			:id = pDecl[:name],
			:role = This._RoleFor(pDecl),
			:name = This._NameFor(pDecl),
			# THE RATIONALE, which every declaration carries because the
			# commons made it mandatory. A description per region, for
			# free, in a format that never set out to provide one.
			:description = pDecl[:rationale],
			:bounds = This._BoundsFor(pDecl[:name]),
			:focusable = This._FocusableFor(pDecl),
			:focused = This._FocusedFor(pDecl[:name]),
			:actions = This._ActionsFor(pDecl),
			:depth = pnDepth,
			:children = _aKidIds_
		]

		# depth-first, in declaration order: the reading order IS the
		# order the author wrote, which is the order the screen shows
		for _i_ = 1 to _nK_
			_dK_ = @oDoc.DeclOf(_aKids_[_i_])
			if len(_dK_) > 0
				This._Visit(_dK_, pnDepth + 1)
			ok
		next

	# The declared role, or an honest default. A default is not a guess
	# about MEANING -- it is the weakest true statement: a panel is a
	# window, a box that groups is a group, and a text is a label.
	def _RoleFor(pDecl)
		_aF_ = @oDoc._EffectiveFields(pDecl)
		_c_ = @oDoc._IdField(_aF_, "ROLE", "")
		if _c_ != ""
			return _c_
		ok
		if strcmp(pDecl[:kind], "PANEL") = 0
			return "window"
		ok
		if strcmp(pDecl[:kind], "TEXT") = 0
			return "label"
		ok
		return "group"

	# What a reader SAYS.
	#
	# LABEL wins, then a TEXT's own content, then NAME FROM CONTENT --
	# the text of the descendants, which is ARIA's own rule and what
	# every browser does for a button whose label is its child.
	#
	# The rule is here because the first tree without it announced the
	# form's buttons as "group" with no name at all: a screen-reader user
	# tabbing to Confirm would have heard "group", which is a defect an
	# assertion about node COUNTS would never have caught.
	#
	# A decorative box still ends with no name, and that is honest --
	# inventing one from an id would make a reader announce "row_one".
	def _NameFor(pDecl)
		_aF_ = @oDoc._EffectiveFields(pDecl)
		_c_ = @oDoc._StrField(_aF_, "LABEL", "")
		if _c_ != ""
			return _c_
		ok
		if strcmp(pDecl[:kind], "TEXT") = 0
			return @oDoc._StrField(_aF_, "CONTENT", "")
		ok
		# NAME FROM CONTENT IS GATED BY ROLE, as ARIA gates it. A button
		# is named by its label; a window, a group or a region is NOT --
		# the first version named every box from its descendants, so the
		# window announced the ENTIRE SCREEN as its name and a plain
		# grouping row announced "Confirm Cancel". A reader that says the
		# whole screen before every element is worse than one that says
		# nothing.
		#
		# A textbox is absent from this list on purpose: its content is
		# its VALUE, not its name, so it takes a LABEL or goes unnamed --
		# and an unnamed field is a defect the guard reports.
		if NOT This._TakesNameFromContent(This._RoleFor(pDecl))
			return ""
		ok
		return ring_trim(This._TextUnder(pDecl, 0))

	# The roles ARIA names from their own content.
	def _TakesNameFromContent(pcRole)
		_a_ = [ "button", "link", "heading", "label", "listitem", "tab",
			"checkbox", "radio" ]
		_n_ = len(_a_)
		for _i_ = 1 to _n_
			if strcmp(pcRole, _a_[_i_]) = 0
				return TRUE
			ok
		next
		return FALSE

	# The text of everything below a box, joined -- ARIA's name-from-
	# content. Depth-bounded because a cycle would otherwise be a hang,
	# and the court already refuses cycles anyway.
	def _TextUnder(pDecl, pnDepth)
		if pnDepth > 8
			return ""
		ok
		_c_ = ""
		_aKids_ = @oDoc._ChildrenOf(pDecl)
		_n_ = len(_aKids_)
		for _i_ = 1 to _n_
			_dK_ = @oDoc.DeclOf(_aKids_[_i_])
			if len(_dK_) = 0
				loop
			ok
			if strcmp(_dK_[:kind], "TEXT") = 0
				_cT_ = @oDoc._StrField(@oDoc._EffectiveFields(_dK_), "CONTENT", "")
				if _cT_ != ""
					_c_ += _cT_ + " "
				ok
			else
				_c_ += This._TextUnder(_dK_, pnDepth + 1)
			ok
		next
		return _c_

	def _FocusableFor(pDecl)
		_aF_ = @oDoc._EffectiveFields(pDecl)
		return strcmp(@oDoc._IdField(_aF_, "FOCUSABLE", "no"), "yes") = 0

	def _FocusedFor(pcName)
		if @oPanel = NULL
			return FALSE
		ok
		return @oPanel.Focused() = pcName

	# Rule 104 again: an agent operates what a reader operates, so the
	# tree says what CAN be done rather than leaving it to be guessed.
	def _ActionsFor(pDecl)
		_a_ = []
		if This._FocusableFor(pDecl)
			_a_ + "focus"
			_a_ + "click"
		ok
		return _a_

	# From the LAID-OUT panel, so a magnifier lands on the real rectangle.
	# [] when there is no panel -- which is a real answer, and the JSON
	# says null rather than a zero rectangle a magnifier would fly to.
	def _BoundsFor(pcName)
		if @oPanel = NULL
			return []
		ok
		# the PANEL itself is the document root, which carries no element
		# id -- its bounds are the panel's own, and answering [] there
		# would tell a magnifier the whole screen has no position
		_dP_ = @oDoc.PanelDecl()
		if len(_dP_) > 0 and _dP_[:name] = pcName
			return [ 0, 0, @oPanel.Width(), @oPanel.Height() ]
		ok
		_a_ = @oPanel.BoxOf(pcName)
		if len(_a_) != 4
			return []
		ok
		return _a_

	# JSON escaping, built from char() codes rather than literals: a lone
	# backslash inside a Ring string literal is its own adventure, and
	# this runs on every RATIONALE in the document.
	# The one JSON string writer, the engine's (RX1): this used to forget CR
	# and NUL, and a rationale holding either gave an invalid document.
	def _Q(pcText)
		return StzJsonString(pcText)

	def _B(pb)
		if pb
			return "true"
		ok
		return "false"
