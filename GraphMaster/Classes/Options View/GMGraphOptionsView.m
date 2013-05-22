//
//  GMGraphOptionsView.m
//  GraphMaster
//
//  Created by John Newman on 4/30/13.
//  Copyright (c) 2013 John Newman. All rights reserved.
//

#import "GMGraphOptionsView.h"
#import <QuartzCore/QuartzCore.h>

@interface GMGraphOptionsView ()
@property (nonatomic, weak) IBOutlet UITableView *tableView;
@end

@implementation GMGraphOptionsView

@synthesize tableView = _tableView;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

- (void)awakeFromNib {
    algorithmTypes = @[@"Shortest Path", @"Minimum Spanning Tree", @"Search"];
    algorithms = @[@[@"Dijkstra's", @"Bellman-Ford"],@[@"Prim's", @"Kruskals"], @[@"Depth-First", @"Breadth-First"]];
    [_tableView reloadData];
}

#pragma mark -
#pragma mark UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return algorithmTypes.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [[algorithms objectAtIndex:section] count];
}

- (NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return [algorithmTypes objectAtIndex:section];
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"algorithmCell";
    UITableViewCell *tableViewCell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (tableViewCell == nil) {
        tableViewCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    tableViewCell.textLabel.text = [[algorithms objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    return tableViewCell;
}

#pragma mark -
#pragma mark UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([_selectionDelegate respondsToSelector:@selector(graphOptionsView:didSelectAlgorithm:)]) {
        [_selectionDelegate graphOptionsView:self didSelectAlgorithm:(2 * indexPath.section) + indexPath.row];
    }
}

@end
