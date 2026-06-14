load "../../stzBase.ring"
load "../_narrated.ring"

# M-S2 narrated regression suite for stzDecimalToBinary -- decimal
# integer -> binary form ("0b...").

Scenario("Positive integers to binary form")
    Then("8 -> 0b1000",       Dtb("8").ToBinaryForm(), "0b1000")
    Then("42 -> 0b101010",    Dtb("42").ToBinaryForm(), "0b101010")
    Then("127 -> 0b1111111",  Dtb("127").ToBinaryForm(), "0b1111111")
    Then("255 -> 0b11111111", Dtb("255").ToBinaryForm(), "0b11111111")
EndScenario()

Summary()

func Dtb cStr
    return new stzDecimalToBinary(cStr)
