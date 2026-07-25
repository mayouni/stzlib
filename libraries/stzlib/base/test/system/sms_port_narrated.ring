load "../../stzBase.ring"
load "../_narrated.ring"

# stzSmsPort -- phase 6, second half: the notification category.
#
# An SMS port is "any object with Send(number, text)". Twilio, Vonage,
# MessageBird, an operator gateway -- one verb.
#
# stzSmsSandbox is a CAPTURE SINK, the same shape as the mail sink built for
# passwordless login: it records what would have been sent and delivers nothing, so
# the outbox becomes something a test can assert on. That part is unremarkable.
#
# WHAT EARNS THIS FILE ITS PLACE is that SMS is BILLED PER SEGMENT, and the segment
# count is not the character count -- it depends on the ALPHABET:
#
#   * text entirely inside the GSM 7-bit alphabet (GSM 03.38) packs 7 bits per
#     character: 160 in one message, 153 per part once it must be split (the other
#     7 septets carry the concatenation header).
#   * ONE character outside that alphabet forces the WHOLE message to UCS-2 at 16
#     bits each: 70 in one message, 67 per part.
#
# So the same message costs one segment in English and two in Arabic, and adding a
# single emoji to a template can double the bill for a campaign while nothing in
# the code looks any different. That is precisely the class of defect a sandbox
# should surface -- so this one counts segments and names the encoding.

Scenario("segmentation decides the bill, and it is not the character count")
	Then("a short ASCII message is one segment", StzSmsSegments("Your code is 4821")[:segments], 1)
	Then("...in the 7-bit alphabet", StzSmsSegments("Your code is 4821")[:encoding], :gsm7)

	Then("exactly 160 ASCII characters still fit one segment",
	     StzSmsSegments(StzRepeatStr("a", 160))[:segments], 1)
	Then("161 becomes TWO", StzSmsSegments(StzRepeatStr("a", 161))[:segments], 2)
	Then("...and 306 (2 x 153) is still two, because a split message carries a header",
	     StzSmsSegments(StzRepeatStr("a", 306))[:segments], 2)
	Then("...while 307 is three", StzSmsSegments(StzRepeatStr("a", 307))[:segments], 3)

	Then("an empty text costs nothing", StzSmsSegments("")[:segments], 0)
EndScenario()

Scenario("THE CLIFF: one character outside the alphabet re-encodes everything")
	cEmoji = StzUnicodeToChar(128512)

	Then("100 ASCII characters are one segment", StzSmsSegments(StzRepeatStr("a", 100))[:segments], 1)

	When("a single emoji is added to that same message")
	aE = StzSmsSegments(StzRepeatStr("a", 100) + cEmoji)
	Then("the encoding changes for the WHOLE message", aE[:encoding], :ucs2)
	Then("...so 70 is now the limit and it costs TWO segments", aE[:segments], 2)
	Then("...and the emoji itself counts as 2 units, being outside the BMP", aE[:units], 102)
	# the bill doubled. Nothing in the source looks different: someone edited a
	# template. This is the commonest real SMS cost defect there is.

	Given("a message in Arabic")
	cAr = ""
	for i = 1 to 9
		cAr += StzUnicodeToChar(1605)
	next
	Then("nine characters is one segment", StzSmsSegments(cAr)[:segments], 1)
	Then("...but in UCS-2, so the ceiling is 70 not 160", StzSmsSegments(cAr)[:encoding], :ucs2)
	Then("which means 71 Arabic characters already cost two",
	     StzSmsSegments(StzRepeatStr(StzUnicodeToChar(1605), 71))[:segments], 2)
	# the same template is one segment for a French customer and two for a Tunisian
	# one. A cost model that assumes 160 is wrong for most of the world.
EndScenario()

Scenario("the GSM extension table: nine characters that cost double")
	# ^ { } \ [ ~ ] | and the euro sign are reachable in GSM-7 only via an escape,
	# so each occupies TWO septets rather than one.
	Then("a lone euro sign stays in the 7-bit alphabet",
	     StzSmsSegments(StzUnicodeToChar(8364))[:encoding], :gsm7)
	Then("...but bills as 2 units, not 1", StzSmsSegments(StzUnicodeToChar(8364))[:units], 2)

	Then("100 curly braces bill as 200 septets", StzSmsSegments(StzRepeatStr("{", 100))[:units], 200)
	Then("...which is TWO segments, from 100 characters", StzSmsSegments(StzRepeatStr("{", 100))[:segments], 2)
	Then("while 100 plain letters are one", StzSmsSegments(StzRepeatStr("x", 100))[:segments], 1)
	# a JSON snippet or a code block in an SMS costs about twice what it looks like.
EndScenario()

Scenario("a number is validated, because the real gateway would")
	Then("an E.164 number passes", StzIsE164("+21612345678"), TRUE)
	Then("a missing + fails", StzIsE164("21612345678"), FALSE)
	Then("too short fails", StzIsE164("+123"), FALSE)
	Then("a letter fails", StzIsE164("+2161234567a"), FALSE)
	Then("spaces and dashes fail -- normalise before sending", StzIsE164("+216 12 345 678"), FALSE)
	# a sandbox that accepted these would let you ship a bug the gateway catches --
	# the same reason the payments sandbox refuses a float.
EndScenario()

Scenario("the sink: assert on what WOULD have been sent")
	oSms = new stzSmsSandbox()
	Then("it declares itself a double", oSms.IsSandbox(), TRUE)
	Then("the outbox starts empty", oSms.IsEmpty(), TRUE)

	aR = oSms.Send("+21612345678", "Your code is 4821")
	Then("the send succeeds", aR[:ok], TRUE)
	Then("...with a deterministic id (no randomness in a sandbox)", aR[:id], "sms_1")
	Then("...reporting the segments it would be billed as", aR[:segments], 1)
	Then("...and the encoding", aR[:encoding], :gsm7)

	Then("the message is in the outbox", oSms.NumberOfMessages(), 1)
	Then("...addressed correctly", oSms.LastTo(), "+21612345678")
	Then("...with its text", oSms.LastText(), "Your code is 4821")
	Then("...and its cost", oSms.LastSegments(), 1)
	Then("a recipient's messages are findable", oSms.WasSentTo("+21612345678"), TRUE)
	Then("...and someone never texted says so", oSms.WasSentTo("+21699999999"), FALSE)

	When("a long message is sent as well")
	oSms.Send("+21612345678", StzRepeatStr("a", 200))
	Then("THE BILL is assertable", oSms.TotalSegments(), 3)
	Then("...across both messages", oSms.NumberOfMessages(), 2)
	Then("...and that recipient's inbox holds both", len(oSms.InboxOf("+21612345678")), 2)
	# exactly as the LLM port lets a test assert token cost: a fee-free plane
	# should let you assert the fee.

	oSms.ClearQ()
	Then("the outbox clears between phases of a test", oSms.NumberOfMessages(), 0)
EndScenario()

Scenario("an OUTAGE is not a REJECTION, and the difference matters")
	oSms = new stzSmsSandbox()

	When("the number is malformed")
	aBad = oSms.Send("21612345678", "hi")
	Then("it is REJECTED", aBad[:status], :rejected)
	Then("...saying why", StzFindFirst("not an E.164", aBad[:why]) > 0, TRUE)

	When("a number is nominated unreachable")
	oSms.RejectNumberQ("+21600000000")
	Then("that number is refused", oSms.Send("+21600000000", "hi")[:status], :rejected)
	Then("...while others still work", oSms.Send("+21612345678", "hi")[:ok], TRUE)

	When("the gateway is unreachable")
	oSms.FailNextQ()
	aOut = oSms.Send("+21612345678", "hi")
	Then("the call fails as :refused, NOT :rejected", aOut[:status], :refused)
	Then("...because the gateway was unreachable", StzFindFirst("unreachable", aOut[:why]) > 0, TRUE)
	Then("nothing was recorded for it", oSms.NumberOfMessages(), 1)
	Then("...and it is one-shot, so the next send works", oSms.Send("+21612345678", "hi")[:ok], TRUE)
	# a rejection means FIX THE DATA (this number will never work); an outage means
	# RETRY (the number is fine). Code that conflates them either spams the
	# customer or silently drops the message.

	When("the text is empty")
	Then("it is refused", oSms.Send("+21612345678", "")[:ok], FALSE)
EndScenario()

Scenario("through the registry, and refused in production")
	oSms = new stzSmsSandbox()
	oReg = new stzServiceRegistry("app")
	oReg.Bind(:sms, oSms)
	Then("the registry recognises the sink", oReg.PostureOf(:sms), :sandbox)

	When("the application texts through the service the registry hands back")
	oReg.Service(:sms).Send("+21655555555", "through the registry")
	Then("the ORIGINAL sink recorded it -- state survived Ring's copy",
	     oSms.WasSentTo("+21655555555"), TRUE)

	When("the phase becomes production with the sink still bound")
	oReg.SetPhaseQ(:production)
	Then("it is refused", oReg.IsSound(), FALSE)
	Then("...naming the sms service", oReg.Findings()[1][:where], "app/sms")
	# the honest limit: a sink proves what you WOULD have sent, not that a carrier
	# would accept it -- carrier filtering, per-country sender-ID rules and
	# asynchronous delivery receipts are not modelled. The Twilio/Vonage adapter
	# binds the same one method and is infra-gated.
EndScenario()

Summary()
