//
//  GMNodeOptionsViewController.m
//  GraphMaster
//
//  Created by John Newman on 4/21/13.
//  Copyright (c) 2013 John Newman. All rights reserved.
//

#import "GMNodeOptionsViewController.h"
#import <QuartzCore/QuartzCore.h>

#define kVIEW_WIDTH 75
#define kVIEW_PADDING 5
#define kBUTTON_HEIGHT 40

@interface GMNodeOptionsViewController ()
- (void) stylizeButton:(UIButton*)button;
- (void)increasePrioritySelected;
- (void)decreasePrioritySelected;
- (void)deleteButtonSelected;
@end

@implementation GMNodeOptionsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.contentSizeForViewInPopover = CGSizeMake(kVIEW_WIDTH, kBUTTON_HEIGHT * 3 + kVIEW_PADDING * 2);
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    UIButton *incPriorityButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, kVIEW_WIDTH, kBUTTON_HEIGHT)];
    [incPriorityButton setTitle:@"+ Priority" forState:UIControlStateNormal];
    [incPriorityButton addTarget:self action:@selector(increasePrioritySelected) forControlEvents:UIControlEventTouchUpInside];
    [self stylizeButton:incPriorityButton];
    [self.view addSubview:incPriorityButton];
    
    UIButton *decPriorityButton = [[UIButton alloc] initWithFrame:CGRectMake(0, incPriorityButton.frame.size.height + kVIEW_PADDING, kVIEW_WIDTH, kBUTTON_HEIGHT)];
    [decPriorityButton setTitle:@"- Priority" forState:UIControlStateNormal];
    [decPriorityButton addTarget:self action:@selector(decreasePrioritySelected) forControlEvents:UIControlEventTouchUpInside];
    [self stylizeButton:decPriorityButton];
    [self.view addSubview:decPriorityButton];
    
    
    UIButton *deleteButton = [[UIButton alloc] initWithFrame:CGRectMake(0, decPriorityButton.frame.origin.y + kBUTTON_HEIGHT + kVIEW_PADDING, kVIEW_WIDTH, kBUTTON_HEIGHT)];
    deleteButton.layer.borderWidth = 2.0f;
    deleteButton.layer.cornerRadius = 5.0f;
    deleteButton.backgroundColor = [UIColor redColor];
    [deleteButton setTitleColor:[UIColor blackColor] forState:UIControlStateHighlighted];
    [deleteButton setTitle:@"Delete" forState:UIControlStateNormal];
    [deleteButton addTarget:self action:@selector(deleteButtonSelected) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:deleteButton];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) stylizeButton:(UIButton*)button {
    button.layer.borderWidth = 2.0f;
    button.layer.cornerRadius = 5.0f;
    button.backgroundColor = [UIColor lightGrayColor];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
}

- (void)increasePrioritySelected {
    
}

- (void)decreasePrioritySelected {
    
}

- (void)deleteButtonSelected {
    
}

@end
