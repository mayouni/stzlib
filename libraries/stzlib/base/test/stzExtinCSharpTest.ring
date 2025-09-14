load "../stzbase.ring"

/*==== Using a C# code inside Ring  #===
*/
StartProfiler()

# This is a C# code showing string interpolation:
'
int max = int.MaxValue;
int min = int.MinValue;
Console.WriteLine($"The range of integers is {min} to {max}");
'

# And here is the same code translated to Ring:

int max = int.MaxValue;
int min = int.MinValue;
Console.WriteLine( $("The range of integers is {min} to {max}") );
#--> The range of integers is '-999_999_999_999_999' to '999_999_999_999_999'

#NOTE // that the only change made to the original C# code is to bound the string with ()

StopProfiler()
# Executed in 0.01 second(s) in Ring 1.23
# Executed in 0.02 second(s) in Ring 1.21
# Executed in 0.10 second(s) in Ring 1.20
