//
//  DebugTools.cpp
//  
//
//  on 14-12-30.
//
//

#include "DebugTools.h"
#include <stdlib.h>

#if defined(CC_TARGET_OS_IPHONE)
    #include <execinfo.h>
#endif


void DebugTools::printStackTrace(const std::string &title)
{
#if defined(CC_TARGET_OS_IPHONE)
    printf("*** %s ***\n", title.c_str());
    static const int SIZE = 128;
    void * array[SIZE];
    const int stackNum = backtrace(array, SIZE);
    char ** stackTrace = backtrace_symbols(array, stackNum);
    for0_n(i, stackNum)
    {
        printf("%s\n", stackTrace[i]);
    }
    free(stackTrace);
#else
    printf("error: DebugTools::printStackTrace, not implemented!");
#endif
}
