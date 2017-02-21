#ifndef ____Bundle__
#define ____Bundle__

#include "cocos2d.h"
#include <map>
#include <string>
#include "Macros.h"
#include "Common.h"

xxx_BEGIN

class Bundle final : public cocos2d::Ref
{
public:
    Bundle();
    ~Bundle();
    
public:
    static Bundle *create();
    
    //
    // setter
    void setInt(const std::string &key, int data);
    void setInt64(const std::string &key, int64 data);
    void setFloat(const std::string &key, float data);
    void setString(const std::string &key, const std::string &data);
    void setBundle(const std::string &key, Bundle *bundle);

    //
    // getter
    int getInt(const std::string &key) const;
    int64 getInt64(const std::string &key) const;
    float getFloat(const std::string &key) const;
    std::string getString(const std::string &key) const;
    Bundle *getBundle(const std::string &key) const;
    
private:
    typedef std::map<std::string, int> IntMap;
    typedef std::map<std::string, int64> Int64Map;
    typedef std::map<std::string, float> FloatMap;
    typedef std::map<std::string, std::string> StringMap;
    typedef std::map<std::string, Bundle*> BundleMap;
    
    IntMap mInts;
    Int64Map mInt64s;
    FloatMap mFloats;
    StringMap mStrings;
    BundleMap mBundles;
};

xxx_END

#endif /* defined(____Bundle__) */
