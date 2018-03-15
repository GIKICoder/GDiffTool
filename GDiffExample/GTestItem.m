//
//  GTestItem.m
//  GDiffExample
//
//  Created by GIKI on 2018/3/12.
//  Copyright © 2018年 GIKI. All rights reserved.
//

#import "GTestItem.h"

@implementation GTestItem
+ (instancetype)ID:(NSString*)ID INDEX:(NSInteger)index
{
    GTestItem *item = [GTestItem new];
    
    item.ID = ID;
    item.index = index;
    return item;
}

- (nonnull id<NSObject>)diffIdentifier
{
    return self.ID;
}


- (BOOL)isEqual:(nullable id<GDiffObjectProtocol>)object
{
    GTestItem * test = object;
    BOOL tf = (self.index == test.index);
    return ( tf);
}
@end
