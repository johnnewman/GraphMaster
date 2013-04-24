//
//  GMNodeView.h
//  GraphMaster
//
//  Created by John Newman on 4/2/13.
//  Copyright (c) 2013 John Newman. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GMNodeViewSelectionDelegate.h"

@class GMEdge;

@interface GMNodeView : UIView {
    BOOL isDrawingNewEdge;
    CGPoint newEdgeDestPoint;
}

@property (nonatomic, weak) id<GMNodeViewSelectionDelegate>delegate;
@property (nonatomic) NSUInteger number;
@property (nonatomic, strong, readonly) NSMutableArray *outgoingEdges;
@property (nonatomic, strong, readonly) NSHashTable *outgoingNodes;


- (id)initWithNumber:(NSUInteger)nodeNumber;

- (void)tapOccurred:(UITapGestureRecognizer*)tapGesture;
- (void)longPressOccurred:(UILongPressGestureRecognizer*)longPressGesture;

- (void)addOutgoingEdge:(GMEdge*)edge;
- (void)removeOutgoingEdge:(GMEdge*)edge;


@end
