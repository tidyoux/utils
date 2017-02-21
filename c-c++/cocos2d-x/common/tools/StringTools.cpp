//
//  StringTools.cpp
//  
//
//  on 14-11-10.
//
//

#include "StringTools.h"
#include <stdlib.h>
#include <sstream>


#define to_stream(_s_, _v_) \
    std::ostringstream _s_; \
    _s_ << _v_;

#define to_value(_s_, _v_) \
    std::stringstream _ss_(_s_); \
    _ss_ >> _v_;

#define make_vector_by_string(_str_, _separator_, _vector_, _convert_) \
do \
{ \
    std::string s; \
    std::string remain = _str_; \
    std::string::size_type k = remain.find(_separator_); \
    while (k != remain.npos) \
    { \
        s = remain.substr(0, k); \
        if (!s.empty()) \
        { \
            _vector_.push_back(_convert_(s.c_str())); \
        } \
        remain = remain.substr(k + 1); \
        k = remain.find(_separator_); \
    } \
    if (!remain.empty()) \
    { \
        _vector_.push_back(_convert_(remain.c_str())); \
    } \
} while(false)

/////////////////////////////////////////////////

std::string StringTools::toString(int value)
{
    to_stream(s, value);
    return s.str();
}

std::string StringTools::toString(float value)
{
    to_stream(s, value);
    return s.str();
}

std::string StringTools::toString(double value)
{
    to_stream(s, value);
    return s.str();
}

std::string StringTools::toString(int64 value)
{
    to_stream(s, value);
    return s.str();
}

void StringTools::toValue(const std::string &s, int &value)
{
    to_value(s, value);
}

void StringTools::toValue(const std::string &s, float &value)
{
    to_value(s, value);
}

void StringTools::toValue(const std::string &s, double &value)
{
    to_value(s, value);
}

bool StringTools::toIntVector(const std::string &str, IntVector &intVector)
{
    return toIntVector(str, "|", intVector);
}

bool StringTools::toIntVector(const std::string &str, const std::string &separator, IntVector &intVector)
{
    if (str.empty() || separator.empty() || str == "0")
    {
        return false;
    }
    
    make_vector_by_string(str, separator, intVector, atoi);
    
    return true;
}

bool StringTools::toInt64Vector(const std::string &str, Int64Vector &int64Vector)
{
    return toInt64Vector(str, "|", int64Vector);
}

bool StringTools::toInt64Vector(const std::string &str, const std::string &separator, Int64Vector &int64Vector)
{
    if (str.empty() || separator.empty() || str == "0")
    {
        return false;
    }
    
    make_vector_by_string(str, separator, int64Vector, atoll);
    
    return true;
}

bool StringTools::toFloatVector(const std::string &str, FloatVector &floatVector)
{
    return toFloatVector(str, "|", floatVector);
}

bool StringTools::toFloatVector(const std::string &str, const std::string &separator, FloatVector &floatVector)
{
    if (str.empty() || separator.empty())
    {
        return false;
    }
    
    make_vector_by_string(str, separator, floatVector, atof);
    
    return true;
}

bool StringTools::toStringVector(const std::string &str, StringVector &stringVector)
{
    return toStringVector(str, "|", stringVector);
}

bool StringTools::toStringVector(const std::string &str, const std::string &separator, StringVector &stringVector)
{
    if (str.empty() || separator.empty())
    {
        return false;
    }
    
    make_vector_by_string(str, separator, stringVector, std::string);
    
    return true;
}

