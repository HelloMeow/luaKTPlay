//
//  KTPlayBridge.h
//
//  Created by HelloMeowLab on 5/8/16.
//
//


#import <Foundation/Foundation.h>

@interface KTPlayBridge : NSObject{
}
+ (KTPlayBridge*) getInstance;
+ (void)showLoginView:(NSDictionary*)paras;
+ (void)reportScore:(NSDictionary*)paras;
+ (void)globalLeaderboard:(NSDictionary*)paras;
+ (void)setLoginStatusChangedBlock:(NSDictionary*)paras;
+ (void)currentAccount:(NSDictionary*)paras;
+ (void)setDidDispatchRewardBlock:(NSDictionary*)paras;
+ (void)setOnNewActivityStatusChangedCallback:(NSDictionary*)paras;
@end
