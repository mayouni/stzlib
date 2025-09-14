load "../stzbase.ring"

/*==== USING a JS code inside Ring  #===
*/
pr()

# The following JS code translate some string to
# uppercase in a locale sensitive way:
# (you can paste/test it here: https://bit.ly/3WdzMdF)
"
console.log('tunis'.toUpperCase());
//--> TUNIS
console.log('Iİıi'.toLocaleUpperCase('TR'));
//--> IİIİ
console.log('ß'.toLocaleUpperCase('de'));
//--> SS
"
# You can write nearly the same code, with almost the
# same JS-style, in Ring, using Softanza:

console.log( Q('tunis').toUpperCase() );
#--> TUNIS
	
console.log( Q('Iİıi').toLocaleUpperCase('TR') );
#--> IİII
	
console.log( Q('ß').toLocaleUppercase('de') );
#--> SS

#NOTE // that the only difference is to elevate the string to
# stzString objects using Q()

pf()
# Executed in 0.01 second(s) in Ring 1.21
# Executed in 0.05 second(s) in Ring 1.20
