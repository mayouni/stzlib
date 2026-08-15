#---------------------------------------------------------------------------#
#  STZSCREENREADERBRIDGE -- the tree, handed to the operating system.        #
#---------------------------------------------------------------------------#
#
#     oB = new stzScreenReaderBridge(oWindow)
#     oB.Announce(oTree)                 # ...and again whenever it changes
#     ? oB.TimesRead()                   # did anything actually READ it?
#
# G4b of SOFTANZA_GUI_PLAN.md, and the last half of accessibility. G4a
# built the tree and asserted its laws; this hands it to UI Automation,
# NSAccessibility or AT-SPI -- whichever the machine has -- through
# AccessKit.
#
# WHY THIS IS A THIN CLASS. The tree is already correct and already DATA:
# `stzAccessibilityTree.ToJSON()` is what crosses, unchanged, which is
# Rule 104 taken literally -- what a screen reader can operate, an agent
# can operate, and they read the same document. So this class carries no
# accessibility knowledge at all. It owns a platform connection and a
# lifetime; the meaning lives one layer up, where G4a put it.
#
# WHAT `TimesRead()` IS FOR, and it is the honest number here. A bridge
# that reported success on pushing a tree would look exactly the same on a
# machine with a screen reader and a machine without one. `TimesAnnounced`
# counts what WE did; `TimesRead` counts the times an assistive technology
# actually asked for the tree. On a quiet machine it stays 0, and that is
# the truth rather than a failure.
#
# THE WINDOW IS HIDDEN AND RE-SHOWN when the bridge attaches, because
# AccessKit's subclassing adapter refuses a window that is already
# visible. Attach right after creating the window and nothing flickers.
# The cost is stated here rather than hidden, because a caller who
# attaches mid-session WILL see the window blink and should know why.

func StzScreenReaderBridgeQ(poWindow)
	return new stzScreenReaderBridge(poWindow)

# Is there a bridge to be had on this machine at all? A caller asks this
# before building one, the same way it asks StzGuiAvailable().
func StzScreenReaderAvailable()
	return StzA11yReady()

class stzScreenReaderBridge from stzObject

	@nId = 0
	@nAnnounced = 0
	@cLastError = ""

	def init(poWindow)
		if NOT isObject(poWindow)
			StzRaise("stzScreenReaderBridge: give an stzWindow.")
		ok
		if NOT StzA11yReady()
			# NOT an error. A machine with no vendored runtime, or a
			# platform with no adapter, has no bridge -- and everything
			# else about the program is unaffected. IsLive() says so.
			@cLastError = "no accessibility runtime on this machine"
			return
		ok
		_nH_ = poWindow.NativeHandle()
		if _nH_ = 0
			@cLastError = "the window has no platform handle"
			return
		ok
		_n_ = StzEngineA11yAttach(_nH_)
		if _n_ <= 0
			@cLastError = "" + StzEngineA11yLastError()
			if @cLastError = ""
				@cLastError = "the platform refused the window (status " + _n_ + ")"
			ok
			return
		ok
		@nId = _n_

	def IsLive()
		if @nId = 0
			return FALSE
		ok
		return StzEngineA11yIsLive(@nId) = 1

	def LastError()
		return @cLastError

	#-- the one verb ---------------------------------------------------------

	# Hand over a tree. Call it once at startup and again whenever the
	# interface changed -- a new screen, a focus move, a value edited.
	#
	# Takes an stzAccessibilityTree, or the JSON itself, because the JSON
	# is the contract and a caller that already has one should not have to
	# rebuild the object to say it.
	def Announce(pTree)
		if NOT This.IsLive()
			return FALSE
		ok
		_c_ = ""
		if isString(pTree)
			_c_ = pTree
		but isObject(pTree)
			_c_ = pTree.ToJSON()
		else
			StzRaise("stzScreenReaderBridge.Announce: give a tree or its JSON.")
		ok
		if StzEngineA11yUpdate(@nId, _c_) != 0
			@cLastError = "" + StzEngineA11yLastError()
			return FALSE
		ok
		@nAnnounced++
		return TRUE

	def AnnounceQ(pTree)
		This.Announce(pTree)
		return This

	#-- what actually happened -----------------------------------------------

	# How many times WE handed a tree over.
	def TimesAnnounced()
		return @nAnnounced

	# How many times an assistive technology ASKED for one. This is the
	# number that distinguishes a working bridge from a hopeful one.
	def TimesRead()
		_a_ = This.Stats()
		if len(_a_) < 2
			return 0
		ok
		return _a_[2]

	# How many nodes the platform currently holds.
	def NodeCount()
		_a_ = This.Stats()
		if len(_a_) < 3
			return 0
		ok
		return _a_[3]

	# [ announced, read, nodes ] straight from the bridge, or [].
	def Stats()
		if @nId = 0
			return []
		ok
		return StzEngineA11yStats(@nId)

	# TRUE when something has read the tree at least once -- which is the
	# only evidence available in-process that a screen reader is there.
	def IsBeingRead()
		return This.TimesRead() > 0

	def Free()
		if @nId != 0
			StzEngineA11yDetach(@nId)
			@nId = 0
		ok
