#include "Bundle.h"

xxx_BEGIN

Bundle::Bundle()
{
    
}

Bundle::~Bundle()
{
    
}

Bundle *Bundle::create()
{
    auto ret = new Bundle();
    ret->autorelease();
    return ret;
}

//
// setter
void Bundle::setInt(const std::string &key, int data)
{
    if (!key.empty())
    {
        mInts[key] = data;
    }
}

void Bundle::setInt64(const std::string &key, int64 data)
{
    if (!key.empty())
    {
        mInt64s[key] = data;
    }
}

void Bundle::setFloat(const std::string &key, float data)
{
    if (!key.empty())
    {
        mFloats[key] = data;
    }
}

void Bundle::setString(const std::string &key, const std::string &data)
{
    if (!key.empty())
    {
        mStrings[key] = data;
    }
}

void Bundle::setBundle(const std::string &key, Bundle *bundle)
{
    if (!key.empty() && bundle != nullptr)
    {
        mBundles[key] = bundle;
    }
}

//
// getter
int Bundle::getInt(const std::string &key) const
{
    auto it = mInts.find(key);
    if (it != mInts.end())
    {
        return it->second;
    }
    return 0;
}

int64 Bundle::getInt64(const std::string &key) const
{
    auto it = mInt64s.find(key);
    if (it != mInt64s.end())
    {
        return it->second;
    }
    return 0;
}

float Bundle::getFloat(const std::string &key) const
{
    auto it = mFloats.find(key);
    if (it != mFloats.end())
    {
        return it->second;
    }
    return 0;
}

std::string Bundle::getString(const std::string &key) const
{
    auto it = mStrings.find(key);
    if (it != mStrings.end())
    {
        return it->second;
    }
    return "";
}

Bundle * Bundle::getBundle(const std::string &key) const
{
    auto it = mBundles.find(key);
    if (it != mBundles.end())
    {
        return it->second;
    }
    return nullptr;
}

xxx_END
