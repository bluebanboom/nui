//
//  NUIJSONStyleParser.m
//  NUIDemo
//
//  Created by sgl on 13-7-18.
//  Copyright (c) 2013年 Tom Benner. All rights reserved.
//

#import "NUIJSONStyleParser.h"
#import "JSONKit.h"

@implementation NUIJSONStyleParser

- (NSMutableDictionary*)getStylesFromFile:(NSString*)fileName
{
    NSString* path = [[NSBundle mainBundle] pathForResource:fileName ofType:@"json"];
    NSAssert1(path != nil, @"File \"%@\" does not exist", fileName);
    NSString* content = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
    id jsonData = [content objectFromJSONString];
    return [self consolidateRuleSets:[self getRuleSets:jsonData] withTopLevelDeclarations:[self getTopLevelDeclarations:jsonData]];
}

- (NSMutableDictionary*)getStylesFromPath:(NSString*)path
{
    NSString* content = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
    return [self consolidateRuleSets:[self getRuleSets:content] withTopLevelDeclarations:[self getTopLevelDeclarations:content]];
}

- (NSMutableDictionary*)getTopLevelDeclarations:(id)content
{
    return [content objectForKey:@"Declarations"];
}

- (NSMutableArray*)getRuleSets:(id)content
{
    id jsonData = [content objectForKey:@"RuleSets"];
    NSArray *keys = [jsonData allKeys];
    NSMutableArray *ruleSets = [[NSMutableArray alloc] init];
    for (id one in keys ) {
        NSString *classExpression = one;
        NSMutableDictionary *declarations = [jsonData objectForKey:one];
        NSDictionary *ruleSet = [NSDictionary dictionaryWithObjectsAndKeys:
                                 classExpression, @"classExpression",
                                 declarations, @"declarations",
                                 nil];
        [ruleSets addObject:ruleSet];
    }
    return ruleSets;
}

- (NSMutableDictionary*)consolidateRuleSets:(NSMutableArray*)ruleSets withTopLevelDeclarations:(NSMutableDictionary*)topLevelDeclarations
{
    NSMutableDictionary *consolidatedRuleSets = [[NSMutableDictionary alloc] init];
    for (NSMutableDictionary *ruleSet in ruleSets) {
        NSString *classExpression = [ruleSet objectForKey:@"classExpression"];
        NSArray *classes = [self getClassesFromClassExpression:classExpression];
        for (NSString *class in classes) {
            if ([consolidatedRuleSets objectForKey:class] == nil) {
                [consolidatedRuleSets setValue:[[NSMutableDictionary alloc] init] forKey:class];
            }
            [self mergeRuleSetIntoConsolidatedRuleSet:ruleSet consolidatedRuleSet:[consolidatedRuleSets objectForKey:class] topLevelDeclarations:topLevelDeclarations];
        }
    }
    return consolidatedRuleSets;
}

- (NSMutableDictionary*)mergeRuleSetIntoConsolidatedRuleSet:(NSMutableDictionary*)ruleSet consolidatedRuleSet:(NSMutableDictionary*)consolidatedRuleSet topLevelDeclarations:(NSMutableDictionary*)topLevelDeclarations
{
    NSMutableDictionary *declarations = [ruleSet objectForKey:@"declarations"];
    for (NSString *property in declarations) {
        NSString *value = [declarations objectForKey:property];
        if ([value hasPrefix:@"@"]) {
            value = [topLevelDeclarations objectForKey:value];
        }
        [consolidatedRuleSet setValue:value forKey:property];
    }
    return consolidatedRuleSet;
}

- (NSArray*)getClassesFromClassExpression:(NSString*)classExpression
{
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@",[\\s]*" options:0 error:nil];
    NSString *modifiedClassExpression = [regex stringByReplacingMatchesInString:classExpression options:0 range:NSMakeRange(0, [classExpression length]) withTemplate:@", "];
    NSArray *separatedClasses = [modifiedClassExpression componentsSeparatedByString:@", "];
    NSMutableArray *classes = [[NSMutableArray alloc] init];
    for (NSString *class in separatedClasses) {
        [classes addObject:[class stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]];
    }
    return classes;
}

@end
