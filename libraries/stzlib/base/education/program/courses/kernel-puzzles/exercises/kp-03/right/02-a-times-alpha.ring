# The same product written the other way round.
k = StzKernelMakerQ()
k.TakesVector(:a)
k.TakesScalar(:alpha)
k.ReturnsVector(:c)
k.ForEachElement('{ @c = @a * alpha }')
? StzKernelPuzzleQ("kp-03").Grade(k)
