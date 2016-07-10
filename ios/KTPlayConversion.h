//
//  KTPlayConversion.h
//
//  Created by HelloMeowLab on 5/8/16.
//
//

#import <Foundation/Foundation.h>

@class KTUser;
@class KTLeaderboardPaginator;

@interface KTPlayConversion : NSObject

+ (NSDictionary*) dictionaryWithKTUser:(KTUser*)user;
+ (NSDictionary*) dictionaryWithKTLeaderboardPaginator:(KTLeaderboardPaginator*)leaderboard;
+ (NSDictionary*) dictionaryWithKTRewards:(NSArray*)rewards;

@end
