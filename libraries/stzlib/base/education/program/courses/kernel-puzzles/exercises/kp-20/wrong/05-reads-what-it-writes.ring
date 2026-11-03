# Adds its left neighbour into the very array it writes: the threads would race, so the checker refuses it.
k = StzKernelMakerQ()
k.TakesVector(:a)
k.ReturnsVector(:c)
k.Shared(:t, 256)
k.Stage('{ @t[@l] = @t[@l] + @t[@l - 1] }')
k.ForEachElement('{ @c = @t[@l] }')
? StzKernelPuzzleQ("kp-20").Grade(k)
