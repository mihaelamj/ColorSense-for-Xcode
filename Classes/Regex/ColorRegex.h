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

@interface ColorRegex : NSObject

@property (nonatomic, readonly) OMColorType colorType;

- (instancetype)initWithColorType:(OMColorType)colorType;

@end
