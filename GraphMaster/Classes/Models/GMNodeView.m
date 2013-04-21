//
//  GMNodeView.m
//  GraphMaster
//
//  Created by John Newman on 4/2/13.
//  Copyright (c) 2013 John Newman. All rights reserved.
//

#import "GMNodeView.h"
#import "GMGraphViewController.h"

@interface GMNodeView ()

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
        self.alpha = 0.5;
        
        _incomingEdges = [NSMutableArray array];
        _outgoingEdges = [NSMutableArray array];
    }
    return self;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    if ([_delegate respondsToSelector:@selector(nodeViewTouchesBegan:)])
        [_delegate nodeViewTouchesBegan:self];
    [super touchesBegan:touches withEvent:event];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    if (currentDrawType == NODE_TYPE) {
        [self moveNodeWithTouch:[touches anyObject]];
    }
    [super touchesMoved:touches withEvent:event];
}

- (void)moveNodeWithTouch:(UITouch*)touch {
    CGPoint touchPoint = [touch locationInView:self.superview];
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
}

- (void)setNumber:(NSUInteger)number {
    _number = number;
    _numberLabel.text = [NSString stringWithFormat:@"%d", _number];
}

- (void)addIncomingEdge:(GMEdge *)edge {
    [_incomingEdges addObject:edge];
    [self setNeedsDisplay];
}

- (void)addOutgoingEdge:(GMEdge *)edge {
    [_outgoingEdges addObject:edge];
    [self setNeedsDisplay];
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
