//
//  GMGraphOptionsView.h
//  GraphMaster
//
//  Created by John Newman on 4/30/13.
//  Copyright (c) 2013 John Newman. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GMGraphOptionsView : UIView <UITableViewDelegate, UITableViewDataSource> {
    NSArray *algorithms;
    NSArray *algorithmTypes;
}

@property (nonatomic, weak, readonly) IBOutlet UITableView *tableView;

@end
