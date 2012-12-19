//
//  WMNodeTypeTableViewController.h
//  Wheelmap
//
//  Created by Andrea Gerlach on 12.12.12.
//  Copyright (c) 2012 Sozialhelden e.V. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WMNodeTypeTableViewController : WMTableViewController

@property (nonatomic, strong) NSSet *nodeArray;
@property (strong, nonatomic) id delegate;

@end