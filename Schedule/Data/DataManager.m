//
//  DataManager.m
//  NBASchedule2016~2017
//
//  Created by yuedong_chen on 16/8/17.
//  Copyright © 2016年 yuedong_chen. All rights reserved.
//

#import "DataManager.h"
#import "AFNetworking.h"
#import "GameInfo.h"

@implementation DataManager

- (id)initWithDelegate:(id<DataMangerDelegate>)delegate
{
    self = [super init];
    if (self) {
        self.delegate = delegate;
    }
    return self;
}

- (void)requestWithMonth:(NSInteger)month year:(NSInteger)year andTeamId:(NSString *)tid
{
    [self.gameInfoList removeAllObjects];
    
    NSString *str = [NSString stringWithFormat:@"http://sportsnba.qq.com/match/calendar?month=%ld&teamId=%@&year=%ld", (long)month, tid, (long)year];
    
    NSURL *url = [NSURL URLWithString:str];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSString *htmlString = operation.responseString;
        
        NSData *htmlData = [htmlString dataUsingEncoding:NSUTF8StringEncoding];
        
        NSDictionary *htmlDict = [NSJSONSerialization JSONObjectWithData:htmlData options:NSJSONReadingMutableLeaves error:nil];
        
        NSDictionary *data = [htmlDict objectForKey:@"data"];
        
        NSDictionary *matchVs = [data objectForKey:@"matchVs"];
        
        NSLog(@"获取到的数据为：%@ ",matchVs);
        
        NSArray *allKeys = [matchVs allKeys];
        
        for (NSString *key in allKeys) {
            NSDictionary *dayValue = [matchVs objectForKey:key];
            
            GameInfo *info = [[GameInfo alloc] init];
            info.gameDay = [key integerValue];
            info.isWin = [[dayValue objectForKey:@"isWin"] integerValue];
            info.isMaster = [[dayValue objectForKey:@"isMaster"] integerValue];
            info.rivalGoal = [[dayValue objectForKey:@"rivalGoal"] integerValue];
            info.selfGoal = [[dayValue objectForKey:@"selfGoal"] integerValue];
            info.startTime = [[dayValue objectForKey:@"startTime"] integerValue];
            info.vsTeamId = [dayValue objectForKey:@"vsTeamId"];
            info.vsTeamName = [dayValue objectForKey:@"vsTeamName"];
            
            [self.gameInfoList addObject:info];
        }
        
        if ([self.delegate respondsToSelector:@selector(loadingDataFinished:)]) {
            [self.delegate loadingDataFinished:self];
        }
        
    }failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"发生错误！%@",error);
        
        if ([self.delegate respondsToSelector:@selector(loadingDatafailured:error:)]) {
            [self.delegate loadingDatafailured:self error:error];
        }
    }];
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    [queue addOperation:operation];

}

- (NSMutableArray *)gameInfoList
{
    if (!_gameInfoList) {
        _gameInfoList = [NSMutableArray array];
    }
    return _gameInfoList;
}

+ (NSDictionary *)teamDic
{
        return     @{@"1" : @"亚特兰大老鹰",
                     @"2"  : @"波士顿凯尔特人",
                     @"3"  : @"新奥尔良鹈鹕",
                     @"4"  : @"芝加哥公牛",
                     @"5"  : @"克利夫兰骑士",
                     @"6"  : @"达拉斯小牛",
                     @"7"  : @"丹佛掘金",
                     @"8"  : @"底特律活塞",
                     @"9"  : @"金州勇士",
                     @"10"  : @"休斯顿火箭",
                     @"11"  : @"印第安纳步行者",
                     @"12"  : @"洛杉矶快船",
                     @"13"  : @"洛杉矶湖人",
                     @"14"  : @"迈阿密热火",
                     @"15"  : @"密尔沃基雄鹿",
                     @"16"  : @"明尼苏达森林狼",
                     @"17"  : @"新泽西篮网",
                     @"18"  : @"纽约尼克斯",
                     @"19"  : @"奥兰多魔术",
                     @"20"  : @"费城76人",
                     @"21"  : @"菲尼克斯太阳",
                     @"22"  : @"波特兰开拓者",
                     @"23"  : @"萨克拉门托国王",
                     @"24"  : @"圣安东尼奥马刺",
                     @"25"  : @"俄克拉荷马雷霆",
                     @"26"  : @"犹他爵士",
                     @"27"  : @"华盛顿奇才",
                     @"28"  : @"多伦多猛龙",
                     @"29"  : @"孟菲斯灰熊",
                     @"30"  : @"夏洛特黄蜂"};
}


@end
