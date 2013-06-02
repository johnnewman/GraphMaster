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
    if ([_delegate respondsToSelector:@selector(nodeView:isDrawingEdgeToPoint:)])
        [_delegate nodeView:self isDrawingEdgeToPoint:[[touches anyObject] locationInView:self.superview]];
    [super touchesMoved:touches withEvent:event];
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
    if ([_delegate respondsToSelector:@selector(nodeViewNeedsOptionsDialog:)])
        [_delegate nodeViewNeedsOptionsDialog:self];
}

- (void)longPressOccurred:(UILongPressGestureRecognizer*)longPressGesture {
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
