//
//  ParserViewController.m
//  Parser
//
//  Created by Ivan Sadikov on 4/07/14.
//  Copyright (c) 2014 Ivan Sadikov. All rights reserved.
//

#import "ParserViewController.h"
#import "ISXMLParser.h"

@interface ParserViewController () <ISXMLParserDelegate>
@end

#define GEOCODE_URL     @"https://maps.googleapis.com/maps/api/place/autocomplete/xml?input=Christchurch&types=geocode&key=AIzaSyCkziRBB3NXF7DvQwEIoGMyqwCFpDAqGaw1"

@implementation ParserViewController

- (IBAction)parse:(UIButton *)sender {
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:GEOCODE_URL]
                                             cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
                                         timeoutInterval:180];
    // send request
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:[NSOperationQueue currentQueue]
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
                               if (connectionError) {
                                   NSLog(@"Connection error: %@", [connectionError description]);
                               } else {
                                   ISXMLParser *parser = [[ISXMLParser alloc] initWithData:data];
                                   parser.delegate = self;
                                   [parser startParsing];
                               }
                           }];
}

- (void)parserDidStartParsingData:(ISXMLParser *)parser {
    NSLog(@"Parser did start parsing data");
}

- (void)parser:(ISXMLParser *)parser didFinishParsingWithResult:(NSDictionary *)result {
    NSLog(@"Parser did finish successfully: %@", [result description]);
}

- (void)parser:(ISXMLParser *)parser didFailWithError:(NSError *)error {
    NSLog(@"Parser did fail with error: %@", [error description]);
}

@end
