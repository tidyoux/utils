//
//  CustomDataEvent.h
//  xxx
//
//  on 15-6-30.
//
//

#ifndef __xxx__CustomDataEvent__
#define __xxx__CustomDataEvent__

#include "cocos2d.h"
#include "../Macros.h"
#include "../Bundle.h"

using namespace xxx;

class CustomDataEvent : public cocos2d::EventCustom
{
public:
    static CustomDataEvent *create(const std::string &eventName);
    
    void setBundleData(Bundle *data);
    Bundle *getBundleData() const;
    
public:
    CustomDataEvent(const std::string &eventName);
    ~CustomDataEvent();
    
private:
    Bundle *m_pData;
};


#endif /* defined(__xxx__CustomDataEvent__) */
