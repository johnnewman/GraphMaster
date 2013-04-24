//
//  GMEdgeOptionsViewController.h
//  GraphMaster
//
//  Created by John Newman on 4/17/13.
//  Copyright (c) 2013 John Newman. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GMEdgeOptionsDelegate.h"

@interface GMEdgeOptionsViewController : UIViewController <UIPickerViewDelegate, UIPickerViewDataSource>

@property(nonatomic, weak)id<GMEdgeOptionsDelegate> delegate;

@end
