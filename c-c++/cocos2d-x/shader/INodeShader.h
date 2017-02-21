
#ifndef _INodeShader_h
#define _INodeShader_h

#include "cocos2d.h"

class INodeShader : public cocos2d::Ref
{
public:
    virtual ~INodeShader(){}
    virtual void shader(cocos2d::Node *node, bool recursive) = 0;
};

#endif // _INodeShader_h
