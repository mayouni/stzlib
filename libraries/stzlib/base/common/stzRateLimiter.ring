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

	A key with NO configured limit is UNLIMITED (Allow always 1) -- you
	opt a key into limiting with SetLimit. Counts (allowed/rejected) are kept
	per key for observability. Named Allow(), not Try() -- `try` is a Ring
	keyword and Ring is case-insensitive (a `Try` method is a C27 error).
*/

func StzRateLimiter(pcName)
	return new stzRateLimiter(pcName)

# Admits or refuses requests per key with one engine token bucket each, so short bursts pass and the sustained rate stays capped.
#
# Give each key a rate and a burst with SetLimit, then ask Allow before serving a request. A key
# with no limit is unlimited. Block and BlockFor shut a key out whatever its bucket holds; refusals
# are noted in the refusal ledger. Where stzRetryBudget caps the retries of one workload, this class
# caps the request rate of many independent keys. Destroy frees the engine buckets.
#
#   receiver   o1 = new stzRateLimiter("api") o1.SetLimit("alice", 2, 3)
#   example    ? o1.Allow("alice")
#              #--> 1
#              ? o1.AllowN("alice", 2)
#              #--> 1
#              ? o1.Allow("alice")
#              #--> 0
#              ? o1.RejectedCount("alice")
#              #--> 1
#              ? o1.Allow("bob")
#              #--> 1
#              o1.Destroy()
#   see        stzRetryBudget, stzLatencyHistogram
class stzRateLimiter from stzObject

	@cName = ""
	@aBuckets = []   # [ key, burst, ratePerSec, pHandle, nAllowed, nRejected ]
	@aBlocked = []   # [ key, reason, untilWallMs (0 = until Unblock), nRefused ]

	# Creates an empty rate limiter with a name, ready to receive one limit per key.
	#
	#   pcName     the limiter's name, used in reports and refusal notes
	#   returns    nothing; the object is built
	#   see        SetLimit, Name_
	def init(pcName)
		@cName = "" + pcName
		@aBuckets = []
		@aBlocked = []

	# Blocks a key until it is unblocked, whatever its bucket holds, and notes the refusal reason.
	#
	#   pcKey      the key to block, matched without regard to case
	#   pcReason   why it is blocked, kept for BlockOf and the refusal note
	#   returns    the limiter itself, so calls chain
	#   warning    blocking a key again replaces the earlier block and resets its refused count
	#   see        BlockFor, Unblock, IsBlocked
	#@ aka  -- BLOCKING a source (containment's :ShedSource) ------------------------
	def Block(pcKey, pcReason)
		return This.BlockFor(pcKey, pcReason, 0)

	# Blocks a key for a number of milliseconds, after which the block lifts by itself; 0 or less blocks it without end.
	#
	#   pcKey      the key to block, matched without regard to case
	#   pcReason   why it is blocked
	#   pnMs       how long the block lasts, in milliseconds
	#   returns    the limiter itself, so calls chain
	#   warning    the end of the block is stored as wall-clock epoch milliseconds
	#   see        Block, Unblock, BlockOf
	def BlockFor(pcKey, pcReason, pnMs)
		_cK_ = StzLower("" + pcKey)
		This.Unblock(_cK_)
		_nUntil_ = 0
		if pnMs > 0  _nUntil_ = StzEngineTimeWallMs() + pnMs  ok
		@aBlocked + [ _cK_, "" + pcReason, _nUntil_, 0 ]
		StzNoteRefusal("ratelimit.blocked", _cK_, "ratelimit:" + @cName + "/" + _cK_, "" + pcReason)
		return This

	# Lifts the block on a key; a key that is not blocked changes nothing.
	#
	#   pcKey      the key to unblock, matched without regard to case
	#   returns    the limiter itself, so calls chain
	#   warning    the bucket keeps whatever it held, so a key blocked for a long time may be
	#              refused right after
	#   see        Block, IsBlocked
	def Unblock(pcKey)
		_cK_ = StzLower("" + pcKey)
		_aNew_ = []
		_n_ = len(@aBlocked)
		for _i_ = 1 to _n_
			if @aBlocked[_i_][1] != _cK_
				_aNew_ + @aBlocked[_i_]
			ok
		next
		@aBlocked = _aNew_
		return This

	# TRUE if the key is blocked now.
	#
	#   pcKey      the key to test, matched without regard to case
	#   returns    TRUE or FALSE
	#   see        Block, BlockOf
	def IsBlocked(pcKey)
		return This._BlockIndex(StzLower("" + pcKey)) > 0

	# Returns the block on a key as [ :reason, :until, :refused ], or an empty list when it is not blocked.
	#
	#   pcKey      the key to look up, matched without regard to case
	#   returns    a hashlist; [ ] when not blocked
	#   warning    :until is 0 for a block without end, else epoch milliseconds; :refused counts the
	#              Allow calls the block turned away
	#   see        Block, BlockFor
	#@ aka  [ :reason, :until, :refused ] or [] when the key is not blocked
	def BlockOf(pcKey)
		_i_ = This._BlockIndex(StzLower("" + pcKey))
		if _i_ = 0  return []  ok
		return [ :reason = @aBlocked[_i_][2], :until = @aBlocked[_i_][3], :refused = @aBlocked[_i_][4] ]

	# Returns the keys that are blocked now, lower-cased, after dropping the blocks whose time has run out.
	#
	#   returns    a list of texts
	#   see        BlockOf, Block
	def BlockedKeys()
		This._ExpireBlocks()
		_a_ = []
		_n_ = len(@aBlocked)
		for _i_ = 1 to _n_
			_a_ + @aBlocked[_i_][1]
		next
		return _a_

	def _ExpireBlocks()
		_nNow_ = StzEngineTimeWallMs()
		_aNew_ = []
		_n_ = len(@aBlocked)
		for _i_ = 1 to _n_
			if @aBlocked[_i_][3] = 0 or @aBlocked[_i_][3] > _nNow_
				_aNew_ + @aBlocked[_i_]
			ok
		next
		@aBlocked = _aNew_

	def _BlockIndex(pcKey)
		if len(@aBlocked) = 0  return 0  ok
		This._ExpireBlocks()
		_n_ = len(@aBlocked)
		for _i_ = 1 to _n_
			if @aBlocked[_i_][1] = pcKey  return _i_  ok
		next
		return 0

	# Returns the name the limiter was created with.
	#
	#   returns    a text
	#   see        init
	def Name_()
		return @cName

	# Gives a key its own token bucket: it holds nBurst tokens and refills at nRatePerSec tokens a second.
	#
	#   pcKey         the key to limit, matched without regard to case
	#   nRatePerSec   the sustained rate, in tokens a second
	#   nBurst        the bucket size, the most tokens that can be spent at once
	#   returns       the limiter itself, so calls chain
	#   note          a key with no limit is unlimited
	#   warning       a rate or burst below 1 is raised to 1; setting a key again replaces its
	#                 bucket, which starts full
	#   see           Allow, RateOf, BurstOf
	#@ aka  -- configuring a key --------------------------------------------------
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

	# TRUE if the key has a bucket.
	#
	#   pcKey      the key to test, matched without regard to case
	#   returns    TRUE or FALSE
	#   see        SetLimit, Keys
	def HasLimit(pcKey)
		return This._IndexOf(StzLower("" + pcKey)) > 0

	# Returns the keys that have a bucket, lower-cased, in the order they were set.
	#
	#   returns    a list of texts
	#   see        HasLimit, SetLimit
	def Keys()
		_a_ = []
		_n_ = len(@aBuckets)
		for _i_ = 1 to _n_
			_a_ + @aBuckets[_i_][1]
		next
		return _a_

	# Takes one token from the key's bucket and answers whether the request may go ahead.
	#
	#   pcKey      the key making the request, matched without regard to case
	#   returns    TRUE or FALSE
	#   warning    a key with no limit is always allowed; a blocked key is always refused, and its
	#              refusal is counted on the block and not in RejectedCount
	#   see        AllowN, Available, Block
	#@ aka  -- the gate -----------------------------------------------------------
	def Allow(pcKey)
		return This.AllowN(pcKey, 1)

	# Takes n tokens from the key's bucket at once and answers whether the request may go ahead.
	#
	#   pcKey      the key making the request, matched without regard to case
	#   n          how many tokens the request costs
	#   returns    TRUE or FALSE
	#   warning    n of 0 is always allowed; a refused request takes nothing from the bucket
	#   see        Allow, Available
	#@ aka  Admit n at once (all-or-nothing). Counts one allowed / one rejected DECISION regardless of n.
	def AllowN(pcKey, n)
		_cK_ = StzLower("" + pcKey)
		# a BLOCKED key is refused before any bucket is consulted
		_b_ = This._BlockIndex(_cK_)
		if _b_ > 0
			@aBlocked[_b_][4]++
			StzNoteRefusal("ratelimit.shed", _cK_, "ratelimit:" + @cName + "/" + _cK_,
				"blocked: " + @aBlocked[_b_][2])
			return 0
		ok
		_i_ = This._IndexOf(_cK_)
		if _i_ = 0  return 1  ok     # no limit configured -> unlimited
		if StzEngineRateTryTake(@aBuckets[_i_][4], n) = 1
			@aBuckets[_i_][5]++          # allowed
			return 1
		ok
		@aBuckets[_i_][6]++              # rejected
		# Incident I2. The counter above says HOW MANY were shed; it cannot
		# say WHEN, so a steady trickle and a sudden flood read the same
		# from it. A shed is `info` severity on purpose -- shedding is the
		# limiter working, not a failure -- but the TIMES are what turns a
		# burst of them into a detection.
		StzNoteRefusal("ratelimit.shed", "" + pcKey, "ratelimit:" + @cName + "/" + pcKey,
			"the token bucket had no tokens left for this key")
		return 0

	# Returns how many tokens are left in the key's bucket, as a decimal, or -1 for a key with no limit.
	#
	#   pcKey      the key to read, matched without regard to case
	#   returns    a number
	#   warning    the bucket refills continuously, so a reading just after a spend is already a
	#              little above the exact remainder
	#   see        Allow, SetLimit
	#@ aka  -- metrics ------------------------------------------------------------
	def Available(pcKey)
		_i_ = This._IndexOf(StzLower("" + pcKey))
		if _i_ = 0  return -1  ok
		return StzEngineRateAvailable(@aBuckets[_i_][4])

	# Returns how many tokens were granted to the key so far; 0 for an unknown key.
	#
	#   pcKey      the key to read, matched without regard to case
	#   returns    a number
	#   warning    it counts tokens, not calls: AllowN(key, 2) adds 2
	#   see        RejectedCount, AllowN
	def AllowedCount(pcKey)
		_i_ = This._IndexOf(StzLower("" + pcKey))
		if _i_ = 0  return 0  ok
		return @aBuckets[_i_][5]

	# Returns how many requests the key's bucket refused so far; 0 for an unknown key.
	#
	#   pcKey      the key to read, matched without regard to case
	#   returns    a number
	#   warning    requests turned away by a block are not counted here
	#   see        AllowedCount, BlockOf
	def RejectedCount(pcKey)
		_i_ = This._IndexOf(StzLower("" + pcKey))
		if _i_ = 0  return 0  ok
		return @aBuckets[_i_][6]

	# Returns the key's sustained rate in tokens a second; 0 for a key with no limit.
	#
	#   pcKey      the key to read, matched without regard to case
	#   returns    a number
	#   see        BurstOf, SetLimit
	def RateOf(pcKey)
		_i_ = This._IndexOf(StzLower("" + pcKey))
		if _i_ = 0  return 0  ok
		return @aBuckets[_i_][3]

	# Returns the key's bucket size; 0 for a key with no limit.
	#
	#   pcKey      the key to read, matched without regard to case
	#   returns    a number
	#   see        RateOf, SetLimit
	def BurstOf(pcKey)
		_i_ = This._IndexOf(StzLower("" + pcKey))
		if _i_ = 0  return 0  ok
		return @aBuckets[_i_][2]

	# Returns a few lines of text that describe each limited key with its rate, burst and counts.
	#
	#   returns    a text
	#   see        Keys, AllowedCount
	def Narrate()
		_cR_ = "rate limiter " + @cName + " [" + len(@aBuckets) + " key(s)]:"
		_n_ = len(@aBuckets)
		for _i_ = 1 to _n_
			_cR_ += char(10) + "  " + @aBuckets[_i_][1] + " " + @aBuckets[_i_][3] +
				"/s burst=" + @aBuckets[_i_][2] + " allowed=" + @aBuckets[_i_][5] +
				" rejected=" + @aBuckets[_i_][6]
		next
		return _cR_

	# Frees the engine buckets of every key and forgets the limits.
	#
	#   returns    the limiter itself, so calls chain
	#   warning    the blocks are kept
	#   see        SetLimit
	#@ aka  -- teardown (engine buckets hold native handles) ----------------------
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
