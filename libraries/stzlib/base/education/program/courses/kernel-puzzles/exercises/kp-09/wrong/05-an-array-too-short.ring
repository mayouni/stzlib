# Declares the group's array with 128 floats for 256 threads: half the writes are dropped, half the reads find nothing.
k = StzKernelMakerQ()
k.TakesVector(:a)
k.ReturnsVector(:c)
k.Shared(:t, 128)
k.Stage('{ @t[@l] = @a }')
k.ForEachElement('{ @c = @t[255 - @l] }')
? StzKernelPuzzleQ("kp-09").Grade(k)
