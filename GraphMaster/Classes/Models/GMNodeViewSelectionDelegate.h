//
//  GMNodeViewSelectionDelegate.h
//  GraphMaster
//
//  Created by John Newman on 4/17/13.
//  Copyright (c) 2013 John Newman. All rights reserved.
//

#import <Foundation/Foundation.h>

@class GMNodeView;

@protocol GMNodeViewSelectionDelegate <NSObject>
- (void)nodeViewTouchesBegan:(GMNodeView*)nodeView;
- (void)nodeViewIsMovingOrigin:(GMNodeView*)nodeView;
@end
