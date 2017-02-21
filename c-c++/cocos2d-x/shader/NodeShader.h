//
//  NodeShader.h
//  
//
//  on 14-12-19.
//
//

#ifndef ____NodeShader__
#define ____NodeShader__

#include "INodeShader.h"
#include <string>

using namespace cocos2d;

class NodeShader : public INodeShader
{
public:
    NodeShader();
    ~NodeShader();
    
    static NodeShader* create(const std::string &vert, const std::string &frag);
    
    virtual void shader(Node *node, bool recursive) override;
    
    virtual bool init(const std::string &vert, const std::string &frag);
    
private:
    std::string m_vertSource;
    std::string m_fragSource;
};

#endif /* defined(____NodeShader__) */
