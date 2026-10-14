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

# Captures every message instead of sending it, so a magic link or a one-time code lands in an inbox a test can read.
#
# A mail port is any object with Send(to, subject, body). This sandbox is the development stand-in:
# free, deterministic and offline, it records what would have gone out and never delivers, so an
# agent set loose with only a sandbox port causes no real effect. The captured messages live in a
# shared sink keyed by an id, so a copy of the object, which Ring makes when it is stored in another
# object, reads and writes the same sink. At deploy you bind your own adapter behind the same one-
# method contract. It does not validate addresses or text.
#
#   receiver   o1 = new stzMailSandbox()
#   example    o1.Send("aicha@example.com", "Your code", "Code 492039")
#              o1.Send("zin@example.com", "Hello", "Hi Zin")
#              ? o1.Count()
#              #--> 2
#              ? o1.LastTo()
#              #--> zin@example.com
#              ? o1.InboxOf("aicha@example.com")[1][:body]
#              #--> Code 492039
#              ? o1.IsSandbox()
#              #--> 1
#   see        stzSmsSandbox, stzServiceRegistry, stzAuth
class stzMailSandbox from stzObject

	@nId = 0       # index into $aStzMailSinks (survives a copy -> shared sink)

	# Builds a mail capture sink with an empty inbox, a shared slot that copies of the object also use.
	#
	#   returns    nothing; the object is built
	#   see        Send, Sent
	def init()
		$nStzMailSinkSeq = $nStzMailSinkSeq + 1
		@nId = $nStzMailSinkSeq
		$aStzMailSinks + [ @nId, [] ]

	# Captures a message that would have been sent and delivers nothing, so a test can assert on it.
	#
	#   pcTo        the recipient
	#   pcSubject   the subject line
	#   pcBody      the message text
	#   returns     the sandbox itself, so calls chain
	#   note        the message gets a sequence number
	#   warning     nothing is validated: a recipient or subject holding a line break, such as a
	#               header-injection attempt, is captured as given, so a test passes on input that a
	#               real mail adapter must refuse
	#   see         Sent, InboxOf
	#@ aka  -- the PORT contract -----------------------------------------------
	def Send(pcTo, pcSubject, pcBody)
		_i_ = This._SinkIndex()
		_seq_ = len($aStzMailSinks[_i_][2]) + 1
		$aStzMailSinks[_i_][2] + [ :to = "" + pcTo, :subject = "" + pcSubject,
		                           :body = "" + pcBody, :seq = _seq_ ]
		return This

	# TRUE if the object is a test double; here it always is, so the registry can refuse it in production.
	#
	#   returns    TRUE
	#   see        stzServiceRegistry
	#@ aka  A double says so itself. The registry asks this rather than guessing from a class name, and it is what makes "no sandbox in production" enforceable.
	def IsSandbox()
		return 1

	# Returns every captured message, in order.
	#
	#   returns    a list of hash lists [ :to, :subject, :body, :seq ]
	#   see        Last, InboxOf
	#@ aka  -- inspection (what makes the sink assertable) ---------------------
	def Sent()
		return $aStzMailSinks[This._SinkIndex()][2]

	# Returns how many messages are captured.
	#
	#   returns    a number
	#   see        Sent, IsEmpty
	def Count()
		return len(This.Sent())

	# TRUE if nothing has been captured.
	#
	#   returns    TRUE or FALSE
	#   see        Count
	def IsEmpty()
		return len(This.Sent()) = 0

	# Returns the last captured message.
	#
	#   returns    a hash list [ :to, :subject, :body, :seq ]; an empty list when none
	#   see        LastBody, LastTo
	def Last()
		_a_ = This.Sent()
		if len(_a_) = 0
			return []
		ok
		return _a_[len(_a_)]

	# Returns the body of the last captured message, such as a magic link or a one-time code.
	#
	#   returns    a text; empty when none
	#   see        Last
	def LastBody()
		_m_ = This.Last()
		if len(_m_) = 0
			return ""
		ok
		return _m_[:body]

	# Returns the recipient of the last captured message.
	#
	#   returns    a text; empty when none
	#   see        Last
	def LastTo()
		_m_ = This.Last()
		if len(_m_) = 0
			return ""
		ok
		return _m_[:to]

	# Returns the captured messages addressed to one recipient.
	#
	#   pcTo       the recipient, matched exactly, case included
	#   returns    a list of hash lists
	#   see        Sent
	#@ aka  every message addressed to one recipient (their "inbox" in the sink).
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

	# Removes every captured message from the sink, keeping the sink itself.
	#
	#   returns    nothing; use ClearQ to chain
	#   see        Sent
	def Clear()
		This.ClearQ()

	def ClearQ()
		$aStzMailSinks[This._SinkIndex()][2] = []
		return This

	# Prints one line with the number of captured messages.
	#
	#   returns    nothing; it prints
	#   see        Count
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
