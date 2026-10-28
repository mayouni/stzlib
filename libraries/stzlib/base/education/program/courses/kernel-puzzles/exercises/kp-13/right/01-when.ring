# Up to t, the amount itself; past t, t plus twice what is over.
k = StzKernelMakerQ()
k.TakesVector(:a)
k.TakesScalar(:t)
k.ReturnsVector(:c)
k.ForEachElement('{ @c = when(@a <= t, @a, t + 2 * (@a - t)) }')
? StzKernelPuzzleQ("kp-13").Grade(k)
