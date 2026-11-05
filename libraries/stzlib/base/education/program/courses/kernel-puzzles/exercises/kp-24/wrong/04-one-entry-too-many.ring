# Nine entries a row instead of eight: the ninth is the first entry of the NEXT row, read as if it were this one's.
k = StzKernelMakerQ()
k.TakesVector(:a)
k.TakesVector(:b)
k.TakesVector(:x)
k.ReturnsVector(:y)
k.ForEachElement('{ @y = sum(j, 0, 9, @a[@i * 8 + j] * @x[@b[@i * 8 + j]]) }')
? StzKernelPuzzleQ("kp-24").Grade(k)
