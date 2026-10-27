# Reverses the whole vector instead of each group of 256.
k = StzKernelMakerQ()
k.TakesVector(:a)
k.ReturnsVector(:c)
k.Shared(:t, 256)
k.ForEachElement('{ @c = @a[n - 1 - @i] }')
? StzKernelPuzzleQ("kp-09").Grade(k)
