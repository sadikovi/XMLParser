//
//  Stack.h
//  Parser
//
//  Created by Ivan Sadikov on 4/07/14.
//  Copyright (c) 2014 Ivan Sadikov. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Stack : NSObject
@property (nonatomic, strong, readonly) NSArray *stackElements;

- (void)insertElement:(id)element;
- (void)removeElement:(id)element;
- (id)getElement;
- (BOOL)isEmpty;

@end
