LOCAL_PATH := $(call my-dir)
 
include $(CLEAR_VARS)
 
$(call import-add-path, $(LOCAL_PATH)/../../../../cocos2d-x)
$(call import-add-path, $(LOCAL_PATH)/../../../../cocos2d-x/cocos)
$(call import-add-path, $(LOCAL_PATH)/../../../../cocos2d-x/external)
 
LOCAL_MODULE := cocos2dcpp_shared
 
LOCAL_MODULE_FILENAME := libcocos2dcpp
 
MY_FILES_PATH := $(LOCAL_PATH)
MY_FILES_PATH += $(LOCAL_PATH)/../../../Classes
 
MY_FILES_SUFFIX := %.cpp %.c %.cc
                        
# Make does not offer a recursive wildcard function, so here's one:
rwildcard=$(wildcard $1$2) $(foreach d,$(wildcard $1*),$(call rwildcard,$d/,$2))
     
# Retrieve all source files in each dir recursively.
MY_ALL_FILES := $(foreach src_path,$(MY_FILES_PATH), $(call rwildcard,$(src_path),*.*) )
MY_ALL_FILES := $(MY_ALL_FILES:$(MY_CPP_PATH)/./%=$(MY_CPP_PATH)%)
MY_SRC_LIST  := $(filter $(MY_FILES_SUFFIX),$(MY_ALL_FILES))
MY_SRC_LIST  := $(MY_SRC_LIST:$(LOCAL_PATH)/%=%)
 
# helper function for remove duplicated words in string test
define uniq =
  $(eval seen :=)
  $(foreach _,$1,$(if $(filter $_,${seen}),,$(eval seen += $_)))
  ${seen}
endef
     
# Retrieve all directory recursively.
MY_ALL_DIRS := $(dir $(foreach src_path,$(MY_FILES_PATH), $(call rwildcard,$(src_path),*/) ) )
MY_ALL_DIRS := $(call uniq,$(MY_ALL_DIRS))
 
# All done, just tell NDK build system.
LOCAL_SRC_FILES := $(MY_SRC_LIST)
LOCAL_C_INCLUDES := $(MY_ALL_DIRS)

LOCAL_STATIC_LIBRARIES := curl_static_prebuilt

LOCAL_WHOLE_STATIC_LIBRARIES := cocos2dx_static
LOCAL_WHOLE_STATIC_LIBRARIES += cocos2d_lua_static

include $(BUILD_SHARED_LIBRARY)

$(call import-module, scripting/lua-bindings/proj.android)
$(call import-module, .)


