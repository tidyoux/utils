//
//  PopBoard.h
//  
//
//  on 15-1-29.
//
//

#ifndef ____PopBoard__
#define ____PopBoard__

#include "cocos2d.h"
#include "../Macros.h"

using namespace cocos2d;


class PopBoard : public Node
{
public:
    static PopBoard *getInstance();
    virtual ~PopBoard();
    
    static void show(Node *parent);
    static void hide();
    
private:
    make_static_class(PopBoard);
    bool init();
};

#endif /* defined(____PopBoard__) */
