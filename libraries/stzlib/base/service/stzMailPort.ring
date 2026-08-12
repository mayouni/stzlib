#================================================================#
#  STZMAILPORT -- the mail SERVICE PORT (service-virtualization)   #
#================================================================#

/*--- Send mail through a swappable PORT, not a hard-wired sender.

The first piece of the service-virtualization plane (see
SOFTANZA_SERVICE_VIRTUALIZATION_PLAN.md): a program codes against a duck-typed
SERVICE PORT and binds it to a fee-free SANDBOX while developing, then to a live
adapter at deploy -- the same shape as stzVaultResolver ("any object with
Resolve"), one level up. A mail port is "any object with Send(to, subject, body)".

  stzMailSandbox -- the dev stand-in. It CAPTURES every message and never sends,
    so tests and dev can assert on exactly what WOULD have gone out: the
    magic-link or the email-OTP lands in an inspectable inbox instead of a real
    mailbox. Free, deterministic, offline.

  <your SMTP adapter> -- at deploy you bind any object exposing Send(to, subject,
    body); it actually delivers. Softanza binds to no vendor. A real SMTP client
    is infra-gated (the engine reactor speaks HTTP/TLS, not SMTP), so the live
    adapter is yours to supply behind this same one-method contract.

This is why passwordless auth (stzAuth magic-link / email-OTP) interlocks with
this plane: the factor takes a mail port; in dev the code is captured and
assertable, in production it is really sent -- the SAME code, no fees, no fakes.
And an agent set loose with only a sandbox mail port causes NO real effect: a
captured mail sends nothing.
*/

# The captured messages live in a SHARED sink table keyed by a sandbox id, NOT in
# the object's own attributes. Ring copies an object on `=` (so a sandbox stored
# in stzAuth's @oMailPort is a private copy), but a copy keeps the same id -- so
# both the copy and the original you handed in read + write the SAME sink. This is
# the handle-table workaround for sharing a mutable object across Ring's copy
# boundary (the same reason stzAuthDbStore leans on the sqlite handle). A real
# SMTP adapter is stateless, so it has no such concern.
#
# NOTE: these initializers sit BEFORE the first func/class on purpose -- Ring only
# runs a loaded file's top-level code that precedes its definitions.
$aStzMailSinks   = []   # [ [ id, [ [ :to, :subject, :body, :seq ], ... ] ], ... ]
$nStzMailSinkSeq = 0

func StzMailSandboxQ()
	return new stzMailSandbox()


  #=========================================================#
 #  MAIL SANDBOX -- the fee-free capture sink (dev + tests)  #
#=========================================================#

class stzMailSandbox from stzObject

	@nId = 0       # index into $aStzMailSinks (survives a copy -> shared sink)

	def init()
		$nStzMailSinkSeq = $nStzMailSinkSeq + 1
		@nId = $nStzMailSinkSeq
		$aStzMailSinks + [ @nId, [] ]

	  #-- the PORT contract -----------------------------------------------

	# capture a message. This is the whole contract a mail port must satisfy;
	# the sandbox records instead of delivering.
	def Send(pcTo, pcSubject, pcBody)
		_i_ = This._SinkIndex()
		_seq_ = len($aStzMailSinks[_i_][2]) + 1
		$aStzMailSinks[_i_][2] + [ :to = "" + pcTo, :subject = "" + pcSubject,
		                           :body = "" + pcBody, :seq = _seq_ ]
		return This

	# A double says so itself. The registry asks this rather than guessing from a
	# class name, and it is what makes "no sandbox in production" enforceable.
	def IsSandbox()
		return 1

	  #-- inspection (what makes the sink assertable) ---------------------

	def Sent()
		return $aStzMailSinks[This._SinkIndex()][2]

	def Count()
		return len(This.Sent())

	def IsEmpty()
		return len(This.Sent()) = 0

	def Last()
		_a_ = This.Sent()
		if len(_a_) = 0
			return []
		ok
		return _a_[len(_a_)]

	def LastBody()
		_m_ = This.Last()
		if len(_m_) = 0
			return ""
		ok
		return _m_[:body]

	def LastTo()
		_m_ = This.Last()
		if len(_m_) = 0
			return ""
		ok
		return _m_[:to]

	# every message addressed to one recipient (their "inbox" in the sink).
	def InboxOf(pcTo)
		_t_ = "" + pcTo
		_out_ = []
		_a_ = This.Sent()
		_n_ = len(_a_)
		for _i_ = 1 to _n_
			if _a_[_i_][:to] = _t_
				_out_ + _a_[_i_]
			ok
		next
		return _out_

	def Clear()
		This.ClearQ()

	def ClearQ()
		$aStzMailSinks[This._SinkIndex()][2] = []
		return This

	def Show()
		? "stzMailSandbox: " + This.Count() + " captured message(s)"

	  #-- internals -------------------------------------------------------

	def _SinkIndex()
		_n_ = len($aStzMailSinks)
		for _i_ = 1 to _n_
			if $aStzMailSinks[_i_][1] = @nId
				return _i_
			ok
		next
		$aStzMailSinks + [ @nId, [] ]   # a stray copy -> lazily reattach a sink
		return len($aStzMailSinks)
