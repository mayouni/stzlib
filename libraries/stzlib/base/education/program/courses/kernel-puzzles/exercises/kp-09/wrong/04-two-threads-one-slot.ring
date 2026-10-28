# Stages through the index modulo 128: threads 0 and 128 write the same slot -- a race.
k = StzKernelMakerQ()
k.TakesVector(:a)
k.ReturnsVector(:c)
k.Shared(:t, 256)
k.Stage('{ @t[@l % 128] = @a }')
k.ForEachElement('{ @c = @t[255 - @l] }')
? StzKernelPuzzleQ("kp-09").Grade(k)
