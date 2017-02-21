//
//  NetworkClient.cpp
//  game
//
//  on 3/6/14.
//
//

#include "NetworkClient.h"
#include "send_queue.h"
#include "receive_queue.h"
#include "message.h"
#include "data_buffer.h"
#include "ThreadHelper.h"
#include "message_handler.h"


NetworkClient::NetworkClient()
:m_port(0)
,m_netRun(nullptr)
,m_inited(false)
,m_currentNetState(state_not_ready)
{
}

NetworkClient::~NetworkClient()
{
    clear();
}

NetworkClient *NetworkClient::getInstance()
{
    static NetworkClient ret;
    return &ret;
}

// 将接收到的消息进行派发
void NetworkClient::update(float dt)
{
    if (m_inited && m_netRun)
    {
        auto *msg = m_netRun->recMessage();
        if (msg != nullptr)
        {
            message_handler::handle_message(msg);
        }
    }
}

void NetworkClient::clear()
{
    m_inited = false;
    Director::getInstance()->getScheduler()->unschedule(schedule_selector(NetworkClient::update), this);
    if (m_netRun != nullptr)
    {
        m_netRun->stop();
        m_netRun = nullptr;
    }
    m_port = 0;
    m_currentNetState = state_not_ready;
}

bool NetworkClient::init()
{
    m_inited = true;
    if (m_netRun == nullptr)
    {
        m_netRun = new net_runnable(m_host, m_port, new receive_queue(), new send_queue());
        xxx::ThreadHelper::start(m_netRun);
        Director::getInstance()->getScheduler()->schedule(schedule_selector(NetworkClient::update), this, -1, 0);
    }
    
    return true;
}

bool NetworkClient::hasInited() const
{
    return m_inited;
}

//连接
bool NetworkClient::connect()
{
    if (!m_inited)
    {
        init();
    }
    return true;
}

bool NetworkClient::reconnect(const std::string &host, unsigned short port)
{
    set_host_port(host, port);
    if (!m_inited)
    {
        init();
    }
    m_netRun->reconnect(host, port);
    return true;
}

void NetworkClient::disconnect()
{
    clear();
}

void NetworkClient::set_host_port(const std::string &host, unsigned short port)
{
    m_host = host;
    m_port = port;
}

std::string NetworkClient::get_host() const
{
    return m_host;
}

unsigned short NetworkClient::get_port() const
{
    return m_port;
}

void NetworkClient::sendMessage(Message *msg)
{
    if (msg && m_inited && m_netRun)
    {
        m_netRun->sendMessage(msg);
    }
}

void NetworkClient::set_net_state(int state)
{
    CCLOG(">NetworkClient::set_net_state, current state is: %d", state);
    m_currentNetState = state;
}

int NetworkClient::get_net_state() const
{
    return m_currentNetState;
}

void NetworkClient::setIsInBackground(bool isInBackground)
{
    if (m_netRun != nullptr)
    {
        m_netRun->setIsInBackground(isInBackground);
    }
}

void NetworkClient::setPingPongEnabled(bool enable)
{
    if (m_netRun != nullptr)
    {
        m_netRun->setPingPongEnabled(enable);
    }
}
