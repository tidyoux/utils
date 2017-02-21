//
//  receive_queue.cpp
//  test_pro
//
//  on 3/6/14.
//
//

#include "receive_queue.h"
#include <thread>
#include <iostream>
#include <poll.h>
#include <sys/socket.h>
#include <arpa/inet.h>
#include "message.h"


static int doRecvBuffer(unsigned int net_sockfd, char *buff, int total_len, ErrcodeHandler errHandler)
{
    int remain_len = total_len;
    while(remain_len > 0)
    {
        const ssize_t recvn = recv(net_sockfd, buff, remain_len, 0);
        if(recvn < 0)
        {
            if(errno == EINTR || errno == EAGAIN)
            {
                continue;
            }
            else
            {
                std::cout << "Error: doRecvBuffer, recv errno: " << errno << std::endl;
                errHandler(errno);
                break;
            }
        }
        else if(recvn == 0) // server shutdown (not crash)
        {
            errHandler(ECONNRESET);
            break;
        }
        else
        {
            remain_len -= recvn;
            buff += recvn;
        }
    }
    
    return total_len - remain_len;
}

//如果接收队列有消息，则取出，否则线程循环
void receive_queue::handle(unsigned int the_socket, ErrcodeHandler errHandler)
{
    struct pollfd pfd;
    pfd.fd = the_socket;
    pfd.events = POLLIN;
    
    // 检测socket状态 是否有数据要读取
    const int result = poll(&pfd, 1, WAIT_TIME_MICROSECOND);
    if(result > 0)
    {
        // 从缓冲器中读取消息头
        char head[4] = {0};
        const int32_t head_len = sizeof(head);
        int recvn = doRecvBuffer(the_socket, head, head_len, errHandler);
        if (recvn <= 0)
        {
            return;
        }
        
        // 读取数据有错误 长度不一样
        if(recvn != head_len)
        {
            // 这里消息出错了
            std::cout << "Error: receive_queue, bad msg head!" << std::endl;
            return;
        }
        
        // 读取消息的长度
        int32_t len = 0;
        memcpy(&len, head, 4);
        // 转化成32位
        len = htonl(len);
        
        // 判断大小
        if (len <= 0)
        {
            std::cout << "Error: receive_queue, msg len err!";
            return;
        }
        
        // 声明足够大的内存来读取缓冲区的消息
        char *buf = (char *)malloc(head_len + len);
        if(buf == nullptr)
        {
            std::cout << "Error: receive_queue, malloc buff failed!";
            return;
        }
        
        // 将消息头放在缓冲器中
        memcpy(buf, head, head_len);
        
        char *pbuf = buf;
        pbuf += head_len;
        recvn += doRecvBuffer(the_socket, pbuf, len, errHandler);
        if (recvn != (head_len + len))
        {
            std::cout << "Error: receive_queue, bad msg body!" << std::endl;
            free(buf);
            return;
        }
        
        message *msg = new message(buf, recvn);
        push(msg);
        
        errHandler(0);
    }
}

