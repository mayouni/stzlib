/*
	_stzFolderWatcher_ -- engine-backed folder watcher.
	Backed by a Zig worker thread that polls std.fs at 250ms and
	emits ADD / MOD / DEL events for the Ring side to drain.

	Usage:
	    o = new _stzFolderWatcher_
	    o.Watch("./mydir")
	    aEvents = o.Drain()            # list of [:kind, :name]
	    o.Stop()
*/

class _stzFolderWatcher_ from stzObject

	@hWatcher = NULL    # opaque engine handle
	@cPath = ""
	@bRunning = FALSE

	def init()
		# Nothing to wire up; caller invokes Watch(path) to start.

	def Watch(cPath)
		if @bRunning return This ok
		if NOT isString(cPath) or cPath = "" return This ok
		@cPath = cPath
		@hWatcher = StzEngineFsWatchStart(cPath)
		if StzEngineFsWatchLastError() = ""
			@bRunning = TRUE
		ok
		return This

	def IsRunning()
		return @bRunning

	def Path()
		return @cPath

	def LastError()
		return StzEngineFsWatchLastError()

	# Drain all queued events. Returns a list of [ :kind, :name ]
	# pairs. Caller polls this on a Ring-side schedule (e.g. every
	# tick of a stzReactiveTimer).
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

	def Stop()
		if @bRunning and @hWatcher != NULL
			StzEngineFsWatchStop(@hWatcher)
			@hWatcher = NULL
			@bRunning = FALSE
		ok
		return This
