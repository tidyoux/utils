//
//  IPlatform.h
//  
//
//  on 15-1-27.
//
//

#ifndef _IPlatform_h
#define _IPlatform_h

#include <string>
#include "cocos2d.h"

class IPlatform : public cocos2d::Ref
{
public:
    virtual ~IPlatform(){}
    
    virtual void login() = 0;
    virtual void pay(int count, const std::string &itemId) = 0;
    virtual void operate(int opcode, const std::string &args) = 0;
};

#endif // _IPlatform_h
