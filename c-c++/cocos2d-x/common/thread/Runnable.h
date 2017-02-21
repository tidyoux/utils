//
//  Runnable.h
//  
//
//  on 14-10-30.
//
//

#ifndef ____Runnable__
#define ____Runnable__

#include "Macros.h"

xxx_BEGIN

class Runnable
{
public:
    virtual ~Runnable() {};
    
    virtual void run() = 0;
    virtual void stop() = 0;
};

xxx_END

#endif /* defined(____Runnable__) */
