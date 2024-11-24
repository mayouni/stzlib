
#===========================================#
#   CHECKING IF THE LIST IS A NAMED PARAM   #
#===========================================#

#NOTE
# This file replaces all the methods in stzList initailly made
# to check named params. Hence, they are transformed to global
# functions, without the need of instanciating a stzList object
# at each use. Which also leads to better performance.

#TODO // Test this file, repalce all the occurrence where named
# params are used in the library with these global functions,
# and then remove all the relative methods from stzList class.

# Currently (V1) Softanza supports more then 1760 named params

#TODO // Add @ to all params, like this:
# (paList[1] = :ParamName or paList[1] = :ParamName@ ) )

#TODO // Add _acNamedParams = [] list and use it to check if
# a give string is a named param (to avoid the current solution
# implemented using eval, see IsNamedParam() function)

