//
//  KTPlayBridge.m
//
//  Created by HelloMeowLab on 5/8/16.
//
//

#import "KTPlayBridge.h"
#import "KTAccountManager.h"
#import "KTLeaderboard.h"
#import "KTUser.h"
#import "KTPlayConversion.h"
#include "CCLuaEngine.h"
#include "CCLuaBridge.h"

@interface KTPlayBridge()

@property(nonatomic, retain) NSMutableDictionary* cbOs;
@property(nonatomic, retain) NSMutableDictionary* cbXs;

@end

@implementation KTPlayBridge

@synthesize cbOs, cbXs;

static KTPlayBridge* s_instance = nil;

+ (KTPlayBridge*) getInstance
{
    if (!s_instance)
    {
        s_instance = [KTPlayBridge alloc];
        [s_instance init];
    }

    return s_instance;
}

- (id)init
{
    self.cbOs = [NSMutableDictionary dictionary];
    self.cbXs = [NSMutableDictionary dictionary];
    return self;
}

static cocos2d::LuaValue getLuaValue(id value)
{
    if (value != nil) {
        if ([value isKindOfClass:[NSNumber class]])
        {
            NSNumber *number = (NSNumber *)value;
            const char *numberType = [number objCType];
            if (strcmp(numberType, @encode(BOOL)) == 0)
            {
                return cocos2d::LuaValue::booleanValue([number boolValue]);
            }
            else if (strcmp(numberType, @encode(int)) == 0)
            {
                return cocos2d::LuaValue::intValue([number intValue]);
            }
            else
            {
                return cocos2d::LuaValue::floatValue([number floatValue]);
            }
        }
        else if ([value isKindOfClass:[NSString class]])
        {
            return cocos2d::LuaValue::stringValue([value cStringUsingEncoding:NSUTF8StringEncoding]);
        }
        else if ([value isKindOfClass:[NSArray class]])
        {
            cocos2d::LuaValueArray arr;

            for (id v in value) {
                arr.push_back(getLuaValue(v));
            }

            return cocos2d::LuaValue::arrayValue(arr);
        }
        else if ([value isKindOfClass:[NSDictionary class]])
        {
            cocos2d::LuaValueDict dict;

            for (id key in value)
            {
                const char* key_ = [[NSString stringWithFormat:@"%@", key]
                                    cStringUsingEncoding:NSUTF8StringEncoding];
                dict[key_] = getLuaValue([value objectForKey:key]);
            }

            return cocos2d::LuaValue::dictValue(dict);
        }
    }
    return cocos2d::LuaValue::stringValue("Invalid value");
}

- (void)callback:(int)handler withData:(id)data
{
    if (handler)
    {
        cocos2d::LuaBridge::pushLuaFunctionById(handler);
        cocos2d::LuaStack *stack = cocos2d::LuaBridge::getStack();
        int numArgs = 0;
        if (data != nil)
        {
            stack->pushLuaValue(getLuaValue(data));
            numArgs = 1;
        }
        stack->executeFunction(numArgs);
    }
}

+ (void)setCbOk:(int)cb withKey:(NSString*)key
{
    int old_cb = [[[KTPlayBridge getInstance].cbOs objectForKey:key] intValue];
    if (old_cb) {
        cocos2d::LuaBridge::releaseLuaFunctionById(old_cb);
    }
    [[KTPlayBridge getInstance].cbOs setObject:[NSNumber numberWithInt:cb] forKey:key];
}

+ (void)setCbFail:(int)cb withKey:(NSString*)key
{
    int old_cb = [[[KTPlayBridge getInstance].cbXs objectForKey:key] intValue];
    if (old_cb) {
        cocos2d::LuaBridge::releaseLuaFunctionById(old_cb);
    }
    [[KTPlayBridge getInstance].cbXs setObject:[NSNumber numberWithInt:cb] forKey:key];
}

+ (void)callCbOk:(NSString*)key withData:(id)data needsCleanup:(BOOL)cleanup
{
    int cb = [[[KTPlayBridge getInstance].cbOs objectForKey:key] intValue];
    [[KTPlayBridge getInstance] callback:cb withData:data];
    if (cleanup) {
        cocos2d::LuaBridge::releaseLuaFunctionById(cb);
        [[KTPlayBridge getInstance].cbOs removeObjectForKey:key];
    }
}

+ (void)callCbFail:(NSString*)key withData:(id)data needsCleanup:(BOOL)cleanup
{
    int cb = [[[KTPlayBridge getInstance].cbXs objectForKey:key] intValue];
    [[KTPlayBridge getInstance] callback:cb withData:data];

    if (cleanup) {
        cocos2d::LuaBridge::releaseLuaFunctionById(cb);
        [[KTPlayBridge getInstance].cbXs removeObjectForKey:key];
    }
}

+ (void)showLoginView:(NSDictionary*)paras
{
    BOOL closable = [[paras objectForKey:@"closable"] boolValue];

    [KTPlayBridge setCbOk:[[paras objectForKey:@"cb_ok"] intValue] withKey:@"loginView"];
    [KTPlayBridge setCbFail:[[paras objectForKey:@"cb_fail"] intValue] withKey:@"loginView"];

    [KTAccountManager showLoginView:closable success:^(KTUser * account){
        // ok
        id user = [KTPlayConversion dictionaryWithKTUser:account];
        [KTPlayBridge callCbOk:@"loginView" withData:user needsCleanup:YES];
    }failure:^(NSError *error) {
        // fail
        [KTPlayBridge callCbFail:@"loginView" withData:error.localizedDescription needsCleanup:YES];
    }];
}

+ (void)reportScore:(NSDictionary*)paras
{
    long long score = [[paras objectForKey:@"score"] longLongValue];
    NSString* leaderboardId = [paras objectForKey:@"leaderboardId"];

    [KTPlayBridge setCbOk:[[paras objectForKey:@"cb_ok"] intValue] withKey:leaderboardId];
    [KTPlayBridge setCbFail:[[paras objectForKey:@"cb_fail"] intValue] withKey:leaderboardId];

    [KTLeaderboard reportScore:score leaderboardId:leaderboardId scoreTag:@"default" success:^{
        // ok
        [KTPlayBridge callCbOk:leaderboardId withData:nil needsCleanup:YES];
    } failure:^(NSError *error) {
        // fail
        [KTPlayBridge callCbFail:leaderboardId withData:error.localizedDescription needsCleanup:YES];
    }];
}


+ (void)globalLeaderboard:(NSDictionary*)paras
{
    NSString* leaderboardId = [paras objectForKey:@"leaderboardId"];
    int startIndex = [[paras objectForKey:@"startIndex"] intValue];
    int count = [[paras objectForKey:@"count"] intValue];

    [KTPlayBridge setCbOk:[[paras objectForKey:@"cb_ok"] intValue] withKey:leaderboardId];
    [KTPlayBridge setCbFail:[[paras objectForKey:@"cb_fail"] intValue] withKey:leaderboardId];

    [KTLeaderboard globalLeaderboard:leaderboardId
                          startIndex:startIndex
                               count:count
                             success:^(KTLeaderboardPaginator *leaderboard) {
                                 // ok
                                 id data = [KTPlayConversion dictionaryWithKTLeaderboardPaginator:leaderboard];
                                 [KTPlayBridge callCbOk:leaderboardId withData:data needsCleanup:YES];
    }
                             failure:^(NSError *error) {
                                 // fail
                                 [KTPlayBridge callCbFail:leaderboardId withData:error.localizedDescription needsCleanup:YES];
    }];
}

+ (void)setLoginStatusChangedBlock:(NSDictionary*)paras
{
    [KTPlayBridge setCbOk:[[paras objectForKey:@"cb_login"] intValue] withKey:@"login"];
    [KTPlayBridge setCbOk:[[paras objectForKey:@"cb_logout"] intValue] withKey:@"logout"];

    [KTAccountManager setLoginStatusChangedBlock:^(BOOL isLoggedIn, KTUser *account) {
        NSLog(@"LoginStatusChanged:%d", isLoggedIn);
        id user = [KTPlayConversion dictionaryWithKTUser:account];
        if (isLoggedIn) {
            [KTPlayBridge callCbOk:@"login" withData:user needsCleanup:NO];
        } else {
            [KTPlayBridge callCbOk:@"logout" withData:user needsCleanup:NO];
        }

    }];
}


+ (void)currentAccount:(NSDictionary*)paras
{
    if (nil == [paras objectForKey:@"cb"]) return;

    int cb = [[paras objectForKey:@"cb"] intValue];
    if (cb) {
        if ([KTAccountManager isLoggedIn]) {
            id user = [KTPlayConversion dictionaryWithKTUser:[KTAccountManager currentAccount]];
            [[KTPlayBridge getInstance] callback:cb
                                        withData:user];
        }
        else {
            [[KTPlayBridge getInstance] callback:cb
                                        withData:nil];
        }
        cocos2d::LuaBridge::releaseLuaFunctionById(cb);
    }
}


+ (void)setDidDispatchRewardBlock:(NSDictionary*)paras
{
    [KTPlayBridge setCbOk:[[paras objectForKey:@"cb"] intValue] withKey:@"reward"];

    [KTPlay setDidDispatchRewardsBlock:^(KTReward* reward) {
        id reward_dict = [KTPlayConversion dictionaryWithKTRewards:reward.items];
        [KTPlayBridge callCbOk:@"reward" withData:reward_dict needsCleanup:NO];
    }];

}

+ (void)setOnNewActivityStatusChangedCallback:(NSDictionary*)paras
{
    [KTPlayBridge setCbOk:[[paras objectForKey:@"cb"] intValue] withKey:@"activity"];

    [KTPlay setActivityStatusChangedBlock:^(BOOL hasNewActivity) {
        [KTPlayBridge callCbOk:@"activity" withData:[NSNumber numberWithBool:hasNewActivity] needsCleanup:NO];
    }];
}

@end
