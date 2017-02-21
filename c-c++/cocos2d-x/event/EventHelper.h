//
//  EventHelper.h
//  
//
//  on 14-10-29.
//
//

#ifndef ____EventHelper__
#define ____EventHelper__

#include "EventName.h"
#include "Bundle.h"
#include "CustomDataEvent.h"
#include "Macros.h"


class EventHelper
{
public:
    static void dispatch(const std::string &eventName, Bundle *bundleData);
    
    // msg
    static void msgResponse(const std::string &source, int errcode);
    static void msgResponse(const std::string &source, int errcode, int64 int1);
    static void msgResponse(const std::string &source, int errcode, int int1, int int2, int int3);
    static void msgResponse(const std::string &source, int errcode, int int1, int int2, int int3, const std::string &str1);
    
    static void msgNotify(const std::string &source, int opcode);
    static void msgNotify(const std::string &source, int opcode, int64 int1);
    static void msgNotify(const std::string &source, int opcode, int64 int1, int int2);
    static void msgNotify(const std::string &source, int opcode, int int1);
    static void msgNotify(const std::string &source, int opcode, int int1, int int2, int int3);
    static void msgNotify(const std::string &source, int opcode, int int1, int int2, int int3, const std::string &str1);
    static void msgNotify(const std::string &source, int opcode, const std::string &str1);
    
    // network
    static void netStateChange(int state);
    
private:
    make_static_class(EventHelper);
};

#endif /* defined(____EventHelper__) */
