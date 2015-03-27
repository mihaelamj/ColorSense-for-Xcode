//
//  ColorRegex.h
//  OMColorSense
//
//  Created by Mihaela Mihaljević Jakić on 27/03/15.
//
//

#import <Foundation/Foundation.h>

//color types
#import "OMColorType.h"

//for NSColor
#import <AppKit/AppKit.h>

@interface ColorRegex : NSObject

@property (nonatomic, readonly) OMColorType colorType;

- (instancetype)initWithColorType:(OMColorType)colorType;

+ (NSColor *)colorInText:(NSString *)text selectedRange:(NSRange)selectedRange type:(OMColorType *)type matchedRange:(NSRangePointer)matchedRange;
+ (NSString *)colorStringForColor:(NSColor *)color withType:(OMColorType)colorType;
+ (NSDictionary *)constantColors;

@end
