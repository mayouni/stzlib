
B = list(4)
//? b

//? char(ascii("b"))

for i = 1 to 4
        B[i]= Space(4)
        for j = 1 to 4
		B[i][j] = char( 60 + 4 * i + j )
	next j

        ? "B" + i +": " + B[i]
next

? bytes2double("ABCDEFGH")
//? bytes2int("ح")

/*
string: 1 byte (8 bits)
stzstring : 2 bytes (16 bits)
int : 4 bytes (32 bits)
float : 4 bytes (32 bits)
double : 8 bytes (64 bits)

	Number			Byte		Number
	         int2bytes(n)	     bytes2int()
		float2bytes(n)	     bytes2float()
		double2bytes(n)	     bytes2double()
/*
