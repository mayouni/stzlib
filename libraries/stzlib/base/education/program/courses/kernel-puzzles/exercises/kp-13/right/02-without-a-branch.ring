# No when at all: the amount, plus what is over t once more (max keeps it from going below zero).
k = StzKernelMakerQ()
k.TakesVector(:a)
k.TakesScalar(:t)
k.ReturnsVector(:c)
k.ForEachElement('{ @c = @a + max(@a - t, 0) }')
? StzKernelPuzzleQ("kp-13").Grade(k)
