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

@interface PointPair : NSObject
@property(nonatomic) CGPoint point1;
@property(nonatomic) CGPoint point2;
@end
@implementation PointPair
@end

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
    CGPoint startNodeCenter, destNodeCenter;
    CGPoint straightEdgeMidpoint;
    CGPoint nodeIntersectPoint;
    CGPoint bezierControlPoint;
    CGPoint bezierIntersectPoint;
    CGFloat estimatedTForIntersection;
    CGFloat tDiff;
    CGFloat dx, dy;
    CGPoint bezierCenterPoint;
    CGFloat bezierEstimationSlope;
    PointPair *arrowEdgeStartPoints;
    
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
            
            if (edge.isTraveled) {
                CGContextStrokePath(context);
                CGContextSetStrokeColorWithColor(context, [UIColor redColor].CGColor);
            }
            
            startNodeFrame = edge.startNode.frame;
            startNodeCenter = CGPointMake(CGRectGetMidX(startNodeFrame), CGRectGetMidY(startNodeFrame));
            destNodeFrame = edge.destNode.frame;
            destNodeCenter = CGPointMake(CGRectGetMidX(destNodeFrame), CGRectGetMidY(destNodeFrame));
            
              //edges are reciprocally connected, need to draw bezier curve
            if ([edge.destNode.outgoingNodes containsObject:node]) {
                bezierControlPoint = [self getBezierControlPointWithStartPoint:startNodeCenter endPoint:destNodeCenter];
                CGContextMoveToPoint(context, startNodeCenter.x, startNodeCenter.y);
                CGContextAddQuadCurveToPoint(context, bezierControlPoint.x, bezierControlPoint.y, destNodeCenter.x, destNodeCenter.y);
                bezierCenterPoint = CGPointMake(0.25 * startNodeCenter.x + 0.5 * bezierControlPoint.x + 0.25 * destNodeCenter.x,
                                                0.25 * startNodeCenter.y + 0.5 * bezierControlPoint.y + 0.25 * destNodeCenter.y);
                
                [edge centerWeightLabelToPoint:bezierCenterPoint];
                
                bezierIntersectPoint = [self estimateBezierIntersectWithStartPoint:startNodeCenter endPoint:destNodeCenter controlPoint:bezierControlPoint t:&estimatedTForIntersection];
                tDiff = 1 - estimatedTForIntersection;
                dx = (tDiff * bezierControlPoint.x + estimatedTForIntersection * destNodeCenter.x) - (tDiff * startNodeCenter.x + estimatedTForIntersection * bezierControlPoint.x);
                dy = (tDiff * bezierControlPoint.y + estimatedTForIntersection * destNodeCenter.y) - (tDiff * startNodeCenter.y + estimatedTForIntersection * bezierControlPoint.y);
                bezierEstimationSlope = dy/dx;
                
                arrowEdgeStartPoints = [self getArrowEdgeStartPointsWithIntersectPoint:bezierIntersectPoint endPoint:destNodeCenter slope:bezierEstimationSlope];
                [self addArrowEdgesToContext:context withStartPoints:arrowEdgeStartPoints toEndPoint:bezierIntersectPoint];
            }
            else {
                straightEdgeMidpoint = CGPointMake((destNodeCenter.x + startNodeCenter.x)/2, (destNodeCenter.y + startNodeCenter.y)/2);
                [edge centerWeightLabelToPoint:straightEdgeMidpoint];
                
                CGContextMoveToPoint(context, startNodeCenter.x, startNodeCenter.y);
                CGContextAddLineToPoint(context, destNodeCenter.x, destNodeCenter.y);
                nodeIntersectPoint = [self getNodeIntersectPointWithStartPoint:startNodeCenter endPoint:destNodeCenter];
                arrowEdgeStartPoints = [self getArrowEdgeStartPointsWithIntersectPoint:nodeIntersectPoint endPoint:destNodeCenter slope:(destNodeCenter.y - startNodeCenter.y) / (destNodeCenter.x - startNodeCenter.x)];
                [self addArrowEdgesToContext:context withStartPoints:arrowEdgeStartPoints toEndPoint:nodeIntersectPoint];
            }
            
            if (edge.isTraveled) {
                CGContextStrokePath(context);
                CGContextSetStrokeColorWithColor(context, [UIColor blackColor].CGColor);
            }
        }
    }
    CGContextStrokePath(context);
}

- (CGPoint)getNodeIntersectPointWithStartPoint:(CGPoint)startPoint endPoint:(CGPoint)endPoint
{
    CGFloat slope = (endPoint.y - startPoint.y) / (endPoint.x - startPoint.x);
    CGFloat nodeIntersectX;
    
    [self prepareSlope:&slope andPerpSlope:nil];
    if (startPoint.x < endPoint.x)
        nodeIntersectX = endPoint.x - (kNODE_RADIUS / (sqrt(1+pow(slope, 2.0))));
    else
        nodeIntersectX = endPoint.x + (kNODE_RADIUS / (sqrt(1+pow(slope, 2.0))));
    return CGPointMake(nodeIntersectX, (slope * (nodeIntersectX - endPoint.x)) + endPoint.y);
}

- (CGPoint)getBezierControlPointWithStartPoint:(CGPoint)startPoint endPoint:(CGPoint)endPoint
{
    CGPoint midpoint = CGPointMake((startPoint.x + endPoint.x)/2, (startPoint.y + endPoint.y)/2);
    CGFloat slope = (endPoint.y - startPoint.y) / (endPoint.x - startPoint.x);
    CGFloat perpSlope;
    CGFloat bezierCurveXOffset;
    
    [self prepareSlope:&slope andPerpSlope:&perpSlope];
    
    //special case for if the start and end are on the same y-plane.  Need to flip the control
    //  point for one edge so that they both don't use the same control point.
    if (startPoint.y == endPoint.y && startPoint.x > endPoint.x)
        bezierCurveXOffset = midpoint.x + (kBEZIER_PATH_CONTROL_OFFSET / (sqrt(1+pow(perpSlope, 2.0))));
    else if (startPoint.y < endPoint.y)
        bezierCurveXOffset = midpoint.x + (kBEZIER_PATH_CONTROL_OFFSET / (sqrt(1+pow(perpSlope, 2.0))));
    else
        bezierCurveXOffset = midpoint.x - (kBEZIER_PATH_CONTROL_OFFSET / (sqrt(1+pow(perpSlope, 2.0))));
    return CGPointMake(bezierCurveXOffset, (perpSlope * (bezierCurveXOffset - midpoint.x)) + midpoint.y);
}

- (void)addArrowEdgesToContext:(CGContextRef)context withStartPoints:(PointPair*)pointPair toEndPoint:(CGPoint)endPoint
{
    CGContextMoveToPoint(context, pointPair.point1.x, pointPair.point1.y);
    CGContextAddLineToPoint(context, endPoint.x, endPoint.y);
    CGContextMoveToPoint(context, pointPair.point2.x, pointPair.point2.y);
    CGContextAddLineToPoint(context, endPoint.x, endPoint.y);
}


- (PointPair*)getArrowEdgeStartPointsWithIntersectPoint:(CGPoint)intersectPoint endPoint:(CGPoint)endPoint slope:(CGFloat)slope
{
    CGFloat perpSlope;
    CGFloat perpLineXIntersect;
    CGPoint perpLineIntersectPoint;
    
    CGFloat arrowStartX1;
    CGFloat arrowStartX2;
    PointPair *pointPair = [[PointPair alloc] init];
    
    [self prepareSlope:&slope andPerpSlope:&perpSlope];
    
    //step back from the intersect to start arrow
    BOOL subracted;
    CGFloat xDifferenceToIntersect = (kARROW_DISTANCE_FROM_NODE / (sqrt(1+pow(slope, 2.0))));
    if (intersectPoint.x  < endPoint.x) {
        subracted = YES;
        perpLineXIntersect = intersectPoint.x - xDifferenceToIntersect;
    }
    else {
        perpLineXIntersect = intersectPoint.x + xDifferenceToIntersect;
        subracted = NO;
    }
    perpLineIntersectPoint = CGPointMake(perpLineXIntersect, (slope * (perpLineXIntersect - intersectPoint.x)) + intersectPoint.y);
    
    
    if (sqrt(powf(perpLineXIntersect - endPoint.x, 2) + powf(perpLineIntersectPoint.y - endPoint.y, 2)) < kNODE_RADIUS) {
        if (subracted)
            perpLineXIntersect = intersectPoint.x + xDifferenceToIntersect;
        else
            perpLineXIntersect = intersectPoint.x - xDifferenceToIntersect;
        perpLineIntersectPoint = CGPointMake(perpLineXIntersect, (slope * (perpLineXIntersect - intersectPoint.x)) + intersectPoint.y);
    }
    
    
    //move up and down the perpendicular line
    arrowStartX1 = perpLineIntersectPoint.x - (kARROW_DISTANCE_FROM_EDGE / (sqrt(1+pow(perpSlope, 2.0))));
    pointPair.point1 = CGPointMake(arrowStartX1, (perpSlope * (arrowStartX1 - perpLineIntersectPoint.x)) + perpLineIntersectPoint.y);
    
    arrowStartX2 = perpLineIntersectPoint.x + (kARROW_DISTANCE_FROM_EDGE / (sqrt(1+pow(perpSlope, 2.0))));
    pointPair.point2 = CGPointMake(arrowStartX2, (perpSlope * (arrowStartX2 - perpLineIntersectPoint.x)) + perpLineIntersectPoint.y);
    
    return pointPair;
}


- (void)prepareSlope:(CGFloat*)slope andPerpSlope:(CGFloat*)perpSlope
{
    //need to avoid vertical and horizontal lines
    if (*slope == -INFINITY)
        *slope = 200;
    else if (*slope == INFINITY)
        *slope = -200;
    
    if (perpSlope != nil) {
        if (*slope == 0)
            *perpSlope = 200;
        else
            *perpSlope = -1 / *slope;
    }
}

- (CGPoint)estimateBezierIntersectWithStartPoint:(CGPoint)startPoint endPoint:(CGPoint)endPoint controlPoint:(CGPoint)controlPoint t:(CGFloat*)t
{
    CGPoint intersectPoint;
    CGFloat lowerLimit = 0;
    CGFloat upperLimit = 1;
    CGFloat distanceFromIntersectToEnd;
    for (NSUInteger i = 0; i < 10; i++)
    {
        //Reduced Quadratic Bezier Curve formula : B(t) = (1-t)^2P0 + 2(1-t)t(P1) + t^2P2 , T->[0,1]
        //Distance formula: d = srqt((x2-x1)^2 + (y2-y1)^2)
        
        intersectPoint = CGPointMake(pow((1-*t), 2)*startPoint.x + 2*(1-*t) * *t * controlPoint.x + pow(*t, 2.0) * endPoint.x,
                                     pow((1-*t), 2)*startPoint.y + 2*(1-*t) * *t * controlPoint.y + pow(*t, 2.0) * endPoint.y);
        distanceFromIntersectToEnd = sqrtf(powf(intersectPoint.x - endPoint.x, 2) + powf(intersectPoint.y - endPoint.y, 2));
        
        if (distanceFromIntersectToEnd == kNODE_RADIUS) //on edge
            break;
        
        else if (distanceFromIntersectToEnd > kNODE_RADIUS)
        {
            //outside circle
            lowerLimit = *t;
            *t += (upperLimit-lowerLimit)/2;
        }
        else
        {
            //inside circle
            upperLimit = *t;
            *t -= (upperLimit-lowerLimit)/2;
        }
    }
    return intersectPoint;
}


@end
