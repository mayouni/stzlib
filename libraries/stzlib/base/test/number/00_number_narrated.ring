load "../../stzBase.ring"
load "../_narrated.ring"

# M-S2 narrated regression suite for stzNumber (engine-backed number theory
# + arithmetic). Deterministic. Objects via Q(n).

Scenario("Number theory")
    Then("5! is 120", Q(5).Factorial(), 120)
    Then("GCD(12,18) is 6", Q(12).GCD(18), 6)
    Then("LCM(4,6) is 12", Q(4).LCM(6), 12)
    Then("Fibonacci(10) is 55", Q(10).Fibonacci(), 55)
EndScenario()

Scenario("Primality and parity")
    Then("17 is prime", Q(17).IsPrime(), TRUE)
    Then("18 is not prime", Q(18).IsPrime(), FALSE)
    Then("4 is even", Q(4).IsEven(), TRUE)
    Then("4 is not odd", Q(4).IsOdd(), FALSE)
    Then("12 is a multiple of 3", Q(12).IsMultipleOf(3), TRUE)
    Then("12 is not a multiple of 5", Q(12).IsMultipleOf(5), FALSE)
EndScenario()

Scenario("Arithmetic and sign")
    Then("2^10 is 1024", Q(2).Power(10), 1024)
    Then("Abs(-7) is 7", Q(-7).Abs(), 7)
    Then("-3 is negative", Q(-3).IsNegative(), TRUE)
    Then("-3 is not positive", Q(-3).IsPositive(), FALSE)
    Then("Digits(1245) is [1,2,4,5]", ListEq(Q(1245).Digits(), [ 1, 2, 4, 5 ]), TRUE)
EndScenario()

Summary()

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
