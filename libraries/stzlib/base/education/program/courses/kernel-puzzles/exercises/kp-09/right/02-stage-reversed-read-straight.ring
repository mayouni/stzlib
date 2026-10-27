# The same reverse done on the way in: write to the mirror slot, read your own.
k = StzKernelMakerQ()
k.TakesVector(:a)
k.ReturnsVector(:c)
k.Shared(:t, 256)
k.Stage('{ @t[255 - @l] = @a }')
k.ForEachElement('{ @c = @t[@l] }')
? StzKernelPuzzleQ("kp-09").Grade(k)
