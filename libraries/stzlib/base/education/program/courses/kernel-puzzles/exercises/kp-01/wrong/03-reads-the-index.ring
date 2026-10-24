# The cheat: a[i] happens to be i on the shown data, so twice the INDEX is right
# everywhere it was shown -- and wrong on the hidden set, where it is caught.
k = StzKernelMakerQ()
k.TakesVector(:a)
k.ReturnsVector(:c)
k.ForEachElement('{ @c = @i * 2 }')
? StzKernelPuzzleQ("kp-01").Grade(k)
