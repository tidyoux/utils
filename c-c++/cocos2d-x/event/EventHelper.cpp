//
//  EventHelper.cpp
//  
//
//  on 14-10-29.
//
//
#include "Bundle.h"
#include "EventHelper.h"

using namespace cocos2d;

void EventHelper::dispatch(const std::string &eventName, Bundle *bundleData)
{
    auto evt = CustomDataEvent::create(eventName);
    if (bundleData != nullptr)
    {
        evt->setBundleData(bundleData);
    }
    auto dispatcher = Director::getInstance()->getEventDispatcher();
    dispatcher->dispatchEvent(evt);
}

void EventHelper::msgResponse(const std::string &source, int errcode)
{
    msgResponse(source, errcode, 0, 0, 0, "");
}

void EventHelper::msgResponse(const std::string &source, int errcode, int64 int1)
{
    auto bd = Bundle::create();
    bd->setString("source", source);
    bd->setInt("errcode", errcode);
    bd->setInt64("int1", int1);
    dispatch(EventName::msg_response, bd);
}

void EventHelper::msgResponse(const std::string &source, int errcode, int int1, int int2, int int3)
{
    msgResponse(source, errcode, int1, int2, int3, "");
}

void EventHelper::msgResponse(const std::string &source, int errcode, int int1, int int2, int int3, const std::string &str1)
{
    auto bd = Bundle::create();
    bd->setString("source", source);
    bd->setInt("errcode", errcode);
    bd->setInt("int1", int1);
    bd->setInt("int2", int2);
    bd->setInt("int3", int3);
    bd->setString("str1", str1);
    dispatch(EventName::msg_response, bd);
    
}

void EventHelper::msgNotify(const std::string &source, int opcode)
{
    msgNotify(source, opcode, 0, 0, 0, "");
}

void EventHelper::msgNotify(const std::string &source, int opcode, int64 int1)
{
    msgNotify(source, opcode, int1, 0);
}

void EventHelper::msgNotify(const std::string &source, int opcode, int64 int1, int int2)
{
    auto bd = Bundle::create();
    bd->setString("source", source);
    bd->setInt("opcode", opcode);
    bd->setInt64("int1", int1);
    bd->setInt("int2", int2);
    dispatch(EventName::msg_notify, bd);
}

void EventHelper::msgNotify(const std::string &source, int opcode, int int1)
{
    msgNotify(source, opcode, int1, 0, 0);
}

void EventHelper::msgNotify(const std::string &source, int opcode, int int1, int int2, int int3)
{
    msgNotify(source, opcode, int1, int2, int3, "");
}

void EventHelper::msgNotify(const std::string &source, int opcode, int int1, int int2, int int3, const std::string &str1)
{
    auto bd = Bundle::create();
    bd->setString("source", source);
    bd->setInt("opcode", opcode);
    bd->setInt("int1", int1);
    bd->setInt("int2", int2);
    bd->setInt("int3", int3);
    bd->setString("str1", str1);
    dispatch(EventName::msg_notify, bd);
}

void EventHelper::msgNotify(const std::string &source, int opcode, const std::string &str1)
{
    auto bd = Bundle::create();
    bd->setString("source", source);
    bd->setInt("opcode", opcode);
    bd->setString("str1", str1);
    dispatch(EventName::msg_notify, bd);
}

void EventHelper::netStateChange(int state)
{
    auto bd = Bundle::create();
    bd->setInt("state", state);
    dispatch(EventName::net_change, bd);
}