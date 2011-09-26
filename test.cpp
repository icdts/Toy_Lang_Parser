#include <iostream>
#include <sstream>
#include <unordered_map>

using namespace std;

int main(void){
    unordered_map<string,string> list;

    list["a"] = "123asdf";

    string s;
    stringstream out;
    out << list["a"];
    s = out.str();

    cout << s;

    return 0;
}
