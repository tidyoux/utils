//
//  EventName.h
//  
//
//  on 14-10-25.
//
//

#ifndef _EventName_h
#define _EventName_h

#include <string>

namespace EventName
{
    // event from network
    static const std::string net_change = "net_change";
    
    // event from msg
    static const std::string http_response = "http_response";
    static const std::string msg_response = "msg_response";
    static const std::string msg_notify = "msg_notify";
    
    // event from ui
    static const std::string ui_open = "ui_open";
    static const std::string ui_close = "ui_close";
    static const std::string ui_change = "ui_change";
    static const std::string ui_notify = "ui_notify";
    static const std::string ui_finish = "ui_finish";
    
    // event from guide
    static const std::string guide_msg = "guide_msg";
    
    // event from logic
    static const std::string lgc_change = "lgc_change";
    static const std::string lgc_finish = "lgc_finish";
    
    // event from data
    static const std::string data_change = "data_change";
}

#endif // _EventName_h
