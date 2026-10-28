# Past t it charges only the extra units: 7 costs 2 where it should cost 8.
k = StzKernelMakerQ()
k.TakesVector(:a)
k.TakesScalar(:t)
k.ReturnsVector(:c)
k.ForEachElement('{ @c = when(@a <= t, @a, 2 * (@a - t)) }')
? StzKernelPuzzleQ("kp-13").Grade(k)
