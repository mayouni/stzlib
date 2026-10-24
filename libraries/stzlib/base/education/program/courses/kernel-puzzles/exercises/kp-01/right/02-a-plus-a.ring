# The same answer written another way: the checker compares values, never text.
k = StzKernelMakerQ()
k.TakesVector(:a)
k.ReturnsVector(:c)
k.ForEachElement('{ @c = @a + @a }')
? StzKernelPuzzleQ("kp-01").Grade(k)
