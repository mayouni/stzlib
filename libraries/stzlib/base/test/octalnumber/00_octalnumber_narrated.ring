load "../../stzBase.ring"
load "../_narrated.ring"

# M-S2 narrated regression suite for stzOctalNumber -- base-8 number
# with conversions to/from decimal, binary, and hexadecimal. (The
# constructor now requires the canonical "0o" prefix; the classic tests'
# bare "o2007" form is no longer accepted.)

Scenario("Convert an octal number to other bases")
    Given("the octal number 0o2007")
    o = OctNum("0o2007")
    Then("OctalNumber() is 0o2007",      o.OctalNumber(), "0o2007")
    Then("ToDecimal is 1031",            o.ToDecimal(), 1031)
    Then("ToBinary is 0b10000000111",    o.ToBinary(), "0b10000000111")
    Then("ToHex is 0x407",               o.ToHex(), "0x407")
EndScenario()

Scenario("Build an octal number from other bases")
    Given("an octal number rebuilt from decimal 1031")
    o2 = OctNum("0o0")
    o2.FromDecimal(1031)
    Then("FromDecimal(1031) -> 0o2007", o2.OctalNumber(), "0o2007")
    When("rebuilt from hex 0x407")
    o2.FromHex("0x407")
    Then("FromHex(0x407) -> 0o2007", o2.OctalNumber(), "0o2007")
    When("rebuilt from binary 0b10000000111")
    o2.FromBinary("0b10000000111")
    Then("FromBinary(...) -> 0o2007", o2.OctalNumber(), "0o2007")
EndScenario()

Summary()

func OctNum cStr
    return new stzOctalNumber(cStr)
