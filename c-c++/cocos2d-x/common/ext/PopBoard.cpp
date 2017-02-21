//
//  PopBoard.cpp
//  
//
//  on 15-1-29.
//
//

#include "PopBoard.h"
#include "CocosTools.h"
#include "NodeShader.h"


PopBoard::PopBoard()
{
    
}

PopBoard::~PopBoard()
{

}

bool PopBoard::init()
{
    if (Node::init())
    {
        hide();
        return true;
    }
    return false;
}

PopBoard * PopBoard::getInstance()
{
    static PopBoard *ret = nullptr;
    if (ret == nullptr)
    {
        ret = new PopBoard();
        ret->init();
    }
    return ret;
}

void PopBoard::show(Node *parent)
{
    return_if(parent == nullptr, _void_);
    
    hide();
    
    auto board = getInstance();
    board->setVisible(true);
    parent->addChild(board, -1);
    
    const Size &winSize = Director::getInstance()->getWinSize();
    const Size &blackBoardSize = winSize * 4;
    LayerColor *layer = LayerColor::create(Color4B(0, 0, 0, 150), blackBoardSize.width, blackBoardSize.height);
    layer->setPosition((winSize - blackBoardSize) / 2);
    board->addChild(layer);
}

void PopBoard::hide()
{
    auto board = getInstance();
    board->setVisible(false);
    board->removeAllChildren();
    board->removeFromParent();
}

