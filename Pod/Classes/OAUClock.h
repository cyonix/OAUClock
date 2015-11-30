//
//  OAUClock.h
//  Pods
//
//  Created by Austin Ugbeme on 10/14/15.
//
//

#import <UIKit/UIKit.h>

@interface OAUClock : UIView

// Set/Get current hour
@property (nonatomic) NSInteger hour;

// Set/Get current minute
@property (nonatomic) NSInteger minute;

// Set/Get current seconds
@property (nonatomic) NSInteger seconds;

// AM/PM (ante/post meridien)
@property (nonatomic) BOOL showMeridies;
@property (nonatomic) UIColor *meridiesColor;
@property (nonatomic, readonly) BOOL isAM;

// Show numbers [1-12] at tick marks (hour positions)
@property (nonatomic) BOOL showNumbers;
@property (nonatomic) UIColor *numbersColor;

// Allows for clock to track the real time
@property (nonatomic, getter=isRealTime) BOOL realtime;

// Color for the clock face
@property (nonatomic) UIColor *faceColor;

// Graduations ON/OFF and associated color
@property (nonatomic) BOOL showGraduations;
@property (nonatomic) UIColor *graduationsColor;

// Border width and color
@property (nonatomic) CGFloat borderWidth;
@property (nonatomic) UIColor *borderColor;

@end
