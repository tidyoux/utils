//
//  CustomDataEvent.cpp
//  xxx
//
//  on 15-6-30.
//
//

#include "CustomDataEvent.h"
#include "Bundle.h"

using namespace cocos2d;


CustomDataEvent *CustomDataEvent::create(const std::string &eventName)
{
    CustomDataEvent *ret = new CustomDataEvent(eventName);
    ret->autorelease();
    return ret;
}

CustomDataEvent::CustomDataEvent(const std::string &eventName)
:EventCustom(eventName)
,m_pData(nullptr)
{
    
}

CustomDataEvent::~CustomDataEvent()
{
    CC_SAFE_RELEASE(m_pData);
    m_pData = nullptr;
}

void CustomDataEvent::setBundleData(Bundle *data)
{
    m_pData = data;
    CC_SAFE_RETAIN(m_pData);
}

Bundle *CustomDataEvent::getBundleData() const
{
    return m_pData;
}
