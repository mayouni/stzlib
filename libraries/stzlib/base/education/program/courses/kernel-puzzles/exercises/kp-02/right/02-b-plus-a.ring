# The same sum the other way round: the checker compares values, never text.
k = StzKernelMakerQ()
k.TakesVector(:a)
k.TakesVector(:b)
k.ReturnsVector(:c)
k.ForEachElement('{ @c = @b + @a }')
? StzKernelPuzzleQ("kp-02").Grade(k)
