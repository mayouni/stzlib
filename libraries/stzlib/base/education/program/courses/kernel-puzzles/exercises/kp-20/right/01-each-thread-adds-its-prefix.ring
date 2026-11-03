# The slow answer: every thread adds the numbers of the threads up to its own, 256 additions for the last one.
k = StzKernelMakerQ()
k.TakesVector(:a)
k.ReturnsVector(:c)
k.Shared(:t, 256)
k.Stage('{ @t[@l] = @a }')
k.ForEachElement('{ @c = sum(j, 0, 256, when(j <= @l, @t[j], 0)) }')
? StzKernelPuzzleQ("kp-20").Grade(k)
