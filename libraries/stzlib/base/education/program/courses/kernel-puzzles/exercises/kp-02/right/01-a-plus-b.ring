# Each thread adds ITS a to ITS b.
k = StzKernelMakerQ()
k.TakesVector(:a)
k.TakesVector(:b)
k.ReturnsVector(:c)
k.ForEachElement('{ @c = @a + @b }')
? StzKernelPuzzleQ("kp-02").Grade(k)
