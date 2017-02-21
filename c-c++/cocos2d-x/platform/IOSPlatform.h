//
//  IOSPlatform.h
//  
//
//  on 15-1-27.
//
//

#ifndef ____IOSPlatform__
#define ____IOSPlatform__

#include "IPlatform.h"

struct BaseData;
class IOSPlatform : public IPlatform
{
public:
    IOSPlatform();
    virtual ~IOSPlatform();
    
    CREATE_FUNC(IOSPlatform);
    
    virtual void login() override;
    virtual void pay(int count, const std::string &itemId) override;
    virtual void operate(int opcode, const std::string &args) override;
    
private:
    bool init();
    
private:
    BaseData *mData;
};

#endif /* defined(____IOSPlatform__) */
