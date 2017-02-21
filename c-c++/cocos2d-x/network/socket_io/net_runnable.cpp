//
//  net_runnable.cpp
//  
//
//  on 14-10-30.
//
//

#include "net_runnable.h"
#include <iostream>
#include <sys/socket.h>
#include <arpa/inet.h>
#include <sys/errno.h>
#include <unistd.h>
#include <sys/ioctl.h>
#include <sys/types.h>
#include <netdb.h>
#include "LockedQueue.h"
#include "socket_handler.h"
#include "MsgBase.pb.h"
#include "MsgClient.pb.h"
#include "StringTools.h"


using namespace com::xxx::msg;


static const int PING_INTERVAL = 5;
static const int MAX_PONG_WAIT_TIME = 15;


net_runnable::net_runnable(const std::string &host, unsigned short port, socket_handler *recHandler, socket_handler *sendHandler)
:m_toStop(false)
,m_host(host)
,m_port(port)
,m_isConnected(false)
,m_toDisconnect(false)
,m_isInBackground(false)
,m_pingPongEnabled(true)
,m_lastPingTime(0)
,m_lastReceiveMsgTime(0)
,m_socket(-1)
,m_recHandler(recHandler)
,m_sendHandler(sendHandler)
{
    //
}

net_runnable::~net_runnable()
{
    m_toStop = true;
}

void net_runnable::run()
{
    if (m_toStop)
    {
        return;
    }
    
    if (!init())
    {
        m_toStop = true;
        std::cout << "Error: net_runnable, init failed" << std::endl;
        return;
    }
    
    while(!m_toStop)
    {
        handleOutCmd();
        if (m_isConnected)
        {
            if (m_isInBackground)
            {
                m_lastReceiveMsgTime = time(nullptr);
                usleep(1500000);
                continue;
            }
            
            if (m_recHandler && !m_toDisconnect)
            {
                m_recHandler->handle(m_socket, [this](int errcode)
                                     {
                                         if (errcode == 0)
                                         {
                                             m_lastReceiveMsgTime = time(nullptr);
                                         }
                                         else if(errcode == ECONNRESET || errcode == ENOTCONN)
                                         {
                                             m_toDisconnect = true;
                                         }
                                     });
            }
            
            if (m_sendHandler && !m_toDisconnect)
            {
                m_sendHandler->handle(m_socket, [this](int errcode)
                                          {
                                              if(errcode == ECONNRESET || errcode == ENOTCONN)
                                              {
                                                  m_toDisconnect = true;
                                              }
                                          });
            }
            
            if (m_pingPongEnabled && !m_toDisconnect)
            {
                const time_t curTime = time(nullptr);
                if (curTime - m_lastPingTime > PING_INTERVAL)
                {
                    ping();
                }
                
                if (curTime - m_lastReceiveMsgTime > MAX_PONG_WAIT_TIME)
                {
                    m_toDisconnect = true;
                }
            }
            
            if (m_toDisconnect)
            {
                doDisconnect();
            }
            
            usleep(3000);
        }
        else
        {
            usleep(1500000);
            m_isConnected = connect();
        }
    }
    
    unInit();
}

void net_runnable::stop()
{
    m_toStop = true;
}

void net_runnable::reconnect(const std::string &host, unsigned short port)
{
    if ((m_host != host) || (m_port != port))
    {
        m_host = host;
        m_port = port;
        disconnect();
    }
    else
    {
        if (m_isConnected)
        {
            std::cout << "net_runnable, network is already connected!" << std::endl;
        }
        else
        {
            std::cout << "net_runnable, network is connecting!" << std::endl;
            stateNotify(state_connecting);
        }
    }
}

void net_runnable::disconnect()
{
    if (!m_toDisconnect)
    {
        addOutCmd([](net_runnable *rnb)
                  {
                      rnb->m_toDisconnect = true;
                  });
    }
}

void net_runnable::sendMessage(Message *msg)
{
    m_sendHandler->push(new message(msg));
}

message *net_runnable::recMessage()
{
    if (m_recHandler)
    {
        auto *msg = m_recHandler->pop();
        return msg;
    }
    return nullptr;
}

void net_runnable::setIsInBackground(bool isInBackground)
{
    m_isInBackground = isInBackground;
}

void net_runnable::setPingPongEnabled(bool enable)
{
    if (enable != m_pingPongEnabled)
    {
        addOutCmd([enable](net_runnable *rnb)
                  {
                      rnb->m_pingPongEnabled = enable;
                      rnb->m_lastReceiveMsgTime = time(nullptr);
                  });
    }
}

bool net_runnable::init()
{
    if (!m_isConnected)
    {
        m_isConnected = connect();
        if (!m_isConnected)
        {
            stateNotify(state_not_ready);
        }
    }
    
    return true;
}

void net_runnable::unInit()
{
    if (m_socket >= 0) {
        shutdown(m_socket, SHUT_RDWR);
        close(m_socket);
        m_socket = -1;
    }
    
    m_isConnected = false;
    m_toDisconnect = false;
    m_lastPingTime = 0;
    m_outCmds.clear();
    
    if (m_toStop)
    {
        if (m_recHandler)
        {
            delete m_recHandler;
            m_recHandler = nullptr;
        }
        
        if (m_sendHandler)
        {
            delete m_sendHandler;
            m_sendHandler = nullptr;
        }    
    }
}

int tcp_connect(const char *host, const char *serv)
{
    int sockfd, err;
    struct addrinfo hints, *res, *ressave;
    
    bzero(&hints, sizeof(struct addrinfo));
    hints.ai_family = AF_UNSPEC;
    hints.ai_socktype = SOCK_STREAM;
    
    err = getaddrinfo(host, serv, &hints, &res);
    if (err != 0)
    {
        return -1;
    }
    
    ressave = res;
    
    do
    {
        sockfd = socket(res->ai_family, res->ai_socktype, res->ai_protocol);
        if (sockfd < 0)
        {
            continue; // ignore this one
        }
        
        err = connect(sockfd, res->ai_addr, res->ai_addrlen);
        if (err == 0)
        {
            break; // success
        }
        
        close(sockfd); // ignore this one
        
        res = res->ai_next;
    } while(res != nullptr);
        
    if (res == nullptr)
    {
        return -1;
    }
    
    freeaddrinfo(ressave);
    
    return sockfd;
}

bool net_runnable::connect()
{
    if (m_host.empty())
    {
        return false;
    }
    
    if (m_socket >= 0)
    {
        close(m_socket);
        m_socket = -1;
    }
    
    stateNotify(state_connecting);
    
    const std::string &port = StringTools::toString(m_port);
    int ret = tcp_connect(m_host.c_str(), port.c_str());
    if(ret == -1)
    {
        std::cout << "Error(" << errno << "): net_runnable, failed to connect -> " << m_host << ":" << m_port << std::endl;
        
        stateNotify(state_not_ready);
        return false;
    }
    
    m_socket = ret;
    m_toDisconnect = false;
    
    std::cout << "success to connect -> " << m_host << ":" << m_port << std::endl;
    
    const unsigned long ul = 1;
    ret = ioctl(m_socket, FIONBIO, &ul);
    if(ret == -1)
    {
        std::cout << "Error(" << errno << "): net_runnable, failed to ioctlsocket." << std::endl;
        stateNotify(state_not_ready);
        return false;
    }
    
    m_isConnected = true;
    m_lastPingTime = time(nullptr);
    m_lastReceiveMsgTime = time(nullptr);
    stateNotify(state_connected);
    
    return true;
}

void net_runnable::doDisconnect()
{
    if (m_isConnected)
    {
        std::cout << "net_runnable, do disconnect, shutdown socket." << std::endl;
        unInit();
        stateNotify(state_disconnected);
    }
}

void net_runnable::stateNotify(int state)
{
    if (m_recHandler)
    {
        auto *msg = new MsgClientNetStateNotify();
        msg->set_current_state(state);
        m_recHandler->push(new message(msg, false));
    }
}

void net_runnable::ping()
{
    if (m_sendHandler)
    {
        auto *msg = new MsgPing();
        m_sendHandler->push(new message(msg, true));
        
        m_lastPingTime = time(nullptr);
    }
}

void net_runnable::handleOutCmd()
{
    OutCommand cmd;
    while(m_outCmds.pickFront(cmd))
    {
        if (cmd != nullptr)
        {
            cmd(this);
        }
    }
}

void net_runnable::addOutCmd(OutCommand cmd)
{
    if (cmd != nullptr)
    {
        m_outCmds.pushBack(cmd);
    }
}



