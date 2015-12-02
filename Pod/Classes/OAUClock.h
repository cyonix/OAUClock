//
//  OAUClock.h
//  Pods
//
//  Created by Austin Ugbeme on 10/14/15.
//
//

@import Foundation;
@import UIKit;

@interface OAUClock : UIView

// Set/Get current time as a `date`
@property (nonatomic, strong) NSDate *date;

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

// Convenient method to construct a date from a string (in hh:mm:ss format)
+ (NSDate *)dateFromString:(NSString *)dateString;

@end
