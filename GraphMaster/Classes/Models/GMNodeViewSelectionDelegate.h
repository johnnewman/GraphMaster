//
//  GMNodeViewSelectionDelegate.h
//  GraphMaster
//
//  Created by John Newman on 4/17/13.
//  Copyright (c) 2013 John Newman. All rights reserved.
//

#import <Foundation/Foundation.h>

@class GMNodeView;

@protocol GMNodeViewSelectionDelegate <NSObject>

- (void)nodeViewDidBeginDrawingEdge:(GMNodeView *)nodeView;
- (void)nodeView:(GMNodeView*)nodeView isDrawingEdgeToPoint:(CGPoint)point;
- (void)nodeView:(GMNodeView*)nodeView didEndDrawingEdgeToPoint:(CGPoint)point;

- (void)nodeViewDidBeginMovingOrigin:(GMNodeView *)nodeView;
- (void)nodeViewIsMovingOrigin:(GMNodeView*)nodeView;
- (void)nodeViewDidEndMovingOrigin:(GMNodeView *)nodeView;

- (void)nodeViewNeedsOptionsDialog:(GMNodeView*)nodeView;
@end
