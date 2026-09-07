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

class stzStoryboard from stzObject

	@cName = ""
	@oPic = NULL
	@cFolio = "."
	@aFrames = []      # [ cRaw, cFilled, cFile, aHoles, aFindings, nMarks ]
	@cOpen = ""        # the caption of the frame being built, "" when none
	@aHoles = []       # [ [ cHole, aFact ] ] for the frame being built
	@bOpen = FALSE
	@bExpect = FALSE   # this frame is ABOUT something the gate finds

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

	#-- the frames -----------------------------------------------------------

	# Open a frame. The one before it closes here: its caption is filled
	# from the facts bound to it, its picture is drawn and judged, and
	# neither can be changed afterwards.
	def Frame(pcCaption)
		This._CloseOpen()
		@cOpen = "" + pcCaption
		@aHoles = []
		@bOpen = TRUE
		@bExpect = FALSE
		return This

		def FrameQ(pcCaption)
			return This.Frame(pcCaption)

	# the same, on a different picture: a narration may show two solves of
	# one content, or two contents that make one point
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

	# A FRAME MAY BE ABOUT A PICTURE THE GATE FINDS FAULT WITH, and that is
	# not a defect in the telling -- it is often the point. "Here is what
	# goes wrong" is a frame whose picture is meant to be unlawful. So a
	# frame says so, and then the gate's findings are its SUBJECT rather
	# than its failure. A frame that expects findings and gets none is
	# itself reported, because a flag nobody checks is a flag that rots.
	def ExpectFindings()
		This._RequireOpen("ExpectFindings")
		@bExpect = TRUE
		return This

	# BIND A HOLE TO A FACT. The fact is read when the frame closes, not
	# now, so an action later in the same frame still moves the number.
	def Bind(pcHole, pcKind, paArgs)
		This._RequireOpen("Bind")
		@aHoles + [ ring_trim("" + pcHole), "" + pcKind, paArgs ]
		return This

		def BindQ(pcHole, pcKind, paArgs)
			return This.Bind(pcHole, pcKind, paArgs)

	# A FACT FROM ANOTHER PLANE. The fact shape is one shape on purpose
	# (DN9b), so a verdict an org chart reached, or a count a notation
	# picture keeps, can be quoted in a caption about a drawing of it. The
	# caller supplies the fact; the storyboard still holds the caption to
	# it, which is the whole point of binding rather than typing.
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

	#-- what a frame may do to the picture -----------------------------------

	def Show(pcRule)
		This._RequireOpen("Show")
		@oPic.Show(pcRule)
		return This

	def Region(pcRule)
		This._RequireOpen("Region")
		@oPic.Region(pcRule)
		return This

	def Measure(pcA, pcB, paOpts)
		This._RequireOpen("Measure")
		@oPic.Measure(pcA, pcB, paOpts)
		return This

	def Callout(pcTarget, pcText, paOpts)
		This._RequireOpen("Callout")
		@oPic.Callout(pcTarget, pcText, paOpts)
		return This

	def Emphasis(pcTarget, pcMode)
		This._RequireOpen("Emphasis")
		@oPic.Emphasis(pcTarget, pcMode)
		return This

	def ClearMarks()
		This._RequireOpen("ClearMarks")
		@oPic.ClearMarks()
		return This

	def WindowOn(pcPath, pnReach)
		This._RequireOpen("WindowOn")
		@oPic.WindowOn(pcPath, pnReach)
		return This

	def SetWindow(pnCx, pnCy, pnW, pnH)
		This._RequireOpen("SetWindow")
		@oPic.SetWindow(pnCx, pnCy, pnW, pnH)
		return This

	def ClearWindow()
		This._RequireOpen("ClearWindow")
		@oPic.ClearWindow()
		return This

	# AN ACTION IS WHAT TURNS A PICTURE INTO A DEMONSTRATION. Between two
	# frames something changes -- a point is dragged, a datum is set -- and
	# the next frame shows what that did. The verbs are the picture's own.
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

	#-- what the storyboard is, once written --------------------------------

	def NumberOfFrames()
		This._CloseOpen()
		return len(@aFrames)

	def Caption(pnI)
		This._CloseOpen()
		return @aFrames[pnI][2]

	def RawCaption(pnI)
		This._CloseOpen()
		return @aFrames[pnI][1]

	def FileOf(pnI)
		This._CloseOpen()
		return @aFrames[pnI][3]

	def HolesOf(pnI)
		This._CloseOpen()
		return @aFrames[pnI][4]

	def FindingsOf(pnI)
		This._CloseOpen()
		return @aFrames[pnI][5]

	def ExpectsFindings(pnI)
		This._CloseOpen()
		return @aFrames[pnI][7]

	# how many numbers this narration shows, all of them from facts
	def NumberOfHoles()
		This._CloseOpen()
		_n_ = 0
		for _i_ = 1 to len(@aFrames)
			_n_ += len(@aFrames[_i_][4])
		next
		return _n_

	# EVERY FRAME THROUGH THE GATE, EVERY HOLE HELD TO ITS FACT. The second
	# half is what makes a filled caption evidence rather than decoration:
	# the number the reader sees must be the number the fact reported, and
	# a hole the author never bound must not survive into the sentence.
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

	def IsClean()
		return len(This.Judge()) = 0

	#-- the folio, and the page ---------------------------------------------

	# The frames are already drawn, one file each, as they closed. This
	# writes the page that puts them in order with their sentences.
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

	#-- the document ---------------------------------------------------------

	# EMITTED IN THE SIBLING'S FORMAT, AND PROVISIONAL UNTIL IT SAYS SO.
	# Softanza Narrations owns `.narration`; this writes the v0 grammar it
	# published on 2026-08-11 -- NARRATION, PROSE and CELL, three kinds and
	# no fourth -- and pins that version here so a change there is a change
	# this must be told about rather than one it silently diverges from.
	#
	# THE ONE LAW OF THAT FORMAT IS HONOURED BY CONSTRUCTION: the document
	# is plain text and outputs are never stored in it. So a caption goes
	# out as PROSE with its holes STILL OPEN, and every number is a CELL
	# that recomputes on arrival. What is written here can be read a year
	# from now and will either recompute to the same numbers or say why
	# not -- which is the whole reason that law exists.
	#
	# The question of whether this shape conforms was routed to the sibling
	# through Central as DN9-EMITTER-01 and is unanswered; silence is not a
	# veto here, so this is written, pinned and marked, and a correction
	# costs one function.
	def ToNarration(pcPath)
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

	#-- A VALUE THAT SAYS WHAT IT IS (DN9g) ---------------------------------

	# A STORYBOARD IS NOT A PICTURE, and its rendition says so by its kind:
	# markup, the page that puts its frames in order. A consumer choosing a
	# surface from the kind alone therefore opens it as a document rather
	# than trying to draw it, without knowing what class it came from.
	def Rendition()
		return This.RenditionAs(:markup)

	def RenditionKinds()
		return [ :markup, :text ]

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

	#-- reading the picture, without being able to mutate it by accident ----

	def Fact(pcKind, paArgs)
		return @oPic.Fact(pcKind, paArgs)

	def PictureName()
		return @cName

	def Folio()
		return @cFolio
