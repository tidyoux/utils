//
//  StringTools.h
//  
//
//  on 14-11-10.
//
//

#ifndef ____StringTools__
#define ____StringTools__

#include <string>
#include <vector>
#include "Macros.h"
#include "Common.h"

typedef std::vector<int> IntVector;
typedef std::vector<int64> Int64Vector;
typedef std::vector<float> FloatVector;
typedef std::vector<std::string> StringVector;

class StringTools
{
public:
    static std::string toString(int value);
    static std::string toString(float value);
    static std::string toString(double value);
    static std::string toString(int64 value);
    
    static void toValue(const std::string &s, int &value);
    static void toValue(const std::string &s, float &value);
    static void toValue(const std::string &s, double &value);
    
    static bool toIntVector(const std::string &str, IntVector &intVector);
    static bool toIntVector(const std::string &str, const std::string &separator, IntVector &intVector);
    
    static bool toInt64Vector(const std::string &str, Int64Vector &int64Vector);
    static bool toInt64Vector(const std::string &str, const std::string &separator, Int64Vector &int64Vector);
    
    static bool toFloatVector(const std::string &str, FloatVector &floatVector);
    static bool toFloatVector(const std::string &str, const std::string &separator, FloatVector &floatVector);
    
    static bool toStringVector(const std::string &str, StringVector &stringVector);
    static bool toStringVector(const std::string &str, const std::string &separator, StringVector &stringVector);
    
private:
    make_static_class(StringTools);
};

#endif /* defined(____StringTools__) */
