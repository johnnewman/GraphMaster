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
@property (nonatomic, strong) NSMutableArray *outgoingEdges;
@property (nonatomic, strong) NSMutableArray *incomingEdges;


- (id)initWithNumber:(NSUInteger)nodeNumber;
- (void)tapOccurred:(UITapGestureRecognizer*)tapGesture;
- (void)addIncomingEdge:(GMEdge*)edge;
- (void)addOutgoingEdge:(GMEdge*)edge;


@end
