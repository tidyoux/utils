//
//  DebugTools.h
//  
//
//  on 14-12-30.
//
//

#ifndef ____DebugTools__
#define ____DebugTools__

#include "Macros.h"
#include <string>

class DebugTools
{
public:
    static void printStackTrace(const std::string &title);
    
private:
    make_static_class(DebugTools);
};

#endif /* defined(____DebugTools__) */
