//
//  AndroidPlatform.cpp
//  
//
//  on 15-1-27.
//
//

#include "AndroidPlatform.h"
#include "jni/JniHelper.h"
#include "PlatformOpcode.h"
#include "EventHelper.h"
#include "LuaWrapper.h"
#include "GameDataManager.h"

using namespace cocos2d;
using namespace xxx;


static const char *CLASS_NAME = "com/xxx/platform/Platform";

static void callStaticVoidVoid(const std::string &fnName)
{
    CCLOG("AndroidPlatform, callStaticVoidVoid: %s", fnName.c_str());
    
    JniMethodInfo info;
    if (JniHelper::getStaticMethodInfo(info, CLASS_NAME, fnName.c_str(), "()V"))
    {
        info.env->CallStaticVoidMethod(info.classID, info.methodID);
        info.env->DeleteLocalRef(info.classID);
    }
}

static void callStaticIntVoid(const std::string &fnName, const int data)
{
    CCLOG("AndroidPlatform, callStaticIntVoid: %s, %d", fnName.c_str(), data);
    
    JniMethodInfo info;
    if (JniHelper::getStaticMethodInfo(info, CLASS_NAME, fnName.c_str(), "(I)V"))
    {
        info.env->CallStaticVoidMethod(info.classID, info.methodID, data);
        info.env->DeleteLocalRef(info.classID);
    }
}

static void callStaticIntStringVoid(const std::string &fnName, const int data1, const std::string &data2)
{
    CCLOG("AndroidPlatform, callStaticIntStringVoid: %s, %d, %s", fnName.c_str(), data1, data2.c_str());

    JniMethodInfo info;
    if (JniHelper::getStaticMethodInfo(info, CLASS_NAME, fnName.c_str(), "(ILjava/lang/String;)V"))
    {
        info.env->CallStaticVoidMethod(info.classID, info.methodID, data1, info.env->NewStringUTF(data2.c_str()));
        info.env->DeleteLocalRef(info.classID);
    }
}

//
// AndroidPlatform
//
AndroidPlatform::AndroidPlatform()
{
    //
}

AndroidPlatform::~AndroidPlatform()
{
    //
}

bool AndroidPlatform::init()
{
    return true;
}

void AndroidPlatform::login()
{
    callStaticVoidVoid("login");
}

void AndroidPlatform::pay(int count, const std::string &itemId)
{
    callStaticIntVoid("pay", count);
}

void AndroidPlatform::operate(int opcode, const std::string &args)
{
    switch(opcode)
    {
        default:
        {
            callStaticIntStringVoid("operate", opcode, args);
            break;
        }
    }
}


//
// c to java
//
extern "C" {
    JNIEXPORT void JNICALL Java_com_xxx_platform_Platform_setChannelNane(JNIEnv *env, jobject thiz, jstring channelName)
    {
        const std::string &channelNameStr = JniHelper::jstring2string(channelName);
        CCLOG("jni setChannelNane, %s", channelNameStr.c_str());

        MJLua.push(channelNameStr);
        MJLua.call("data_helper", "setChannelIdByChannelName", 1, 0);
    }

    JNIEXPORT void JNICALL Java_com_xxx_platform_Platform_loginRequest(JNIEnv *env, jobject thiz, jstring uid, jstring sid)
    {
        const std::string &uidStr = JniHelper::jstring2string(uid);
        const std::string &sidStr = JniHelper::jstring2string(sid);
        CCLOG("jni loginRequest, %s, %s", uidStr.c_str(), sidStr.c_str());

        const std::string &FAILED_MSG = "failed";
        if ((uidStr == FAILED_MSG) && (sidStr == FAILED_MSG))
        {
            Bundle *data = Bundle::create();
            data->setString("target", "login_scene");
            data->setString("reason", "loginFailed");
            EventHelper::dispatch(EventName::lgc_finish, data);
        }
        else
        {
            Bundle *data = Bundle::create();
            data->setString("target", "login_scene");
            data->setString("reason", "loginRequest");
            data->setString("uid", uidStr);
            data->setString("sid", sidStr);
            EventHelper::dispatch(EventName::lgc_finish, data);
        }
    }
    
    JNIEXPORT jstring JNICALL Java_com_xxx_platform_Platform_getAId(JNIEnv *env, jobject thiz)
    {
        if (env != NULL)
        {
            std::string aid = "";
            if (MJLua.call("data_helper", "getAId", 0, 1))
            {
                MJLua.pop(aid);
            }
            return env->NewStringUTF(aid.c_str());
        }
        return NULL;
    }
    
    JNIEXPORT jint JNICALL Java_com_xxx_platform_Platform_getPlayerId(JNIEnv *env, jobject thiz)
    {
        int playerId = 0;
        auto *info = GameDataMnger->getPlayerInfo();
        if (info != nullptr)
        {
            playerId = info->getPlayerId();
        }
        return playerId;
    }
    
    JNIEXPORT jstring JNICALL Java_com_xxx_platform_Platform_getPlayerName(JNIEnv *env, jobject thiz)
    {
        if (env != NULL)
        {
            std::string playerName = "";
            auto *info = GameDataMnger->getPlayerInfo();
            if (info != nullptr)
            {
                playerName = info->getName();
            }
            return env->NewStringUTF(playerName.c_str());
        }
        return NULL;
    }
    
    JNIEXPORT jint JNICALL Java_com_xxx_platform_Platform_getServerId(JNIEnv *env, jobject thiz)
    {
        int serverId = 0;
        if (MJLua.call("data_helper", "getServerId", 0, 1))
        {
            MJLua.pop(serverId);
        }
        return serverId;
    }
    
    JNIEXPORT jstring JNICALL Java_com_xxx_platform_Platform_getServerName(JNIEnv *env, jobject thiz)
    {
        if (env != NULL)
        {
            std::string serverName = "";
            if (MJLua.call("data_helper", "getServerName", 0, 1))
            {
                MJLua.pop(serverName);
            }
            return env->NewStringUTF(serverName.c_str());
        }
        return NULL;
    }
    
    JNIEXPORT jint JNICALL Java_com_xxx_platform_Platform_getPlayerLevel(JNIEnv *env, jobject thiz)
    {
        int playerLevel = 0;
        return playerLevel;
    }

    JNIEXPORT void JNICALL Java_com_xxx_platform_Platform_logout(JNIEnv *env, jobject thiz)
    {
        MJLua.call("scene_manager", "backToLogin", 0, 0);
    }
    
    JNIEXPORT void JNICALL Java_com_xxx_platform_Platform_showGameExitConfirm(JNIEnv *env, jobject thiz)
    {
        MJLua.push("gameExit");
        MJLua.call("ui_helper", "showNotePanel", 1, 0);
    }
}


