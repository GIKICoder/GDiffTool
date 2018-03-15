//
//  GDiffMoveItem.h
//  GDiffExample
//
//  Created by GIKI on 2018/3/12.
//  Copyright © 2018年 GIKI. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GDiffMoveItem : NSObject
@property (nonatomic, assign) NSUInteger  toIndex;
@property (nonatomic, assign) NSUInteger  fromIndex;
- (instancetype)initWithFrom:(NSUInteger)from to:(NSUInteger)to;

@end
