//
//  CocosTools.cpp
//  
//
//  on 15-1-29.
//
//

#include "CocosTools.h"

static void onCaptureScreen(const CapturedCallback &afterCaptured)
{
    auto glView = Director::getInstance()->getOpenGLView();
    auto frameSize = glView->getFrameSize();
#if (CC_TARGET_PLATFORM == CC_PLATFORM_MAC) || (CC_TARGET_PLATFORM == CC_PLATFORM_WIN32) || (CC_TARGET_PLATFORM == CC_PLATFORM_LINUX)
    frameSize = frameSize * glView->getFrameZoomFactor() * glView->getRetinaFactor();
#endif
    
    const int width = static_cast<int>(frameSize.width);
    const int height = static_cast<int>(frameSize.height);
    
    Image *image = nullptr;
    do
    {
        std::shared_ptr<GLubyte> buffer(new GLubyte[width * height * 4], [](GLubyte* p){ CC_SAFE_DELETE_ARRAY(p); });
        if (!buffer)
        {
            break;
        }
        
        glPixelStorei(GL_PACK_ALIGNMENT, 1);
        
#if (CC_TARGET_PLATFORM == CC_PLATFORM_WP8)
        // The frame buffer is always created with portrait orientation on WP8.
        // So if the current device orientation is landscape, we need to rotate the frame buffer.
        auto renderTargetSize = glView->getRenerTargetSize();
        CCASSERT(width * height == static_cast<int>(renderTargetSize.width * renderTargetSize.height), "The frame size is not matched");
        glReadPixels(0, 0, (int)renderTargetSize.width, (int)renderTargetSize.height, GL_RGBA, GL_UNSIGNED_BYTE, buffer.get());
#else
        glReadPixels(0, 0, width, height, GL_RGBA, GL_UNSIGNED_BYTE, buffer.get());
#endif
        
        std::shared_ptr<GLubyte> flippedBuffer(new GLubyte[width * height * 4], [](GLubyte* p) { CC_SAFE_DELETE_ARRAY(p); });
        if (!flippedBuffer)
        {
            break;
        }
        
#if (CC_TARGET_PLATFORM == CC_PLATFORM_WP8)
        if (width == static_cast<int>(renderTargetSize.width))
        {
            // The current device orientation is portrait.
            for (int row = 0; row < height; ++row)
            {
                memcpy(flippedBuffer.get() + (height - row - 1) * width * 4, buffer.get() + row * width * 4, width * 4);
            }
        }
        else
        {
            // The current device orientation is landscape.
            for (int row = 0; row < width; ++row)
            {
                for (int col = 0; col < height; ++col)
                {
                    *(int*)(flippedBuffer.get() + (height - col - 1) * width * 4 + row * 4) = *(int*)(buffer.get() + row * height * 4 + col * 4);
                }
            }
        }
#else
        for (int row = 0; row < height; ++row)
        {
            memcpy(flippedBuffer.get() + (height - row - 1) * width * 4, buffer.get() + row * width * 4, width * 4);
        }
#endif
        
        image = new Image();
        if (image)
        {
            image->initWithRawData(flippedBuffer.get(), width * height * 4, width, height, 8);
            image->autorelease();
        }
    }while(0);
    
    if (afterCaptured)
    {
        afterCaptured(image);
    }
}

///////////////////////////////////////////////////////////////
void CocosTools::resetParent(Node *child, Node *newParent)
{
    if (child != nullptr && newParent != nullptr)
    {
        child->retain();
        child->removeFromParent();
        newParent->addChild(child);
        child->release();
    }
}

void CocosTools::setTouchListener(ui::Widget * widget, ui::Widget::TouchEventType eventType, const MJTouchCallback &callback)
{
    if (widget != nullptr)
    {
        widget->addTouchEventListener([=](Ref *sender, ui::Widget::TouchEventType evtType){
            if (evtType == eventType)
            {
                if (callback != nullptr)
                {
                    callback(sender);
                }
            }
        });
    }
}

void CocosTools::delayRun(cocos2d::Node *node, float dt, std::function<void()> fn)
{
    if (node == nullptr || fn == nullptr)
    {
        return;
    }
    
    node->runAction(Sequence::create(DelayTime::create(dt),
                                     CallFunc::create(fn),
                                     nullptr));
}

void CocosTools::captureScreen(const CapturedCallback &callback)
{
    static CustomCommand captureScreenCommand;
    captureScreenCommand.init(std::numeric_limits<float>::max());
    captureScreenCommand.func = std::bind(onCaptureScreen, callback);
    Director::getInstance()->getRenderer()->addCommand(&captureScreenCommand);
}

RenderTexture * CocosTools::captureNode(Node *target)
{
    auto director = Director::getInstance();
    if (target == nullptr)
    {
        target = director->getRunningScene();
    }
    
    const Size &size = target->boundingBox().size;
    auto renderTexture = RenderTexture::create(size.width, size.height, Texture2D::PixelFormat::RGB888);
    renderTexture->beginWithClear(0.0f, 0.0f, 0.0f, 0.0f);
    target->setAnchorPoint(Point::ZERO);
    target->setPosition(Point::ZERO);
    target->visit();
    renderTexture->end();
    
    return renderTexture;
}

Texture2D * CocosTools::createTexture2D(Image *image)
{
    Texture2D *ret = new Texture2D();
    if (ret && ret->initWithImage(image))
    {
        ret->autorelease();
        return ret;
    }
    CC_SAFE_DELETE(ret);
    return ret;
}









