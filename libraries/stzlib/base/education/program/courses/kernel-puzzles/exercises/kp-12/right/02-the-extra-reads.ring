# Right and slower: every thread also reads the first 64 numbers of a and multiplies their sum by 0.
k = StzKernelMakerQ()
k.TakesVector(:a)
k.TakesVector(:b)
k.TakesScalar(:alpha)
k.ReturnsVector(:c)
k.ForEachElement('{ @c = alpha * @a + @b + 0 * sum(k, 0, 64, @a[k]) }')
? StzKernelPuzzleQ("kp-12").Grade(k)
