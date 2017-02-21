//
//  LuaWrapper.cpp
//  game
//
//  on 15-6-29.
//
//

#include "LuaWrapper.h"
#include "CCLuaEngine.h"

#ifdef __cplusplus
extern "C"
{
#endif
    
#include "lua.h"
#include "lualib.h"
#include "lauxlib.h"
    
#ifdef __cplusplus
};
#endif


static const char* lua_getType(lua_State* L, int idx)
{
    static const char* LUA_TYPE_NAMES[] =
    {
        "LUA_TNONE",//      (-1)
        "LUA_TNIL",//       0
        "LUA_TBOOLEAN",//       1
        "LUA_TLIGHTUSERDATA",// 2
        "LUA_TNUMBER",//        3
        "LUA_TSTRING",//        4
        "LUA_TTABLE",//     5
        "LUA_TFUNCTION",//      6
        "LUA_TUSERDATA",//      7
        "LUA_TTHREAD",//        8
    };
    int nType = lua_type(L, idx);
    if (nType>=LUA_TNONE &&
        nType<=LUA_TTHREAD)
    {
        return LUA_TYPE_NAMES[nType+1];
    }
    else
    {
        return "LUA_TXXXX";
    }
}

static int traceback (lua_State *L) {
    if (!lua_isstring(L, 1))  /* 'message' not a string? */
        return 1;  /* keep it intact */
    lua_getfield(L, LUA_GLOBALSINDEX, "debug");
    if (!lua_istable(L, -1)) {
        lua_pop(L, 1);
        return 1;
    }
    lua_getfield(L, -1, "traceback");
    if (!lua_isfunction(L, -1)) {
        lua_pop(L, 2);
        return 1;
    }
    lua_pushvalue(L, 1);  /* pass error message */
    lua_pushinteger(L, 2);  /* skip this function and traceback */
    lua_call(L, 2, 1);  /* call debug.traceback */
    return 1;
}

static int docall (lua_State *L, int narg, int nres) {
    int status;
    int base = lua_gettop(L) - narg;  /* function index */
    lua_pushcfunction(L, traceback);  /* push traceback function */
    lua_insert(L, base);  /* put it under chunk and args */
    status = lua_pcall(L, narg, nres, base);
    lua_remove(L, base);  /* remove traceback function */
    /* force a complete garbage collection in case of errors */
    if (status != 0) lua_gc(L, LUA_GCCOLLECT, 0);
    return status;
}
#define __USE_TRACE_BACK__
#ifdef  __USE_TRACE_BACK__
#define lua_pcall_ex(l, narg, nres) docall(l, narg, nres)
#else
#define lua_pcall_ex(l, narg, nres) lua_pcall(l, narg, nres, 0)
#endif

LuaWrapper &LuaWrapper::getInstance()
{
    static LuaWrapper ret;
    return ret;
}

LuaWrapper::LuaWrapper()
:m_pState(cocos2d::LuaEngine::getInstance()->getLuaStack()->getLuaState())
{
    
}

lua_State *LuaWrapper::getState() const
{
    return m_pState;
}

void LuaWrapper::push(int32 data)
{
    lua_pushinteger(m_pState, data);
}

void LuaWrapper::push(int64 data)
{
    lua_pushnumber(m_pState, data);
}

void LuaWrapper::push(float data)
{
    lua_pushnumber(m_pState, data);
}

void LuaWrapper::push(const std::string &data)
{
    lua_pushstring(m_pState, data.c_str());
}

bool LuaWrapper::pop(bool &data)
{
    if (lua_isboolean(m_pState, -1))
    {
        data = lua_toboolean(m_pState, -1);
        lua_pop(m_pState, 1);
        return true;
    }
    
    lua_pop(m_pState, 1);
    return false;
}

bool LuaWrapper::pop(int32 &data)
{
    if (lua_isnumber(m_pState, -1))
    {
        data = (int32)lua_tointeger(m_pState, -1);
        lua_pop(m_pState, 1);
        return true;
    }
    
    lua_pop(m_pState, 1);
    return false;
}

bool LuaWrapper::pop(int64 &data)
{
    if (lua_isnumber(m_pState, -1))
    {
        data = lua_tonumber(m_pState, -1);
        lua_pop(m_pState, 1);
        return true;
    }
    
    lua_pop(m_pState, 1);
    return false;
}

bool LuaWrapper::pop(float &data)
{
    if (lua_isnumber(m_pState, -1))
    {
        data = lua_tonumber(m_pState, -1);
        lua_pop(m_pState, 1);
        return true;
    }
    
    lua_pop(m_pState, 1);
    return false;
}

bool LuaWrapper::pop(std::string &data)
{
    if (lua_isstring(m_pState, -1))
    {
        const char *ret = lua_tostring(m_pState, -1);
        if (ret)
        {
            data = ret;
        }
        lua_pop(m_pState, 1);
        return true;
    }
    
    lua_pop(m_pState, 1);
    return false;
}

bool LuaWrapper::call(const std::string &func, int arg, int ret)
{
    if (arg > lua_gettop(m_pState))
    {
        CCLOGERROR("Lua::call, input arg count too big : %d", arg);
        return false;
    }
    
    lua_getglobal(m_pState, func.c_str());
    if (!lua_isfunction(m_pState, -1))
    {
        CCLOGERROR("Lua::call, invalid function name : %s", func.c_str());
        return false;
    }
    
    if (arg > 0)
    {
        lua_insert(m_pState, -(arg + 1));
    }
    
    if (lua_pcall_ex(m_pState, arg, ret) != 0)
    {
        CCLOGERROR("Lua::call, invalid function: %s > %s", func.c_str(), lua_tostring(m_pState, -1));
        return false;
    }
    return true;
}

bool LuaWrapper::call(const std::string &ns, const std::string &func, int arg, int ret)
{
    if (arg > lua_gettop(m_pState))
    {
        CCLOGERROR("Lua::call, input arg count too big : %d", arg);
        return false;
    }
    
    lua_getglobal(m_pState, ns.c_str());
    if (!lua_istable(m_pState, -1))
    {
        CCLOGERROR("Lua::call, null function namespace: %s", ns.c_str());
        return false;
    }
    
    lua_pushstring(m_pState, func.c_str());
    lua_gettable(m_pState, -2);
    if (!lua_isfunction(m_pState, -1))
    {
        CCLOGERROR("Lua::call, invalid function name : %s", func.c_str());
        return false;
    }
    
    //  remove the ns table
    lua_remove(m_pState, -2);
    if (arg > 0)
    {
        lua_insert(m_pState, -(arg + 1));
    }
    
    if (lua_pcall_ex(m_pState, arg, ret) != 0)
    {
        CCLOGERROR("Lua::call, invalid function: %s > %s", func.c_str(), lua_tostring(m_pState, -1));
        return false;
    }
    return true;
}

bool LuaWrapper::execute(const std::string &code)
{
    if (luaL_loadstring(m_pState, code.c_str()) == 0)
    {
        if (lua_pcall_ex(m_pState, 0, 0) == 0)
        {
            return true;
        }
        CCLOGERROR("Lua::call, invalid code, runtime error: %s > %s", code.c_str(), lua_tostring(m_pState, -1));
        return false;
    }
    CCLOGERROR("Lua::call, invalid code, syntax error: %s > %s", code.c_str(), lua_tostring(m_pState, -1));
    return false;
}

void LuaWrapper::registerUserModule(lua_register register_func)
{
    if (register_func != nullptr)
    {
        lua_getglobal(m_pState, "_G");
        register_func(m_pState);
        lua_settop(m_pState, 0);
    }
}