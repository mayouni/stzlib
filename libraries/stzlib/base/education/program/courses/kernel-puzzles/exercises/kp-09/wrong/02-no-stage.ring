# Reads the group's memory that no stage wrote: every slot is still zero.
k = StzKernelMakerQ()
k.TakesVector(:a)
k.ReturnsVector(:c)
k.Shared(:t, 256)
k.ForEachElement('{ @c = @t[255 - @l] }')
? StzKernelPuzzleQ("kp-09").Grade(k)
