//
//  ColorRegex.m
//  OMColorSense
//
//  Created by Mihaela Mihaljević Jakić on 27/03/15.
//
//

#import "ColorRegex.h"

//for NSColor
#import <AppKit/AppKit.h>

@interface ColorRegex ()

@property (nonatomic, strong) NSRegularExpression *regex;

@end

@implementation ColorRegex

#pragma mark -
#pragma mark Init

- (instancetype)initWithColorType:(OMColorType)colorType
{
    self = [super init];
    if (self) {
        _colorType = colorType;
    }
    return self;
}

#pragma mark -
#pragma mark Public Methods

+ (NSColor *)colorInText:(NSString *)text selectedRange:(NSRange)selectedRange type:(OMColorType *)type matchedRange:(NSRangePointer)matchedRange
{
    NSColor *foundColor = nil;
    NSRange foundColorRange = NSMakeRange(NSNotFound, 0);
    OMColorType foundColorType = OMColorTypeNone;
    
    for (ColorRegex *colorRegex in [self regexArray]) {
        foundColor = [colorRegex colorInText:text selectedRange:selectedRange type:&foundColorType matchedRange:&foundColorRange];
        if (foundColor) {
            break;
        }
    }
    
    *type = foundColorType;
    *matchedRange = foundColorRange;
    return foundColor;
}


#pragma mark -
#pragma mark Private Methods

- (NSColor *)colorInText:(NSString *)text selectedRange:(NSRange)selectedRange type:(OMColorType *)type matchedRange:(NSRangePointer)matchedRange
{
    __block NSColor *foundColor = nil;
    __block NSRange foundColorRange = NSMakeRange(NSNotFound, 0);
    __block OMColorType foundColorType = OMColorTypeNone;
    
    [self.regex enumerateMatchesInString:text options:0 range:NSMakeRange(0, text.length) usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
        
        NSRange colorRange = [result range];
        
        if (selectedRange.location >= colorRange.location && NSMaxRange(selectedRange) <= NSMaxRange(colorRange)) {
            
            switch (self.colorType) {
                    
                case OMColorTypeUIRGBA:
                case OMColorTypeUIRGBAInit:
                case OMColorTypeNSRGBACalibrated:
                case OMColorTypeNSRGBADevice: {
                    
                    CGFloat red, green, blue, alpha;
                    [self fetchColorType:&foundColorType red:&red green:&green blue:&blue alpha:&alpha text:text result:result];
                    if (foundColorType == OMColorTypeNSRGBADevice) {
                        foundColor = [NSColor colorWithDeviceRed:red green:green blue:blue alpha:alpha];
                    } else {
                        foundColor = [NSColor colorWithCalibratedRed:red green:green blue:blue alpha:alpha];
                    }
                    foundColorRange = colorRange;
                }
                    break;
                    
                case OMColorTypeUIWhite:
                case OMColorTypeUIWhiteInit:
                case OMColorTypeNSWhiteCalibrated:
                case OMColorTypeNSWhiteDevice: {
                    
                    CGFloat white, alpha;
                    [self fetchColorType:&foundColorType white:&white alpha:&alpha text:text result:result];
                    if (foundColorType == OMColorTypeNSWhiteDevice) {
                        foundColor = [NSColor colorWithDeviceWhite:white alpha:alpha];
                    } else {
                        foundColor = [NSColor colorWithCalibratedWhite:white alpha:alpha];
                    }
                    foundColorRange = colorRange;
                }
                    break;
                    
                case OMColorTypeUIConstant:
                case OMColorTypeNSConstant: {
                    //implement
                }
                    
                default:
                    break;
            }
            
            *stop = YES;
        }
    }];
    
    if (foundColor) {
        if (matchedRange != NULL) {
            *matchedRange = foundColorRange;
        }
        if (type != NULL) {
            *type = foundColorType;
        }
        return foundColor;
    }
    
    return nil;
}

- (void)fetchColorType:(OMColorType *)colorType red:(CGFloat *)red green:(CGFloat *)green blue:(CGFloat *)blue alpha:(CGFloat *)alpha text:(NSString *)text result:(NSTextCheckingResult *)result
{
    NSString *typeIndicator = [text substringWithRange:[result rangeAtIndex:1]];
    *colorType = [self colorTypeForText:typeIndicator];
    
    *red = [[text substringWithRange:[result rangeAtIndex:2]] doubleValue];
    *red = [ColorRegex dividedValue:*red withDivisorRange:[result rangeAtIndex:3] inString:text];
    
    *green = [[text substringWithRange:[result rangeAtIndex:4]] doubleValue];
    *green = [ColorRegex dividedValue:*green withDivisorRange:[result rangeAtIndex:5] inString:text];
    
    *blue = [[text substringWithRange:[result rangeAtIndex:6]] doubleValue];
    *blue = [ColorRegex dividedValue:*blue withDivisorRange:[result rangeAtIndex:7] inString:text];
    
    *alpha = [[text substringWithRange:[result rangeAtIndex:8]] doubleValue];
    *alpha = [ColorRegex dividedValue:*alpha withDivisorRange:[result rangeAtIndex:9] inString:text];
}

- (void)fetchColorType:(OMColorType *)colorType white:(CGFloat *)white alpha:(CGFloat *)alpha text:(NSString *)text result:(NSTextCheckingResult *)result
{
    NSString *typeIndicator = [text substringWithRange:[result rangeAtIndex:1]];
    *colorType = [self colorTypeForText:typeIndicator];
    
    *white = [[text substringWithRange:[result rangeAtIndex:2]] doubleValue];
    *white = [ColorRegex dividedValue:*white withDivisorRange:[result rangeAtIndex:3] inString:text];
				
    *alpha = [[text substringWithRange:[result rangeAtIndex:4]] doubleValue];
    *alpha = [ColorRegex dividedValue:*alpha withDivisorRange:[result rangeAtIndex:5] inString:text];
}

- (OMColorType)colorTypeForText:(NSString *)text
{
    if (self.colorType == OMColorTypeUIRGBA || self.colorType == OMColorTypeUIRGBAInit) {
        
        if ([text rangeOfString:@"init"].location != NSNotFound) {
            return OMColorTypeUIRGBAInit;
        } else {
            return OMColorTypeUIRGBA;
        }
        
    } else if (self.colorType == OMColorTypeNSRGBADevice || self.colorType == OMColorTypeNSRGBACalibrated) {
        
        if ([text isEqualToString:@"Device"]) {
            return OMColorTypeNSRGBADevice;
        } else {
            return OMColorTypeNSRGBACalibrated;
        }
        
    } else if (self.colorType == OMColorTypeUIWhiteInit || self.colorType == OMColorTypeUIWhite) {
        
        if ([text rangeOfString:@"init"].location != NSNotFound) {
            return OMColorTypeUIWhiteInit;
        } else {
            return OMColorTypeUIWhite;
        }
        
    } else if (self.colorType == OMColorTypeNSWhiteDevice || self.colorType == OMColorTypeNSWhiteCalibrated) {
        
        if ([text isEqualToString:@"Device"]) {
            return  OMColorTypeNSWhiteDevice;
        } else {
            return  OMColorTypeNSWhiteCalibrated;
        }
    }
    
    return OMColorTypeNone;
}


- (NSString *)stringForColorType:(OMColorType)colorType
{
    switch (colorType) {
            
        case OMColorTypeUIRGBA:
        case OMColorTypeUIRGBAInit:
            return @"(\\[\\s*UIColor\\s+colorWith|\\[\\s*\\[\\s*UIColor\\s+alloc\\]\\s*initWith)Red:\\s*([0-9]*\\.?[0-9]*f?)\\s*(\\/\\s*[0-9]*\\.?[0-9]*f?)?\\s+green:\\s*([0-9]*\\.?[0-9]*f?)\\s*(\\/\\s*[0-9]*\\.?[0-9]*f?)?\\s+blue:\\s*([0-9]*\\.?[0-9]*f?)\\s*(\\/\\s*[0-9]*\\.?[0-9]*f?)?\\s*alpha:\\s*([0-9]*\\.?[0-9]*f?)\\s*(\\/\\s*[0-9]*\\.?[0-9]*f?)?\\s*\\]";
            
        case OMColorTypeUIWhite:
        case OMColorTypeUIWhiteInit:
            return @"(\\[\\s*UIColor\\s+colorWith|\\[\\s*\\[\\s*UIColor\\s+alloc\\]\\s*initWith)White:\\s*([0-9]*\\.?[0-9]*f?)\\s*(\\/\\s*[0-9]*\\.?[0-9]*f?)?\\s+alpha:\\s*([0-9]*\\.?[0-9]*f?)\\s*(\\/\\s*[0-9]*\\.?[0-9]*f?)?\\s*\\]";

        case OMColorTypeNSRGBACalibrated:
        case OMColorTypeNSRGBADevice:
            return @"\\[\\s*NSColor\\s+colorWith(Calibrated|Device)Red:\\s*([0-9]*\\.?[0-9]*f?)\\s*(\\/\\s*[0-9]*\\.?[0-9]*f?)?\\s+green:\\s*([0-9]*\\.?[0-9]*f?)\\s*(\\/\\s*[0-9]*\\.?[0-9]*f?)?\\s+blue:\\s*([0-9]*\\.?[0-9]*f?)\\s*(\\/\\s*[0-9]*\\.?[0-9]*f?)?\\s+alpha:\\s*([0-9]*\\.?[0-9]*f?)\\s*(\\/\\s*[0-9]*\\.?[0-9]*f?)?\\s*\\]";
            
        case OMColorTypeNSWhiteCalibrated:
        case OMColorTypeNSWhiteDevice:
            return @"\\[\\s*NSColor\\s+colorWith(Calibrated|Device)White:\\s*([0-9]*\\.?[0-9]*f?)\\s*(\\/\\s*[0-9]*\\.?[0-9]*f?)?\\s+alpha:\\s*([0-9]*\\.?[0-9]*f?)\\s*(\\/\\s*[0-9]*\\.?[0-9]*f?)?\\s*\\]";
            
        case OMColorTypeUIConstant:
        case OMColorTypeNSConstant:
            return @"\\[\\s*(UI|NS)Color\\s+(black|darkGray|lightGray|white|gray|red|green|blue|cyan|yellow|magenta|orange|purple|brown|clear)Color\\s*\\]";
            
        default:
            return nil;
    }
}

+ (double)dividedValue:(double)value withDivisorRange:(NSRange)divisorRange inString:(NSString *)text
{
    if (divisorRange.location != NSNotFound) {
        double divisor = [[[text substringWithRange:divisorRange] stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"/ "]] doubleValue];
        if (divisor != 0) {
            value /= divisor;
        }
    }
    return value;
}

#pragma mark -
#pragma mark Private Properties

+ (NSArray *)regexArray
{
    static NSArray *_regexArray;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _regexArray = @[[[ColorRegex alloc] initWithColorType:OMColorTypeUIRGBA],
                        [[ColorRegex alloc] initWithColorType:OMColorTypeUIWhite],
                        [[ColorRegex alloc] initWithColorType:OMColorTypeNSRGBACalibrated],
                        [[ColorRegex alloc] initWithColorType:OMColorTypeNSWhiteCalibrated],
                        [[ColorRegex alloc] initWithColorType:OMColorTypeUIConstant]];

    });
    return _regexArray;
}

- (NSRegularExpression *)regex
{
    if (!_regex) {
        NSString *regexString = [self stringForColorType:self.colorType];
        _regex = [NSRegularExpression regularExpressionWithPattern:regexString options:0 error:nil];
    }
    return _regex;
}

@end
