# At exactly t both formulas give t, so the boundary may sit on either side.
k = StzKernelMakerQ()
k.TakesVector(:a)
k.TakesScalar(:t)
k.ReturnsVector(:c)
k.ForEachElement('{ @c = when(@a < t, @a, t + 2 * (@a - t)) }')
? StzKernelPuzzleQ("kp-13").Grade(k)
