load "../../stzBase.ring"
load "../_narrated.ring"

# M-S2 narrated regression suite for stzListOfBytes -- the byte-level view
# of a (possibly multibyte UTF-8) string. Asserts on byte COUNTS and byte
# CODES (numbers), never on rendered glyphs, so console output stays ASCII.
#
# Regression guard: NumberOfBytes()/Bytecodes()/Bytes() previously used
# StzLen (codepoint count) instead of len (raw byte count), so they
# under-counted / truncated on multibyte input. Fixed to len(@cData).

Scenario("Byte counts on ASCII vs multibyte")
    Given("the ASCII string 'RING' (4 single-byte chars)")
    a = Lob("RING")
    Then("NumberOfBytes is 4", a.NumberOfBytes(), 4)
    Then("Bytecodes are the ASCII codes", ListEq(a.Bytecodes(), [ 82, 73, 78, 71 ]), TRUE)
    Given("a 3-char string spanning 1+2+3 bytes")
    o = Lob("mЖ丽")
    Then("NumberOfBytes counts all 6 bytes (not 3 chars)", o.NumberOfBytes(), 6)
    Then("Bytecodes lists all 6 byte values", ListEq(o.Bytecodes(), [ 109, 208, 150, 228, 184, 189 ]), TRUE)
    Then("Bytes() yields one entry per byte (6)", len(o.Bytes()), 6)
EndScenario()

Scenario("Bytes-per-char breakdown")
    Given("the same 1+2+3 byte string")
    o = Lob("mЖ丽")
    Then("NumberOfBytesPerChar maps each char to its byte width", ListEq(o.NumberOfBytesPerChar(), [ [ "m", 1 ], [ "Ж", 2 ], [ "丽", 3 ] ]), TRUE)
EndScenario()

Scenario("Hex rendering of the byte buffer")
    Given("a two-byte ASCII string 'de'")
    Then("ToHex prefixes with 0x and renders both bytes", Lob("de").ToHex(), "0x6465")
    Given("a single 3-byte CJK char")
    Then("ToHex renders all three bytes", Lob("で").ToHex(), "0xe381a7")
EndScenario()

Scenario("Byte-accurate slicing")
    Given("the 1+2+3 byte string (6 bytes total)")
    o = Lob("mЖ丽")
    Then("NLeftBytes(3) takes 'm' + the 2-byte char", o.NLeftBytes(3), "mЖ")
    Then("NRightBytes(3) takes the 3-byte char", o.NRightBytes(3), "丽")
    Then("Range(1,1) is the first byte's char", o.Range(1, 1), "m")
EndScenario()

Summary()

func Lob cStr
    return new stzListOfBytes(cStr)

func ListEq aA, aE
    if len(aA) != len(aE) return FALSE ok
    nLen = len(aA)
    for i = 1 to nLen
        if isList(aA[i]) and isList(aE[i])
            if NOT ListEq(aA[i], aE[i]) return FALSE ok
        else
            if aA[i] != aE[i] return FALSE ok
        ok
    next
    return TRUE
