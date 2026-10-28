# The two prices in each other's place: wrong from the first element, where 0 becomes -6.
k = StzKernelMakerQ()
k.TakesVector(:a)
k.TakesScalar(:t)
k.ReturnsVector(:c)
k.ForEachElement('{ @c = when(@a <= t, t + 2 * (@a - t), @a) }')
? StzKernelPuzzleQ("kp-13").Grade(k)
