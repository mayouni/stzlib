# The same sum the other way round.
k = StzKernelMakerQ()
k.TakesVector(:a)
k.ReturnsVector(:c)
k.ForEachElement('{ @c = @i + @a }')
? StzKernelPuzzleQ("kp-04").Grade(k)
