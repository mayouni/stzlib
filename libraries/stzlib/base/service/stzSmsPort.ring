#================================================================#
#  STZSMSPORT -- the SMS port (a capture sink that counts segments)  #
#================================================================#

/*--- Phase 6, second half: the notification category, and a cost trap.

An SMS port is **"any object with `Send(number, text)`"** returning
`[ :ok, :id, :segments, :encoding, :why ]`. Twilio, Vonage, MessageBird, an
operator gateway -- one verb.

`stzSmsSandbox` is a **capture sink**, the same shape as `stzMailSandbox` from the
passwordless work: it records what would have been sent and delivers nothing, so
the outbox becomes something a test can assert on. That part is unremarkable.

WHAT EARNS THIS FILE ITS PLACE is that SMS is **billed per segment**, and the
segment count is not the character count. It depends on the *alphabet*:

  * text entirely within the **GSM 7-bit alphabet** (GSM 03.38) packs 7 bits per
    character: **160** in one message, and **153** per part once it must be split
    (the other 7 septets carry the concatenation header).
  * one single character outside that alphabet forces the whole message to
    **UCS-2**, at 16 bits each: **70** in one message, **67** per part.

So a 90-character message is ONE segment in English and TWO in Arabic. Adding one
emoji to a 100-character template turns a one-segment message into **two**, and
adding it to a 160-character one turns it into **three** -- the bill for that
campaign doubles or triples, and nothing in the code looks different. Nine
characters are worse still: `^ { } \ [ ~ ] | EUR` are in the GSM *extension* table
and each costs **two** septets, so a message of 160 curly braces is two segments.

That is exactly the class of defect a sandbox should surface, so this one counts
segments and names the encoding, and `TotalSegments()` lets a test assert the bill:

    oSms = new stzSmsSandbox()
    oSms.Send("+21612345678", cTemplate)
    oSms.LastSegments()      # -> 1
    oSms.LastEncoding()      # -> :gsm7 or :ucs2
    oSms.TotalSegments()     # -> assert your cost, as the LLM port does for tokens

Numbers are validated as **E.164** (`+` then 8-15 digits) because a sandbox that
accepts a malformed number lets you ship a bug the real gateway would have caught
-- the same reason the payments sandbox refuses a float.

And as there, **an outage is not a rejection**: `FailNextQ()` yields `:refused`
with nothing recorded in the outbox, while a bad number yields `:rejected`. One
means retry; the other means fix the data. Code that conflates them either spams
or silently drops messages.

THE HONEST LIMIT: a sink proves what you *would* have sent, not that a carrier
would accept it. Real delivery has carrier filtering, sender-ID rules that differ
by country, per-country alphabet quirks, and delivery receipts that arrive
asynchronously -- none of which is modelled here. The Twilio/Vonage adapter binds
the same one method and is infra-gated (account + key + network).
*/

# shared across copies -- see the Ring note in stzServiceRegistry
# [ [ id, outbox, failNext, rejected[], seq ], ... ]
$aStzSmsSandboxes = []
$nStzSmsSandboxSeq = 0

# GSM 03.38 default alphabet, as codepoints. One septet each.
$anStzGsm7Basic = [
	64, 163, 36, 165, 232, 233, 249, 236, 242, 199, 10, 216, 248, 13, 197, 229,
	916, 95, 934, 915, 923, 937, 928, 936, 931, 920, 926, 198, 230, 223, 201,
	32, 33, 34, 35, 164, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47,
	48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 58, 59, 60, 61, 62, 63,
	161, 65, 66, 67, 68, 69, 70, 71, 72, 73, 74, 75, 76, 77, 78, 79,
	80, 81, 82, 83, 84, 85, 86, 87, 88, 89, 90, 196, 214, 209, 220, 167,
	191, 97, 98, 99, 100, 101, 102, 103, 104, 105, 106, 107, 108, 109, 110, 111,
	112, 113, 114, 115, 116, 117, 118, 119, 120, 121, 122, 228, 246, 241, 252, 224 ]

# GSM 03.38 extension table: reachable, but each costs TWO septets (an escape
# plus the character). Form feed, ^ { } \ [ ~ ] | and the euro sign.
$anStzGsm7Extended = [ 12, 94, 123, 125, 92, 91, 126, 93, 124, 8364 ]

func StzSmsSandboxQ()
	return new stzSmsSandbox()

# How a carrier would bill this text: [ :encoding, :units, :segments ].
# Exposed as a plain function so it is useful (and testable) on its own -- you can
# check a message template's cost without a sandbox at all.
func StzSmsSegments(pcText)
	_anU_ = StzUnicodes("" + pcText)
	_n_ = len(_anU_)
	if _n_ = 0
		return [ :encoding = :gsm7, :units = 0, :segments = 0 ]
	ok

	# one character outside the GSM alphabet drags the WHOLE message to UCS-2
	_bGsm_ = 1
	_nSeptets_ = 0
	for _i_ = 1 to _n_
		if StzFindFirst(_anU_[_i_], $anStzGsm7Basic) > 0
			_nSeptets_ += 1
		but StzFindFirst(_anU_[_i_], $anStzGsm7Extended) > 0
			_nSeptets_ += 2
		else
			_bGsm_ = 0
			exit
		ok
	next

	if _bGsm_
		if _nSeptets_ <= 160
			return [ :encoding = :gsm7, :units = _nSeptets_, :segments = 1 ]
		ok
		return [ :encoding = :gsm7, :units = _nSeptets_,
		         :segments = ceil(_nSeptets_ / 153) ]
	ok

	# UCS-2 is billed in UTF-16 code units, so an astral character (an emoji)
	# counts TWICE -- one emoji is two of your seventy.
	_nUnits_ = 0
	for _i_ = 1 to _n_
		_nUnits_ += 1
		if _anU_[_i_] > 65535
			_nUnits_ += 1
		ok
	next
	if _nUnits_ <= 70
		return [ :encoding = :ucs2, :units = _nUnits_, :segments = 1 ]
	ok
	return [ :encoding = :ucs2, :units = _nUnits_, :segments = ceil(_nUnits_ / 67) ]

# E.164: a leading + and 8 to 15 digits. Deliberately strict.
func StzIsE164(pcNumber)
	_s_ = ring_trim("" + pcNumber)
	if len(_s_) < 9 or len(_s_) > 16
		return 0
	ok
	if _s_[1] != "+"
		return 0
	ok
	for _i_ = 2 to len(_s_)
		if StzFindFirst(_s_[_i_], "0123456789") = 0
			return 0
		ok
	next
	return 1


  #=========================================================#
 #  SMS SANDBOX -- records, never delivers, counts the bill   #
#=========================================================#

# Captures text messages instead of sending them, validates the number, and counts the billable segments a carrier would charge.
#
# A capture sink with the shape of stzMailSandbox, whose point is the bill. SMS is charged per
# segment, and the segment count depends on the alphabet: text within the GSM 7-bit alphabet takes
# 160 characters in one segment and 153 per part, and one character outside it, such as an Arabic
# letter or an emoji, makes the whole message UCS-2 with 70 and 67; nine characters of the extension
# table cost two septets each. Send names the encoding and the segments, and TotalSegments lets a
# test assert the cost. Numbers must be E.164. An outage is refused and recorded nowhere, while a
# bad number is rejected, so retrying and fixing the data are told apart. The honest limit: a sink
# shows what you would have sent, not that a carrier would accept it. The outbox is shared by copies
# of the object.
#
#   receiver   o1 = new stzSmsSandbox()
#   example    ? o1.Send("+22790123456", "Your code is 482910")[:segments]
#              #--> 1
#              ? o1.LastEncoding()
#              #--> gsm7
#              ? o1.Send("+22790123456", "Salut, code 482910 😀")[:encoding]
#              #--> ucs2
#              ? o1.Send("0612345678", "hi")[:status]
#              #--> rejected
#              ? o1.TotalSegments()
#              #--> 2
#              ? o1.WasSentTo("+22790123456")
#              #--> 1
#   see        stzMailSandbox, stzServiceRegistry, StzSmsSegments
class stzSmsSandbox from stzObject

	@nId = 0

	# Builds an SMS capture sink with an empty outbox, a shared slot that copies of the object also use.
	#
	#   returns    nothing; the object is built
	#   see        Send, Sent
	def init()
		$nStzSmsSandboxSeq = $nStzSmsSandboxSeq + 1
		@nId = $nStzSmsSandboxSeq
		$aStzSmsSandboxes + [ @nId, [], 0, [], 0 ]

	# TRUE if the object is a test double; here it always is, so the registry can refuse it in production.
	#
	#   returns    TRUE
	#   see        stzServiceRegistry
	#@ aka  a double declares itself -- see stzServiceRegistry
	def IsSandbox()
		return 1

	# Records a text message that would have been sent, counting the segments a carrier would bill, and delivers nothing.
	#
	#   pcNumber   the destination in E.164 form, + then 8 to 15 digits
	#   pcText     the message, which may not be empty
	#   returns    a hash list [ :ok, :id, :segments, :encoding, :status, :why ]; status is sent,
	#              rejected for bad data, or refused for an outage
	#   note       rejected means fix the data and refused means retry; the text is kept as given
	#   warning    a number that is not E.164, a number marked by RejectNumber and an empty text are
	#              rejected, and an outage set by FailNext is refused with nothing recorded; the
	#              rejection reason quotes the number as given, without escaping, so show it as text
	#              and not as markup
	#   see        FailNext, RejectNumber, TotalSegments
	#@ aka  -- the PORT contract ------------------------------------------------
	def Send(pcNumber, pcText)
		_i_ = This._Slot()
		_num_ = ring_trim("" + pcNumber)

		# an OUTAGE: no message, no id, and nothing in the outbox. Distinct from a
		# rejection, because the caller should retry rather than fix the data.
		if $aStzSmsSandboxes[_i_][3]
			$aStzSmsSandboxes[_i_][3] = 0
			return [ :ok = 0, :id = "", :segments = 0, :encoding = :none,
			         :status = :refused, :why = "the SMS gateway was unreachable" ]
		ok

		if NOT StzIsE164(_num_)
			return [ :ok = 0, :id = "", :segments = 0, :encoding = :none,
			         :status = :rejected,
			         :why = "'" + _num_ + "' is not an E.164 number (+ then 8-15 digits)" ]
		ok
		if StzFindFirst(_num_, $aStzSmsSandboxes[_i_][4]) > 0
			return [ :ok = 0, :id = "", :segments = 0, :encoding = :none,
			         :status = :rejected, :why = "the number is unreachable" ]
		ok
		if "" + pcText = ""
			return [ :ok = 0, :id = "", :segments = 0, :encoding = :none,
			         :status = :rejected, :why = "an empty message may not be sent" ]
		ok

		_aSeg_ = StzSmsSegments(pcText)
		$aStzSmsSandboxes[_i_][5] = $aStzSmsSandboxes[_i_][5] + 1
		_id_ = "sms_" + $aStzSmsSandboxes[_i_][5]
		$aStzSmsSandboxes[_i_][2] + [ _id_, _num_, "" + pcText,
		                              _aSeg_[:segments], _aSeg_[:encoding], _aSeg_[:units] ]
		return [ :ok = 1, :id = _id_, :segments = _aSeg_[:segments],
		         :encoding = _aSeg_[:encoding], :status = :sent, :why = "" ]

	# Makes the next Send fail once as an outage, so the retry path can be tested.
	#
	#   returns    nothing; use FailNextQ to chain
	#   note       the failure is refused and not recorded in the outbox
	#   see        Send, RejectNumber
	#@ aka  -- rules, so the FAILURE paths are testable -------------------------
	def FailNext()
		This.FailNextQ()

	def FailNextQ()
		$aStzSmsSandboxes[This._Slot()][3] = 1
		return This

	# Marks a number as unreachable, so every Send to it is rejected.
	#
	#   pcNumber   the number to refuse, as sent
	#   returns    nothing; use RejectNumberQ to chain
	#   note       the match is on the number as given after trimming
	#   see        Send, FailNext
	def RejectNumber(pcNumber)
		This.RejectNumberQ(pcNumber)

	def RejectNumberQ(pcNumber)
		$aStzSmsSandboxes[This._Slot()][4] + ring_trim("" + pcNumber)
		return This

	# Returns every recorded message, in order.
	#
	#   returns    a list of rows [ id, number, text, segments, encoding, units ]
	#   see        Last, InboxOf
	#@ aka  -- the outbox: assert on what WOULD have been sent -------------------
	def Sent()
		return $aStzSmsSandboxes[This._Slot()][2]

	# Returns how many messages are recorded.
	#
	#   returns    a number
	#   see        Sent, TotalSegments
	def NumberOfMessages()
		return len( This.Sent() )

	# TRUE if nothing has been recorded.
	#
	#   returns    TRUE or FALSE
	#   see        NumberOfMessages
	def IsEmpty()
		return This.NumberOfMessages() = 0

	# Returns the last recorded message.
	#
	#   returns    a row [ id, number, text, segments, encoding, units ]; an empty list when none
	#   see        LastText, LastTo, Sent
	def Last()
		_a_ = This.Sent()
		if len(_a_) = 0
			return []
		ok
		return _a_[len(_a_)]

	# Returns the text of the last message.
	#
	#   returns    a text; empty when none
	#   see        Last
	def LastText()
		_m_ = This.Last()
		if len(_m_) = 0
			return ""
		ok
		return _m_[3]

	# Returns the destination of the last message.
	#
	#   returns    a text; empty when none
	#   see        Last
	def LastTo()
		_m_ = This.Last()
		if len(_m_) = 0
			return ""
		ok
		return _m_[2]

	# Returns how many billable segments the last message takes.
	#
	#   returns    a number; 0 when none
	#   see        TotalSegments, LastEncoding
	def LastSegments()
		_m_ = This.Last()
		if len(_m_) = 0
			return 0
		ok
		return _m_[4]

	# Returns the alphabet the last message was billed in: gsm7 or ucs2.
	#
	#   returns    the text gsm7 or ucs2; none when nothing was sent
	#   see        LastSegments
	def LastEncoding()
		_m_ = This.Last()
		if len(_m_) = 0
			return :none
		ok
		return _m_[5]

	# Returns the recorded messages addressed to one number.
	#
	#   pcNumber   the destination number, trimmed
	#   returns    a list of message rows
	#   see        WasSentTo, Sent
	def InboxOf(pcNumber)
		_num_ = ring_trim("" + pcNumber)
		_out_ = []
		_a_ = This.Sent()
		_n_ = len(_a_)
		for _i_ = 1 to _n_
			if _a_[_i_][2] = _num_
				_out_ + _a_[_i_]
			ok
		next
		return _out_

	# TRUE if at least one message was recorded for that number.
	#
	#   pcNumber   the destination number, trimmed
	#   returns    TRUE or FALSE
	#   see        InboxOf
	def WasSentTo(pcNumber)
		return len( This.InboxOf(pcNumber) ) > 0

	# Returns the billable segments of everything recorded, the bill a test can assert.
	#
	#   returns    a number
	#   note       a message is one segment up to 160 GSM characters or 70 UCS-2 units, then 153 or
	#              67 per part
	#   see        LastSegments, Send
	#@ aka  THE BILL. A test can assert it, exactly as the LLM port lets you assert tokens.
	def TotalSegments()
		_t_ = 0
		_a_ = This.Sent()
		_n_ = len(_a_)
		for _i_ = 1 to _n_
			_t_ += _a_[_i_][4]
		next
		return _t_

	# Empties the outbox; the failure and rejection rules stay.
	#
	#   returns    nothing; use ClearQ to chain
	#   see        Sent
	def Clear()
		This.ClearQ()

	def ClearQ()
		$aStzSmsSandboxes[This._Slot()][2] = []
		return This

	# Prints one line with the number of messages and of billable segments.
	#
	#   returns    nothing; it prints
	#   see        TotalSegments
	def Show()
		? "stzSmsSandbox: " + This.NumberOfMessages() + " message(s), " +
		  This.TotalSegments() + " billable segment(s)"

	  #-- internals -------------------------------------------------------

	def _Slot()
		_n_ = len($aStzSmsSandboxes)
		for _i_ = 1 to _n_
			if $aStzSmsSandboxes[_i_][1] = @nId
				return _i_
			ok
		next
		$aStzSmsSandboxes + [ @nId, [], 0, [], 0 ]
		return len($aStzSmsSandboxes)
