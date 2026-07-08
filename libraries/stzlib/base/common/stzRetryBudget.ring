/*
	Softanza retry budget -- gap-analysis Tier 1 item 5.

	A global cap on retries across a workload, so a storm of transient
	failures cannot turn into a retry storm that hammers a struggling
	downstream. It reuses the engine token-bucket rate limiter
	(engine/src/resilience.zig, stz_resilience.dll) with a budget-shaped
	API: a budget of N retries that refills over a window of W seconds.

		oBudget = new stzRetryBudget(100, 10)   # 100 retries / 10 sec
		if oBudget.Allow()
			# spend one retry -- go ahead
		else
			# budget exhausted -- escalate to failure instead of retrying
		ok
		...
		oBudget.Destroy()

	Internally: capacity = N, refill = floor(N / W) tokens/sec (min 1).
	Allow() takes one token; it succeeds while the budget has tokens and
	refuses once spent, recovering as the window refills.

	NOTE: the method is Allow() (with a Spend() alias), not Try() --
	`try` is a Ring keyword (try/catch/done) and Ring is case-insensitive,
	so a `Try` method raises a C27 syntax error.
*/

func StzRetryBudget(nBudget, nWindowSeconds)
	return new stzRetryBudget(nBudget, nWindowSeconds)

class stzRetryBudget from stzObject

	pHandle = NULL
	bReady  = FALSE
	nBudget = 0
	nWindow = 1
	nRefill = 1

	def init(pnBudget, pnWindowSeconds)
		nBudget = pnBudget
		if pnWindowSeconds < 1
			nWindow = 1
		else
			nWindow = pnWindowSeconds
		ok
		This._Ensure()

	# Lazy handle creation -- robust whether or not init() ran (paren-less
	# `new` skips init in Ring); guarded by a plain boolean.
	def _Ensure()
		if bReady = FALSE
			nRefill = nBudget / nWindow
			if nRefill < 1
				nRefill = 1
			ok
			pHandle = StzEngineRateCreate(nBudget, nRefill)
			bReady = TRUE
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
		return nBudget

	def Window()
		return nWindow

	def RefillPerSecond()
		return nRefill

	def Destroy()
		if bReady = TRUE
			StzEngineRateDestroy(pHandle)
			pHandle = NULL
			bReady = FALSE
		ok
		return This
