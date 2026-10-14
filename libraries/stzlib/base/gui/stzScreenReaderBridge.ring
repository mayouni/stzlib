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

# Hands the accessibility tree of a window to the operating system's screen-reader service and counts whether anything read it.
#
# The class carries no accessibility knowledge: the tree is built and judged by
# stzAccessibilityTree, and its JSON crosses unchanged. The bridge owns a platform connection
# through AccessKit and a lifetime. A machine with no runtime, or a window with no platform handle,
# is not an error, the bridge is simply not live and LastError says why. TimesAnnounced counts what
# the program did and TimesRead counts the times an assistive technology asked, which stays 0 on a
# quiet machine. Attaching to a window hides and re-shows it. The live path needs a real window and
# was not run for this reference: the example uses an object with no platform handle.
#
#   receiver   eval("class StzNoHandleWindow" + char(10) + "def NativeHandle()" + char(10) + "return
#              0") o1 = new stzScreenReaderBridge(new StzNoHandleWindow)
#   example    ? o1.IsLive()
#              #--> 0
#              ? o1.LastError()
#              #--> the window has no platform handle
#              ? o1.Announce("{}")
#              #--> 0
#              ? o1.TimesAnnounced()
#              #--> 0
#              ? @@( o1.Stats() )
#              #--> [ ]
#   see        stzAccessibilityTree, stzWindow, stzPanel
class stzScreenReaderBridge from stzObject

	@nId = 0
	@nAnnounced = 0
	@cLastError = ""

	# Connects a window to the operating system's accessibility service, or records why it could not.
	#
	#   poWindow   the stzWindow whose platform handle is handed to the accessibility runtime
	#   returns    nothing; the bridge is live only if the platform accepted the window
	#   note       no runtime, a window with no platform handle, or a platform that refuses is not
	#              an error: the bridge is simply not live and LastError says why; read from the
	#              code, attaching hides and re-shows the window, so it blinks;
	#              StzScreenReaderAvailable tells beforehand whether a runtime exists; not run with
	#              a real window
	#   warning    a value that is not an object raises error stzScreenReaderBridge: give an
	#              stzWindow
	#   see        IsLive, LastError, Announce
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

	# TRUE if the platform accepted the window and a tree can be handed over.
	#
	#   returns    TRUE or FALSE, as 1 or 0
	#   note       it is 0 for an object whose window had no platform handle, as the one tried here
	#   see        LastError, Announce
	def IsLive()
		if @nId = 0
			return FALSE
		ok
		return StzEngineA11yIsLive(@nId) = 1

	# Returns why the bridge is not live, or why the last tree was refused.
	#
	#   returns    the reason as text, such as the window has no platform handle or no accessibility
	#              runtime on this machine; an empty text when nothing went wrong
	#   see        IsLive, Announce
	def LastError()
		return @cLastError

	# Hands the accessibility tree to the platform, to be called again whenever the interface changes.
	#
	#   pTree      a stzAccessibilityTree, or its JSON as text
	#   returns    TRUE if the platform took the tree, FALSE when the bridge is not live or the
	#              platform refused it; AnnounceQ returns the bridge for chaining
	#   note       on a bridge that is not live it answers FALSE without looking at the argument and
	#              changes no count
	#   warning    read from the code, a value that is neither a tree nor text raises error
	#              stzScreenReaderBridge.Announce: give a tree or its JSON, but only on a live
	#              bridge; not run on a live bridge
	#   see        TimesAnnounced, IsLive
	#@ aka  -- the one verb ---------------------------------------------------------
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

	# Returns how many times a tree was handed over and accepted.
	#
	#   returns    a number; 0 on a bridge that is not live
	#   see        TimesRead, Announce
	#@ aka  -- what actually happened -----------------------------------------------
	def TimesAnnounced()
		return @nAnnounced

	# Returns how many times an assistive technology actually asked for the tree.
	#
	#   returns    a number; 0 on a quiet machine or a bridge that is not live
	#   note       it is the number that tells a working bridge from a hopeful one
	#   see        TimesAnnounced, IsBeingRead
	#@ aka  How many times an assistive technology ASKED for one. This is the number that distinguishes a working bridge from a hopeful one.
	def TimesRead()
		_a_ = This.Stats()
		if len(_a_) < 2
			return 0
		ok
		return _a_[2]

	# Returns how many nodes the platform currently holds.
	#
	#   returns    a number; 0 on a bridge that is not live
	#   see        Stats, TimesAnnounced
	#@ aka  How many nodes the platform currently holds.
	def NodeCount()
		_a_ = This.Stats()
		if len(_a_) < 3
			return 0
		ok
		return _a_[3]

	# Returns the three counters straight from the bridge.
	#
	#   returns    a list [ announced, read, nodes ]; [ ] on a bridge that is not live
	#   see        TimesRead, NodeCount
	#@ aka  [ announced, read, nodes ] straight from the bridge, or [].
	def Stats()
		if @nId = 0
			return []
		ok
		return StzEngineA11yStats(@nId)

	# TRUE if something has read the tree at least once.
	#
	#   returns    TRUE or FALSE, as 1 or 0
	#   note       it is the only in-process evidence that a screen reader is there
	#   see        TimesRead
	#@ aka  TRUE when something has read the tree at least once -- which is the only evidence available in-process that a screen reader is there.
	def IsBeingRead()
		return This.TimesRead() > 0

	# Detaches the bridge from the window.
	#
	#   returns    nothing; the bridge is no longer live
	#   note       freeing a bridge that is not live does nothing
	#   see        IsLive, init
	def Free()
		if @nId != 0
			StzEngineA11yDetach(@nId)
			@nId = 0
		ok
