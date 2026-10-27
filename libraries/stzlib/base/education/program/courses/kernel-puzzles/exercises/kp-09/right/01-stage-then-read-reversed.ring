# Each thread puts its element in the group's memory; after the barrier it reads the slot its mirror wrote.
k = StzKernelMakerQ()
k.TakesVector(:a)
k.ReturnsVector(:c)
k.Shared(:t, 256)
k.Stage('{ @t[@l] = @a }')
k.ForEachElement('{ @c = @t[255 - @l] }')
? StzKernelPuzzleQ("kp-09").Grade(k)
