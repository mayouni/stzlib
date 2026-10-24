# The wrong operator: named at the first element where the two differ.
k = StzKernelMakerQ()
k.TakesVector(:a)
k.TakesVector(:b)
k.ReturnsVector(:c)
k.ForEachElement('{ @c = @a - @b }')
? StzKernelPuzzleQ("kp-02").Grade(k)
