/*
	Softanza reactor pool -- gap-analysis Tier 2 (horizontal scale).

	N reactors, each a libuv loop on its own thread (epoll/kqueue/IOCP).
	This is libuv's recommended multi-loop scaling model: work is
	round-robined across the loops, and each loop multiplexes many
	concurrent connections. Ring stays synchronous -- submit a batch, then
	await the results.

		_oPool_ = new stzReactorPool(4)         # 4 loops / threads
		_aReqs_ = [
		    ["example.com", 80, cReq],
		    ["example.org", 80, cReq2]
		]
		_aBodies_ = _oPool_.FetchAll(_aReqs_, 15000) # all run in parallel
		_oPool_.Destroy()

	Note on scale: confirm your workload actually needs many thousands of
	concurrent connections before sizing the pool large -- for most uses a
	handful of loops (or even the single-reactor + thread-pool path) is
	plenty. See base/doc/design/TIER2_REACTOR_DIRECTION.md.
*/

func StzReactorPool(nWorkers)
	return new stzReactorPool(nWorkers)

class stzReactorPool from stzObject

	_aReactors_ = []
	_nNext_ = 1

	def init(nWorkers)
		_n_ = nWorkers
		if _n_ < 1
			_n_ = 1
		ok
		for _i_ = 1 to _n_
			_aReactors_ + new stzReactor()
		next

	def Count()
		return len(_aReactors_)

	# Round-robin pick of the next loop.
	def _Pick()
		_oR_ = _aReactors_[_nNext_]
		_nNext_++
		if _nNext_ > len(_aReactors_)
			_nNext_ = 1
		ok
		return _oR_

	# Submit a whole batch across the loops (so they run concurrently),
	# then await each. aRequests is a list of [cHost, nPort, cPayload].
	# Returns a list of response bodies (same order as the input).
	def FetchAll(aRequests, nTimeoutMs)
		_aJobs_ = []
		_nL_ = len(aRequests)
		for _i_ = 1 to _nL_
			_oR_ = This._Pick()
			_req_ = aRequests[_i_]
			_nId_ = _oR_.SubmitTcp(_req_[1], _req_[2], _req_[3])
			_aJobs_ + [ _oR_, _nId_ ]
		next
		_aBodies_ = []
		_nJ_ = len(_aJobs_)
		for _i_ = 1 to _nJ_
			_aBodies_ + _aJobs_[_i_][1].AwaitTcp(_aJobs_[_i_][2], nTimeoutMs)
		next
		return _aBodies_

	def Destroy()
		_nL_ = len(_aReactors_)
		for _i_ = 1 to _nL_
			_aReactors_[_i_].Destroy()
		next
		_aReactors_ = []
		_nNext_ = 1
		return This
