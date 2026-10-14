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

# Caps the retries of a whole workload with an engine token bucket, so a storm of failures cannot turn into a retry storm.
#
# A budget of N retries refills over a window of W seconds, at floor(N / W) retries a second and
# never less than one. Ask Allow before every retry; when it answers FALSE, fail instead of
# retrying. One budget guards one workload; for many independent keys use stzRateLimiter.
#
#   receiver   o1 = new stzRetryBudget(5, 10)
#   example    ? o1.Allow()
#              #--> 1
#              ? o1.AllowN(5)
#              #--> 0
#              ? o1.RefillPerSecond()
#              #--> 1
#              o1.Destroy()
#   see        stzRateLimiter, stzCancelToken
class stzRetryBudget from stzObject

	pHandle = ""
	bReady  = 0
	nBudget = 0
	nWindow = 1
	nRefill = 1

	# Creates a retry budget: a token bucket of pnBudget retries that refills over a window of pnWindowSeconds.
	#
	#   pnBudget          how many retries the bucket holds
	#   pnWindowSeconds   the seconds over which the budget refills, raised to 1 if smaller
	#   returns           nothing; the object is built
	#   warning           the refill rate is floor(pnBudget / pnWindowSeconds) tokens a second, with
	#                     a minimum of 1
	#   see               Allow, RefillPerSecond
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
		if bReady = 0
			nRefill = nBudget / nWindow
			if nRefill < 1
				nRefill = 1
			ok
			pHandle = StzEngineRateCreate(nBudget, nRefill)
			bReady = 1
		ok

	# Takes one retry from the budget and answers whether the retry may go ahead.
	#
	#   returns    TRUE or FALSE
	#   warning    refuses once the budget is spent and recovers as the window refills
	#   see        AllowN, Available, Spend
	#@ aka  Spend one retry. Returns TRUE if the budget allowed it. (Named Allow, not Try -- `try` is a Ring keyword.)
	def Allow()
		This._Ensure()
		return StzEngineRateTryTake(pHandle, 1) = 1

	# Takes one retry from the budget and answers whether it may go ahead, as the call with the other name does.
	#
	#   returns    TRUE or FALSE
	#   see        Allow, AllowN
	#@ aka  Alias for Allow().
	def Spend()
		This._Ensure()
		return StzEngineRateTryTake(pHandle, 1) = 1

	# Takes n retries from the budget at once and answers whether they may all go ahead.
	#
	#   n          how many retries to take
	#   returns    TRUE or FALSE
	#   warning    a refused request takes nothing; n of 0 is allowed
	#   see        Allow, Available
	#@ aka  Spend n retries at once (all-or-nothing). Returns TRUE if granted.
	def AllowN(n)
		This._Ensure()
		return StzEngineRateTryTake(pHandle, n) = 1

	# Returns how many retries are left in the budget, as a decimal.
	#
	#   returns    a number
	#   warning    the budget refills continuously, so a reading just after a spend is slightly
	#              above the exact remainder
	#   see        Allow, Budget
	#@ aka  Tokens (retries) currently available -- a float, refills continuously.
	def Available()
		This._Ensure()
		return StzEngineRateAvailable(pHandle)

	# Returns the size of the budget, as given at construction.
	#
	#   returns    a number
	#   see        Window, Available
	def Budget()
		return nBudget

	# Returns the refill window in seconds, with a minimum of 1.
	#
	#   returns    a number
	#   see        Budget, RefillPerSecond
	def Window()
		return nWindow

	# Returns how many retries the budget regains each second.
	#
	#   returns    a number
	#   warning    floor(budget / window), never below 1
	#   see        Window, Budget
	def RefillPerSecond()
		return nRefill

	# Frees the engine bucket and marks the object unusable.
	#
	#   returns    the budget itself, so calls chain
	#   warning    a later call builds a new full bucket
	#   see        init
	def Destroy()
		if bReady = 1
			StzEngineRateDestroy(pHandle)
			pHandle = ""
			bReady = 0
		ok
		return This
