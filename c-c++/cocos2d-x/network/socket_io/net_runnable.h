//
//  net_runnable.h
//  
//
//  on 14-10-30.
//
//

#ifndef ____net_runnable__
#define ____net_runnable__

#include "Runnable.h"
#include <string>
#include <functional>
#include <netinet/in.h>
#include "Macros.h"
#include "LockedQueue.h"
#include "socket_handler.h"

namespace google {
    namespace protobuf {
        class Message;
    }
}

enum state
{
    state_not_ready = 0,
    state_connecting = 1,
    state_connected = 2,
    state_disconnected = 3,
};

class socket_handler;
class message;
class net_runnable : public xxx::Runnable
{
private:
    typedef std::function<void(net_runnable *rnb)> OutCommand;
    
public:
    net_runnable(const std::string &host, unsigned short port, socket_handler *recHandler, socket_handler *sendHandler);
    virtual ~net_runnable();
    
    virtual void run() override;
    virtual void stop() override;
    
    void reconnect(const std::string &host, unsigned short port);
    void disconnect();
    void sendMessage(Message *msg);
    message *recMessage();
    
    void setIsInBackground(bool isInBackground);
    void setPingPongEnabled(bool enable);
    
private:
    bool init();
    void unInit();
    
    bool connect();
    void doDisconnect();
    
    void stateNotify(int state);
    
    void ping();
    
    void handleOutCmd();
    void addOutCmd(OutCommand cmd);
    
private:
    bool m_toStop;
    
    std::string m_host;
    unsigned short m_port;
    bool m_isConnected;
    bool m_toDisconnect;
    bool m_isInBackground;
    bool m_pingPongEnabled;
    
    time_t m_lastPingTime;
    time_t m_lastReceiveMsgTime;
    
    int m_socket;
    
    socket_handler *m_recHandler;
    socket_handler *m_sendHandler;
    
    LockedQueue<OutCommand> m_outCmds;
};

#endif /* defined(____net_runnable__) */
