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
    CGPoint movePoint;
}

@property (nonatomic, weak)GMNodeView *nodeWithTouches;
@property (nonatomic)BOOL isDrawingNewEdge;
@property (nonatomic, weak)NSMutableArray *nodes;

@end
