//
//  thread_helper.cpp
//  
//
//  on 14-10-30.
//
//

#include "ThreadHelper.h"
#include "Runnable.h"
#include <thread>

xxx_BEGIN

void ThreadHelper::start(Runnable *rnb)
{
    if (rnb != nullptr)
    {
        std::thread t = std::thread([rnb]()
                                    {
                                        rnb->run();
                                        delete rnb;
                                    });
        t.detach();
    }
}

xxx_END