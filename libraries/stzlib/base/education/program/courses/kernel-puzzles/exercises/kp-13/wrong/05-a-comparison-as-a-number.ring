# A comparison used as 0 or 1: refused, since on the device it is a truth value, not a number.
k = StzKernelMakerQ()
k.TakesVector(:a)
k.TakesScalar(:t)
k.ReturnsVector(:c)
k.ForEachElement('{ @c = @a + (@a > t) * (@a - t) }')
? StzKernelPuzzleQ("kp-13").Grade(k)
