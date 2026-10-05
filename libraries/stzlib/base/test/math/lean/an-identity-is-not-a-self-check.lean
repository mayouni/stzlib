-- an-identity-is-not-a-self-check: 6 claim(s) emitted by stzMathClaimSet (plane stzlib-math, M6)
-- check with: lake env lean <this file>   inside a Lake project holding Mathlib
import Mathlib

-- three four five: 3^2 + 4^2 = 5^2
theorem c1_three_four_five : ((3^2 + 4^2 : ℕ) = 5^2) := by norm_num

-- the wrong formula is not an identity: 3^2 + 4^2 + 1 != 5^2
theorem c2_the_wrong_formula_is_not_an_identity : ((3^2 + 4^2 + 1 : ℕ) ≠ 5^2) := by norm_num

-- the root squared: sqrt(3)^2 = 3
theorem c3_the_root_squared : ((Real.sqrt (3)^2 : ℝ) = 3) := by rw [Real.sq_sqrt (by norm_num)]

-- the zero lies above 1.7: 1.7 < sqrt(3)
theorem c4_the_zero_lies_above_1_7 : ((1.7 : ℝ) < Real.sqrt (3)) := by rw [Real.lt_sqrt (by norm_num)]; norm_num

-- the zero lies below 1.8: sqrt(3) < 1.8
theorem c5_the_zero_lies_below_1_8 : ((Real.sqrt (3) : ℝ) < 1.8) := by rw [Real.sqrt_lt' (by norm_num)]; norm_num

-- one and a half is not the root: 1.5^2 != 3
theorem c6_one_and_a_half_is_not_the_root : ((1.5^2 : ℝ) ≠ 3) := by norm_num

