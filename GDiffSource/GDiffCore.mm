//
//  GDiffCore.m
//  GDiffExample
//
//  Created by GIKI on 2018/3/11.
//  Copyright © 2018年 GIKI. All rights reserved.
//

#import "GDiffCore.h"
#import <stack>
#import <unordered_map>
#import <vector>

#import "GDiffObjectProtocol.h"
#import "GDiffMoveItem.h"
#import "GDiffResult.h"
using namespace std;

struct GDiffEntry {
    NSInteger oldCounter = 0;
    NSInteger newCounter = 1;
    stack<NSInteger> oldIndexs;
    BOOL update = NO;
};

struct GDiffRecord {
    GDiffEntry *entry;
    mutable NSInteger index;
    
    GDiffRecord() {
        entry = NULL;
        index = NSNotFound;
    }
};

struct GDiffEqualID {
    bool operator()(const id a, const id b) const {
        return (a == b) || [a isEqual: b];
    }
};

struct GDiffHashID {
    size_t operator()(const id o) const {
        return (size_t)[o hash];
    }
};

static id<NSObject>  GDiffTableKey(id<GDiffObjectProtocol> object) {
    id<NSObject> key = [object diffIdentifier];
    return key;
}

static id GDiffProcessor (NSArray<id<GDiffObjectProtocol>> *oldArray,
                          NSArray<id<GDiffObjectProtocol>> *newArray,
                          GDiffOption option) {
    
    NSInteger oldCount = oldArray.count;
    NSInteger newCount = newArray.count;
  
    unordered_map<id<NSObject>, GDiffEntry, GDiffHashID, GDiffEqualID> table;
    
    /// 1.为newarray中的每个数据创建一个diffEntry
    vector<GDiffRecord> newResultsArray(newCount);
    for (NSInteger i = 0; i < newCount; i++) {
        id<NSObject> key = GDiffTableKey(newArray[i]);
        GDiffEntry &entry = table[key];
        entry.newCounter++;
        entry.oldIndexs.push(NSNotFound);
        
        newResultsArray[i].entry = &entry;
    }
    // 2,为oldArray中的数据 更新或者新建diffEntry

    vector<GDiffRecord> oldResultsArray(oldCount);
    for (NSInteger i = 0; i < oldCount; i++) {
        id<NSObject> key = GDiffTableKey(oldArray[i]);
        GDiffEntry &entry = table[key];
        entry.oldCounter++;
        entry.oldIndexs.push(i);
        
        oldResultsArray[i].entry = &entry;
    }
    
    /// 3.在一个数组中处理i
    for (NSInteger i = 0; i<newCount; i++) {
        GDiffEntry *entry = newResultsArray[i].entry;
        
         NSCAssert(!entry->oldIndexs.empty(), @"Old indexes is empty while iterating new item %zi. Should have NSNotFound", i);
        const NSInteger originalIndex = entry->oldIndexs.top();
        entry->oldIndexs.pop();
        
        if (originalIndex < oldCount) {
            const id<GDiffObjectProtocol> newTemp = newArray[i];
            const id<GDiffObjectProtocol> oldTemp = oldArray[originalIndex];
            switch (option) {
                case GDiffOptionEquality:
                    if (![newTemp isEqual:oldTemp]) {
                        entry->update = YES;
                    }
                    break;
                    
                case GDiffOptionPointerPersonality:
                    
                    if (newTemp != oldTemp) {
                        entry->update = YES;
                    }
                    break;
                default:
                    break;
            }
            
            if (originalIndex != NSNotFound
                && entry->newCounter > 0
                && entry->oldCounter > 0) {
                //如果项目出现在新数组和旧数组中，则它是唯一的
                //将新记录和旧记录的索引分配给相反的索引(反向查找)
                newResultsArray[i].index = originalIndex;
                oldResultsArray[originalIndex].index = i;
            }
        }
    }
        
        id Inserts = [NSMutableArray new];
        id Moves = [NSMutableArray new];
        id Updates = [NSMutableArray new];
        id Deletes = [NSMutableArray new];
  
        void (^addIndexToCollection)(id, NSInteger, id) = ^(id collection, NSInteger index, id obj) {
            if (obj) {
                [collection addObject:obj];
            }  else {
                [collection addObject:@(index)];
            }
        };
        NSMapTable *oldMap = [NSMapTable strongToStrongObjectsMapTable];
        NSMapTable *newMap = [NSMapTable strongToStrongObjectsMapTable];
        
        void (^addIndexToMap)(NSInteger, NSArray *, NSMapTable *) = ^(NSInteger index, NSArray *array, NSMapTable *map) {
            id value = @(index);
            [map setObject:value forKey:[array[index] diffIdentifier]];
        };
        
        vector<NSInteger> deleteOffsets(oldCount), insertOffsets(newCount);
        NSInteger runningOffset = 0;

        // 重复检查删除旧数组记录
        for (NSInteger i = 0; i < oldCount; i++) {
            deleteOffsets[i] = runningOffset;
            const GDiffRecord record = oldResultsArray[i];
            
            if (record.index == NSNotFound) {
                addIndexToCollection(Deletes, i, nil);
                runningOffset++;
            }
            
            addIndexToMap(i, oldArray, oldMap);
        }
        
        // 重置 已经从插入项
        runningOffset = 0;
        for (NSInteger i = 0; i < newCount; i++) {
            insertOffsets[i] = runningOffset;
            const GDiffRecord record = newResultsArray[i];
            const NSInteger oldIndex = record.index;
        
            if (record.index == NSNotFound) {
                addIndexToCollection(Inserts, i, nil);
                runningOffset++;
            } else {
                // updated /and/ moved
                if (record.entry->update) {
                    addIndexToCollection(Updates, oldIndex, nil);
                }
                
                
                // 计算偏移量和确定其是否有移动
                const NSInteger insertOffset = insertOffsets[i];
                const NSInteger deleteOffset = deleteOffsets[oldIndex];
                if ((oldIndex - deleteOffset + insertOffset) != i) {
                  GDiffMoveItem*  move = [[GDiffMoveItem alloc] initWithFrom:oldIndex to:i];
                    addIndexToCollection(Moves, NSNotFound, move);
                }
            }
            addIndexToMap( i, newArray, newMap);
        }
        
    NSCAssert((oldCount + [Inserts count] - [Deletes count]) == newCount,
                  @"Sanity check failed applying %zi inserts and %zi deletes to old count %zi equaling new count %zi",
                  oldCount, [Inserts count], [Deletes count], newCount);
    
   
    return [[GDiffResult alloc] initWithInserts:Inserts deletes:Deletes updates:Updates moves:Moves oldIndexPathMap:oldMap newIndexPathMap:newMap];
    
}

@implementation GDiffCore

- (GDiffResult*)diff:(NSArray*)oldArray newArray:(NSArray*)newArray
{
    return GDiffProcessor(oldArray, newArray, GDiffOptionEquality);
}
@end
