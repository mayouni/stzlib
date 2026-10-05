# No seed: the throws differ on every run, and no promise about them can be kept.
n = 0
for i = 1 to 500
	if StzRandom01() < 0.5  n++  ok
next
? n
? 1
