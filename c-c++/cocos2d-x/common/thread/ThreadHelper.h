//
//  thread_helper.h
//  
//
//  on 14-10-30.
//
//

#ifndef ____ThreadHelper__
#define ____ThreadHelper__

#include "Macros.h"

xxx_BEGIN

class Runnable;
class ThreadHelper
{
public:
    static void start(Runnable *rnb);
    
private:
    make_static_class(ThreadHelper);
};

xxx_END

#endif /* defined(____ThreadHelper__) */
