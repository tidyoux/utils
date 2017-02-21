//
//  receive_queue.h
//  test_pro
//
//  on 3/6/14.
//
//

#ifndef __test_pro__receive_queue__
#define __test_pro__receive_queue__

#include "socket_handler.h"

class receive_queue : public socket_handler
{
public:
    virtual void handle(unsigned int the_socket, ErrcodeHandler errHandler) override;
};


#endif /* defined(__test_pro__receive_queue__) */
	