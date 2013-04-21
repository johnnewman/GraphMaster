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

#define kMIN_LABEL_WIDTH 20
#define kLABEL_HEIGHT 20

@interface GMEdge ()
- (void)weightButtonSelected;
@end

@implementation GMEdge

- (id)initWithWeight:(NSInteger)weight startNode:(GMNodeView*)startNode destNode:(GMNodeView*)destNode {
    if (self = [super init]) {
        _startNode = startNode;
        _destNode = destNode;
        
        _weightButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _weightButton.frame = CGRectMake(0, 0, kMIN_LABEL_WIDTH, kLABEL_HEIGHT);
        [_weightButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [_weightButton addTarget:self action:@selector(weightButtonSelected) forControlEvents:UIControlEventTouchUpInside];
        _weightButton.titleLabel.textAlignment = NSTextAlignmentCenter;
        _weightButton.backgroundColor = [UIColor lightGrayColor];
        _weightButton.layer.cornerRadius = 5.0;
        _weightButton.layer.borderWidth = 2.0;
        
        self.weight = _weight;
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
    
    NSString *weightText = [NSString stringWithFormat:@"%d", _weight];
    CGSize neededSize = [weightText sizeWithFont:_weightButton.titleLabel.font];
    
    CGRect weightButtonFrame = _weightButton.frame;
    if (neededSize.width > kMIN_LABEL_WIDTH)
        weightButtonFrame.size.width = neededSize.width + 4;
    else
        weightButtonFrame.size.width = kMIN_LABEL_WIDTH;
    _weightButton.frame = weightButtonFrame;
    
    [_weightButton setTitle:weightText forState:UIControlStateNormal];
}

@end
