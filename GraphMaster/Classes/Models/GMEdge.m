//
//  GMEdge.m
//  GraphMaster
//
//  Created by John Newman on 3/13/13.
//  Copyright (c) 2013 John Newman. All rights reserved.
//

#import "GMEdge.h"
#import "GMNodeView.h"
#import <QuartzCore/QuartzCore.h>

@interface GMEdge ()
- (void)weightButtonSelected;
@end

@implementation GMEdge

- (id)initWithWeight:(NSInteger)weight startNode:(GMNodeView*)startNode destNode:(GMNodeView*)destNode {
    if (self = [super init]) {
        _startNode = startNode;
        _destNode = destNode;
        
        _weightButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _weightButton.titleLabel.font = [UIFont systemFontOfSize:kEDGE_TEXT_SIZE];
        [_weightButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        _weightButton.titleLabel.textAlignment = NSTextAlignmentCenter;
        _weightButton.backgroundColor = [UIColor lightGrayColor];
        _weightButton.layer.cornerRadius = 5.0;
        _weightButton.layer.borderWidth = 2.0;
        [_weightButton addTarget:self action:@selector(weightButtonSelected) forControlEvents:UIControlEventTouchUpInside];
        
        self.weight = weight;
    }
    return self;
}

- (void)weightButtonSelected {
    if ([_delegate respondsToSelector:@selector(edgeSelected:)]) {
        [_delegate edgeSelected:self];
    }
}

- (void)centerWeightLabel {
    CGPoint startMidPoint = CGPointMake(CGRectGetMidX(_startNode.frame), CGRectGetMidY(_startNode.frame));
    CGPoint destMidPoint = CGPointMake(CGRectGetMidX(_destNode.frame), CGRectGetMidY(_destNode.frame));
    CGPoint midPointBetweenNodes = CGPointMake((destMidPoint.x + startMidPoint.x)/2, (destMidPoint.y + startMidPoint.y)/2);
    _weightButton.center = midPointBetweenNodes;
}

- (void)setWeight:(NSInteger)weight {
    _weight = weight;
    NSString *weightText = [NSString stringWithFormat:@" %d ", _weight];
    [_weightButton setTitle:weightText forState:UIControlStateNormal];
    [_weightButton sizeToFit];
    [self centerWeightLabel];
}

@end
