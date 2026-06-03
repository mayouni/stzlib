# Narrative
# --------
# Running multiple functions in parallel
#
# Extracted from stzreactivefunctest.ring, block #2.

load "../../stzBase.ring"


# The power of reactive functions: multiple heavy operations at once
# Traditional approach would run them one after another (sequential)
# Reactive approach runs them simultaneously (parallel)

pr()

oRs = new stzReactiveSystem()
oRs {

    # Three different CPU-intensive functions
    fFibonacci = func n {
        if n <= 1 return n ok
        a = 0  b = 1
        for i = 2 to n
            temp = a + b
            a = b
            b = temp
        next
        return b
    }
    
    fFactorial = func n {
        result = 1
        for i = 2 to n
            result *= i
        next
        return result
    }
    
    fPrimeCount = func limit {
        count = 0
        for num = 2 to limit
            isPrime = true
            for i = 2 to sqrt(num)
                if num % i = 0
                    isPrime = false
                    exit
                ok
            next
            if isPrime count++ ok
        next
        return count
    }

    # Make all functions reactive
    RFib = Reactivate(fFibonacci) # Or MakeReactive()
    RFact = Reactivate(fFactorial) 
    RPrime = Reactivate(fPrimeCount)


    # Launch all three simultaneously
    ? "Starting three heavy calculations in parallel..." + NL
    
    RFib.CallAsync([35], func result { 
        ? "Fibonacci(35): " + result 
    }, NULL)
    
    RFact.CallAsync([15], func result { 
        ? "Factorial(15): " + result 
    }, NULL)
    
    RPrime.CallAsync([1000], func result { 
        ? "Primes up to 1000: " + result 
    }, NULL)

    # All tasks queued - processing now
    Start()
    #-->
    # Starting three heavy calculations in parallel...
    # Factorial(15): 1307674368000
    # Fibonacci(35): 9227465
    # Primes up to 1000: 168

}

pf()
# Executed in 0.92 second(s) in Ring 1.23

#-----------------------------#
#  EXAMPLE 3: ERROR HANDLING  #
#-----------------------------#
