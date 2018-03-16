//
//  ViewController.m
//  GDiffExample
//
//  Created by GIKI on 2018/3/11.
//  Copyright © 2018年 GIKI. All rights reserved.
//

#import "ViewController.h"
#import "GDiffCore.h"
#import "GTestItem.h"
@interface ViewController ()
@property (nonatomic, strong) NSArray   *oldArray;
@property (nonatomic, strong) NSArray  *nArray;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.oldArray = @[createTest(@"1", 3),createTest(@"1", 3),createTest(@"1", 3),createTest(@"3", 1),createTest(@"4", 1),createTest(@"6", 1),createTest(@"1", 3),createTest(@"1", 3),createTest(@"1", 3),createTest(@"3", 1),createTest(@"4", 1),createTest(@"6", 1),createTest(@"1", 3),createTest(@"1", 3),createTest(@"1", 3),createTest(@"3", 1),createTest(@"4", 1),createTest(@"6", 1)];
    self.nArray = @[createTest(@"1", 1),createTest(@"1", 1),createTest(@"1246", 3),createTest(@"4234", 1)];
    

}


- (IBAction)btnClick:(id)sender {
    
    double StartTime = CACurrentMediaTime();
    GDiffCore *diff = [GDiffCore new];
    GDiffResult *result = [diff diff:self.oldArray newArray:self.nArray];
    double launchTime = (CACurrentMediaTime() - StartTime);
    
    printf("❤️❤️❤️❤️❤️❤️❤️❤️❤️❤️❤️❤️❤️❤️❤️main_start_Time:%f ms❤️❤️❤️❤️❤️❤️❤️❤️❤️❤️❤️❤️❤️❤️❤️\n",launchTime);
    NSLog(@"test");
}


@end
