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
    
    if (_nodeWithNewEdge) {
        CGPoint nodeCenter = _nodeWithNewEdge.center;
        CGContextMoveToPoint(context, nodeCenter.x, nodeCenter.y);
        CGContextAddLineToPoint(context, _edgeEndPoint.x, _edgeEndPoint.y);
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
                
                bezierIntersectPoint = [self estimateBezierIntersectWithStartNode:edge.startNode endNode:edge.destNode controlPoint:bezierControlPoint t:&estimatedTForIntersection];
                tDiff = 1 - estimatedTForIntersection;
                dx = (tDiff * bezierControlPoint.x + estimatedTForIntersection * destNodeCenter.x) - (tDiff * startNodeCenter.x + estimatedTForIntersection * bezierControlPoint.x);
                dy = (tDiff * bezierControlPoint.y + estimatedTForIntersection * destNodeCenter.y) - (tDiff * startNodeCenter.y + estimatedTForIntersection * bezierControlPoint.y);
                bezierEstimationSlope = dy/dx;
                
                arrowEdgeStartPoints = [self getArrowEdgeStartPointsWithIntersectPoint:bezierIntersectPoint endNode:edge.destNode slope:bezierEstimationSlope];
                [self addArrowEdgesToContext:context withStartPoints:arrowEdgeStartPoints toEndPoint:bezierIntersectPoint];
            }
            else {
                straightEdgeMidpoint = CGPointMake((destNodeCenter.x + startNodeCenter.x)/2, (destNodeCenter.y + startNodeCenter.y)/2);
                [edge centerWeightLabelToPoint:straightEdgeMidpoint];
                
                CGContextMoveToPoint(context, startNodeCenter.x, startNodeCenter.y);
                CGContextAddLineToPoint(context, destNodeCenter.x, destNodeCenter.y);
                nodeIntersectPoint = [self getNodeIntersectPointWithStartNode:edge.startNode endNode:edge.destNode];
                arrowEdgeStartPoints = [self getArrowEdgeStartPointsWithIntersectPoint:nodeIntersectPoint endNode:edge.destNode slope:(destNodeCenter.y - startNodeCenter.y) / (destNodeCenter.x - startNodeCenter.x)];
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

- (CGPoint)getNodeIntersectPointWithStartNode:(GMNodeView *)startNode endNode:(GMNodeView *)endNode
{
    CGFloat slope = (endNode.center.y - startNode.center.y) / (endNode.center.x - startNode.center.x);
    CGFloat nodeIntersectX;
    
    [self prepareSlope:&slope andPerpSlope:nil];
    if (startNode.center.x < endNode.center.x)
        nodeIntersectX = endNode.center.x - ((endNode.frame.size.width / 2) / (sqrt(1+pow(slope, 2.0))));
    else
        nodeIntersectX = endNode.center.x + ((endNode.frame.size.width / 2) / (sqrt(1+pow(slope, 2.0))));
    return CGPointMake(nodeIntersectX, (slope * (nodeIntersectX - endNode.center.x)) + endNode.center.y);
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


- (PointPair*)getArrowEdgeStartPointsWithIntersectPoint:(CGPoint)intersectPoint endNode:(GMNodeView *)endNode slope:(CGFloat)slope
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
    if (intersectPoint.x  < endNode.center.x) {
        subracted = YES;
        perpLineXIntersect = intersectPoint.x - xDifferenceToIntersect;
    }
    else {
        perpLineXIntersect = intersectPoint.x + xDifferenceToIntersect;
        subracted = NO;
    }
    perpLineIntersectPoint = CGPointMake(perpLineXIntersect, (slope * (perpLineXIntersect - intersectPoint.x)) + intersectPoint.y);
    
    //if the points are inside the node, need to flip them
    if (sqrt(powf(perpLineXIntersect - endNode.center.x, 2) + powf(perpLineIntersectPoint.y - endNode.center.y, 2)) < endNode.frame.size.width / 2) {
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

- (CGPoint)estimateBezierIntersectWithStartNode:(GMNodeView *)startNode endNode:(GMNodeView *)endNode controlPoint:(CGPoint)controlPoint t:(CGFloat*)t
{
    CGPoint intersectPoint;
    CGFloat lowerLimit = 0;
    CGFloat upperLimit = 1;
    CGFloat distanceFromIntersectToEnd;
        
    for (NSUInteger i = 0; i < 10; i++)
    {
        //Reduced Quadratic Bezier Curve formula : B(t) = (1-t)^2P0 + 2(1-t)t(P1) + t^2P2 , T->[0,1]
        //Distance formula: d = srqt((x2-x1)^2 + (y2-y1)^2)
        
        intersectPoint = CGPointMake(pow((1-*t), 2)*startNode.center.x + 2*(1-*t) * *t * controlPoint.x + pow(*t, 2.0) * endNode.center.x,
                                     pow((1-*t), 2)*startNode.center.y + 2*(1-*t) * *t * controlPoint.y + pow(*t, 2.0) * endNode.center.y);
        distanceFromIntersectToEnd = sqrtf(powf(intersectPoint.x - endNode.center.x, 2) + powf(intersectPoint.y - endNode.center.y, 2));
        
        if (distanceFromIntersectToEnd == endNode.frame.size.width/2) //on edge
            break;
        
        else if (distanceFromIntersectToEnd > endNode.frame.size.width/2)
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
