/*
	Softanza reactor pool -- gap-analysis Tier 2 (horizontal scale).

	N reactors, each a libuv loop on its own thread (epoll/kqueue/IOCP).
	This is libuv's recommended multi-loop scaling model: work is
	round-robined across the loops, and each loop multiplexes many
	concurrent connections. Ring stays synchronous -- submit a batch, then
	await the results.

		oPool = new stzReactorPool(4)         # 4 loops / threads
		aReqs = [
		    ["example.com", 80, cReq],
		    ["example.org", 80, cReq2]
		]
		aBodies = oPool.FetchAll(aReqs, 15000) # all run in parallel
		oPool.Destroy()

	Note on scale: confirm your workload actually needs many thousands of
	concurrent connections before sizing the pool large -- for most uses a
	handful of loops (or even the single-reactor + thread-pool path) is
	plenty. See base/doc/design/TIER2_REACTOR_DIRECTION.md.
*/

func StzReactorPool(nWorkers)
	return new stzReactorPool(nWorkers)

# Holds several reactors, each an event loop on its own thread, and sends a batch of TCP requests across them at once.
#
# A pool is libuv's multi-loop scaling model: work is round-robined across the loops, each loop
# multiplexes many connections, and Ring stays synchronous, submitting a batch and then awaiting the
# answers in order. A handful of loops is plenty for most uses. FetchAll takes a list of [ host,
# port, payload ] and answers the response texts in the same order. The requests reach the network
# and were not run for this reference.
#
#   receiver   o1 = StzReactorPool(3)
#   example    ? o1.Count()
#              #--> 3
#              ? @@( o1.FetchAll([ ], 100) )
#              #--> [ ]
#              o1.Destroy()
#              ? o1.Count()
#              #--> 0
#              ? StzReactorPool(0).Count()
#              #--> 1
#   see        stzReactor, stzReactiveHttp
class stzReactorPool from stzObject

	@aReactors = []
	@nNext = 1

	# Builds a pool of reactors, each an event loop on its own thread.
	#
	#   nWorkers   the number of loops, 1 or more
	#   returns    nothing; the reactors are started
	#   note       StzReactorPool builds the same object; a handful of loops is plenty for most uses
	#   warning    a value below 1 gives one reactor; a value that is not a number raises error R41
	#              Invalid numeric string
	#   see        Count, FetchAll
	def init(nWorkers)
		_n_ = nWorkers
		if _n_ < 1
			_n_ = 1
		ok
		for _i_ = 1 to _n_
			@aReactors + new stzReactor()
		next

	# Returns how many reactors the pool holds.
	#
	#   returns    a number; 0 after Destroy
	#   see        init, Destroy
	def Count()
		return len(@aReactors)

	# Round-robin pick of the next loop.
	def _Pick()
		_oR_ = @aReactors[@nNext]
		@nNext++
		if @nNext > len(@aReactors)
			@nNext = 1
		ok
		return _oR_

	# Sends a batch of TCP requests across the loops in turn so they run at once, then waits for every answer.
	#
	#   aRequests    a list of [ host, port, payload ]
	#   nTimeoutMs   how long to wait for each answer, in milliseconds
	#   returns      a list of response texts in the order of the requests; [ ] for an empty batch
	#   note         the requests are submitted round-robin and then awaited in order
	#   warning      not run with real requests: it reaches the network; with an empty batch it
	#                answered [ ]
	#   see          Count, Destroy
	#@ aka  Submit a whole batch across the loops (so they run concurrently), then await each. aRequests is a list of [cHost, nPort, cPayload]. Returns a list of response bodies (same order as the input).
	def FetchAll(aRequests, nTimeoutMs)
		_aJobs_ = []
		_nL_ = len(aRequests)
		for _i_ = 1 to _nL_
			_oR_ = This._Pick()
			_req_ = aRequests[_i_]
			_nId_ = _oR_.SubmitTcp(_req_[1], _req_[2], _req_[3])
			_aJobs_ + [ _oR_, _nId_ ]
		next
		aBodies = []
		_nJ_ = len(_aJobs_)
		for _i_ = 1 to _nJ_
			aBodies + _aJobs_[_i_][1].AwaitTcp(_aJobs_[_i_][2], nTimeoutMs)
		next
		return aBodies

	# Destroys every reactor in the pool.
	#
	#   returns    the pool itself, so calls chain
	#   note       after it Count answers 0 and FetchAll must not be used
	#   see        Count, init
	def Destroy()
		_nL_ = len(@aReactors)
		for _i_ = 1 to _nL_
			@aReactors[_i_].Destroy()
		next
		@aReactors = []
		@nNext = 1
		return This
