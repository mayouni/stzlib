# The scalar is one value every thread reads; the task's alpha.
k = StzKernelMakerQ()
k.TakesVector(:a)
k.TakesScalar(:alpha)
k.ReturnsVector(:c)
k.ForEachElement('{ @c = alpha * @a }')
? StzKernelPuzzleQ("kp-03").Grade(k)
