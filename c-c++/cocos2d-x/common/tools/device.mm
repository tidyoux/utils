//
//  device.cpp
//  gane3.1
//
//  on 5/28/14.
//
//

#include "device.h"
#import <Foundation/Foundation.h>
//#import "SvUDIDTools.h"

string localizedModel()
{
    return [[[UIDevice currentDevice] localizedModel] cStringUsingEncoding:NSUTF8StringEncoding];
}

string identifier_for_vendor()
{
    return [[[[UIDevice currentDevice] identifierForVendor] UUIDString] cStringUsingEncoding:NSUTF8StringEncoding];
}

void test_device_log()
{
    
    CCLOG("name:[%s]", device_name().c_str());
    CCLOG("device_version:[%s]", device_version().c_str());
    CCLOG("device_model:[%s]", device_model().c_str());
    CCLOG("identifierForVendor:[%s]", identifier_for_vendor().c_str());
    
    //NSString *udid = [SvUDIDTools UDID];
    //NSLog(@"udid in keychain %@", udid);
}

string device_name()
{
    return [[[UIDevice currentDevice] systemName] cStringUsingEncoding:NSUTF8StringEncoding];
}

string device_version()
{
    return [[[UIDevice currentDevice] systemVersion] cStringUsingEncoding:NSUTF8StringEncoding];
}

string device_model() {
    return [[[UIDevice currentDevice] model] cStringUsingEncoding:NSUTF8StringEncoding];
}