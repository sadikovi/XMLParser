//
//  ISXMLParser.m
//  Parser
//
//  Created by Ivan Sadikov on 4/07/14.
//  Copyright (c) 2014 Ivan Sadikov. All rights reserved.
//

#import "ISXMLParser.h"

@interface ISXMLParser () <NSXMLParserDelegate>
// actual NSXMLParser instance
@property (nonatomic, strong) NSXMLParser *parser;
// response dictionary - result
@property (nonatomic, strong) NSMutableDictionary *responseDictionary;
// for text between tags
@property (nonatomic, readwrite) BOOL isCurrentProcessedData;
@property (nonatomic, strong) NSString *parsedBuffer;
// current processed element
@property (nonatomic, strong) NSMutableDictionary *currentProcessedElement;
// all opened elements for XML (main "root" element is in there by default)
@property (nonatomic, strong) NSMutableArray *openedElements;
// for current parent element
@property (nonatomic, strong) NSMutableArray *currentParentEntities;
@end

@implementation ISXMLParser

// opened elements for XML document
- (NSMutableArray *)openedElements {
    if (!_openedElements) {
        _openedElements = [[NSMutableArray alloc] init];
        [_openedElements addObject:self.responseDictionary];
    }
    
    return _openedElements;
}

// final NSDictionary to represent XML
- (NSMutableDictionary *)responseDictionary {
    if (!_responseDictionary) {
        _responseDictionary = [[NSMutableDictionary alloc] initWithObjectsAndKeys:XML_TAG_MAIN, XML_TAG_MAIN, nil];
        [_responseDictionary setObject:[NSMutableArray array] forKey:ENTITIES];
    }
    
    return _responseDictionary;
}

- (NSMutableDictionary *)currentProcessedElement {
    if (!_currentProcessedElement)  _currentProcessedElement = [NSMutableDictionary dictionary];
    return _currentProcessedElement;
}

- (id)lastElementInArray:(NSArray *)array {
    // fix things for iOS 4
    if ([array respondsToSelector:@selector(lastObject)]) {
        return [array lastObject];
    } else {
        if (![array count]) {
             return nil;
        } else {
             return [array objectAtIndex:([array count]-1)];
        }
    }
}

// current parent entities
// used to identify and fill children for ENTITIES tag
- (NSMutableArray *)currentParentEntities {
    NSDictionary *lastOpenedElement = [self lastElementInArray:self.openedElements];
    
    return (NSMutableArray *)[lastOpenedElement objectForKey:ENTITIES];
}

- (NSString *)parsedBuffer {
    if (!_parsedBuffer) _parsedBuffer = [NSString string];
    return _parsedBuffer;
}

- (void)setParser:(NSXMLParser *)parser {
    _parser = parser;
    self.responseDictionary = nil;
    self.parsedBuffer = nil;
    self.openedElements = nil;
}

#pragma mark - Main methods

- (void)initParserWithData:(NSData *)data {
    if (!self.parser) {
        self.parser = [[NSXMLParser alloc] initWithData:data];
    }
    self.parser.delegate = self;
    self.parser.shouldProcessNamespaces = YES;
}

- (id)initWithData:(NSData *)data {
    self = [super init];
    if (self) {
        [self initParserWithData:data];
    }
    
    return self;
}

- (void)setData:(NSData *)data {
    if (self.parser) {
        self.parser = nil;
    }
    
    [self initParserWithData:data];
}

- (void)startParsing {
    if (self.parser) [self.parser parse];
}

- (void)cancelParsing {
    if (self.parser) [self.parser abortParsing];
}

#pragma mark - XML Parser

- (void)parserDidStartDocument:(NSXMLParser *)parser {
    [self.delegate parserDidStartParsingData:self];
}

- (void)parserDidEndDocument:(NSXMLParser *)parser {
    [self.delegate parser:self didFinishParsingWithResult:self.responseDictionary];
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict {
    
    // create dictionary for current element
    NSMutableDictionary *elementDictionary = [NSMutableDictionary dictionaryWithDictionary:attributeDict];
    [elementDictionary setObject:[NSMutableArray array] forKey:ENTITIES];
    [elementDictionary setObject:qName forKey:QUALIFIED_NAME];
    
    self.currentProcessedElement = elementDictionary;
    [self.currentParentEntities addObject:elementDictionary];
    [self.openedElements addObject:elementDictionary];
    
    // start processing element text
    self.isCurrentProcessedData = YES;
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName {
    if (self.parsedBuffer) {
        if ([[self.currentProcessedElement objectForKey:QUALIFIED_NAME] isEqualToString:qName]) {
            [self.currentProcessedElement setObject:self.parsedBuffer forKey:ELEMENT_TEXT];
        }
    }
    
    self.parsedBuffer = nil;
    self.isCurrentProcessedData = NO;
    
    // get last element and compare qNames
    NSMutableDictionary *element = [self lastElementInArray:self.openedElements];
    if ([[element objectForKey:QUALIFIED_NAME] isEqualToString:qName]) {
        [self.openedElements removeObject:element];
    }
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {
    if (self.isCurrentProcessedData) self.parsedBuffer = string;
}

/**
 * TODO check this implementation on real CData.
 *
 */
- (void)parser:(NSXMLParser *)parser foundCDATA:(NSData *)CDATABlock {
    NSString *string = [[NSString alloc] initWithData:CDATABlock encoding:NSUTF8StringEncoding];
    if (self.isCurrentProcessedData) self.parsedBuffer = string;
}

- (void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError {
    [self.delegate parser:self didFailWithError:parseError];
    [self cancelParsing];
}

@end
