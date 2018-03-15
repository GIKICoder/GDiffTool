//
//  GTestItem.h
//  GDiffExample
//
//  Created by GIKI on 2018/3/12.
//  Copyright © 2018年 GIKI. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GDiffObjectProtocol.h"
#define createTest(str,ind) [GTestItem ID:str INDEX:ind]
@interface GTestItem : NSObject
@property (nonatomic, strong) NSString  *ID;
@property (nonatomic, assign) NSInteger  index;
+ (instancetype)ID:(NSString*)ID INDEX:(NSInteger)index;
@end
