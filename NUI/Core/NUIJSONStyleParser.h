//
//  NUIJSONStyleParser.h
//  NUIDemo
//
//  Created by sgl on 13-7-18.
//  Copyright (c) 2013年 Tom Benner. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NUIJSONStyleParser : NSObject

- (NSMutableDictionary*)getStylesFromFile:(NSString*)fileName;
- (NSMutableDictionary*)getStylesFromPath:(NSString*)path;

@end
