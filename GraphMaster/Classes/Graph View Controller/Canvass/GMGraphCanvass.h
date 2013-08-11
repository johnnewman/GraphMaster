//
//  GMGraphCanvass.h
//  GraphMaster
//
//  Created by John Newman on 3/13/13.
//  Copyright (c) 2013 John Newman. All rights reserved.
//

#import <UIKit/UIKit.h>
@class GMNodeView;

@interface GMGraphCanvass : UIView

@property (nonatomic, weak)GMNodeView *nodeWithNewEdge;
@property (nonatomic, assign)CGPoint edgeEndPoint;

@property (nonatomic)BOOL isDrawingNewEdge;
@property (nonatomic, weak)NSMutableArray *nodes;

@end
