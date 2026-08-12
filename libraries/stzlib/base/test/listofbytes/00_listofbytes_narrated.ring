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
    Then("Range(2,2) is the 2-byte char, taken as bytes", ListEq(Lob(o.Range(2, 2)).Bytecodes(), [ 208, 150 ]), TRUE)
    Then("Section(1,3) spans three BYTES, not three chars", len(o.Section(1, 3)), 3)
EndScenario()

# The counting half of this class (NumberOfBytes/Bytecodes/Bytes) was moved off
# StzLen and onto len long ago -- see the header. The POSITIONAL half was not:
# every slice still went through StzLeft/StzMid/StzRight/StzLen, which count
# CODEPOINTS. On ASCII the two axes agree, which is why it stayed hidden; on
# this 1+2+3 string they disagree on every method below.
#
# Each assertion here answered differently before the fix -- NLeftBytes(3)
# returned all six bytes, UnicodeOfNthByte(4) returned -1 for a byte that
# plainly exists, and Resize(4) left the buffer at six.

Scenario("Positional methods measure BYTES, not codepoints")
    Given("the 1+2+3 byte string (3 chars, 6 bytes)")
    o = Lob("mЖ丽")

    Then("UnicodeOfNthByte(1) is the ASCII 'm'", o.UnicodeOfNthByte(1), 109)
    Then("UnicodeOfNthByte(4) reaches into the 3-byte char", o.UnicodeOfNthByte(4), 228)
    Then("UnicodeOfNthByte(6) is the LAST byte", o.UnicodeOfNthByte(6), 189)
    # The negative sibling: past the true byte end, still refused.
    Then("UnicodeOfNthByte(7) is out of range", o.UnicodeOfNthByte(7), -1)
    Then("UnicodeOfNthByte(0) is out of range", o.UnicodeOfNthByte(0), -1)

    Given("TruncatedAt(3) on the same string")
    Then("it keeps 3 BYTES", len(o.TruncatedAt(3)), 3)
    Then("...and leaves the original untouched", o.NumberOfBytes(), 6)

    Given("Resize(4) shrinking the buffer")
    p = Lob("mЖ丽")
    p.Resize(4)
    Then("the buffer is 4 bytes", p.NumberOfBytes(), 4)

    Given("Resize(8) growing an ASCII buffer")
    q = Lob("ab")
    q.Resize(8)
    Then("it pads to 8 bytes", q.NumberOfBytes(), 8)

    Given("RemoveNBytesFromEnd(3) dropping the CJK char")
    r = Lob("mЖ丽")
    r.RemoveNBytesFromEnd(3)
    Then("3 bytes remain", r.NumberOfBytes(), 3)
    Then("...and they are 'm' + the 2-byte char", ListEq(r.Bytecodes(), [ 109, 208, 150 ]), TRUE)

    Given("RemoveNBytesStartingAt(2, 2) excising the middle char")
    s = Lob("mЖ丽")
    s.RemoveNBytesStartingAt(2, 2)
    Then("4 bytes remain", s.NumberOfBytes(), 4)
    Then("...and they are 'm' + the 3-byte char", ListEq(s.Bytecodes(), [ 109, 228, 184, 189 ]), TRUE)
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
