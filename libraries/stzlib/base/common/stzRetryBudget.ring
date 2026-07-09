/*
	Softanza retry budget -- gap-analysis Tier 1 item 5.

	A global cap on retries across a workload, so a storm of transient
	failures cannot turn into a retry storm that hammers a struggling
	downstream. It reuses the engine token-bucket rate limiter
	(engine/src/resilience.zig, stz_resilience.dll) with a budget-shaped
	API: a budget of N retries that refills over a window of W seconds.

		_oBudget_ = new stzRetryBudget(100, 10)   # 100 retries / 10 sec
		if _oBudget_.Allow()
			# spend one retry -- go ahead
		else
			# budget exhausted -- escalate to failure instead of retrying
		ok
		...
		_oBudget_.Destroy()

	Internally: capacity = N, refill = floor(N / W) tokens/sec (min 1).
	Allow() takes one token; it succeeds while the budget has tokens and
	refuses once spent, recovering as the window refills.

	NOTE: the method is Allow() (with a Spend() alias), not Try() --
	`try` is a Ring keyword (try/catch/done) and Ring is case-insensitive,
	so a `Try` method raises a C27 syntax error.
*/

func StzRetryBudget(_nBudget_, nWindowSeconds)
	return new stzRetryBudget(_nBudget_, nWindowSeconds)

class stzRetryBudget from stzObject

	pHandle = NULL
	_bReady_  = FALSE
	_nBudget_ = 0
	_nWindow_ = 1
	_nRefill_ = 1

	def init(pnBudget, pnWindowSeconds)
		_nBudget_ = pnBudget
		if pnWindowSeconds < 1
			_nWindow_ = 1
		else
			_nWindow_ = pnWindowSeconds
		ok
		This._Ensure()

	# Lazy handle creation -- robust whether or not init() ran (paren-less
	# `new` skips init in Ring); guarded by a plain boolean.
	def _Ensure()
		if _bReady_ = FALSE
			_nRefill_ = _nBudget_ / _nWindow_
			if _nRefill_ < 1
				_nRefill_ = 1
			ok
			pHandle = StzEngineRateCreate(_nBudget_, _nRefill_)
			_bReady_ = TRUE
		ok

	# Spend one retry. Returns TRUE if the budget allowed it.
	# (Named Allow, not Try -- `try` is a Ring keyword.)
	def Allow()
		This._Ensure()
		return StzEngineRateTryTake(pHandle, 1) = 1

	# Alias for Allow().
	def Spend()
		This._Ensure()
		return StzEngineRateTryTake(pHandle, 1) = 1

	# Spend n retries at once (all-or-nothing). Returns TRUE if granted.
	def AllowN(n)
		This._Ensure()
		return StzEngineRateTryTake(pHandle, n) = 1

	# Tokens (retries) currently available -- a float, refills continuously.
	def Available()
		This._Ensure()
		return StzEngineRateAvailable(pHandle)

	def Budget()
		return _nBudget_

	def Window()
		return _nWindow_

	def RefillPerSecond()
		return _nRefill_

	def Destroy()
		if _bReady_ = TRUE
			StzEngineRateDestroy(pHandle)
			pHandle = NULL
			_bReady_ = FALSE
		ok
		return This
