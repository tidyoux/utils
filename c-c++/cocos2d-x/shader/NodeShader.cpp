//
//  NodeShader.cpp
//  
//
//  on 14-12-19.
//
//

#include "NodeShader.h"
#include "cocos2d.h"

NodeShader::NodeShader()
{
    
}

NodeShader::~NodeShader()
{
    
}

NodeShader* NodeShader::create(const std::string &vert, const std::string &frag)
{
    NodeShader *ret = new NodeShader();
    if (ret && ret->init(vert, frag))
    {
        ret->autorelease();
        return ret;
    }
    CC_SAFE_DELETE(ret);
    return nullptr;
}

bool NodeShader::init(const std::string &vert, const std::string &frag)
{
    const std::string &fragFullPath = FileUtils::getInstance()->fullPathForFilename(frag);
    const std::string &vertFullPath = FileUtils::getInstance()->fullPathForFilename(vert);
    
    if (vert.empty())
    {
        m_vertSource = ccPositionTextureColor_noMVP_vert;
    }
    else
    {
        m_vertSource = FileUtils::getInstance()->getStringFromFile(vertFullPath);
    }
    
    if (frag.empty())
    {
        m_fragSource = ccPositionTextureColor_noMVP_frag;
    }
    else
    {
        m_fragSource = FileUtils::getInstance()->getStringFromFile(fragFullPath);
    }
    
    if (m_vertSource.empty() || m_fragSource.empty())
    {
        return false;
    }
    return true;
}

static void shaderNode(Node *node, GLProgram *glProgram, bool recursive)
{
    if (node == nullptr || glProgram == nullptr)
    {
        return;
    }
    
    node->setGLProgram(glProgram);
    if (recursive)
    {
        for (auto child:node->getChildren())
        {
            shaderNode(child, glProgram, recursive);
        }
    }
}
void NodeShader::shader(Node *node, bool recursive)
{
    GLProgram *glProgram = GLProgram::createWithByteArrays(m_vertSource.c_str(), m_fragSource.c_str());
    shaderNode(node, glProgram, recursive);
}
