# The stop is a condition, not a number: refused before anything runs.
k = StzKernelMakerQ()
k.TakesVector(:a)
k.ReturnsVector(:c)
k.ForEachElement('{ @c = iterate(k, 0, 40, s, 0.5, s * 2, s) }')
? StzKernelPuzzleQ("kp-18").Grade(k)
