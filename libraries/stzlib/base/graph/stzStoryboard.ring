# DN9f -- THE STORYBOARD: frames in order, and a caption that cannot lie
#
# A narration is facts made visible, IN AN ORDER. The order is this file's
# business. A storyboard holds one picture and a sequence of frames over
# it: each frame adds a mark or two, may move the view, may change the
# content, and carries one sentence.
#
# THE SENTENCE CARRIES HOLES, NEVER NUMBERS. "the leash allows {leash} px"
# is bound to a FACT, and the number is put in when the frame closes, from
# the picture as it stands in THAT frame. An author who types a number
# into a caption has written something nobody checks -- measured on this
# very plane, where two numbers in three hand-drawn diagrams were wrong.
#
# EVERY FRAME IS JUDGED. It goes through the one gate as it closes, and
# every filled hole is held to the fact it came from. A lesson whose
# pictures are lawful and whose numbers are true is a claim no textbook
# makes, and it is only worth making if a machine checks it.
#
# THE PICTURE IS OWNED, NOT BORROWED. Ring copies an object on
# assignment, so a storyboard given a picture holds its own; an author
# who kept mutating the outer variable would be decorating a different
# object. Everything a frame does to the picture therefore goes through
# the storyboard, which is why the marks are forwarded here rather than
# left to the caller.

# Tells a story over one picture as an ordered list of frames, each with a caption whose numbers are read from the picture's facts.
#
# A frame is opened with Frame, changed with marks (Emphasis, Callout, Measure, Show, Region), a
# window (WindowOn, SetWindow) or an action (Act), and closed by opening the next frame or by asking
# any question about the frames. The caption carries holes, written {name}, never numbers: Bind ties
# a hole to a fact read from the picture when the frame closes, and BindFact takes a fact from
# another plane. Closing a frame draws the picture to a PNG file named after the storyboard, in the
# folio, and puts it through the picture gate, which prints a line. Judge then checks every frame
# against the gate and every hole against its fact, and Render writes the HTML page that shows the
# frames in order. A frame about a picture that is meant to be unlawful says so with ExpectFindings.
# Marks stay on the picture from frame to frame until ClearMarks. The storyboard keeps its own copy
# of the picture, so every change goes through it. ToNarration writes the same story as a .narration
# document, and RenditionAs gives it as markup or text.
#
#   receiver   oS = new stzMathSubstance(StzSetTheoryDomain()); oS.DeclareAll("Set", [ "A", "B" ]);
#              oS.Assert("Subset", [ "B", "A" ]); oS.AutoLabelAll(); oP = new
#              stzMathDiagram(StzSetTheoryDomain(), oS, StzEulerStyle()); oP.SetFont(new
#              stzFont("C:/Windows/Fonts/segoeui.ttf"), 28); oP.SetVariation("twosets");
#              StzEngineDirCreatePath("t_story_doc"); o1 = new stzStoryboard("sets", oP,
#              "t_story_doc")
#   example    o1.Frame("B has radius {r} px and A has {ra} px.")
#              o1.Bind("r", :value, [ "B.icon.r" ])
#              o1.Bind("ra", :value, [ "A.icon.r" ])
#              o1.Emphasis("B.icon", :ring)
#              ? o1.Caption(1)
#              #--> B has radius 46.40 px and A has 155.32 px.
#              ? o1.FileOf(1)
#              #--> sets_01.png
#              ? o1.NumberOfHoles()
#              #--> 2
#              ? o1.IsClean()
#              #--> 1
#              o1.Frame("A frame that expects something to be wrong.")
#              o1.ExpectFindings()
#              ? o1.Judge()[1][:rule]
#              #--> expected_a_finding_and_got_none
#   see        stzMathDiagram, StzCheckPictures
class stzStoryboard from stzObject

	@cName = ""
	@oPic = NULL
	@cFolio = "."
	@aFrames = []      # [ cRaw, cFilled, cFile, aHoles, aFindings, nMarks ]
	@cOpen = ""        # the caption of the frame being built, "" when none
	@aHoles = []       # [ [ cHole, aFact ] ] for the frame being built
	@bOpen = FALSE
	@bExpect = FALSE   # this frame is ABOUT something the gate finds

	# Builds a storyboard of frames about one picture, named so that its frame files are named after it.
	#
	#   pcName      the storyboard's name, which starts the name of every frame file
	#   poPicture   the picture the frames are about, such as a stzMathDiagram
	#   pcFolio     the folder that receives the frame files and the page, or an empty text for the
	#               current folder
	#   returns     nothing; the object is built
	#   note        the storyboard keeps its own copy of the picture, so changes must go through the
	#               storyboard
	#   warning     an empty name raises stzStoryboard: a storyboard needs a name, and a picture
	#               that is not an object raises give the picture the frames are about; the folder
	#               must already exist
	#   see         Frame, Folio, PictureName
	def init(pcName, poPicture, pcFolio)
		if NOT isObject(poPicture)
			stzraise("stzStoryboard: give the picture the frames are about.")
		ok
		@cName = ring_trim("" + pcName)
		if @cName = ""
			stzraise("stzStoryboard: a storyboard needs a name -- its frames are " +
				"written to files named after it.")
		ok
		@oPic = poPicture
		@cFolio = ring_trim("" + pcFolio)
		if @cFolio = ""  @cFolio = "."  ok

	# Closes the frame being built, if any, and opens a new one with its caption, whose {holes} are filled when it closes.
	#
	#   pcCaption   the sentence of the frame, with a hole written {name} wherever a number from a
	#               fact goes
	#   returns     the storyboard itself, so calls chain
	#   note        FrameQ is the same call; a frame closes by itself when another is opened or any
	#               question about the frames is asked
	#   warning     the marks of earlier frames stay on the picture: use ClearMarks to start a frame
	#               clean; closing a frame draws the picture to a PNG file and prints the gate's
	#               line pictures judged
	#   see         FrameOf, Bind, Caption
	#@ aka  -- the frames -----------------------------------------------------------
	def Frame(pcCaption)
		This._CloseOpen()
		@cOpen = "" + pcCaption
		@aHoles = []
		@bOpen = TRUE
		@bExpect = FALSE
		return This

		def FrameQ(pcCaption)
			return This.Frame(pcCaption)

	# Closes the frame being built and opens a new one on a different picture, which becomes the picture of the storyboard.
	#
	#   poPicture   the picture this frame and the next ones are about
	#   pcCaption   the sentence of the frame, with its holes
	#   returns     the storyboard itself, so calls chain
	#   note        FrameOfQ is the same call
	#   warning     a picture that is not an object raises give the picture this frame is about
	#   see         Frame, Bind
	#@ aka  the same, on a different picture: a narration may show two solves of one content, or two contents that make one point
	def FrameOf(poPicture, pcCaption)
		if NOT isObject(poPicture)
			stzraise("stzStoryboard.FrameOf: give the picture this frame is about.")
		ok
		This._CloseOpen()
		@oPic = poPicture
		@cOpen = "" + pcCaption
		@aHoles = []
		@bOpen = TRUE
		@bExpect = FALSE
		return This

		def FrameOfQ(poPicture, pcCaption)
			return This.FrameOf(poPicture, pcCaption)

	# Says the open frame is about a picture the gate finds fault with, so the findings are its subject and not its failure.
	#
	#   returns    the storyboard itself, so calls chain
	#   warning    a frame that expects findings and gets none is itself reported by Judge, as
	#              expected_a_finding_and_got_none; with no frame open it raises open a frame first
	#   see        Judge, ExpectsFindings, FindingsOf
	#@ aka  A FRAME MAY BE ABOUT A PICTURE THE GATE FINDS FAULT WITH, and that is not a defect in the telling -- it is often the point. "Here is what goes wrong" is a frame whose picture is meant to be unlawful. So a frame says so, and then the gate's findings are its SUBJECT rather than its failure. A frame that expects findings and gets none is itself reported, because a flag nobody checks is a flag that ro
	def ExpectFindings()
		This._RequireOpen("ExpectFindings")
		@bExpect = TRUE
		return This

	# Ties a hole of the open frame to a fact read from the picture when the frame closes, and returns the storyboard.
	#
	#   pcHole     the hole's name, as written between braces in the caption
	#   pcKind     the kind of fact, such as :value or :distance
	#   paArgs     the list of arguments of that fact, such as [ "B.icon.r" ]
	#   returns    the storyboard itself, so calls chain
	#   note       BindQ is the same call; the number is read at close, so a later action in the
	#              same frame still moves it
	#   warning    with no frame open it raises open a frame first; a hole the caption never quotes
	#              is reported by Judge as fact_bound_but_never_shown
	#   see        BindFact, Fact, Caption
	#@ aka  BIND A HOLE TO A FACT. The fact is read when the frame closes, not now, so an action later in the same frame still moves the number.
	def Bind(pcHole, pcKind, paArgs)
		This._RequireOpen("Bind")
		@aHoles + [ ring_trim("" + pcHole), "" + pcKind, paArgs ]
		return This

		def BindQ(pcHole, pcKind, paArgs)
			return This.Bind(pcHole, pcKind, paArgs)

	# Ties a hole to a fact handed in whole, from another plane, and returns the storyboard.
	#
	#   pcHole     the hole's name, as written between braces in the caption
	#   paFact     a fact, as Fact() answered it or StzFact() built it, with at least a value and a
	#              message
	#   returns    the storyboard itself, so calls chain
	#   note       BindFactQ is the same call; {name.message} and {name.unit} show the fact's
	#              sentence and unit
	#   warning    a list that is not a fact raises that is not a fact; with no frame open it raises
	#              open a frame first
	#   see        Bind, Judge
	#@ aka  A FACT FROM ANOTHER PLANE. The fact shape is one shape on purpose (DN9b), so a verdict an org chart reached, or a count a notation picture keeps, can be quoted in a caption about a drawing of it. The caller supplies the fact; the storyboard still holds the caption to it, which is the whole point of binding rather than typing.
	def BindFact(pcHole, paFact)
		This._RequireOpen("BindFact")
		if NOT isList(paFact) or NOT HasKey(paFact, "value") or NOT HasKey(paFact, "message")
			stzraise("stzStoryboard.BindFact: that is not a fact -- give what a Fact() " +
				"call answered, or what StzFact() built.")
		ok
		@aHoles + [ ring_trim("" + pcHole), "", paFact ]
		return This

		def BindFactQ(pcHole, paFact)
			return This.BindFact(pcHole, paFact)

	# Draws on the picture the boundary a rule states, such as the circle of a leash, for the open frame.
	#
	#   pcRule     words that appear in the rule's own line, such as disjoint or lessthan v111
	#   returns    the storyboard itself, so calls chain
	#   note       tested on a sets picture: a thin circle appeared around the smaller set
	#   warning    with no frame open it raises open a frame first; words that match no rule raise
	#              an error saying a rule is addressed by words from its own line
	#   see        Region, Emphasis, ClearMarks
	#@ aka  -- what a frame may do to the picture -----------------------------------
	def Show(pcRule)
		This._RequireOpen("Show")
		@oPic.Show(pcRule)
		return This

	# Tints on the picture the area a clearance rule forbids, for the open frame.
	#
	#   pcRule     words that appear in the rule's own line, such as disjoint
	#   returns    the storyboard itself, so calls chain
	#   note       tested on a sets picture: a pink disc appeared around the smaller set
	#   warning    with no frame open it raises open a frame first; words that match no rule raise
	#              the same error as Show
	#   see        Show, ClearMarks
	def Region(pcRule)
		This._RequireOpen("Region")
		@oPic.Region(pcRule)
		return This

	# Draws on the picture a line between two things, with its length written beside it, for the open frame.
	#
	#   pcA        the first thing, such as A.icon
	#   pcB        the second thing, such as B.icon
	#   paOpts     the options list, or an empty list
	#   returns    the storyboard itself, so calls chain
	#   note       the length is read from the picture; in the test the label was drawn far from the
	#              line, at the bottom of the larger set
	#   warning    with no frame open it raises open a frame first
	#   see        Callout, Fact
	def Measure(pcA, pcB, paOpts)
		This._RequireOpen("Measure")
		@oPic.Measure(pcA, pcB, paOpts)
		return This

	# Writes a short text with a leader line pointing at a thing on the picture, for the open frame.
	#
	#   pcTarget   the thing pointed at, such as B.icon
	#   pcText     the text to write
	#   paOpts     the options list, or an empty list
	#   returns    the storyboard itself, so calls chain
	#   warning    with no frame open it raises open a frame first; the gate may find the text
	#              overlapping a name, as it did in the test, and Judge then reports it
	#   see        Measure, Emphasis
	def Callout(pcTarget, pcText, paOpts)
		This._RequireOpen("Callout")
		@oPic.Callout(pcTarget, pcText, paOpts)
		return This

	# Marks a thing on the picture for the open frame, as a ring around it, a stronger stroke or a dimmed one.
	#
	#   pcTarget   the thing to mark, such as B.icon
	#   pcMode     :ring, :focus or :dim
	#   returns    the storyboard itself, so calls chain
	#   note       the ring was drawn in orange around the smaller set
	#   warning    with no frame open it raises open a frame first; any other mode raises an error
	#              naming the three
	#   see        Callout, ClearMarks
	def Emphasis(pcTarget, pcMode)
		This._RequireOpen("Emphasis")
		@oPic.Emphasis(pcTarget, pcMode)
		return This

	# Removes every mark the picture carries, so the open frame starts clean.
	#
	#   returns    the storyboard itself, so calls chain
	#   note       marks stay from frame to frame until this call
	#   warning    with no frame open it raises open a frame first
	#   see        Emphasis, Callout, Show
	def ClearMarks()
		This._RequireOpen("ClearMarks")
		@oPic.ClearMarks()
		return This

	# Shows only a part of the picture for the open frame: the window centred on a thing, with some reach around it.
	#
	#   pcPath     the thing to centre on, such as B.icon
	#   pnReach    how far around it to show, in pixels
	#   returns    the storyboard itself, so calls chain
	#   note       in the test the window was scaled up to the whole canvas
	#   warning    with no frame open it raises open a frame first; a mark outside the window is
	#              reported by Judge as mark_inside_the_window
	#   see        SetWindow, ClearWindow
	def WindowOn(pcPath, pnReach)
		This._RequireOpen("WindowOn")
		@oPic.WindowOn(pcPath, pnReach)
		return This

	# Shows only a part of the picture for the open frame: a window given by its centre and its size.
	#
	#   pnCx       the x of the window's centre, in pixels
	#   pnCy       the y of its centre
	#   pnW        its width
	#   pnH        its height
	#   returns    the storyboard itself, so calls chain
	#   warning    with no frame open it raises open a frame first; a width or height that is not
	#              positive raises an error
	#   see        WindowOn, ClearWindow
	def SetWindow(pnCx, pnCy, pnW, pnH)
		This._RequireOpen("SetWindow")
		@oPic.SetWindow(pnCx, pnCy, pnW, pnH)
		return This

	# Shows the whole picture again for the open frame.
	#
	#   returns    the storyboard itself, so calls chain
	#   warning    with no frame open it raises open a frame first
	#   see        WindowOn, SetWindow
	def ClearWindow()
		This._RequireOpen("ClearWindow")
		@oPic.ClearWindow()
		return This

	# Changes the picture between two frames with one of its verbs, so the next frame shows what the change did.
	#
	#   pcVerb     DragTo, SetData or SetTheme
	#   paArgs     the verb's arguments: a shape, an x and a y for DragTo
	#   returns    the storyboard itself, so calls chain
	#   note       with SetTheme dark the paper was dark grey and the sets pale grey
	#   warning    any other verb raises that it is not an action a frame takes, and too few
	#              arguments for DragTo or SetData raise an error naming what is needed; with no
	#              frame open it raises open a frame first
	#   see        Frame, ClearMarks
	#@ aka  AN ACTION IS WHAT TURNS A PICTURE INTO A DEMONSTRATION. Between two frames something changes -- a point is dragged, a datum is set -- and the next frame shows what that did. The verbs are the picture's own.
	def Act(pcVerb, paArgs)
		This._RequireOpen("Act")
		_v_ = StzLower(ring_trim("" + pcVerb))
		_a_ = paArgs
		if NOT isList(_a_)  _a_ = [ _a_ ]  ok
		if _v_ = "dragto"
			if len(_a_) < 3
				stzraise("stzStoryboard.Act: DragTo needs a shape and a place.")
			ok
			@oPic.DragTo("" + _a_[1], _a_[2], _a_[3])
		but _v_ = "setdata"
			if len(_a_) < 3
				stzraise("stzStoryboard.Act: SetData needs an object, a key and a number.")
			ok
			@oPic.SetSubstanceData("" + _a_[1], "" + _a_[2], _a_[3])
		but _v_ = "settheme"
			@oPic.SetPictureTheme("" + _a_[1])
		else
			stzraise("stzStoryboard.Act: '" + _v_ + "' is not an action a frame takes " +
				"-- DragTo, SetData or SetTheme.")
		ok
		return This

	#-- closing, and what closing decides -----------------------------------

	def _RequireOpen(pcWhat)
		if NOT @bOpen
			stzraise("stzStoryboard." + pcWhat + ": open a frame first -- a mark " +
				"belongs to the frame that shows it.")
		ok

	# A FRAME CLOSES ONCE AND FOR ALL: the facts are read, the sentence is
	# filled, the picture is drawn to a file, and the one gate judges it.
	def _CloseOpen()
		if NOT @bOpen  return  ok
		_aH_ = []
		for _i_ = 1 to len(@aHoles)
			# an empty kind means the fact was handed in whole, from whichever
			# plane reached it
			if @aHoles[_i_][2] = ""
				_f_ = @aHoles[_i_][3]
			else
				_f_ = @oPic.Fact(@aHoles[_i_][2], @aHoles[_i_][3])
			ok
			# WHICH FORM THE AUTHOR ASKED FOR is what must be checked: a
			# caption may show a fact's number, or its sentence, or its unit,
			# and holding it to the number when it quotes the sentence would
			# be the check misreading the caption rather than the caption
			# misreading the fact.
			_cH_ = @aHoles[_i_][1]
			_aExp_ = []
			if StzFindFirst("{" + _cH_ + "}", @cOpen) > 0
				_aExp_ + StzFactNumText(_f_[:value])
			ok
			if StzFindFirst("{" + _cH_ + ".message}", @cOpen) > 0
				_aExp_ + ("" + _f_[:message])
			ok
			if StzFindFirst("{" + _cH_ + ".unit}", @cOpen) > 0
				_aExp_ + ("" + _f_[:unit])
			ok
			_aH_ + [ _cH_, _f_, StzFactNumText(_f_[:value]), _aExp_ ]
		next
		_c_ = @cOpen
		for _i_ = 1 to len(_aH_)
			_c_ = StzReplace(_c_, "{" + _aH_[_i_][1] + "}", _aH_[_i_][3])
			_c_ = StzReplace(_c_, "{" + _aH_[_i_][1] + ".message}", "" + _aH_[_i_][2][:message])
			_c_ = StzReplace(_c_, "{" + _aH_[_i_][1] + ".unit}", "" + _aH_[_i_][2][:unit])
		next
		_n_ = len(@aFrames) + 1
		_cN_ = "" + _n_
		if _n_ < 10  _cN_ = "0" + _n_  ok
		_cFile_ = @cName + "_" + _cN_ + ".png"
		@oPic.ToPNG(@cFolio + "/" + _cFile_)
		_aF_ = StzCheckPictures([ [ @cName + "/" + _cN_, @oPic ] ]).Findings()
		@aFrames + [ @cOpen, _c_, _cFile_, _aH_, _aF_, @oPic.NumberOfMarks(), @bExpect ]
		@bOpen = FALSE
		@bExpect = FALSE
		@cOpen = ""
		@aHoles = []

	# Returns how many frames were written, closing the open one first.
	#
	#   returns    a number
	#   see        Caption, FileOf
	#@ aka  -- what the storyboard is, once written --------------------------------
	def NumberOfFrames()
		This._CloseOpen()
		return len(@aFrames)

	# Returns the sentence of a frame with its holes filled by the facts.
	#
	#   pnI        the frame's position, from 1
	#   returns    a text
	#   note       it closes the open frame first
	#   warning    a position out of range raises an error
	#   see        RawCaption, HolesOf
	def Caption(pnI)
		This._CloseOpen()
		return @aFrames[pnI][2]

	# Returns the sentence of a frame as it was written, with its holes still open.
	#
	#   pnI        the frame's position, from 1
	#   returns    a text
	#   warning    a position out of range raises an error
	#   see        Caption
	def RawCaption(pnI)
		This._CloseOpen()
		return @aFrames[pnI][1]

	# Returns the name of the PNG file of a frame, inside the folio.
	#
	#   pnI        the frame's position, from 1
	#   returns    a text such as sets_01.png
	#   warning    a position out of range raises an error
	#   see        Folio, Render
	def FileOf(pnI)
		This._CloseOpen()
		return @aFrames[pnI][3]

	# Returns the holes of a frame with the fact each one was filled from.
	#
	#   pnI        the frame's position, from 1
	#   returns    a list of [ hole, fact, shown text, expected texts ]
	#   warning    a position out of range raises an error
	#   see        Bind, NumberOfHoles
	def HolesOf(pnI)
		This._CloseOpen()
		return @aFrames[pnI][4]

	# Returns what the picture gate found against a frame, as findings.
	#
	#   pnI        the frame's position, from 1
	#   returns    a list of findings; empty when the frame is lawful
	#   warning    a position out of range raises an error
	#   see        Judge, ExpectsFindings
	def FindingsOf(pnI)
		This._CloseOpen()
		return @aFrames[pnI][5]

	# TRUE if the frame was declared to be about something the gate finds.
	#
	#   pnI        the frame's position, from 1
	#   returns    1 or 0
	#   warning    a position out of range raises an error
	#   see        ExpectFindings, Judge
	def ExpectsFindings(pnI)
		This._CloseOpen()
		return @aFrames[pnI][7]

	# Returns how many numbers the frames show, all of them read from facts.
	#
	#   returns    a number
	#   see        HolesOf, Judge
	#@ aka  how many numbers this narration shows, all of them from facts
	def NumberOfHoles()
		This._CloseOpen()
		_n_ = 0
		for _i_ = 1 to len(@aFrames)
			_n_ += len(@aFrames[_i_][4])
		next
		return _n_

	# Returns the faults of the storyboard: what the gate found in each frame, and each hole checked against its fact.
	#
	#   returns    a list of findings; empty when every frame and every number holds
	#   note       a frame declared with ExpectFindings does not fail for what the gate finds in it
	#   warning    the rules are hole_left_open, fact_bound_but_never_shown,
	#              hole_not_filled_from_its_fact and expected_a_finding_and_got_none, besides the
	#              gate's own findings
	#   see        IsClean, FindingsOf, ExpectFindings
	#@ aka  EVERY FRAME THROUGH THE GATE, EVERY HOLE HELD TO ITS FACT. The second half is what makes a filled caption evidence rather than decoration: the number the reader sees must be the number the fact reported, and a hole the author never bound must not survive into the sentence.
	def Judge()
		This._CloseOpen()
		_a_ = []
		for _i_ = 1 to len(@aFrames)
			if @aFrames[_i_][7]
				# the frame is about what the gate finds, so finding it is the
				# frame working -- and finding NOTHING is the frame lying
				if len(@aFrames[_i_][5]) = 0
					_a_ + [ :rule = "expected_a_finding_and_got_none", :subject = :frame,
					        :where = @cName + " frame " + _i_, :severity = :error,
					        :message = "this frame says it shows something the gate finds, " +
					          "and the gate finds nothing in it" ]
				ok
			else
				for _k_ = 1 to len(@aFrames[_i_][5])
					_a_ + [ :rule = "" + @aFrames[_i_][5][_k_][:rule], :subject = :frame,
					        :where = @cName + " frame " + _i_, :severity = :error,
					        :message = "" + @aFrames[_i_][5][_k_][:message] ]
				next
			ok
			for _k_ = 1 to len(@aFrames[_i_][4])
				_aE_ = @aFrames[_i_][4][_k_][4]
				if len(_aE_) = 0
					_a_ + [ :rule = "fact_bound_but_never_shown", :subject = :frame,
					        :where = @cName + " frame " + _i_, :severity = :error,
					        :message = "the fact '" + @aFrames[_i_][4][_k_][1] + "' was " +
					          "bound and the caption never quotes it" ]
					loop
				ok
				for _q_ = 1 to len(_aE_)
					if StzFindFirst(_aE_[_q_], @aFrames[_i_][2]) = 0
						_a_ + [ :rule = "hole_not_filled_from_its_fact", :subject = :frame,
						        :where = @cName + " frame " + _i_, :severity = :error,
						        :message = "the caption does not show '" + _aE_[_q_] +
						          "', which is what the fact '" +
						          @aFrames[_i_][4][_k_][1] + "' reports" ]
					ok
				next
			next
			if StzFindFirst("{", @aFrames[_i_][2]) > 0
				_a_ + [ :rule = "hole_left_open", :subject = :frame,
				        :where = @cName + " frame " + _i_, :severity = :error,
				        :message = "the caption still holds a hole nothing was bound to: " +
				          @aFrames[_i_][2] ]
			ok
		next
		return _a_

	# TRUE if Judge finds nothing.
	#
	#   returns    1 or 0
	#   see        Judge
	def IsClean()
		return len(This.Judge()) = 0

	# Writes the page that puts the frames in order with their sentences and the verdict, and returns its path.
	#
	#   returns    a text, the path of the HTML page
	#   note       the page is named after the storyboard and sits in the folio, beside the frame
	#              files
	#   see        ToNarration, Rendition
	#@ aka  -- the folio, and the page ---------------------------------------------
	def Render()
		This._CloseOpen()
		_c_ = "<!doctype html>" + char(10) +
			"<html><head><meta charset='utf-8'><title>" + @cName + "</title>" + char(10) +
			"<style>body{font:16px/1.6 system-ui,sans-serif;max-width:820px;margin:2rem auto;" +
			"padding:0 1rem;color:#1e2230;background:#fafaf7}" +
			"h1{font-size:1.7rem;font-weight:600}figure{margin:2rem 0}" +
			"img{max-width:100%;border:1px solid #dcdde4;border-radius:6px;display:block}" +
			"figcaption{margin-top:.6rem;display:grid;grid-template-columns:2rem 1fr;gap:.5rem}" +
			".n{color:#4b57cc;font-weight:600}" +
			".v{margin-top:2rem;padding-top:1rem;border-top:1px solid #dcdde4;color:#676c7e;font-size:.95rem}" +
			"</style></head><body>" + char(10) +
			"<h1>" + @cName + "</h1>" + char(10)
		for _i_ = 1 to len(@aFrames)
			_c_ += "<figure><img src='" + @aFrames[_i_][3] + "' alt='frame " + _i_ + "'>" +
				"<figcaption><span class='n'>" + _i_ + "</span><span>" +
				@aFrames[_i_][2] + "</span></figcaption></figure>" + char(10)
		next
		_aJ_ = This.Judge()
		_c_ += "<p class='v'>" + len(@aFrames) + " frames, " + This.NumberOfHoles() +
			" numbers, none of them typed. "
		if len(_aJ_) = 0
			_c_ += "Every frame passed the picture gate, and every number shown is the " +
				"number its fact reported.</p>" + char(10)
		else
			_c_ += "" + len(_aJ_) + " findings:</p><ul>" + char(10)
			for _i_ = 1 to len(_aJ_)
				_c_ += "<li>" + _aJ_[_i_][:where] + ": " + _aJ_[_i_][:message] + "</li>" + char(10)
			next
			_c_ += "</ul>" + char(10)
		ok
		_c_ += "</body></html>" + char(10)
		write(@cFolio + "/" + @cName + ".html", _c_)
		return @cFolio + "/" + @cName + ".html"

	# Writes the storyboard as a .narration document, with each caption as prose with its holes open and each number as a cell.
	#
	#   pcPath     the file to write
	#   returns    a text, the path written
	#   note       the format is the sibling narration grammar v0; the document keeps no output
	#   see        Render
	#@ aka  -- the document ---------------------------------------------------------
	def ToNarration(pcPath)
		# EMITTED IN THE SIBLING'S FORMAT, AND PROVISIONAL UNTIL IT SAYS SO.
		# Softanza Narrations owns `.narration`; this writes the v0 grammar it
		# published on 2026-08-11 -- NARRATION, PROSE and CELL, three kinds and
		# no fourth -- and pins that version here so a change there is a change
		# this must be told about rather than one it silently diverges from.
		This._CloseOpen()
		_q_ = char(34)
		_c_ = "-- " + @cName + ".narration -- " + @cName + ", told in " +
			len(@aFrames) + " frames" + char(10) + char(10) +
			"DEFINE NARRATION " + This._Snake(@cName) + " (" + char(10) +
			"    TITLE " + _q_ + @cName + _q_ + char(10) +
			"    PINS   [ commons:1.0 ]" + char(10) +
			") RATIONALE " + _q_ + "Emitted by stzStoryboard against .narration " +
			"grammar v0; every number in the prose is a cell below, never a " +
			"stored output." + _q_ + char(10) + char(10)
		for _i_ = 1 to len(@aFrames)
			_c_ += "DEFINE PROSE frame_" + _i_ + " (" + char(10) +
				"    TEXT <[" + char(10) + @aFrames[_i_][1] + char(10) +
				"    ]>" + char(10) + ") RATIONALE " + _q_ +
				"Frame " + _i_ + " of " + len(@aFrames) + "." + _q_ + char(10) + char(10)
			_c_ += "DEFINE CELL picture_" + _i_ + " (" + char(10) +
				"    SOURCE <[" + char(10) +
				"oStory.FileOf(" + _i_ + ")" + char(10) +
				"    ]>" + char(10) + ") RATIONALE " + _q_ +
				"The picture is named here and drawn on arrival, never stored." +
				_q_ + char(10) + char(10)
			for _k_ = 1 to len(@aFrames[_i_][4])
				_c_ += "DEFINE CELL " + This._Snake(@aFrames[_i_][4][_k_][1]) + "_" + _i_ +
					" (" + char(10) + "    SOURCE <[" + char(10) +
					"oStory.HolesOf(" + _i_ + ")[" + _k_ + "][2][:value]" + char(10) +
					"    ]>" + char(10) + ") RATIONALE " + _q_ +
					"The number the prose shows for {" + @aFrames[_i_][4][_k_][1] +
					"}: computed, and checked against the picture." + _q_ + char(10) + char(10)
			next
		next
		write(pcPath, _c_)
		return pcPath

	def _Snake(pcName)
		_c_ = StzLower("" + pcName)
		_o_ = ""
		for _i_ = 1 to len(_c_)
			_a_ = ascii(_c_[_i_])
			if (_a_ >= 97 and _a_ <= 122) or (_a_ >= 48 and _a_ <= 57)
				_o_ += _c_[_i_]
			but len(_o_) > 0 and StzRight(_o_, 1) != "_"
				_o_ += "_"
			ok
		next
		if _o_ = ""  _o_ = "narration"  ok
		return _o_

	# Returns the storyboard as a value that says it is markup, the page of its frames.
	#
	#   returns    a rendition of the kind markup
	#   see        RenditionAs, RenditionKinds
	#@ aka  -- A VALUE THAT SAYS WHAT IT IS (DN9g) ---------------------------------
	def Rendition()
		return This.RenditionAs(:markup)

	# Returns the forms the storyboard can take as a value.
	#
	#   returns    a list: markup and text
	#   see        RenditionAs
	def RenditionKinds()
		return [ :markup, :text ]

	# Returns the storyboard as a value of the kind asked: markup, the HTML page, or text, the numbered captions.
	#
	#   pcKind     markup or text
	#   returns    a rendition value with its kind, its media type and its content
	#   note       text gives one numbered line per caption
	#   warning    any other kind raises that it is not a way a storyboard shows itself
	#   see        Rendition, Render
	def RenditionAs(pcKind)
		This._CloseOpen()
		_k_ = StzLower(ring_trim("" + pcKind))
		if _k_ = "markup"
			return StzRendition(:markup, "text/html", read(This.Render()), "",
				@cName + ", told in " + len(@aFrames) + " frames")
		but _k_ = "text"
			_c_ = ""
			for _i_ = 1 to len(@aFrames)
				_c_ += "" + _i_ + ". " + @aFrames[_i_][2] + char(10)
			next
			return StzRendition(:text, "text/plain", _c_, "",
				@cName + ", told in " + len(@aFrames) + " frames")
		ok
		stzraise("stzStoryboard.RenditionAs: '" + _k_ + "' is not a way a storyboard " +
			"shows itself -- markup or text.")

	# Reads a fact from the picture as it stands now, without changing it.
	#
	#   pcKind     the kind of fact, such as :value or :distance
	#   paArgs     the list of arguments of that fact
	#   returns    a fact, as a hashlist with its kind, subject, value, unit, where and message
	#   note       Fact(:value, [ "B.icon.r" ]) gave 46.40 px for the smaller set in the test
	#   see        Bind, BindFact
	#@ aka  -- reading the picture, without being able to mutate it by accident ----
	def Fact(pcKind, paArgs)
		return @oPic.Fact(pcKind, paArgs)

	# Returns the storyboard's name.
	#
	#   returns    a text
	#   see        Folio, FileOf
	def PictureName()
		return @cName

	# Returns the folder that receives the frame files and the page.
	#
	#   returns    a text; a point when none was given
	#   see        FileOf, Render
	def Folio()
		return @cFolio
