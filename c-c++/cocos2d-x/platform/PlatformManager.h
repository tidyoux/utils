//
//  PlatformManager.h
//  
//
//  on 15-1-27.
//
//

#ifndef ____PlatformManager__
#define ____PlatformManager__

#include "IPlatform.h"
#include "../common/Macros.h"

class PlatformManager : public cocos2d::Ref
{
public:
    static PlatformManager *getInstance();
    
    void setCurrentPlatform(IPlatform *platform);
    IPlatform *getCurrentPlatform();
    
private:
    make_static_class(PlatformManager);
    ~PlatformManager();
    
private:
    IPlatform *mPlatform;
};
#define MJPlatform PlatformManager::getInstance()->getCurrentPlatform()

#endif /* defined(____PlatformManager__) */
