load "../../stzBase.ring"

# iif - boolean inputs
? iif(1, "yes", "no") = "yes"
? iif(0, "yes", "no") = "no"

# iif - string-expression input (eval branch)
? iif("1 = 1", "T", "F") = "T"
? iif("2 = 3", "T", "F") = "F"

# Length() forwarder
? Length([1, 2, 3]) = 3
? Length("abc") = 3

# range0 (Python-style, end-exclusive)
? @@(range0(3)) = "[ 0, 1, 2 ]"
? @@(range0([1, 4])) = "[ 1, 2, 3 ]"
? @@(range0([1, 6, 2])) = "[ 1, 3, 5 ]"

# range0 negative step
? @@(range0([5, 1, -1])) = "[ 5, 4, 3, 2 ]"

# range1 (1-based, end-inclusive)
? @@(range1(3)) = "[ 1, 2, 3 ]"
? @@(range1([2, 5])) = "[ 2, 3, 4, 5 ]"

# print = ? (just exercise, no value check)
print("[print works]")

? "DONE 11"
