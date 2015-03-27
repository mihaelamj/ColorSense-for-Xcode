//
//  OMColorType.h
//  OMColorSense
//
//  Created by Mihaela Mihaljević Jakić on 27/03/15.
//
//

#ifndef OMColorSense_OMColorType_h
#define OMColorSense_OMColorType_h

typedef enum OMColorType {
    OMColorTypeNone = 0,
    
    OMColorTypeUIRGBA,				//[UIColor colorWithRed:1.0 green:0.0 blue:0.0 alpha:1.0]
    OMColorTypeUIRGBAInit,			//[[UIColor alloc] initWithRed:1.0 green:0.0 blue:0.0 alpha:1.0]
    OMColorTypeUIWhite,				//[UIColor colorWithWhite:0.5 alpha:1.0]
    OMColorTypeUIWhiteInit,			//[[UIColor alloc] initWithWhite:0.5 alpha:1.0]
    OMColorTypeUIConstant,			//[UIColor redColor]
    
    OMColorTypeNSRGBACalibrated,	//[NSColor colorWithCalibratedRed:1.0 green:0.0 blue:0.0 alpha:1.0]
    OMColorTypeNSRGBADevice,		//[NSColor colorWithDeviceRed:1.0 green:0.0 blue:0.0 alpha:1.0]
    OMColorTypeNSWhiteCalibrated,	//[NSColor colorWithCalibratedWhite:0.5 alpha:1.0]
    OMColorTypeNSWhiteDevice,		//[NSColor colorWithDeviceWhite:0.5 alpha:1.0]
    OMColorTypeNSConstant,			//[NSColor redColor]
    
    OMColorTypeCount
    
} OMColorType;

#endif
