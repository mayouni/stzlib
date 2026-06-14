load "../../stzBase.ring"
load "../_narrated.ring"

# M-S2 narrated regression suite for stzBinaryNumber -- binary <-> decimal
# round trips. (The constructor requires the canonical "0b" prefix.)

Scenario("Binary form to decimal")
    Then("0b1111111 -> 127", Bin("0b1111111").ToDecimalForm(), 127)
    Then("0b1010 -> 10",     Bin("0b1010").ToDecimalForm(), 10)
    Then("0b100000 -> 32",   Bin("0b100000").ToDecimalForm(), 32)
EndScenario()

Scenario("Decimal to binary form")
    Given("a binary number rebuilt from decimals")
    o = Bin("0b0")
    o.FromDecimal(127)
    Then("FromDecimal(127) -> 0b1111111", o.BinaryNumber(), "0b1111111")
    o.FromDecimal(255)
    Then("FromDecimal(255) -> 0b11111111", o.BinaryNumber(), "0b11111111")
EndScenario()

Summary()

func Bin cStr
    return new stzBinaryNumber(cStr)
