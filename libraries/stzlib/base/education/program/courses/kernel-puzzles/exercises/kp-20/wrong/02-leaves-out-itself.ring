# Adds the threads BEFORE its own: the exclusive total, one place late.
k = StzKernelMakerQ()
k.TakesVector(:a)
k.ReturnsVector(:c)
k.Shared(:t, 256)
k.Stage('{ @t[@l] = @a }')
k.ForEachElement('{ @c = sum(j, 0, 256, when(j < @l, @t[j], 0)) }')
? StzKernelPuzzleQ("kp-20").Grade(k)
