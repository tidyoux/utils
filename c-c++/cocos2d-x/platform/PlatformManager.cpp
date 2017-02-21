//
//  PlatformManager.cpp
//  
//
//  on 15-1-27.
//
//

#include "PlatformManager.h"

PlatformManager::PlatformManager()
:mPlatform(nullptr)
{
    
}

PlatformManager::~PlatformManager()
{
    CC_SAFE_RELEASE(mPlatform);
    mPlatform = nullptr;
}

PlatformManager *PlatformManager::getInstance()
{
    static PlatformManager ret;
    return &ret;
}

void PlatformManager::setCurrentPlatform(IPlatform *platform)
{
    if (platform != mPlatform)
    {
        CC_SAFE_RELEASE(mPlatform);
        mPlatform = platform;
        CC_SAFE_RETAIN(mPlatform);
    }
}

IPlatform *PlatformManager::getCurrentPlatform()
{
    return mPlatform;
}
