#include <iostream>

extern "C" {
#include "a.h"
}

using namespace std;

int main()
{
    cout << "The answer is " << f() << endl;
    return 0;
}
