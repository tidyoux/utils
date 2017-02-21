//
//  AndroidPlatform.h
//  
//
//  on 15-1-27.
//
//

#ifndef ____AndroidPlatform__
#define ____AndroidPlatform__

#include "IPlatform.h"

class AndroidPlatform : public IPlatform
{
public:
    AndroidPlatform();
    virtual ~AndroidPlatform();
    
    CREATE_FUNC(AndroidPlatform);
    
    virtual void login() override;
    virtual void pay(int count, const std::string &itemId) override;
    virtual void operate(int opcode, const std::string &args) override;
    
private:
    bool init();
};

#endif /* defined(____AndroidPlatform__) */
