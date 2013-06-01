//
//  GMGraphCanvass.h
//  GraphMaster
//
//  Created by John Newman on 3/13/13.
//  Copyright (c) 2013 John Newman. All rights reserved.
//

#import <UIKit/UIKit.h>
@class GMNodeView;

@interface GMGraphCanvass : UIView {
    CGPoint edgeEndPoint;    
}

@property (nonatomic, weak, readonly)GMNodeView *nodeWithNewEdge;
@property (nonatomic)BOOL isDrawingNewEdge;
@property (nonatomic, weak)NSMutableArray *nodes;

- (void)drawNewEdgeFromNode:(GMNodeView*)node toPoint:(CGPoint)edgePoint;

@end
