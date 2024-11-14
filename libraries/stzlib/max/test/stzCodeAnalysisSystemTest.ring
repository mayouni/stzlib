load "../stzmax.ring"


# Example Usage
analy = new stzCodeAnalyzer

# Test code with various scope and reference scenarios
testCode = '
class TestClass {
    value = 0
    func setValue x {
        value = x
        aList = [1,2,3]
        modifyList(aList)
        return value
    }
    func modifyList aParam {
        add(aParam, 4)
    }
}

global = "Global Value"
oTest = new TestClass
result = oTest.setValue(100)
'

analy.analyze(testCode)

/*---------

# Example Usage
analyzer = new AdvancedAnalyzer

testCode = '
load "stdlib.ring"
load "jsonlib.ring"

class DataProcessor {
    data = []
    
    func process aInput {
        for item in aInput {
            if item = null return null  # Potential error
            
            processed = transform(item)
            add(data, processed)
        }
        return data
    }
    
    func transform item {
        if isList(item)
            return reverse(item)
        return item
    }
}

# Create some test data
aList = [[1,2,3], [4,5,6], [7,8,9]]
processor = new DataProcessor
result = processor.process(aList)

# Some potential error cases
x = y + 1  # Undefined variable
aList = null
processor.process(aList)  # Null dereference
'

analyzer.analyze(testCode)
