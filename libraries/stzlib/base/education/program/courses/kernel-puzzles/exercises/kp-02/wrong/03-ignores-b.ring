# Reads a twice and never b: right at element 1 (both 0), wrong from element 2.
k = StzKernelMakerQ()
k.TakesVector(:a)
k.TakesVector(:b)
k.ReturnsVector(:c)
k.ForEachElement('{ @c = @a + @a }')
? StzKernelPuzzleQ("kp-02").Grade(k)
