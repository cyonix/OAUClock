//
//  OAUClock.h
//  Pods
//
//  Created by Austin Ugbeme on 10/14/15.
//
//

#import <UIKit/UIKit.h>

@interface OAUClock : UIView

// Get current hour
@property (nonatomic, readonly) NSInteger hour;

// Get current minute
@property (nonatomic, readonly) NSInteger minute;

// Get current seconds
@property (nonatomic, readonly) NSInteger seconds;

// Shows convenient AM/PM text
@property (nonatomic) BOOL showMeridies;
@property (nonatomic) UIColor *meridiesColor;

// Use numbers [1-12] instead of prominent tick marks at hour positions
@property (nonatomic) BOOL useNumbers;

// Allows for clock to track the real time
@property (nonatomic) BOOL isRealtime;

// Color for the clock face
@property (nonatomic) UIColor *faceColor;

// Graduations ON/OFF and associated color
@property (nonatomic) BOOL showGraduations;
@property (nonatomic) UIColor *graduationsColor;

// Border width and color
@property (nonatomic) CGFloat borderWidth;
@property (nonatomic) UIColor *borderColor;

@end
