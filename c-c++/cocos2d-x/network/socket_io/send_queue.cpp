//
//  send_queue.cpp
//  test_pro
//
//  on 3/6/14.
//
//

#include "send_queue.h"
#include <thread>
#include <iostream>
#include "message.h"
#include <poll.h>
#include <sys/select.h>
#include <netinet/in.h>
#include <sys/socket.h>
#include <assert.h>

using namespace std;


static int doSendBuffer(unsigned int net_sockfd, char *buff, const int total_len)
{
    int remain_len = total_len;
    while(remain_len > 0)
    {
        const ssize_t sendn = send(net_sockfd, buff, remain_len, 0);
        if(sendn < 0)
        {
            if(errno == EINTR || errno == EAGAIN)
            {
                continue;
            }
            else
            {
                std::cout << "Error: doSendBuffer, send errno: " << errno << std::endl;
                break;
            }
        }
        remain_len -= sendn;
        buff += sendn;
    }
    return total_len - remain_len;
}

//发送队列只要有消息，就发出去，否则线程就wait
void send_queue::handle(unsigned int the_socket, ErrcodeHandler errHandler)
{
    if (mMsgQue.isEmpty())
    {
        return;
    }
    
    struct pollfd pfd;
    pfd.fd = the_socket;
    pfd.events = POLLOUT;
    
    const int result = poll(&pfd, 1, WAIT_TIME_MICROSECOND);
    if(result > 0)
    {
        message *msg = pop();
        int send_result = doSendBuffer(the_socket, msg->GetData(), msg->GetMsglen());
        if (send_result != msg->GetMsglen())
        {
            std::cout << "Error: send_queue::handle, send buffer error! ######\n" << std::endl;
            clear();
        }
        else
        {
            errHandler(0);
        }
        delete msg;
    }
}


