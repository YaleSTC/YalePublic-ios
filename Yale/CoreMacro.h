//
//  CoreHeader.h
//  Yale
//
//  Created by Hengchu Zhang on 12/2/14.
//  Copyright (c) 2014 Hengchu Zhang. All rights reserved.
//

#ifndef Yale_CoreMacro_h
#define Yale_CoreMacro_h

#if DEBUG
#define DLog(format, ...) NSLog((format), ## __VA_ARGS__)
#else
#define DLog(format, ...)
#endif

#endif
