//
//  ParserViewController.m
//  Parser
//
//  Created by Ivan Sadikov on 4/07/14.
//  Copyright (c) 2014 Ivan Sadikov. All rights reserved.
//

#import "ParserViewController.h"
#import "ISXMLParser.h"

@interface ParserViewController () <ISXMLParserDelegate, UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *predictions;
@end

#define GEOCODE_URL     @"https://maps.googleapis.com/maps/api/place/autocomplete/xml?input=Christchurch&types=geocode&key=API_KEY"

@implementation ParserViewController

- (NSMutableArray *)predictions {
    if (!_predictions) _predictions = [NSMutableArray array];
    return _predictions;
}

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
    NSArray *main = (NSArray *)[result objectForKey:ENTITIES];
    NSArray *autocompletionResponseArray = (NSArray *)[[main firstObject] objectForKey:ENTITIES];
    for (NSDictionary *element in autocompletionResponseArray) {
        if ([[element valueForKey:QUALIFIED_NAME] isEqualToString:@"prediction"]) {
            NSArray *predictions = (NSArray *)[element valueForKey:ENTITIES];
            [self.predictions addObject:predictions];
            NSLog(@"%@", [self.predictions description]);
        }
    }

    [self.tableView reloadData];
}

- (void)parser:(ISXMLParser *)parser didFailWithError:(NSError *)error {
    NSLog(@"Parser did fail with error: %@", [error description]);
}

#pragma mark - Table View Delegate and Data Source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.predictions count];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Reusable Cell" forIndexPath:indexPath];
    
    NSString *predictionName = [NSString string];
    NSString *typeName = [NSString string];
    
    NSArray *prediction = (NSArray *)[self.predictions objectAtIndex:indexPath.row];
    for (NSDictionary *attribute in prediction) {
        if ([[attribute valueForKey:QUALIFIED_NAME] isEqualToString:@"description"]) {
            predictionName = [attribute valueForKey:ELEMENT_TEXT];
        }
        
        if ([[attribute valueForKey:QUALIFIED_NAME] isEqualToString:@"id"]) {
            typeName = [attribute valueForKey:ELEMENT_TEXT];
        }
    }
    
    cell.textLabel.text = predictionName;
    cell.detailTextLabel.text = typeName;
    
    return cell;
}


@end
