//
//  GMAppDelegate.h
//  GraphMaster
//
//  Created by John Newman on 3/13/13.
//  Copyright (c) 2013 John Newman. All rights reserved.
//

#import <UIKit/UIKit.h>

@class GMViewController;

@interface GMAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) GMViewController *viewController;

@end
