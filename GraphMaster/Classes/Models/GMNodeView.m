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

- (void)moveNodeWithGesture:(UIGestureRecognizer*)gestureRecognizer;

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
        
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapOccurred:)];
        [self addGestureRecognizer:tapGesture];
        
        UILongPressGestureRecognizer *longPressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressOccurred:)];
        [self addGestureRecognizer:longPressGesture];
        
        UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panOccurred:)];
        [self addGestureRecognizer:panGesture];
    }
    return self;
}


//used for drawing a new edge
- (void)panOccurred:(UIPanGestureRecognizer *)panGesture
{
    switch (panGesture.state) {
        case UIGestureRecognizerStateBegan:
        {
            if ([_delegate respondsToSelector:@selector(nodeViewDidBeginDrawingEdge:)])
                [_delegate nodeViewDidBeginDrawingEdge:self];
            break;
        }
        case UIGestureRecognizerStateChanged:
        {
            if ([_delegate respondsToSelector:@selector(nodeView:isDrawingEdgeToPoint:)])
                [_delegate nodeView:self isDrawingEdgeToPoint:[panGesture locationInView:self.superview]];
            break;
        }
        case UIGestureRecognizerStateEnded:
        case UIGestureRecognizerStateFailed:
        case UIGestureRecognizerStateCancelled:
        {
            if ([_delegate respondsToSelector:@selector(nodeView:didFinishDrawingEdgeToPoint:)])
                [_delegate nodeView:self didFinishDrawingEdgeToPoint:[panGesture locationInView:self.superview]];
            break;
        }
        default:
            break;
    }
}


//used for showing an options dialog
- (void)tapOccurred:(UITapGestureRecognizer *)tapGesture {
    if ([_delegate respondsToSelector:@selector(nodeViewNeedsOptionsDialog:)])
        [_delegate nodeViewNeedsOptionsDialog:self];
}


//used for moving the node
- (void)longPressOccurred:(UILongPressGestureRecognizer*)longPressGesture {
    switch (longPressGesture.state) {
        case UIGestureRecognizerStateBegan:
        {
            [self.superview bringSubviewToFront:self];
            [UIView animateWithDuration:0.1 animations:^{
                self.transform = CGAffineTransformMakeScale(1.5f, 1.5f);
            }];
            break;
        }
        case UIGestureRecognizerStateChanged:
        {
            [self moveNodeWithGesture:longPressGesture];
            break;
        }
        case UIGestureRecognizerStateEnded:
        case UIGestureRecognizerStateFailed:
        case UIGestureRecognizerStateCancelled:
        {
            [UIView animateWithDuration:0.1 animations:^{
                self.transform = CGAffineTransformMakeScale(1.0f, 1.0f);
            }];
            break;
        }
        default:
            break;
    }
}

- (void)moveNodeWithGesture:(UIGestureRecognizer*)gestureRecognizer {
    CGPoint touchPoint = [gestureRecognizer locationInView:self.superview];
    touchPoint.x -= kNODE_RADIUS * 0.5;
    touchPoint.y -= kNODE_RADIUS * 0.5;
    
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
