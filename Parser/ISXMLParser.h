//
//  ISXMLParser.h
//  Parser
//
//  Created by Ivan Sadikov on 4/07/14.
//  Copyright (c) 2014 Ivan Sadikov. All rights reserved.
//

#import <Foundation/Foundation.h>

// tags used for xml parser
#define XML_TAG_MAIN    @"ISXMLPARSER_MAIN"
#define ENTITIES        @"ISXMLPARSER_ENTITIES"
#define QUALIFIED_NAME  @"ISXMLPARSER_QUALIFIED_NAME"
#define ELEMENT_TEXT    @"ISXMLPARSER_ELEMENT_TEXT"

@protocol ISXMLParserDelegate;

@interface ISXMLParser : NSObject

@property (nonatomic, weak) id <ISXMLParserDelegate> delegate;

- (id)initWithData:(NSData *)data;
- (void)startParsing;
- (void)cancelParsing;
@end

// protocol for ISXMLParser
@protocol ISXMLParserDelegate
@required
- (void)parserDidStartParsingData:(ISXMLParser *)parser;
- (void)parser:(ISXMLParser *)parser didFinishParsingWithResult:(NSDictionary *)result;
- (void)parser:(ISXMLParser *)parser didFailWithError:(NSError *)error;
@end

