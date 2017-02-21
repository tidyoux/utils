//
//  NetworkClient.h
//  game
//
//  on 3/6/14.
//
//

#ifndef __game__NetworkClient__
#define __game__NetworkClient__

#include "cocos2d.h"
#include "Macros.h"
#include "net_runnable.h"

USING_NS_CC;
using namespace std;

class NetworkClient : public Ref
{
public:
    static NetworkClient *getInstance();
    
    bool init();
    bool hasInited() const;
    
    void update(float dt);
    
    bool connect();
    bool reconnect(const std::string &host, unsigned short port);
    void disconnect();
    
    void sendMessage(google::protobuf::Message* msg);
    
    void set_host_port(const std::string &host, unsigned short port);
    std::string get_host() const;
    unsigned short get_port() const;
    
    void set_net_state(int state);
    int get_net_state() const;
    
    void setIsInBackground(bool isInBackground);
    void setPingPongEnabled(bool enable);

private:
    NetworkClient();
    virtual ~NetworkClient();
    
    void clear();
    
private:
    std::string m_host;
    unsigned short m_port;
    
    volatile bool m_inited;
    net_runnable *m_netRun;
    
    int m_currentNetState;
};

#define MJNetwork NetworkClient::getInstance()

#endif /* defined(__game__NetworkClient__) */
