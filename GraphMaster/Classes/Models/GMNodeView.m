//
//  GMNodeView.m
//  GraphMaster
//
//  Created by John Newman on 4/2/13.
//  Copyright (c) 2013 John Newman. All rights reserved.
//

#import "GMNodeView.h"
#import "GMEdge.h"
#import "GMGraphViewController.h"

@interface GMNodeView ()

- (void)moveNodeWithGesuture:(UIGestureRecognizer*)gestureRecognizer;

@property (nonatomic, strong) UILabel *numberLabel;

@end

@implementation GMNodeView

- (id)initWithNumber:(NSUInteger)nodeNumber {
    if (self = [super init]) {
        _number = nodeNumber;
        
        _numberLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, kNODE_RADIUS*2, kNODE_RADIUS*2)];
        _numberLabel.text = [NSString stringWithFormat:@"%d", _number];
        _numberLabel.font = [UIFont systemFontOfSize:kNODE_TEXT_SIZE];
        _numberLabel.backgroundColor = [UIColor clearColor];
        _numberLabel.textAlignment = NSTextAlignmentCenter;
        
        [self addSubview:_numberLabel];
        
        self.backgroundColor = [UIColor clearColor];
        
        _outgoingEdges = [NSMutableArray array];
        _outgoingNodes = [NSHashTable hashTableWithOptions:NSPointerFunctionsWeakMemory];
    }
    return self;
}


- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    NSLog(@"touches moved");
    if ([_delegate respondsToSelector:@selector(nodeView:isDrawingEdgeToPoint:)])
        [_delegate nodeView:self isDrawingEdgeToPoint:[[touches anyObject] locationInView:self.superview]];
    [super touchesMoved:touches withEvent:event];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    NSLog(@"touches ended");
    isAnimatingSelection = NO;
    [super touchesEnded:touches withEvent:event];
}

- (void)moveNodeWithGesuture:(UIGestureRecognizer*)gestureRecognizer {
    CGPoint touchPoint = [gestureRecognizer locationInView:self.superview];
    if (CGRectContainsPoint(self.superview.bounds, touchPoint)) {
        touchPoint.x -= kNODE_RADIUS;
        touchPoint.y -= kNODE_RADIUS;
        CGRect frame = self.frame;
        frame.origin = touchPoint;
        self.frame = frame;
        
        if ([_delegate respondsToSelector:@selector(nodeViewIsMovingOrigin:)])
            [_delegate nodeViewIsMovingOrigin:self];
    }
}


- (void)tapOccurred:(UITapGestureRecognizer *)tapGesture {
    NSLog(@"tap occurred in node %d", _number);
    if ([_delegate respondsToSelector:@selector(nodeViewNeedsOptionsDialog:)])
        [_delegate nodeViewNeedsOptionsDialog:self];
}

- (void)longPressOccurred:(UILongPressGestureRecognizer*)longPressGesture {
    
    if (!isAnimatingSelection) {
        isAnimatingSelection = YES;
        NSLog(@"long press");
//        CGRect currentFrame = self.frame;
//        [UIView animateWithDuration:0.1 delay:0 options:UIViewAnimationCurveEaseIn animations:^{
//            CGFloat extraEdgeLength = (currentFrame.size.width * 0.3) / 2.0;
//            NSLog(@"extraEdgeLength: %f", extraEdgeLength);
//            self.frame = CGRectMake(currentFrame.origin.x - extraEdgeLength, currentFrame.origin.y - extraEdgeLength, currentFrame.size.width + extraEdgeLength, currentFrame.size.height + extraEdgeLength);
//        } completion:^(BOOL finished){
//            if (finished) {
//                [UIView animateWithDuration:0.1 delay:0 options:UIViewAnimationCurveEaseIn animations:^{
//                    CGFloat extraEdgeLength = (currentFrame.size.width * 0.2) / 2.0;
//                    self.frame = CGRectMake(currentFrame.origin.x - extraEdgeLength, currentFrame.origin.y - extraEdgeLength, currentFrame.size.width + extraEdgeLength, currentFrame.size.height + extraEdgeLength);
//                } completion:nil];
//            }
//        }];
    }
    [self moveNodeWithGesuture:longPressGesture];
}

- (void)setNumber:(NSUInteger)number {
    _number = number;
    _numberLabel.text = [NSString stringWithFormat:@"%d", _number];
}


- (void)addOutgoingEdge:(GMEdge *)edge {
    [_outgoingEdges addObject:edge];
    [_outgoingNodes addObject:edge.destNode];
}

- (void)removeOutgoingEdge:(GMEdge *)edge {
    [_outgoingEdges removeObject:edge];
    [_outgoingNodes removeObject:edge.destNode];
}

- (void)drawRect:(CGRect)rect
{
    rect.origin.x += 2;
    rect.origin.y += 2;
    rect.size.width -= 4;
    rect.size.height -= 4;
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetLineWidth(context, kNODE_EDGE_WIDTH);
    CGContextStrokeEllipseInRect(context, rect);
    
    CGContextSetFillColorWithColor(context, [UIColor whiteColor].CGColor);
    CGContextFillEllipseInRect(context, rect);
}


@end
