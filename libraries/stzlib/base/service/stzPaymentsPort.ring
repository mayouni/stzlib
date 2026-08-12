#================================================================#
#  STZPAYMENTSPORT -- the payments port (the canonical sandbox)     #
#================================================================#

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


class stzPaymentsSandbox from stzObject

	@nId = 0

	def init()
		$nStzPayGatewaySeq = $nStzPayGatewaySeq + 1
		@nId = $nStzPayGatewaySeq
		$aStzPayGateways + [ @nId, [], [], 0, 0, 0, [], 0 ]

	# a double declares itself -- see stzServiceRegistry
	def IsSandbox()
		return 1

	  #-- the rules (deterministic, no randomness) --------------------------

	# approve anything strictly BELOW this amount; 0 = no ceiling.
	def ApproveUnder(pnMinorUnits)
		This.ApproveUnderQ(pnMinorUnits)

	def ApproveUnderQ(pnMinorUnits)
		$aStzPayGateways[This._Slot()][5] = pnMinorUnits
		return This

	# decline anything at or ABOVE this amount; 0 = no ceiling.
	def DeclineOver(pnMinorUnits)
		This.DeclineOverQ(pnMinorUnits)

	def DeclineOverQ(pnMinorUnits)
		$aStzPayGateways[This._Slot()][6] = pnMinorUnits
		return This

	# a token that always declines -- the "test card" every real gateway publishes.
	def DeclineToken(pcToken)
		This.DeclineTokenQ(pcToken)

	def DeclineTokenQ(pcToken)
		$aStzPayGateways[This._Slot()][7] + ("" + pcToken)
		return This

	# make the NEXT call fail as if the gateway were unreachable -- a transient
	# failure, which is different from a decline and must be handled differently
	# (a decline is an answer; an outage is not).
	def FailNext()
		This.FailNextQ()

	def FailNextQ()
		$aStzPayGateways[This._Slot()][8] = 1
		return This

	  #-- the PORT contract ------------------------------------------------

	# -> [ :ok, :id, :status, :amount, :why ]. status is :authorized or :declined.
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

	# Capture an authorization. Full amount by default; CaptureAmount for less.
	def Capture(pcId)
		return This.CaptureAmount(pcId, 0)

	# pnAmount 0 = the whole authorization. A capture may not exceed it, and an
	# authorization may be captured only ONCE -- both are real gateway rules, and
	# both are where naive code goes wrong.
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

	# Refund captured money. Full captured amount by default; partials allowed, and
	# the TOTAL refunded may never exceed what was captured.
	def Refund(pcId)
		return This.RefundAmount(pcId, 0)

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

	  #-- the ledger (what actually happened to the money) -------------------

	def StatusOf(pcId)
		_j_ = This._AuthIndex(pcId)
		if _j_ = 0
			return ""
		ok
		return $aStzPayGateways[This._Slot()][2][_j_][4]

	def AmountOf(pcId)
		_j_ = This._AuthIndex(pcId)
		if _j_ = 0
			return 0
		ok
		return $aStzPayGateways[This._Slot()][2][_j_][2]

	def CapturedOf(pcId)
		_j_ = This._AuthIndex(pcId)
		if _j_ = 0
			return 0
		ok
		return $aStzPayGateways[This._Slot()][2][_j_][5]

	def RefundedOf(pcId)
		_j_ = This._AuthIndex(pcId)
		if _j_ = 0
			return 0
		ok
		return $aStzPayGateways[This._Slot()][2][_j_][6]

	def NumberOfAuthorizations()
		return len($aStzPayGateways[This._Slot()][2])

	def TotalAuthorized()
		return This._SumWhere(:authorized, 2) + This._SumWhere(:captured, 2)

	def TotalCaptured()
		_t_ = 0
		_a_ = $aStzPayGateways[This._Slot()][2]
		_n_ = len(_a_)
		for _i_ = 1 to _n_
			_t_ += _a_[_i_][5]
		next
		return _t_

	def TotalRefunded()
		_t_ = 0
		_a_ = $aStzPayGateways[This._Slot()][2]
		_n_ = len(_a_)
		for _i_ = 1 to _n_
			_t_ += _a_[_i_][6]
		next
		return _t_

	# what the merchant actually keeps.
	def NetCaptured()
		return This.TotalCaptured() - This.TotalRefunded()

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

	# [ [ :seq, :kind, :id, :amount ], ... ] -- kind is authorize/decline/capture/refund
	def Movements()
		_out_ = []
		_a_ = $aStzPayGateways[This._Slot()][3]
		_n_ = len(_a_)
		for _i_ = 1 to _n_
			_out_ + [ :seq = _a_[_i_][1], :kind = _a_[_i_][2],
			          :id = _a_[_i_][3], :amount = _a_[_i_][4] ]
		next
		return _out_

	def NumberOfMovements()
		return len($aStzPayGateways[This._Slot()][3])

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
