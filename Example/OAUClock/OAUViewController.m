//
//  OAUViewController.m
//  OAUClock
//
//  Created by Austin Ugbeme on 10/14/2015.
//  Copyright (c) 2015 Austin Ugbeme. All rights reserved.
//

#import "OAUViewController.h"

#import "OAUClock.h"

@interface OAUViewController ()
@property (nonatomic, weak) IBOutlet OAUClock *clock;
@end

@implementation OAUViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
//    self.clock.showMeridies = YES;
//    self.clock.realtime = NO;
//    self.clock.date = [OAUClock dateFromString:@"12:45:10"];
//    self.clock.showGraduations = NO;
//    self.clock.showMeridies = YES;
//    self.clock.showNumbers = NO;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
