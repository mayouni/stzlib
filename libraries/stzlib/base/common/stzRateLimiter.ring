/*
	Softanza rate limiter -- a MULTI-KEY token-bucket admission gate.

	Where stzRetryBudget caps ONE workload's retries, a rate limiter caps
	the REQUEST RATE of many independent KEYS (a facet, a caller, a client
	ip) -- admission control at the front door. Each key gets its own engine
	token bucket (engine/src/resilience.zig, stz_resilience.dll): a bucket of
	`burst` tokens that refills at `ratePerSec` tokens/second, so short bursts
	are absorbed up to the bucket size while the sustained rate is capped.

		oRL = new stzRateLimiter("front")
		oRL.SetLimit("nlp", 100, 20)     # 100 req/s sustained, burst of 20
		if oRL.Allow("nlp")
			# serve
		else
			# 429 -- too many requests for this key
		ok
		? oRL.Available("nlp")           # tokens left (float)
		? oRL.RejectedCount("nlp")
		oRL.Destroy()

	A key with NO configured limit is UNLIMITED (Allow always TRUE) -- you
	opt a key into limiting with SetLimit. Counts (allowed/rejected) are kept
	per key for observability. Named Allow(), not Try() -- `try` is a Ring
	keyword and Ring is case-insensitive (a `Try` method is a C27 error).
*/

func StzRateLimiter(pcName)
	return new stzRateLimiter(pcName)

class stzRateLimiter from stzObject

	@cName = ""
	@aBuckets = []   # [ key, burst, ratePerSec, pHandle, nAllowed, nRejected ]

	def init(pcName)
		@cName = "" + pcName
		@aBuckets = []

	def Name_()
		return @cName

	#-- configuring a key --------------------------------------------------

	# Opt a key into rate limiting: nRatePerSec sustained, nBurst bucket
	# capacity (max tokens = the largest instantaneous burst allowed).
	# Re-configuring a key replaces its bucket.
	def SetLimit(pcKey, nRatePerSec, nBurst)
		_cK_ = StzLower("" + pcKey)
		if nBurst < 1  nBurst = 1  ok
		if nRatePerSec < 1  nRatePerSec = 1  ok
		_i_ = This._IndexOf(_cK_)
		if _i_ > 0
			StzEngineRateDestroy(@aBuckets[_i_][4])   # replace the old bucket
			@aBuckets[_i_][2] = nBurst
			@aBuckets[_i_][3] = nRatePerSec
			@aBuckets[_i_][4] = StzEngineRateCreate(nBurst, nRatePerSec)
			return This
		ok
		@aBuckets + [ _cK_, nBurst, nRatePerSec,
		              StzEngineRateCreate(nBurst, nRatePerSec), 0, 0 ]
		return This

	def HasLimit(pcKey)
		return This._IndexOf(StzLower("" + pcKey)) > 0

	def Keys()
		_a_ = []
		_n_ = len(@aBuckets)
		for _i_ = 1 to _n_
			_a_ + @aBuckets[_i_][1]
		next
		return _a_

	#-- the gate -----------------------------------------------------------

	# Try to admit ONE request for a key. An unconfigured key is UNLIMITED
	# (always TRUE). A configured key takes a token: TRUE while the bucket
	# has one, FALSE (rate limited) once spent, recovering as it refills.
	def Allow(pcKey)
		return This.AllowN(pcKey, 1)

	# Admit n at once (all-or-nothing). Counts one allowed / one rejected
	# DECISION regardless of n.
	def AllowN(pcKey, n)
		_i_ = This._IndexOf(StzLower("" + pcKey))
		if _i_ = 0  return TRUE  ok     # no limit configured -> unlimited
		if StzEngineRateTryTake(@aBuckets[_i_][4], n) = 1
			@aBuckets[_i_][5]++          # allowed
			return TRUE
		ok
		@aBuckets[_i_][6]++              # rejected
		return FALSE

	#-- metrics ------------------------------------------------------------

	# Tokens currently available for a key (a float; refills continuously).
	# Returns -1 for an unconfigured (unlimited) key.
	def Available(pcKey)
		_i_ = This._IndexOf(StzLower("" + pcKey))
		if _i_ = 0  return -1  ok
		return StzEngineRateAvailable(@aBuckets[_i_][4])

	def AllowedCount(pcKey)
		_i_ = This._IndexOf(StzLower("" + pcKey))
		if _i_ = 0  return 0  ok
		return @aBuckets[_i_][5]

	def RejectedCount(pcKey)
		_i_ = This._IndexOf(StzLower("" + pcKey))
		if _i_ = 0  return 0  ok
		return @aBuckets[_i_][6]

	def RateOf(pcKey)
		_i_ = This._IndexOf(StzLower("" + pcKey))
		if _i_ = 0  return 0  ok
		return @aBuckets[_i_][3]

	def BurstOf(pcKey)
		_i_ = This._IndexOf(StzLower("" + pcKey))
		if _i_ = 0  return 0  ok
		return @aBuckets[_i_][2]

	def Narrate()
		_cR_ = "rate limiter " + @cName + " [" + len(@aBuckets) + " key(s)]:"
		_n_ = len(@aBuckets)
		for _i_ = 1 to _n_
			_cR_ += char(10) + "  " + @aBuckets[_i_][1] + " " + @aBuckets[_i_][3] +
				"/s burst=" + @aBuckets[_i_][2] + " allowed=" + @aBuckets[_i_][5] +
				" rejected=" + @aBuckets[_i_][6]
		next
		return _cR_

	#-- teardown (engine buckets hold native handles) ----------------------

	def Destroy()
		_n_ = len(@aBuckets)
		for _i_ = 1 to _n_
			StzEngineRateDestroy(@aBuckets[_i_][4])
		next
		@aBuckets = []
		return This

	#-- internals ----------------------------------------------------------

	def _IndexOf(pcKey)
		_n_ = len(@aBuckets)
		for _i_ = 1 to _n_
			if @aBuckets[_i_][1] = pcKey  return _i_  ok
		next
		return 0
