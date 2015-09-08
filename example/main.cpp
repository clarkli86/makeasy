#include <iostream>
#include "defs.h"
using namespace std;

extern "C" int c_func();
/* Use the main from gtest_main.cc
int main()
{
    cout << "Hello Make!" << endl;
    cout << "c_func() returns " << c_func() << endl;
    return 0;
}
*/
