#include <iostream>
using namespace std;

extern "C" int c_func();
int main()
{
    cout << "Hello Make!" << endl;
    cout << "c_func() returns " << c_func() << endl;
    return 0;
}
