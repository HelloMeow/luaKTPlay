//
//  KTPlayConversion.m
//
//  Created by HelloMeowLab on 5/8/16.
//
//

#import "KTPlayConversion.h"
#import "KTUser.h"
#import "KTLeaderboard.h"
@implementation KTPlayConversion

static void safe_set_dict(NSMutableDictionary* dict, NSString* key, id value)
{
    if (value) {
        [dict setObject:value forKey:key];
    } else {
        NSLog(@"value for key[%@] is nil", key);
    }
}

+ (NSDictionary*) dictionaryWithKTUser:(KTUser*)user
{
    id dict = [NSMutableDictionary dictionary];

    safe_set_dict(dict, @"userId",              user.userId);
    safe_set_dict(dict, @"headerUrl",           user.headerUrl);
    safe_set_dict(dict, @"nickname",            user.nickname);
    safe_set_dict(dict, @"gender",              @(user.gender));
    safe_set_dict(dict, @"city",                user.city);
    safe_set_dict(dict, @"score",               user.score);
    safe_set_dict(dict, @"rank",                @(user.rank));
    safe_set_dict(dict, @"snsUserId",           user.snsUserId);
    safe_set_dict(dict, @"loginType",           user.loginType);
    safe_set_dict(dict, @"gameUserId",          user.gameUserId);
    safe_set_dict(dict, @"needPresentNickname", @(user.needPresentNickname));
    safe_set_dict(dict, @"originScore",         @(user.originScore));
    safe_set_dict(dict, @"scoreTag",            user.scoreTag);

    return dict;
}


+ (NSDictionary*) dictionaryWithKTLeaderboardPaginator:(KTLeaderboardPaginator*)leaderboard
{
    id dict = [NSMutableDictionary dictionary];

    safe_set_dict(dict, @"total",               @(leaderboard.total));
    safe_set_dict(dict, @"nextCursor",          leaderboard.nextCursor);
    safe_set_dict(dict, @"previousCursor",      leaderboard.previousCursor);
    safe_set_dict(dict, @"leaderboardName",     leaderboard.leaderboardName);
    safe_set_dict(dict, @"leaderboardIcon",     leaderboard.leaderboardIcon);
    safe_set_dict(dict, @"leaderboardId",       leaderboard.leaderboardId);
    safe_set_dict(dict, @"myRank",              @(leaderboard.myRank));
    safe_set_dict(dict, @"myScore",             leaderboard.myScore ? leaderboard.myScore : @"0");
    safe_set_dict(dict, @"myOriginScore",       @(leaderboard.myOriginScore));
    safe_set_dict(dict, @"myScoreTag",          leaderboard.myScoreTag ? leaderboard.myScoreTag : @"default");

    id users = [NSMutableArray arrayWithCapacity:leaderboard.items.count];
    for (KTUser* user in leaderboard.items) {
        [users addObject:[KTPlayConversion dictionaryWithKTUser:user]];
    }
    [dict setObject:users forKey:@"items"];

    return dict;
}

+ (NSDictionary*) dictionaryWithKTRewards:(NSArray*)rewards
{
    id dict = [NSMutableDictionary dictionary];

    for (KTRewardItem *item in rewards) {
        [dict setObject:@(item.value) forKey:item.typeId];
    }

    return dict;
}

@end
