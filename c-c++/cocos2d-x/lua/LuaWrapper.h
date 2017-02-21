//
//  LuaWrapper.h
//  game
//
//  on 15-6-29.
//
//

#ifndef __game__LuaWrapper__
#define __game__LuaWrapper__

#include <string>
#include "Common.h"
#include "Macros.h"


struct lua_State;
typedef int (*lua_register)(lua_State *);

class LuaWrapper
{
public:
    static LuaWrapper &getInstance();
    
    lua_State *getState() const;
    
    void push(int32 data);
    void push(int64 data);
    void push(float data);
    void push(const std::string &data);
    
    bool pop(bool &data);
    bool pop(int32 &data);
    bool pop(int64 &data);
    bool pop(float &data);
    bool pop(std::string &data);
    
    bool call(const std::string &func, int arg, int ret);
    bool call(const std::string &ns, const std::string &func, int arg, int ret);
    
    bool execute(const std::string &code);
    
    void registerUserModule(lua_register register_func);
    
private:
    make_static_class(LuaWrapper);
    
private:
    lua_State* m_pState;
};
#define MJLua LuaWrapper::getInstance()

#endif /* defined(__game__LuaWrapper__) */
