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

#define kLABEL_EDGE 20

@interface GMEdge ()
- (void)weightButtonSelected;
@end

@implementation GMEdge

- (id)initWithWeight:(NSInteger)weight startNode:(GMNodeView*)startNode destNode:(GMNodeView*)destNode {
    if (self = [super init]) {
        _weight = weight;
        _startNode = startNode;
        _destNode = destNode;
        
        
        _weightButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_weightButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [_weightButton setTitle:[NSString stringWithFormat:@"%d", _weight] forState:UIControlStateNormal];
        [_weightButton addTarget:self action:@selector(weightButtonSelected) forControlEvents:UIControlEventTouchUpInside];
        _weightButton.titleLabel.textAlignment = NSTextAlignmentCenter;
        _weightButton.backgroundColor = [UIColor lightGrayColor];
        _weightButton.layer.cornerRadius = 5.0;
        _weightButton.layer.borderWidth = 2.0;
    }
    return self;
}

- (void)weightButtonSelected {
    NSLog(@"weight button ");
    _isSelected = YES;
    if ([_delegate respondsToSelector:@selector(edgeSelected:)]) {
        [_delegate edgeSelected:self];
    }
}

- (void)centerWeightLabel {
    CGPoint startMidPoint = CGPointMake(CGRectGetMidX(_startNode.frame), CGRectGetMidY(_startNode.frame));
    CGPoint destMidPoint = CGPointMake(CGRectGetMidX(_destNode.frame), CGRectGetMidY(_destNode.frame));
    CGPoint midPointBetweenNodes = CGPointMake((destMidPoint.x + startMidPoint.x)/2, (destMidPoint.y + startMidPoint.y)/2);
    _weightButton.frame = CGRectMake(midPointBetweenNodes.x - kLABEL_EDGE/2, midPointBetweenNodes.y - kLABEL_EDGE/2, kLABEL_EDGE, kLABEL_EDGE);
}

@end
