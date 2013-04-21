//
//  GMEdge.h
//  GraphMaster
//
//  Created by John Newman on 3/13/13.
//  Copyright (c) 2013 John Newman. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GMEdgeSelectionDelegate.h"

@class GMNodeView;

@interface GMEdge : NSObject

@property (nonatomic) NSInteger weight;
@property (nonatomic, setter = setSelected:) BOOL isSelected;
@property (nonatomic, weak) GMNodeView *startNode;
@property (nonatomic, weak) GMNodeView *destNode;
@property (nonatomic, strong, readonly) UIButton *weightButton;
@property (nonatomic, weak)id<GMEdgeSelectionDelegate> delegate;

- (id)initWithWeight:(NSInteger)weight startNode:(GMNodeView*)startNode destNode:(GMNodeView*)destNode;
- (void)centerWeightLabel;

@end
