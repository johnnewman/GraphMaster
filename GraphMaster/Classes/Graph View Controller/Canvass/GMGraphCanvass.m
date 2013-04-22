//
//  GMGraphCanvass.m
//  GraphMaster
//
//  Created by John Newman on 3/13/13.
//  Copyright (c) 2013 John Newman. All rights reserved.
//

#import "GMGraphCanvass.h"
#import "GMGraphViewController.h"
#import "GMNodeView.h"
#import "GMEdge.h"

@implementation GMGraphCanvass


- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    if (currentDrawType == EDGE_TYPE && _nodeWithTouches != nil) {
        UITouch *touch = [touches anyObject];
        movePoint = [touch locationInView:self];
        if (CGRectContainsPoint(self.bounds, movePoint)) {
            _isDrawingNewEdge = YES;
            [self setNeedsDisplay];
        }
    }
    [super touchesMoved:touches withEvent:event];
}



- (void)drawRect:(CGRect)rect
{
    CGRect startNodeFrame, destNodeFrame;
    CGPoint destNodeCenter, startNodeCenter;
    
    CGFloat slope, perpendicularSlope;
    
    CGFloat circleIntersectX;
    CGPoint circleIntersectPoint;
    
    CGFloat arrowEdgeStartX;
    CGPoint arrowEdgeStartPoint;
    
    CGFloat arrowStartX1, arrowStartX2;
    CGPoint arrowStartPoint1, arrowStartPoint2;
    
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetLineWidth(context, kEDGE_WIDTH);
    
    if (_isDrawingNewEdge) {
        startNodeFrame = _nodeWithTouches.frame;
        CGContextMoveToPoint(context, CGRectGetMidX(startNodeFrame), CGRectGetMidY(startNodeFrame));
        CGContextAddLineToPoint(context, movePoint.x, movePoint.y);
        CGContextStrokePath(context);
    }    
    
      //draw each node and it's outgoing edges
    for (GMNodeView *node in _nodes) {
        for (GMEdge *edge in node.outgoingEdges) {
            
            [edge centerWeightLabel];
            
            startNodeFrame = edge.startNode.frame;
            startNodeCenter = CGPointMake(CGRectGetMidX(startNodeFrame), CGRectGetMidY(startNodeFrame));
            destNodeFrame = edge.destNode.frame;
            destNodeCenter = CGPointMake(CGRectGetMidX(destNodeFrame), CGRectGetMidY(destNodeFrame));
            
            CGContextMoveToPoint(context, startNodeCenter.x, startNodeCenter.y);
            CGContextAddLineToPoint(context, destNodeCenter.x, destNodeCenter.y);
            
                        
            //ARROW DRAWING
            
            slope = (destNodeCenter.y - startNodeCenter.y) / (destNodeCenter.x - startNodeCenter.x);
            
              //have to avoid vertical and horizontal lines for the arrow drawing
            if (slope == -INFINITY)
                slope = 200;
            else if (slope == INFINITY)
                slope = -200;
            
            if (slope == 0)
                perpendicularSlope = 200;
            else
                perpendicularSlope = -1/slope;
            
            
              //calculate the edge/circle intersect point
            if (startNodeCenter.x < destNodeCenter.x)
                circleIntersectX = destNodeCenter.x - (kNODE_RADIUS / (sqrt(1+pow(slope, 2.0))));
            else
                circleIntersectX = destNodeCenter.x + (kNODE_RADIUS / (sqrt(1+pow(slope, 2.0))));
            circleIntersectPoint = CGPointMake(circleIntersectX, (slope * (circleIntersectX - destNodeCenter.x)) + destNodeCenter.y);
            
            
            
            
              //step back from the node to start arrow
            if (startNodeCenter.x < destNodeCenter.x)
                arrowEdgeStartX = circleIntersectPoint.x - (kARROW_DISTANCE_FROM_NODE / (sqrt(1+pow(slope, 2.0))));
            else
                arrowEdgeStartX = circleIntersectPoint.x + (kARROW_DISTANCE_FROM_NODE / (sqrt(1+pow(slope, 2.0))));
            arrowEdgeStartPoint = CGPointMake(arrowEdgeStartX, (slope * (arrowEdgeStartX - circleIntersectPoint.x)) + circleIntersectPoint.y);
            
            
                        
            arrowStartX1 = arrowEdgeStartPoint.x - (kARROW_DISTANCE_FROM_EDGE / (sqrt(1+pow(perpendicularSlope, 2.0))));
            arrowStartPoint1 = CGPointMake(arrowStartX1, (perpendicularSlope * (arrowStartX1 - arrowEdgeStartPoint.x)) + arrowEdgeStartPoint.y);
            
            arrowStartX2 = arrowEdgeStartPoint.x + (kARROW_DISTANCE_FROM_EDGE / (sqrt(1+pow(perpendicularSlope, 2.0))));
            arrowStartPoint2 = CGPointMake(arrowStartX2, (perpendicularSlope * (arrowStartX2 - arrowEdgeStartPoint.x)) + arrowEdgeStartPoint.y);
            
            
            CGContextMoveToPoint(context, arrowStartPoint1.x, arrowStartPoint1.y);
            CGContextAddLineToPoint(context, circleIntersectPoint.x, circleIntersectPoint.y);
            CGContextMoveToPoint(context, arrowStartPoint2.x, arrowStartPoint2.y);
            CGContextAddLineToPoint(context, circleIntersectPoint.x, circleIntersectPoint.y);
           
//                CGFloat distance = sqrt(pow(destNodeCenter.x - startNodeCenter.x, 2) + pow(destNodeCenter.y - startNodeCenter.y, 2));                
//                CGPoint midpoint = CGPointMake((startNodeCenter.x + destNodeCenter.x)/2, (startNodeCenter.y + destNodeCenter.y)/2);
//                CGFloat tangentPerpYIntercept = (perpSlope * -midpoint.x) + midpoint.y;
//                
//                CGFloat tangentLineEndX = midpoint.x - (40 / (sqrt(1+pow(perpSlope, 2.0))));
//                CGPoint tangentLineEndPoint = CGPointMake(tangentLineEndX, (perpSlope * tangentLineEndX) + tangentPerpYIntercept);
//                
//                CGContextMoveToPoint(context, startNodeCenter.x, startNodeCenter.y);
//                CGContextAddQuadCurveToPoint(context, tangentLineEndPoint.x, tangentLineEndPoint.y, destNodeCenter.x, destNodeCenter.y);
            
            
//                CGFloat opposite = startNodeCenter.y - destNodeCenter.y;
//                CGFloat hypotenuse = distance;
//                CGFloat angle = asinf(opposite/hypotenuse) * 180 / M_PI;
//                if (angle < 0)
//                    angle *= -1;
//                
//                if (startNodeCenter.x > destNodeCenter.x) {
//                    if (destNodeCenter.y < startNodeCenter.y)
//                        angle += 90 + (90 - angle);
//                    else
//                        angle += 180 + (180 - angle);
//                }
//                else if (startNodeCenter.y < destNodeCenter.y)
//                    angle += 270 + (270 - angle);
//                
//                NSLog(@"angle: %f", angle);
//                
//                
//                CGFloat sinOfAngle = sinf(angle);
//                CGFloat cosOfAngle = cosf(angle);
//                
//                CGFloat rotatedX = (destNodeCenter.x * cosOfAngle) - (destNodeCenter.y * sinOfAngle);
//                CGFloat rotatedY = (destNodeCenter.x * sinOfAngle) + (destNodeCenter.y * cosOfAngle);
//                
//                CGPoint rotatedPoint = CGPointMake(rotatedX, rotatedY);
//
//                //NSLog(@"%@", NSStringFromCGPoint(rotatedPoint));
//                //CGContextMoveToPoint(context, ￼, ￼)
//                
//                //CGContextAddArcToPoint(context, tangentLineEndPoint.x, tangentLineEndPoint.y, destNodeCenter.x, destNodeCenter.y, 100);
        }
        
        
    }
    CGContextStrokePath(context);
}


@end
