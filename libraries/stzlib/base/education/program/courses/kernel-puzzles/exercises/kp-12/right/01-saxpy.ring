# Two reads, one multiply, one add, one write per element.
k = StzKernelMakerQ()
k.TakesVector(:a)
k.TakesVector(:b)
k.TakesScalar(:alpha)
k.ReturnsVector(:c)
k.ForEachElement('{ @c = alpha * @a + @b }')
? StzKernelPuzzleQ("kp-12").Grade(k)
