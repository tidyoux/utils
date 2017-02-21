//
//  CocosTools.h
//  
//
//  on 15-1-29.
//
//

#ifndef ____CocosTools__
#define ____CocosTools__

#include "cocos2d.h"
#include "ui/CocosGUI.h"
#include "Macros.h"

using namespace cocos2d;


typedef std::function<void(Ref*)> MJTouchCallback;
typedef std::function<void(Image *image)> CapturedCallback;
class CocosTools
{
public:
    static void resetParent(Node *child, Node *newParent);
    static void setTouchListener(ui::Widget * widget, ui::Widget::TouchEventType eventType, const MJTouchCallback &callback);
    
    static void delayRun(Node *node, float dt, std::function<void()> fn);
    
    // 截屏
    static void captureScreen(const CapturedCallback &callback);
    static RenderTexture * captureNode(Node *target);
    
    static Texture2D *createTexture2D(Image *image);
    
private:
    make_static_class(CocosTools);
};

#endif /* defined(____CocosTools__) */
