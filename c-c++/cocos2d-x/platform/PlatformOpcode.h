//
//  PlatformOpcode.h
//  
//
//  on 15-1-27.
//
//

#ifndef _PlatformOpcode_h
#define _PlatformOpcode_h


class PlatformOpcode
{
public:
    static const int OP_INIT_CHANNEL_NAME = 1;
    static const int OP_GAME_EXIT = 90;
    static const int OP_CONVERSATION = 100;
    static const int OP_SUBMIT_EXT_DATA = 110;
    
    static const int OP_APPLICATION_DID_ENTER_BACKGROUND = 1000;
    static const int OP_APPLICATION_WILL_ENTER_FOREGROUND = 1001;
};

#endif //_PlatformOpcode_h
