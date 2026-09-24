# Prints the rule instead of applying it to the second list.
cRule = "{ @item > 20 }"
? StzListQ([ 12, 0, 30, -5, 18, 25 ]).CountW(cRule)
? cRule
