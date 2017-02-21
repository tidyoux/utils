//
//  IOSPlatform.cpp
//  
//
//  on 15-1-27.
//
//

#include "IOSPlatform.h"
#import <UIKit/UIKit.h>
#import <GameKit/GameKit.h>
#import <StoreKit/StoreKit.h>

#include "PlatformOpcode.h"
#include "device.h"
#include "LuaWrapper.h"
#include "EventHelper.h"
#include "StringTools.h"
#include "Bundle.h"

using namespace cocos2d;

//
// login
//
static void loginRequest(std::string uid)
{
    if (uid.empty())
    {
        bool isFirstLogin = true;
        if (MJLua.call("data_helper", "getIsFirstLogin", 0, 1))
        {
            MJLua.pop(isFirstLogin);
        }
        
        if (MJLua.call("data_helper", "getUuid", 0, 1))
        {
            MJLua.pop(uid);
        }
        
        if (isFirstLogin || uid.empty())
        {
            uid = identifier_for_vendor() + "--" + StringTools::toString((int)time(nullptr));
        }
    }
    
    Bundle *data = Bundle::create();
    data->setString("target", "login_scene");
    data->setString("reason", "loginRequest");
    data->setString("uid", uid);
    data->setString("sid", "");
    EventHelper::dispatch(EventName::lgc_finish, data);
}

//
// addPurchaseReceipt
//
static void addPurchaseReceipt(const std::string &receiptStr)
{
    Bundle *data = Bundle::create();
    data->setString("source", "IOSPlatform");
    data->setString("target", "ios_purchase_check_component");
    data->setString("reason", "addPurchaseReceipt");
    data->setString("receiptStr", receiptStr);
    EventHelper::dispatch(EventName::lgc_change, data);
}

//
// ProductsRequestDelegate
//
@interface ProductsRequestDelegate : NSObject<SKProductsRequestDelegate>
@end

@implementation ProductsRequestDelegate
-(void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response
{
    NSArray *products = response.products;
    if (products.count <= 0)
    {
        log("Error: productsRequest failed, products.count is 0!");
        return;
    }
    
    SKProduct *product = products[0];
    SKPayment *payment = [SKPayment paymentWithProduct:product];
    [[SKPaymentQueue defaultQueue] addPayment:payment];
}
@end

//
// PaymentObserver
//
@interface PaymentObserver : NSObject<SKPaymentTransactionObserver>
@end

@implementation PaymentObserver
-(void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions
{
    for (SKPaymentTransaction *transaction : transactions)
    {
        switch (transaction.transactionState)
        {
            case SKPaymentTransactionStatePurchased: // finish
            {
                NSString *productIdentifier = transaction.payment.productIdentifier;
                if ([productIdentifier length] > 0)
                {
                    NSString *receiptNSStr = [transaction.transactionReceipt base64Encoding];
                    const std::string receiptStr = [receiptNSStr UTF8String];
                    addPurchaseReceipt(receiptStr);
                }
                
                log("Info: PaymentObserver, paymentQueue, transaction finish!");
                [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
                break;
            }
            case SKPaymentTransactionStateFailed: // failed
                NSLog(@"Warning: PaymentObserver, paymentQueue, transaction failed! error: %@", transaction.error);
                [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
                break;
            case SKPaymentTransactionStateRestored: // restore
                //
                [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
                break;
            default:
                break;
        }
    }
}
@end


//////////////////////////////////////////////
namespace PlatformConf
{
    static const std::string &CHANNEL_LABEL = "app_store";
}


///////////////////////////////////////////////
struct BaseData
{
public:
    BaseData()
    :mProductsRequestDelegate(nullptr)
    ,mPaymentObserver(nullptr)
    {}
    
    ~BaseData()
    {
        [mProductsRequestDelegate dealloc];
        [mPaymentObserver dealloc];
    }
    
    ProductsRequestDelegate *mProductsRequestDelegate;
    PaymentObserver *mPaymentObserver;
};
IOSPlatform::IOSPlatform()
:mData(new BaseData())
{
    //
}

IOSPlatform::~IOSPlatform()
{
    delete mData;
}

bool IOSPlatform::init()
{
    mData->mProductsRequestDelegate = [ProductsRequestDelegate alloc];
    mData->mPaymentObserver = [PaymentObserver alloc];
    [[SKPaymentQueue defaultQueue] addTransactionObserver:mData->mPaymentObserver];
    
    return true;
}

void IOSPlatform::login()
{
    GKLocalPlayer *localPlayer = [GKLocalPlayer localPlayer];
    if (localPlayer.isAuthenticated)
    {
        const std::string uid = [localPlayer.playerID UTF8String];
        loginRequest(uid);
        return;
    }
    
    localPlayer.authenticateHandler = ^(UIViewController *viewController, NSError *error)
    {
        std::string uid;
        if (error != nil)
        {
            NSLog(@"Error: IOSPlatform::login, authenticate failed: %@", error);
        }
        else
        {
            if (localPlayer.isAuthenticated)
            {
                uid = [localPlayer.playerID UTF8String];
            }
        }
        loginRequest(uid);
    };
}

void IOSPlatform::pay(int count, const std::string &itemId)
{
    if (![SKPaymentQueue canMakePayments])
    {
        log("Warning: IOSPlatform::pay, can not make payment!");
        return;
    }
    
    if (itemId.size() == 0)
    {
        log("Error: IOSPlatform::pay, itemId.size() == 0");
        return;
    }
    
    NSSet *set = [NSSet setWithArray:@[@(itemId.c_str())]];
    SKProductsRequest *request = [[SKProductsRequest alloc] initWithProductIdentifiers:set];
    request.delegate = mData->mProductsRequestDelegate;
    [request start];
}

void IOSPlatform::operate(int opcode, const std::string &args)
{
    switch (opcode)
    {
        case PlatformOpcode::OP_INIT_CHANNEL_NAME:
        {
            MJLua.push(PlatformConf::CHANNEL_LABEL);
            MJLua.call("data_helper", "setChannelIdByChannelName", 1, 0);
            break;
        }
        case PlatformOpcode::OP_CONVERSATION:
        {
            break;
        }
        case PlatformOpcode::OP_SUBMIT_EXT_DATA:
        {
            break;
        }
        case PlatformOpcode::OP_APPLICATION_DID_ENTER_BACKGROUND:
        {
            break;
        }
        case PlatformOpcode::OP_APPLICATION_WILL_ENTER_FOREGROUND:
        {
            break;
        }
        default:
        {
            CCLOG("warning: IOSPlatform::operate, invalid opcode = %d", opcode);
            break;
        }
    }
}

