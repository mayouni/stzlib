load "../../stzBase.ring"
load "../_narrated.ring"

# M-S2 narrated regression suite for stzHexNumber -- hexadecimal numbers
# with conversions to/from decimal, binary, octal. The constructor now
# requires the canonical "0x" prefix (the classic bare "x167A" form is
# rejected). Content() is the digits WITHOUT prefix; WithPrefix() adds it.

Scenario("Hex helpers")
    Then("HexPrefixes lists the accepted prefixes", ListEq(HexPrefixes(), [ "x", "0x", "U+" ]), TRUE)
    Then("RepresentsNumberInHexForm('0x167A') is TRUE", StzStringQ("0x167A").RepresentsNumberInHexForm(), TRUE)
    Then("HexToDecimal('0x167A') is 5754", HexToDecimal("0x167A"), 5754)
EndScenario()

Scenario("Convert a hex number to other bases")
    Given("the hex number 0x167A")
    o = Hex("0x167A")
    Then("Content() is the digits without prefix", o.Content(), "167A")
    Then("WithPrefix() is 0x167A", o.WithPrefix(), "0x167A")
    Then("ToDecimal() is 5754", o.ToDecimal(), 5754)
    Then("ToBinary() is 0b1011001111010", o.ToBinary(), "0b1011001111010")
    Then("ToOctal() is 0o13172", o.ToOctal(), "0o13172")
EndScenario()

Scenario("Build a hex number from a decimal")
    Given("a hex number rebuilt from decimal 5754")
    o = Hex("0x0")
    o.FromDecimal(5754)
    Then("Content() is 167A (no doubled prefix)", o.Content(), "167A")
    Then("WithPrefix() is 0x167A", o.WithPrefix(), "0x167A")
    When("rebuilt from decimal 255")
    o.FromDecimal(255)
    Then("Content() is FF", o.Content(), "FF")
    Then("WithPrefix() is 0xFF", o.WithPrefix(), "0xFF")
EndScenario()

Summary()

func Hex cStr
    return new stzHexNumber(cStr)

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
