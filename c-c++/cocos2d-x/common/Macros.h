//
//  Macros.h
//  game
//
//  on 15-6-29.
//
//

#ifndef game_Macros_h
#define game_Macros_h


//
// mj game namespace
//
#define xxx_BEGIN namespace xxx {
#define xxx_END }


// 获得带符号数的符号。
#define get_num_flag(_num_) \
(_num_ == 0 ? 0 : (_num_ > 0 ? 1 : -1))

#define log_func() \
CCLOG("[ %s:%d ]", __func__, __LINE__ );

#define log_fix_me \
CCLOG("fix me[ %s ],fuc[ %s ], line[ %d ]", typeid(this).name(), __func__, __LINE__);

#define log_note(__note__) \
CCLOG("note:[ %s ],fuc[ %s ], line[ %d ] note[%s]", typeid(this).name(), __func__, __LINE__, __note__);

#define inverse_value(_v_, _a_, _b_) \
(_v_ == _a_ ? _b_ : _a_)

#define _void_

//满足条件则返回
#define return_if(cond, ret) \
if (cond) \
{ \
return ret; \
}

//起始时间点
#define time_test_init(__time_name__) \
\
uint64_t __time_init, __time_old, __temp;  \
__temp = 0; \
timeval debug_tv; \
std::string __time_str = __time_name__; \
gettimeofday(&debug_tv, nullptr); \
__time_init = __time_old = debug_tv.tv_sec * 1000 + debug_tv.tv_usec / 1000; \
CCLOG("[ --- %s --- ]", __time_name__); \

//当前时间点
#define time_test_log(__var__) \
{ \
gettimeofday(&debug_tv, 0); \
__temp = debug_tv.tv_sec * 1000 + debug_tv.tv_usec / 1000; \
CCLOG("[ (%s) %s: %lld ]", __time_str.c_str(), __var__, __temp - __time_old); \
__time_old = __temp; \
}

//总耗时
#define time_test_total() \
{ \
gettimeofday(&debug_tv, 0); \
__temp = debug_tv.tv_sec * 1000 + debug_tv.tv_usec / 1000; \
CCLOG("【 --- (%s) total: %lld --- 】\n\n", __time_str.c_str(), __temp - __time_init); \
}

//安全删除容器
#define safe_delete_std(__std__) \
do { \
for (auto item : __std__) { \
CC_SAFE_DELETE(item); \
} \
__std__.clear(); \
} while (0) \

#define SAFE_DELETE_STD(__std__) \
safe_delete_std(__std__)

// 数组/向量安全访问宏
#define array_get(_arr_, _size_, _i_, _exe_, _out_, _err_) \
if (_i_ < 0 || _size_ <= _i_) \
{ \
_err_; \
} \
else \
{ \
_out_ = _arr_[_i_]_exe_; \
}

// 在map中查找
#define map_find(_map_, _key_, _out_) \
do \
{ \
auto it = _map_.find(_key_); \
if (it != _map_.end()) \
{ \
_out_ = it->second; \
} \
} while(false)

// 通用for循环
#define fora_b(_i_, _a_, _b_, _step_, _test_) \
for (auto _i_ = _a_; _i_ _test_ _b_; _i_ += _step_)

// 计数for循环
#define for0_n(_i_, _n_) \
fora_b(_i_, 0, _n_, 1, <)

// 通用条件语句
#define common_if(_v_, _value_maker_, _condition_) \
auto _v_ = _value_maker_; \
if (_condition_)

#define func_maker1(_exe1_,_func_) \
if (_exe1_) \
{ \
_exe1_->_func_ ;\
}

#define func_maker2(_exe1_,_exe2_,_func_) \
if (ptr_maker2(_exe1_, _exe2_)) \
{ \
_exe1_->_exe2_->_func_; \
}

// 安全指针值生成器
#define ptr_maker2(_exe1_, _exe2_) \
(_exe1_ ? _exe1_->_exe2_ : nullptr)

#define ptr_maker3(_exe1_, _exe2_, _exe3_) \
(_exe1_ ? (_exe1_->_exe2_ ? _exe1_->_exe2_->_exe3_ : nullptr) : nullptr)

#define ptr_maker4(_exe1_, _exe2_, _exe3_, _exe4_) \
(_exe1_ ? (_exe1_->_exe2_ ? _exe1_->_exe2_->_exe3_ ? _exe1_->_exe2_->_exe3_->_exe4_ : nullptr: nullptr) : nullptr)

// 指针值条件语句
#define ptr_if(_v_, _value_maker_, _condition_) \
common_if(_v_, _value_maker_, _v_ && _condition_)


// 通用switch语句，建议只用于无需调试的简单分支情况
#define case_maker(_case_, _body_) \
case _case_: \
_body_; \
break;

#define common_switch(_exp_, _case_makers_, _default_) \
switch(_exp_) \
{ \
_case_makers_; \
default: \
_default_; \
break; \
}


// 创建单例类或静态类
#define make_static_class(_class_) \
_class_(); \
_class_(const _class_ &); \
_class_ &operator=(const _class_ &);

// 类名获取函数
#define make_class_name_getter(_class_) \
public: static std::string className() {return #_class_;} \
public: virtual std::string getClassName() {return className();}

// 创建带一个参数的create方法。
#define create_func1(_class_, _arg_type_) \
static _class_ *create(_arg_type_ arg) \
{ \
_class_ *ret = new _class_(); \
if (ret && ret->init(arg)) \
{ \
ret->autorelease(); \
return ret; \
} \
CC_SAFE_DELETE(ret); \
return nullptr; \
}

// 创建获取函数和设置函数
#define make_getter_setter(varType, varName, funName)\
private: varType varName;\
public:  varType get##funName(void) const { return varName; }\
public:  void set##funName(const varType &var){ varName = var; }

#define make_getter_setter_point(varType, varName, funName) \
private: varType varName; \
public:  varType get##funName(void) { return varName; } \
public:  void set##funName(varType var) \
{ \
if (var == varName) return; \
CC_SAFE_DELETE(varName); \
varName = var; \
}

#define make_getter_setter_protected(varType, varName, funName)\
protected: varType varName;\
public:  varType get##funName(void) const { return varName; }\
public:  void set##funName(varType var){ varName = var; }


#endif //game_Macros_h
