//
//  OAUClock.m
//  Pods
//
//  Created by Austin Ugbeme on 10/14/15.
//
//

#import "OAUClock.h"

static const NSUInteger HOUR_HAND_WIDTH = 3.f;
static const NSUInteger MIN_HAND_WIDTH = 2.f;
static const NSUInteger SEC_HAND_WIDTH = 1.f;

static inline CGAffineTransform CGPointRotateAboutPivotTransform(CGPoint p, CGPoint pivot, CGFloat degrees);
static inline CGFloat DegreesToRadians(CGFloat degrees);
static inline CGPoint CGPointRotateAboutPivot(CGPoint p, CGPoint pivot, CGFloat degrees);

@interface OAUClock ()
@property (nonatomic, strong) UILabel *meridiesLabel;
@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, strong) CAShapeLayer *hourHandLayer;
@property (nonatomic, strong) CAShapeLayer *minuteHandLayer;
@property (nonatomic, strong) CAShapeLayer *secondsHandLayer;
@property (nonatomic) BOOL isAM;
@end

@implementation OAUClock

+ (void)drawText:(NSString *)text withFont:(UIFont *)font inRect:(CGRect)rect usingColor:(UIColor *)color
{
    NSMutableParagraphStyle *paragraphStyle = [NSMutableParagraphStyle new];
    paragraphStyle.alignment = NSTextAlignmentCenter;
    NSDictionary *stringAttribs = @{
        NSFontAttributeName : font,
        NSForegroundColorAttributeName : color,
        NSBackgroundColorAttributeName : [UIColor clearColor],
        NSParagraphStyleAttributeName : paragraphStyle
    };
    [text drawInRect:rect withAttributes:stringAttribs];
}

+ (UIColor *)colorFromRGBHex:(NSUInteger)hexColor withAlpha:(CGFloat)alpha
{
    const CGFloat red = ((hexColor & 0xFF0000) >> 16) / 255.f;
    const CGFloat green = ((hexColor & 0xFF00) >> 8) / 255.f;
    const CGFloat blue = (hexColor & 0xFF) / 255.f;
    return [UIColor colorWithRed:red green:green blue:blue alpha:alpha];
}

+ (void)strokePathBetweenPoints:(CGPoint)p1 point:(CGPoint)p2 lineWidth:(CGFloat)width color:(UIColor *)color
{
    UIBezierPath *path = [UIBezierPath bezierPath];
    [path setLineWidth:width];
    [path moveToPoint:p1];
    [path addLineToPoint:p2];
    path.lineCapStyle = kCGLineCapSquare;
    [color set];
    [path strokeWithBlendMode:kCGBlendModeNormal alpha:1.f];
}

+ (CAShapeLayer *)createAndConfigureShapeLayerWithWidth:(CGFloat)width andColor:(UIColor *)color
{
    CAShapeLayer *layer = [CAShapeLayer layer];
    layer.strokeColor = color.CGColor;
    layer.lineWidth = width;
    layer.fillColor = color.CGColor;
    layer.lineCap = kCALineCapRound;
    return layer;
}

- (void)addShadowWithRadius:(CGFloat)radius
{
    NSAssert1(radius > 1.f, @"Invalid provided radius: %f", radius);
    self.layer.shadowColor = [UIColor blackColor].CGColor;
    self.layer.shadowOffset = CGSizeMake(radius - 1.f, radius - 1.f);
    self.layer.shadowOpacity = .8f;
    self.layer.shadowRadius = radius;
    
    // Ensure if corner radius was applied, that the shadow follows the same rounded path as the corner radius.
    if (self.layer.cornerRadius) {
        self.layer.shadowPath = [UIBezierPath bezierPathWithRoundedRect:self.bounds cornerRadius:self.layer.cornerRadius].CGPath;
    }
}

- (UIBezierPath *)bezierPathForHourHandWithWidth:(CGFloat)width
{
    CGFloat midX = CGRectGetMidX(self.bounds) - ceil(width / 2);
    CGFloat midY = CGRectGetMidY(self.bounds);
    CGPoint center = CGPointMake(midX, midY);

    CGFloat hrDegrees = self.hour != 12 ? 30.f * ((CGFloat)self.hour + ((CGFloat)self.minute / 60.f)) : 0.f;
    CGPoint startPt = CGPointMake(midX, LONG_GRADUATION_LENGTH + NUMBER_RECT_WIDTH + 30.f);
    CGPoint endPt = CGPointMake(midX, midY + 5.f);
    UIBezierPath *path = [UIBezierPath bezierPathWithRect:CGRectMake(startPt.x, startPt.y, 2.f, endPt.y - startPt.y)];
    [path applyTransform:CGPointRotateAboutPivotTransform(startPt, center, hrDegrees)];
    return path;
}

- (UIBezierPath *)bezierPathForMinuteHandWithWidth:(CGFloat)width
{
    CGFloat midX = CGRectGetMidX(self.bounds) - ceil(width / 2);
    CGFloat midY = CGRectGetMidY(self.bounds);
    CGPoint center = CGPointMake(midX, midY);

    CGFloat minDegrees = 6.f * self.minute;
    CGPoint startPt = CGPointMake(midX, LONG_GRADUATION_LENGTH + NUMBER_RECT_WIDTH + 5.f);
    CGPoint endPt = CGPointMake(midX, midY + 5.f);
    UIBezierPath *path = [UIBezierPath bezierPathWithRect:CGRectMake(startPt.x, startPt.y, 2.f, endPt.y - startPt.y)];
    [path applyTransform:CGPointRotateAboutPivotTransform(startPt, center, minDegrees)];
    return path;
}

- (UIBezierPath *)bezierPathForSecondHandWithWidth:(CGFloat)width
{
    CGFloat midX = CGRectGetMidX(self.bounds) - ceil(width / 2);
    CGFloat midY = CGRectGetMidY(self.bounds);
    CGPoint center = CGPointMake(midX, midY);

    CGFloat secsDegrees = 6.f * self.seconds;
    CGPoint startPt = CGPointMake(midX, LONG_GRADUATION_LENGTH + NUMBER_RECT_WIDTH + 5.f);
    CGPoint endPt = CGPointMake(midX, midY + 7.f);
    UIBezierPath *path = [UIBezierPath bezierPathWithRect:CGRectMake(startPt.x, startPt.y, 1.f, endPt.y - startPt.y)];
    [path applyTransform:CGPointRotateAboutPivotTransform(startPt, center, secsDegrees)];
    return path;
}

- (void)updateCurrentTime
{
    NSDate *date = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"h:mm:ss";
    NSString *dateString = [dateFormatter stringFromDate:date];
    NSArray *comps = [dateString componentsSeparatedByString:@":"];
    
    NSAssert1(comps.count == 3, @"3 components expected. Found %d", (int)comps.count);
    
    self.hour = [comps[0] integerValue];
    self.minute = [comps[1] integerValue];
    self.seconds = [comps[2] integerValue];
    
    //    NSLog(@"Current time is: %d:%d:%2d %@", (int)self.hour, (int)self.minute, (int)self.seconds, self.isAM ? @"AM" : @"PM");
}

- (void)performCommonInit:(CGRect)rect
{
    self.backgroundColor = [UIColor clearColor];
    
    // Default time is 10:10:30 AM
    self.hour = 10;
    self.minute = 10;
    self.seconds = 30;
    
    self.showMeridies = YES;
    self.meridiesColor = [OAUClock colorFromRGBHex:0xE9967A withAlpha:1.f];
    self.isAM = YES;

    self.showNumbers = YES;
    self.numbersColor = [UIColor grayColor];
    
    self.realtime = YES;
    
    self.faceColor = [OAUClock colorFromRGBHex:0xFFFDD0 withAlpha:1.f];
    
    self.showGraduations = YES;
    self.graduationsColor = [OAUClock colorFromRGBHex:0x008080 withAlpha:1.f];
    
    self.borderColor = [OAUClock colorFromRGBHex:0x008080 withAlpha:1.f];
    self.borderWidth = 3.f;
    
    [self addShadowWithRadius:2.f];

    self.hourHandLayer = [OAUClock createAndConfigureShapeLayerWithWidth:HOUR_HAND_WIDTH andColor:[UIColor grayColor]];
    [self.layer addSublayer:self.hourHandLayer];
    
    self.minuteHandLayer = [OAUClock createAndConfigureShapeLayerWithWidth:MIN_HAND_WIDTH andColor:[UIColor grayColor]];
    [self.layer addSublayer:self.minuteHandLayer];
    
    self.secondsHandLayer = [OAUClock createAndConfigureShapeLayerWithWidth:SEC_HAND_WIDTH andColor:[OAUClock colorFromRGBHex:0x800000 withAlpha:1.f]];
    [self.layer addSublayer:self.secondsHandLayer];
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    [self performCommonInit:self.frame];
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self performCommonInit:frame];
    }
    return self;
}

- (void)drawClockFaceWithContext:(CGContextRef)context inRect:(CGRect)rect
{
    CGContextAddEllipseInRect(context, rect);
    CGContextSetFillColorWithColor(context, self.faceColor.CGColor);
    CGContextSetAlpha(context, 1.f);
    CGContextFillPath(context);
}

- (void)drawBorderInRect:(CGRect)rect
{
    self.layer.borderWidth = self.borderWidth;
    self.layer.borderColor = self.borderColor.CGColor;
    self.layer.cornerRadius = CGRectGetWidth(rect) / 2;
    self.layer.rasterizationScale = 2.0 * [UIScreen mainScreen].scale;
    self.layer.shouldRasterize = YES;
}

- (void)drawMeridiesTextInRect:(CGRect)rect
{
    if (self.showMeridies) {
        NSString *meridiesString = [NSString stringWithFormat:@"%@", self.isAM ? @"AM" : @"PM"];
        const CGRect meridiesRect = CGRectMake(CGRectGetMaxX(rect) - 40.f, CGRectGetMidY(rect) - 5.f, 20.f, 10.f);
        UIFont *font = [UIFont fontWithName:@"Avenir" size:9.f];
        [OAUClock drawText:meridiesString withFont:font inRect:meridiesRect usingColor:self.meridiesColor];
    }
}

static const NSUInteger GRADUATION_START = 5.f;
static const NSUInteger GRADUATION_LENGTH = 9.f;
static const NSUInteger LONG_GRADUATION_LENGTH = 12.f;
static const CGFloat NUMBER_RECT_WIDTH = 25.f;

- (void)drawGraduationsAndNumbersInRect:(CGRect)rect
{
    CGFloat y1 = GRADUATION_START;
    CGPoint center = CGPointMake(CGRectGetMidX(rect), CGRectGetMidY(rect));
    for (int graduation = 0; graduation < 60; ++graduation) {
        const BOOL isQuarterHour = graduation % 15 == 0;
        const BOOL isHour = graduation % 5 == 0;
        CGFloat y2 = isQuarterHour || isHour ? LONG_GRADUATION_LENGTH : GRADUATION_LENGTH;
        CGPoint p1 = CGPointMake(CGRectGetWidth(rect) / 2, y1);
        CGPoint p2 = CGPointMake(CGRectGetWidth(rect) / 2, y2);
        
        CGPoint p1Rot = CGPointRotateAboutPivot(p1, center, 6.f * graduation);
        CGPoint p2Rot = CGPointRotateAboutPivot(p2, center, 6.f * graduation);
        
        CGFloat lineWidth = 1.f;
        if (isHour) {
            lineWidth = 2.f;
        }
        if (isQuarterHour) {
            lineWidth = 3.f;
        }
        
        const BOOL strokeLinePath = (isQuarterHour || isHour) ||
            ((!isQuarterHour && !isHour) && self.showGraduations);
        
        if (strokeLinePath) {
            [OAUClock strokePathBetweenPoints:p1Rot
                                        point:p2Rot
                                    lineWidth:lineWidth
                                        color:self.graduationsColor];
        }
        
        if (self.showNumbers && isHour) {
            if (graduation == 15 && self.showMeridies) {
                continue;
            }
            
            const CGPoint pt = CGPointMake(p2.x, p2.y + LONG_GRADUATION_LENGTH);
            const CGPoint ptRot = CGPointRotateAboutPivot(pt, center, 6.f * graduation);
            CGRect rect = CGRectMake(ptRot.x, ptRot.y, NUMBER_RECT_WIDTH, NUMBER_RECT_WIDTH);
            rect = CGRectOffset(rect, -NUMBER_RECT_WIDTH / 2.f, -NUMBER_RECT_WIDTH / 2.f);
            UIFont *font = [UIFont fontWithName:@"Avenir" size:18.f];
            NSString *text = [NSString stringWithFormat:@"%d", graduation == 0 ? 12 : graduation / 5];
            
            [OAUClock drawText:text withFont:font inRect:rect usingColor:self.numbersColor];
        }
        
    }
}

- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
    [self drawClockFaceWithContext:UIGraphicsGetCurrentContext() inRect:rect];
    [self drawBorderInRect:rect];
    [self drawMeridiesTextInRect:rect];
    [self drawGraduationsAndNumbersInRect:rect];
    
    if (self.realtime && !self.timer) {
        self.timer = [NSTimer scheduledTimerWithTimeInterval:1.f target:self selector:@selector(updateTime:) userInfo:nil repeats:YES];
        [self.timer fire];
    } else {
        self.hourHandLayer.path = [self bezierPathForHourHandWithWidth:HOUR_HAND_WIDTH].CGPath;
        self.minuteHandLayer.path = [self bezierPathForMinuteHandWithWidth:MIN_HAND_WIDTH].CGPath;
        self.secondsHandLayer.path = [self bezierPathForSecondHandWithWidth:SEC_HAND_WIDTH].CGPath;
    }
}

- (void)updateTime:(id)sender
{
    if (self.realtime) {
        [self updateCurrentTime];
        self.hourHandLayer.path = [self bezierPathForHourHandWithWidth:HOUR_HAND_WIDTH].CGPath;
        self.minuteHandLayer.path = [self bezierPathForMinuteHandWithWidth:MIN_HAND_WIDTH].CGPath;
        self.secondsHandLayer.path = [self bezierPathForSecondHandWithWidth:SEC_HAND_WIDTH].CGPath;
    }
}
@end

static inline CGFloat DegreesToRadians(CGFloat degrees)
{
    return degrees * M_PI / 180.f;
}

static inline CGAffineTransform CGPointRotateAboutPivotTransform(CGPoint p, CGPoint pivot, CGFloat degrees)
{
    CGAffineTransform t = CGAffineTransformMakeTranslation(pivot.x, pivot.y);
    CGAffineTransform r = CGAffineTransformMakeRotation(DegreesToRadians(degrees));
    CGAffineTransform c = CGAffineTransformConcat(CGAffineTransformConcat( CGAffineTransformInvert(t), r), t);
    return c;
}

static inline CGPoint CGPointRotateAboutPivot(CGPoint p, CGPoint pivot, CGFloat degrees)
{
    CGAffineTransform c = CGPointRotateAboutPivotTransform(p, pivot, degrees);
    return CGPointApplyAffineTransform(p, c);
}
