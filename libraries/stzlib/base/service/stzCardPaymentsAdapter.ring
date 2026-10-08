#================================================================#
#  STZCARDPAYMENTSADAPTER -- the CARD gateway adapter and its sandbox #
#================================================================#

/*--- MOVED 2026-10-05 (payments plane, PY2). THE CARD VERBS ARE ONE ADAPTER, NOT THE PORT.

Authorize / Capture / Refund is the shape of a card gateway, and a platform may bind a
card gateway under any registry name. It is not the shape of money in the UEMOA, where the
hub speaks pay, request-to-pay, return, cancellation and bulk (see stzPaymentsPort.ring and
SOFTANZA_PAYMENTS_PORT.md). The class below is unchanged, only renamed;
`stzPaymentsSandbox` survives as the name the 49 checks of payments_port_narrated and the
registry's own examples use, a subclass with no body of its own.
*/

/*--- Phase 4: the demo that makes the whole plane legible.

A payments port is **"any object with `Authorize(amount, token)` / `Capture(id)` /
`Refund(id)`"**. Payments is the category people picture when they hear "service
virtualization", because the cost of getting it wrong is money and nobody wants a
test suite that charges real cards.

WHAT MAKES THIS MORE THAN A STUB, and it is the whole point of the file: a stub
that answers "approved" to everything lets broken code pass. This sandbox enforces
the STATE MACHINE a real gateway enforces --

    Authorize -> :authorized or :declined
    Capture   -> only an :authorized one, and only ONCE
    Refund    -> only what was CAPTURED, and never more than was captured

-- so code that double-captures, captures a decline, or over-refunds fails HERE, in
a test, instead of in production against a real processor. Most payment bugs are
state-machine bugs, not connectivity bugs, and a permissive fake hides exactly the
class of defect you most need to find.

DETERMINISTIC BY CONSTRUCTION. Rules you write, no randomness, sequential ids:

    oPay = new stzPaymentsSandbox()
    oPay.ApproveUnderQ(10000)                    # approve below 100.00
    oPay.DeclineTokenQ("tok_chargeback")         # a "test card" that always fails
    aA = oPay.Authorize(4200, "tok_visa")        # -> [ :ok, :id "auth_1", :status ]
    oPay.Capture(aA[:id])
    oPay.Refund(aA[:id], 1000)                   # partial refunds allowed

AN ASSERTABLE LEDGER. Every movement is recorded, so a test asserts on what
actually happened to the money rather than on a return value:
`TotalAuthorized`, `TotalCaptured`, `TotalRefunded`, `NetCaptured`, `Movements`.

MONEY IS AN INTEGER IN MINOR UNITS -- cents, not 42.00. Floating-point money is a
defect waiting for a rounding boundary, and a sandbox that accepted floats would
teach the wrong habit. Amounts must be positive whole numbers.

THE LIVE SIDE is a Stripe/PayPal/Adyen client behind the same three methods, and it
is deliberately NOT shipped: it needs an account, a key and a network, so it is
infra-gated. The contract is here; the adapter is yours, and the registry will
refuse to let a sandbox ship in its place.
*/

# state shared across copies -- see the Ring note in stzServiceRegistry:
# [ [ id, auths, movements, seq, approveUnder, declineOver, declinedTokens, failNext ], ... ]
$aStzPayGateways = []
$nStzPayGatewaySeq = 0

func StzPaymentsSandboxQ()
	return new stzPaymentsSandbox()

func StzCardPaymentsAdapterQ()
	return new stzCardPaymentsAdapter()


# Plays a card gateway in memory with the state machine a real one enforces, so double captures and over-refunds fail in a test.
#
# Authorize gives an authorized or declined answer, Capture takes an authorized amount once, and
# Refund gives back only what was captured, never more. The rules are yours and deterministic: a
# ceiling under which everything is approved, a ceiling over which everything is declined, tokens
# that always decline, and one outage on demand. Every movement is recorded, so a test asserts on
# what happened to the money and not on a return value. Money is a positive whole number of minor
# units, 4200 for 42.00, never a float. This is the double only: the live side, a client of a real
# card processor, is not shipped, and the registry refuses a double in production. It is not the
# UEMOA payments port, whose verbs are pay, request to pay, return, cancellation and bulk: see
# stzPaymentsPort.
#
#   receiver   o1 = new stzCardPaymentsAdapter()
#   example    aA = o1.Authorize(4200, "tok_visa")
#              ? aA[:status]
#              #--> authorized
#              o1.Capture(aA[:id])
#              o1.RefundAmount(aA[:id], 1000)
#              ? o1.NetCaptured()
#              #--> 3200
#   see        stzPaymentsSandbox, stzPaymentsPort, stzServiceRegistry
class stzCardPaymentsAdapter from stzObject

	@nId = 0

	# Builds a card-gateway double with its own empty ledger, that approves everything until a rule says otherwise.
	#
	#   returns    nothing; the object is built
	#   note       its state lives in a global table, so a copy of the object (w = o) is the same
	#              gateway; money is in whole minor units, 4200 for 42.00
	#   warning    build it with parentheses or with StzCardPaymentsAdapterQ(): a paren-less new
	#              skips this step, and every object built that way shares one gateway and one
	#              ledger
	#   see        IsSandbox, Authorize
	def init()
		$nStzPayGatewaySeq = $nStzPayGatewaySeq + 1
		@nId = $nStzPayGatewaySeq
		$aStzPayGateways + [ @nId, [], [], 0, 0, 0, [], 0 ]

	# Returns 1, the way a service double declares itself so that the registry can refuse it in production.
	#
	#   returns    the number 1, always
	#   note       there is no live card adapter in the library: the Stripe, PayPal or Adyen side is
	#              yours to write behind the same verbs
	#   see        Authorize
	#@ aka  a double declares itself -- see stzServiceRegistry
	def IsSandbox()
		return 1

	# Sets an approval ceiling: an authorization strictly below it is approved and one at or above it is declined; 0 removes the ceiling.
	#
	#   pnMinorUnits   the ceiling in minor units, 0 for none
	#   returns        nothing; use ApproveUnderQ to chain
	#   note           ApproveUnderQ is the same call and returns the object
	#   see            DeclineOver, Authorize
	#@ aka  -- the rules (deterministic, no randomness) --------------------------
	def ApproveUnder(pnMinorUnits)
		This.ApproveUnderQ(pnMinorUnits)

	def ApproveUnderQ(pnMinorUnits)
		$aStzPayGateways[This._Slot()][5] = pnMinorUnits
		return This

	# Sets a decline ceiling: an authorization at or above it is declined; 0 removes the ceiling.
	#
	#   pnMinorUnits   the ceiling in minor units, 0 for none
	#   returns        nothing; use DeclineOverQ to chain
	#   note           DeclineOverQ is the same call and returns the object
	#   see            ApproveUnder, Authorize
	#@ aka  decline anything at or ABOVE this amount; 0 = no ceiling.
	def DeclineOver(pnMinorUnits)
		This.DeclineOverQ(pnMinorUnits)

	def DeclineOverQ(pnMinorUnits)
		$aStzPayGateways[This._Slot()][6] = pnMinorUnits
		return This

	# Adds a payment token that always declines, like the published test card of a real gateway; the rule lasts as long as the object.
	#
	#   pcToken    the token text to refuse, compared as text
	#   returns    nothing; use DeclineTokenQ to chain
	#   note       DeclineTokenQ is the same call and returns the object
	#   see        Authorize, NumberOfDeclines
	#@ aka  a token that always declines -- the "test card" every real gateway publishes.
	def DeclineToken(pcToken)
		This.DeclineTokenQ(pcToken)

	def DeclineTokenQ(pcToken)
		$aStzPayGateways[This._Slot()][7] + ("" + pcToken)
		return This

	# Makes the next Authorize, Capture or Refund fail as if the gateway were unreachable; only that one call fails.
	#
	#   returns    nothing; use FailNextQ to chain
	#   note       an outage is not a decline: the answer carries ok = 0, status refused and no id,
	#              and nothing was recorded
	#   warning    the failure is taken by the next of those calls even if that call would have been
	#              refused anyway, and it is not recorded in the ledger
	#   see        Authorize, Capture, Refund
	#@ aka  make the NEXT call fail as if the gateway were unreachable -- a transient failure, which is different from a decline and must be handled differently (a decline is an answer; an outage is not).
	def FailNext()
		This.FailNextQ()

	def FailNextQ()
		$aStzPayGateways[This._Slot()][8] = 1
		return This

	# Asks the gateway to approve an amount against a payment token and answers approved or declined, recording the movement.
	#
	#   pnAmount   the amount in minor units, a positive whole number
	#   pcToken    the payment token the customer presented
	#   returns    a list [ ok, id, status, amount, why ]: status is authorized or declined, id is
	#              auth_1, auth_2 and so on, why says the cause of a decline
	#   note       nothing is captured yet: Capture takes the money
	#   warning    an amount that is zero, negative, fractional or not a number is refused with ok =
	#              0, status refused and an empty id; a decline is an answer that takes an id and
	#              counts in NumberOfDeclines, and the rules apply in the order token, decline
	#              ceiling, approval ceiling
	#   see        Capture, DeclineToken, ApproveUnder
	#@ aka  -- the PORT contract ------------------------------------------------
	def Authorize(pnAmount, pcToken)
		_i_ = This._Slot()
		if This._TakeFailure()
			return This._Refuse("", "the gateway is unreachable")
		ok
		if NOT This._IsSaneAmount(pnAmount)
			return This._Refuse("", "an amount must be a positive whole number of minor units")
		ok

		_declined_ = 0
		_why_ = ""
		if This._IsDeclinedToken(pcToken)
			_declined_ = 1
			_why_ = "the payment token was declined"
		ok
		_over_ = $aStzPayGateways[_i_][6]
		if NOT _declined_ and _over_ > 0 and pnAmount >= _over_
			_declined_ = 1
			_why_ = "the amount is at or above the decline ceiling"
		ok
		_under_ = $aStzPayGateways[_i_][5]
		if NOT _declined_ and _under_ > 0 and pnAmount >= _under_
			_declined_ = 1
			_why_ = "the amount is not below the approval ceiling"
		ok

		$aStzPayGateways[_i_][4] = $aStzPayGateways[_i_][4] + 1
		_id_ = "auth_" + $aStzPayGateways[_i_][4]
		if _declined_
			$aStzPayGateways[_i_][2] + [ _id_, pnAmount, "" + pcToken, :declined, 0, 0 ]
			This._Move("decline", _id_, pnAmount)
			return [ :ok = 0, :id = _id_, :status = :declined,
			         :amount = pnAmount, :why = _why_ ]
		ok
		$aStzPayGateways[_i_][2] + [ _id_, pnAmount, "" + pcToken, :authorized, 0, 0 ]
		This._Move("authorize", _id_, pnAmount)
		return [ :ok = 1, :id = _id_, :status = :authorized,
		         :amount = pnAmount, :why = "" ]

	# Takes the whole amount that was approved on an authorization; the money can be taken only once.
	#
	#   pcId       the id returned by Authorize
	#   returns    a list [ ok, id, status, amount, why ]: status is captured, or refused with the
	#              cause in why
	#   warning    a declined, unknown or already captured authorization is refused and the ledger
	#              does not move
	#   see        CaptureAmount, Refund, StatusOf
	#@ aka  Capture an authorization. Full amount by default; CaptureAmount for less.
	def Capture(pcId)
		return This.CaptureAmount(pcId, 0)

	# Takes part of an authorization, or all of it when the amount is 0; a capture may not exceed what was authorized and happens once.
	#
	#   pcId       the id returned by Authorize
	#   pnAmount   the amount to take in minor units, 0 for the whole authorization
	#   returns    a list [ ok, id, status, amount, why ]: status is captured, or refused with the
	#              cause in why
	#   warning    capturing less than the authorized amount closes the authorization: the rest
	#              cannot be captured later
	#   see        Capture, Refund
	#@ aka  pnAmount 0 = the whole authorization. A capture may not exceed it, and an authorization may be captured only ONCE -- both are real gateway rules, and both are where naive code goes wrong.
	def CaptureAmount(pcId, pnAmount)
		_i_ = This._Slot()
		if This._TakeFailure()
			return This._Refuse(pcId, "the gateway is unreachable")
		ok
		_j_ = This._AuthIndex(pcId)
		if _j_ = 0
			return This._Refuse(pcId, "unknown authorization")
		ok
		_a_ = $aStzPayGateways[_i_][2][_j_]
		if _a_[4] = :declined
			return This._Refuse(pcId, "cannot capture a DECLINED authorization")
		ok
		if _a_[4] = :captured or _a_[5] > 0
			return This._Refuse(pcId, "this authorization was already captured")
		ok
		_amt_ = pnAmount
		if _amt_ = 0
			_amt_ = _a_[2]
		ok
		if NOT This._IsSaneAmount(_amt_)
			return This._Refuse(pcId, "an amount must be a positive whole number of minor units")
		ok
		if _amt_ > _a_[2]
			return This._Refuse(pcId, "a capture may not exceed the amount authorized")
		ok
		$aStzPayGateways[_i_][2][_j_] = [ _a_[1], _a_[2], _a_[3], :captured, _amt_, _a_[6] ]
		This._Move("capture", pcId, _amt_)
		return [ :ok = 1, :id = pcId, :status = :captured, :amount = _amt_, :why = "" ]

	# Gives back the rest of what was captured on an authorization.
	#
	#   pcId       the id returned by Authorize
	#   returns    a list [ ok, id, status, amount, why ]: status is refunded, or refused with the
	#              cause in why
	#   note       StatusOf still reads captured after a refund; the refunded sum is read with
	#              RefundedOf
	#   warning    an authorization with nothing left to refund is refused, but the reason says an
	#              amount must be a positive whole number, which is true and is not the cause
	#   see        RefundAmount, NetCaptured
	#@ aka  Refund captured money. Full captured amount by default; partials allowed, and the TOTAL refunded may never exceed what was captured.
	def Refund(pcId)
		return This.RefundAmount(pcId, 0)

	# Gives back part of the captured money, or all that is left when the amount is 0; the total refunded never exceeds what was captured.
	#
	#   pcId       the id returned by Authorize
	#   pnAmount   the amount to give back in minor units, 0 for what is left
	#   returns    a list [ ok, id, status, amount, why ]: status is refunded, or refused with the
	#              cause in why
	#   warning    an authorization that was never captured, or an amount over what is left, is
	#              refused and the ledger does not move
	#   see        Refund, RefundedOf
	def RefundAmount(pcId, pnAmount)
		_i_ = This._Slot()
		if This._TakeFailure()
			return This._Refuse(pcId, "the gateway is unreachable")
		ok
		_j_ = This._AuthIndex(pcId)
		if _j_ = 0
			return This._Refuse(pcId, "unknown authorization")
		ok
		_a_ = $aStzPayGateways[_i_][2][_j_]
		if _a_[5] = 0
			return This._Refuse(pcId, "nothing was captured, so there is nothing to refund")
		ok
		_amt_ = pnAmount
		if _amt_ = 0
			_amt_ = _a_[5] - _a_[6]
		ok
		if NOT This._IsSaneAmount(_amt_)
			return This._Refuse(pcId, "an amount must be a positive whole number of minor units")
		ok
		if (_a_[6] + _amt_) > _a_[5]
			return This._Refuse(pcId, "a refund may not exceed what was captured")
		ok
		$aStzPayGateways[_i_][2][_j_] = [ _a_[1], _a_[2], _a_[3], _a_[4], _a_[5], _a_[6] + _amt_ ]
		This._Move("refund", pcId, _amt_)
		return [ :ok = 1, :id = pcId, :status = :refunded, :amount = _amt_, :why = "" ]

	# Returns the state of an authorization: authorized, declined or captured.
	#
	#   pcId       the id returned by Authorize
	#   returns    a text; empty for an unknown id
	#   note       a refund does not change it: the state stays captured
	#   see        AmountOf, CapturedOf
	#@ aka  -- the ledger (what actually happened to the money) -------------------
	def StatusOf(pcId)
		_j_ = This._AuthIndex(pcId)
		if _j_ = 0
			return ""
		ok
		return $aStzPayGateways[This._Slot()][2][_j_][4]

	# Returns the amount that was asked for in the authorization.
	#
	#   pcId       the id returned by Authorize
	#   returns    a number in minor units; 0 for an unknown id
	#   see        CapturedOf, StatusOf
	def AmountOf(pcId)
		_j_ = This._AuthIndex(pcId)
		if _j_ = 0
			return 0
		ok
		return $aStzPayGateways[This._Slot()][2][_j_][2]

	# Returns how much of an authorization was captured.
	#
	#   pcId       the id returned by Authorize
	#   returns    a number in minor units; 0 when nothing was captured or the id is unknown
	#   see        RefundedOf, AmountOf
	def CapturedOf(pcId)
		_j_ = This._AuthIndex(pcId)
		if _j_ = 0
			return 0
		ok
		return $aStzPayGateways[This._Slot()][2][_j_][5]

	# Returns how much of an authorization has been given back.
	#
	#   pcId       the id returned by Authorize
	#   returns    a number in minor units; 0 when nothing was refunded or the id is unknown
	#   see        CapturedOf, NetCaptured
	def RefundedOf(pcId)
		_j_ = This._AuthIndex(pcId)
		if _j_ = 0
			return 0
		ok
		return $aStzPayGateways[This._Slot()][2][_j_][6]

	# Returns how many authorizations the gateway holds, declined ones included.
	#
	#   returns    a number
	#   note       a call refused before an id was given, such as a bad amount or an outage, is not
	#              counted
	#   see        NumberOfDeclines, NumberOfMovements
	def NumberOfAuthorizations()
		return len($aStzPayGateways[This._Slot()][2])

	# Returns the sum asked for by the authorizations that were approved, whether or not they were captured since.
	#
	#   returns    a number in minor units
	#   note       declined authorizations are left out, and a refund does not lower it
	#   see        TotalCaptured, NumberOfAuthorizations
	def TotalAuthorized()
		return This._SumWhere(:authorized, 2) + This._SumWhere(:captured, 2)

	# Returns the sum captured across every authorization.
	#
	#   returns    a number in minor units
	#   note       a refund does not lower it: NetCaptured does
	#   see        TotalRefunded, NetCaptured
	def TotalCaptured()
		_t_ = 0
		_a_ = $aStzPayGateways[This._Slot()][2]
		_n_ = len(_a_)
		for _i_ = 1 to _n_
			_t_ += _a_[_i_][5]
		next
		return _t_

	# Returns the sum given back across every authorization.
	#
	#   returns    a number in minor units
	#   see        TotalCaptured, NetCaptured
	def TotalRefunded()
		_t_ = 0
		_a_ = $aStzPayGateways[This._Slot()][2]
		_n_ = len(_a_)
		for _i_ = 1 to _n_
			_t_ += _a_[_i_][6]
		next
		return _t_

	# Returns what the merchant keeps: the captured sum less the refunded sum.
	#
	#   returns    a number in minor units
	#   see        TotalCaptured, TotalRefunded
	#@ aka  what the merchant actually keeps.
	def NetCaptured()
		return This.TotalCaptured() - This.TotalRefunded()

	# Returns how many authorizations were declined, by a token or by a ceiling.
	#
	#   returns    a number
	#   see        DeclineToken, NumberOfAuthorizations
	def NumberOfDeclines()
		_k_ = 0
		_a_ = $aStzPayGateways[This._Slot()][2]
		_n_ = len(_a_)
		for _i_ = 1 to _n_
			if _a_[_i_][4] = :declined
				_k_++
			ok
		next
		return _k_

	# Returns the ledger of what happened to the money, oldest first, one record per authorize, decline, capture or refund.
	#
	#   returns    a list of records [ seq, kind, id, amount ] where kind is authorize, decline,
	#              capture or refund
	#   note       a refused call leaves no record: a test asserts on what the money did, not on the
	#              return value
	#   see        NumberOfMovements, NetCaptured
	#@ aka  [ [ :seq, :kind, :id, :amount ], ... ] -- kind is authorize/decline/capture/refund
	def Movements()
		_out_ = []
		_a_ = $aStzPayGateways[This._Slot()][3]
		_n_ = len(_a_)
		for _i_ = 1 to _n_
			_out_ + [ :seq = _a_[_i_][1], :kind = _a_[_i_][2],
			          :id = _a_[_i_][3], :amount = _a_[_i_][4] ]
		next
		return _out_

	# Returns how many records the ledger holds.
	#
	#   returns    a number
	#   see        Movements
	def NumberOfMovements()
		return len($aStzPayGateways[This._Slot()][3])

	# Prints one summary line of the gateway: how many authorizations, and the captured, refunded and net sums.
	#
	#   returns    nothing; it prints a line
	#   note       the line begins with stzPaymentsSandbox, whatever the class used
	#   see        NetCaptured, TotalCaptured
	def Show()
		? "stzPaymentsSandbox: " + This.NumberOfAuthorizations() + " authorization(s), " +
		  "captured " + This.TotalCaptured() + ", refunded " + This.TotalRefunded() +
		  ", net " + This.NetCaptured()

	  #-- internals -------------------------------------------------------

	def _Refuse(pcId, pcWhy)
		return [ :ok = 0, :id = "" + pcId, :status = :refused, :amount = 0, :why = "" + pcWhy ]

	# money is minor units: a positive WHOLE number. A float would be a rounding
	# defect waiting for its boundary.
	def _IsSaneAmount(pnAmount)
		if NOT isNumber(pnAmount)
			return 0
		ok
		if pnAmount <= 0
			return 0
		ok
		return floor(pnAmount) = pnAmount

	def _IsDeclinedToken(pcToken)
		_a_ = $aStzPayGateways[This._Slot()][7]
		_n_ = len(_a_)
		for _i_ = 1 to _n_
			if _a_[_i_] = ("" + pcToken)
				return 1
			ok
		next
		return 0

	# a one-shot transient failure
	def _TakeFailure()
		_i_ = This._Slot()
		if $aStzPayGateways[_i_][8]
			$aStzPayGateways[_i_][8] = 0
			return 1
		ok
		return 0

	def _Move(pcKind, pcId, pnAmount)
		_i_ = This._Slot()
		$aStzPayGateways[_i_][3] + [ len($aStzPayGateways[_i_][3]) + 1,
		                             "" + pcKind, "" + pcId, pnAmount ]

	def _AuthIndex(pcId)
		_a_ = $aStzPayGateways[This._Slot()][2]
		_n_ = len(_a_)
		for _i_ = 1 to _n_
			if _a_[_i_][1] = ("" + pcId)
				return _i_
			ok
		next
		return 0

	def _SumWhere(pcStatus, pnField)
		_t_ = 0
		_a_ = $aStzPayGateways[This._Slot()][2]
		_n_ = len(_a_)
		for _i_ = 1 to _n_
			if _a_[_i_][4] = pcStatus
				_t_ += _a_[_i_][pnField]
			ok
		next
		return _t_

	def _Slot()
		_n_ = len($aStzPayGateways)
		for _i_ = 1 to _n_
			if $aStzPayGateways[_i_][1] = @nId
				return _i_
			ok
		next
		$aStzPayGateways + [ @nId, [], [], 0, 0, 0, [], 0 ]
		return len($aStzPayGateways)

# Names the card-gateway double under its historical name, with no behaviour of its own beyond stzCardPaymentsAdapter.
#
# The class was renamed when the card verbs were moved out of the payments port, and this name stays
# because the payments checks and the registry's examples use it. It adds nothing: every method is
# that of stzCardPaymentsAdapter. Build it with parentheses or with StzPaymentsSandboxQ(), because a
# paren-less new skips init and every object built that way shares one gateway.
#
#   receiver   o1 = new stzPaymentsSandbox()
#   example    o1.DeclineToken("tok_chargeback")
#              ? o1.Authorize(4200, "tok_chargeback")[:status]
#              #--> declined
#              ? o1.NumberOfDeclines()
#              #--> 1
#   see        stzCardPaymentsAdapter, stzServiceRegistry
class stzPaymentsSandbox from stzCardPaymentsAdapter
