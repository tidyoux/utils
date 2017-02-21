//
//  socket_handler.h
//  
//
//  on 14-10-30.
//
//

#ifndef ____socket_handler__
#define ____socket_handler__

#include <string>
#include "Macros.h"
#include "LockedQueue.h"
#include "message.h"


static const int WAIT_TIME_MICROSECOND = 500;

typedef std::function<void(int errcode)> ErrcodeHandler;
class socket_handler
{
public:
    virtual ~socket_handler() {clear();}
    
    virtual void handle(unsigned int the_socket, ErrcodeHandler errHandler) = 0;
    
    void push(message *msg)
    {
        if (msg == nullptr)
        {
            return;
        }
        mMsgQue.pushBack(msg);
    }
    
    message *pop()
    {
        message *ret = nullptr;
        mMsgQue.pickFront(ret);
        return ret;
    }
    
    void clear()
    {
        message *msg = nullptr;
        while(mMsgQue.pickFront(msg))
        {
            if (msg == nullptr)
            {
                break;
            }
            delete msg;
        }
    }
    
protected:
    LockedQueue<message *> mMsgQue;
};

#endif /* defined(____socket_handler__) */
