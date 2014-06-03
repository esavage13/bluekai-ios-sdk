//
//  MasterViewController.h
//  TestRunnerApp
//
//  Created by Shun Chu on 5/20/14.
//  Copyright (c) 2014 BlueKai. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DetailViewController;

@interface MasterViewController : UITableViewController

@property (strong, nonatomic) DetailViewController *detailViewController;

@end
