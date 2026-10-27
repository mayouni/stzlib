# Adds the two vectors and never scales a.
k = StzKernelMakerQ()
k.TakesVector(:a)
k.TakesVector(:b)
k.TakesScalar(:alpha)
k.ReturnsVector(:c)
k.ForEachElement('{ @c = @a + @b }')
? StzKernelPuzzleQ("kp-12").Grade(k)
