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
    CGRect startNodeFrame;
    CGRect destNodeFrame;
    CGPoint destNodeCenter;
    CGPoint startNodeCenter;
    CGFloat slope;
    CGFloat yIntercept;
    
    CGFloat a;
    CGFloat b;
    CGFloat c;
    CGFloat circleIntersectX;
    CGPoint circleIntersectPoint;
    
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
            
            if (startNodeCenter.x == destNodeCenter.x || startNodeCenter.y == destNodeCenter.y) {
                //have vertical line!
                NSLog(@"vertical/horizontal line");
            }
            else {
                
                //drawing arrows
                
                slope = (destNodeCenter.y - startNodeCenter.y) / (destNodeCenter.x - startNodeCenter.x);
                yIntercept = startNodeCenter.y - (startNodeCenter.x * slope);
                
                a = 1 + pow(slope, 2);
                b = (-2 * destNodeCenter.x) + (2 * (slope * (yIntercept - destNodeCenter.y)));
                c = pow(destNodeCenter.x, 2) + pow((yIntercept - destNodeCenter.y), 2) - pow(kNODE_RADIUS, 2);
                
                if (startNodeCenter.x < destNodeCenter.x)
                    circleIntersectX = (-b - sqrt(pow(b, 2.0) - (4*a*c))) / (2*a);
                else
                    circleIntersectX = (-b + sqrt(pow(b, 2.0) - (4*a*c))) / (2*a);
                
                circleIntersectPoint = CGPointMake(circleIntersectX, (slope * circleIntersectX) + yIntercept);
                
                
                CGFloat distanceFromNode = 10.0;
                CGFloat destX;
                if (startNodeCenter.x < destNodeCenter.x)
                    destX = circleIntersectPoint.x - (distanceFromNode / (sqrt(1+pow(slope, 2.0))));
                else
                    destX = circleIntersectPoint.x + (distanceFromNode / (sqrt(1+pow(slope, 2.0))));
                
                CGPoint arrowBackPointOnLine = CGPointMake(destX, (slope * destX) + yIntercept);
                
                
                CGFloat distanceFromArrowBase = 5.0;
                CGFloat perpSlope = -1/slope;
                CGFloat perpYIntercept = (perpSlope * -arrowBackPointOnLine.x) + arrowBackPointOnLine.y;
                
                CGFloat arrowStartX1 = arrowBackPointOnLine.x - (distanceFromArrowBase / (sqrt(1+pow(perpSlope, 2.0))));
                CGPoint arrowStartPoint1 = CGPointMake(arrowStartX1, (perpSlope * arrowStartX1) + perpYIntercept);
                
                CGFloat arrowStartX2 = arrowBackPointOnLine.x + (distanceFromArrowBase / (sqrt(1+pow(perpSlope, 2.0))));
                CGPoint arrowStartPoint2 = CGPointMake(arrowStartX2, (perpSlope * arrowStartX2) + perpYIntercept);
                
                
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
//                //CGContextMoveToPoint(context, <#CGFloat x#>, <#CGFloat y#>)
//                
//                //CGContextAddArcToPoint(context, tangentLineEndPoint.x, tangentLineEndPoint.y, destNodeCenter.x, destNodeCenter.y, 100);
            }
            
            CGContextMoveToPoint(context, startNodeCenter.x, startNodeCenter.y);
            CGContextAddLineToPoint(context, destNodeCenter.x, destNodeCenter.y);
        }
        
        
    }
    CGContextStrokePath(context);
}


@end
