# The starter, untouched: no body yet.
k = StzKernelMakerQ()
k.TakesVector(:a)
k.ReturnsVector(:c)
k.Shared(:t, 256)
k.Shared(:r, 256)
k.Stage('{ @t[@l] = @a }')
? StzKernelPuzzleQ("kp-21").Grade(k)
