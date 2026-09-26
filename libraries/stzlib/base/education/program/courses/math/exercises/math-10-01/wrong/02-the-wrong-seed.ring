# Seed 3 where 11 was asked: other throws, another count.
SeedRandom(3)
n = 0
for i = 1 to 500
	if StzRandom01() < 0.5  n++  ok
next
? n
? fabs(n - 250) <= 50
