/*
	stzFolderWatcher -- engine-backed folder watcher.
	Backed by a Zig worker thread that polls std.fs at 250ms and
	emits ADD / MOD / DEL events for the Ring side to drain.

	Usage:
	    o = new stzFolderWatcher
	    o.Watch("./mydir")
	    aEvents = o.Drain()            # list of [:kind, :name]
	    o.Stop()
*/

# Watches a folder in a worker thread of the engine and hands back the files added, modified or deleted since the last look.
#
# Watch starts the worker, which polls the folder about every 250 ms. Drain, called on your own
# schedule, returns the queued events as [ kind, name ] pairs, kind being ADD, MOD or DEL, and
# empties the queue. Stop ends the worker. Events carry the file name inside the folder, not a full
# path.
#
#   receiver   o1 = new stzFolderWatcher
#   example    ? o1.IsRunning()
#              #--> 0
#              ? len(o1.Drain())
#              #--> 0
#   see        stzFolder, stzFile, stzReactiveTimer
class stzFolderWatcher from stzObject

	@hWatcher = ""    # opaque engine handle
	@cPath = ""
	@bRunning = 0

	# Builds a watcher that is not watching anything yet.
	#
	#   returns    nothing; the object is built
	#   see        Watch
	def init()
	# Starts the engine's polling worker on a folder; a running watcher, an empty path or a path that is not a text changes nothing.
	#
	#   cPath      the folder to watch
	#   returns    the watcher itself, so calls chain
	#   note       a second Watch on a running watcher keeps the first folder
	#   warning    a folder that does not exist is accepted as well: IsRunning becomes 1 and
	#              LastError stays empty, so check the folder first
	#   see        Drain, Stop, IsRunning
	#@ aka  Nothing to wire up; caller invokes Watch(path) to start.
	def Watch(cPath)
		if @bRunning return This ok
		if NOT isString(cPath) or cPath = "" return This ok
		@cPath = cPath
		@hWatcher = StzEngineFsWatchStart(cPath)
		if StzEngineFsWatchLastError() = ""
			@bRunning = 1
		ok
		return This

	# TRUE if a watch is running, which Stop ends.
	#
	#   returns    1 or 0, numbers
	#   see        Watch, Stop
	def IsRunning()
		return @bRunning

	# Returns the folder given to the last accepted Watch, an empty text before it.
	#
	#   returns    a text
	#   see        Watch
	def Path()
		return @cPath

	# Returns the engine's last watcher error, an empty text when there is none.
	#
	#   returns    a text
	#   see        Watch
	def LastError()
		return StzEngineFsWatchLastError()

	# Returns the events queued since the last call, files added, modified or deleted in the folder, and empties the queue.
	#
	#   returns    a list of events, each [ [ kind, ADD or MOD or DEL ], [ name, the file name ] ];
	#              [ ] when nothing happened or no watch runs
	#   note       poll it on your own schedule; an event appears within about a quarter of a second
	#              of the change
	#   see        Watch, Stop
	#@ aka  Drain all queued events. Returns a list of [ :kind, :name ] pairs. Caller polls this on a Ring-side schedule (e.g. every tick of a stzReactiveTimer).
	def Drain()
		if NOT @bRunning return [] ok
		_cBlob_ = StzEngineFsWatchPoll(@hWatcher)
		if _cBlob_ = "" return [] ok
		_aLines_ = @split(_cBlob_, char(10))
		_aR_ = []
		_nL_ = len(_aLines_)
		for _i_ = 1 to _nL_
			_line_ = _aLines_[_i_]
			if _line_ = "" loop ok
			_nTab_ = StzFindFirst(char(9), _line_)
			if _nTab_ < 1 loop ok
			_cKind_ = StzLeft(_line_, _nTab_ - 1)
			_cName_ = StzMidToEnd(_line_, _nTab_ + 1)
			_aR_ + [ :kind = _cKind_, :name = _cName_ ]
		next
		return _aR_

	# Ends the polling worker and returns the watcher to the idle state; stopping an idle watcher changes nothing.
	#
	#   returns    the watcher itself, so calls chain
	#   see        Watch, IsRunning
	def Stop()
		if @bRunning and @hWatcher != ""
			StzEngineFsWatchStop(@hWatcher)
			@hWatcher = ""
			@bRunning = 0
		ok
		return This
