
    #include <iostream>
    #include <fstream>
    
    int main() {
        std::ofstream outFile("cppdata.txt");
        outFile << "[[\"numbers\", [1, 2, 3, 4, 5]]]";
        outFile.close();
        std::cout << "Data written to file" << std::endl;
        return 0;
    }