//
//  Stack.m
//  Parser
//
//  Created by Ivan Sadikov on 4/07/14.
//  Copyright (c) 2014 Ivan Sadikov. All rights reserved.
//

#import "Stack.h"

@interface Stack ()
@property (nonatomic, strong) NSMutableArray *stack;
@end

@implementation Stack

- (id)init {
    self = [super init];
    return self;
}

- (NSMutableArray *)stack {
    if (!_stack) {
        _stack = [NSMutableArray array];
    }
    
    return _stack;
}

- (NSArray *)stackElements {
    return self.stack;
}

- (void)insertElement:(id)element {
    [self.stack addObject:element];
}

- (void)removeElement:(id)element {
    if (![self isEmpty] && [element isEqual:[self.stack objectAtIndex:[self.stack count]-1]]) {
        [self.stack removeObjectAtIndex:[self.stack count]-1];
    }
}

- (id)getElement {
    if ([self isEmpty]) {
        return nil;
    } else {
        id object = [self.stack objectAtIndex:[self.stack count]-1];
        return object;
    }
}

- (BOOL)isEmpty {
    return ![self.stack count];
}

@end
