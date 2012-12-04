//
//  WMNavigationControllerBaseViewController.m
//  Wheelmap
//
//  Created by Dorian Roy on 07.11.12.
//  Copyright (c) 2012 Sozialhelden e.V. All rights reserved.
//

#import <CoreLocation/CoreLocation.h>
#import <QuartzCore/QuartzCore.h>
#import "WMNavigationControllerBase.h"
#import "WMDataManager.h"
#import "WMDetailViewController.h"
#import "WMDashboardViewController.h"
#import "WMEditPOIViewController.h"
#import "WMShareSocialViewController.h"
#import "Node.h"
#import "Category.h"


@implementation WMNavigationControllerBase
{
    NSArray *nodes;
    WMDataManager *dataManager;
    CLLocationManager *locationManager;
    
    WMWheelChairStatusFilterPopoverView* wheelChairFilterPopover;
    WMCategoryFilterPopoverView* categoryFilterPopover;
    
}

#pragma mark - Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidBecomeActive:) name:UIApplicationDidBecomeActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillResignActive:) name:UIApplicationWillResignActiveNotification object:nil];
    
    dataManager = [[WMDataManager alloc] init];
    dataManager.delegate = self;
    
    locationManager = [[CLLocationManager alloc] init];
    locationManager.delegate = self;
    locationManager.distanceFilter = 50.0f;
	locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters;
    
    // configure initial vc from storyboard. this is necessary for iPad, since iPad's topVC is not the Dashboard!
    if ([self.topViewController conformsToProtocol:@protocol(WMNodeListView)]) {
        id<WMNodeListView> initialNodeListView = (id<WMNodeListView>)self.topViewController;
        initialNodeListView.dataSource = self;
        initialNodeListView.delegate = self;
    }
    
    self.wheelChairFilterStatus = [[NSMutableDictionary alloc] initWithObjectsAndKeys:[NSNumber numberWithBool:YES], @"yes",
                                   [NSNumber numberWithBool:YES], @"limited",
                                   [NSNumber numberWithBool:YES], @"no",
                                   [NSNumber numberWithBool:YES], @"unknown",nil];
    self.categoryFilterStatus = [[NSMutableDictionary alloc] init];
    for (Category* c in dataManager.categories) {
        [self.categoryFilterStatus setObject:[NSNumber numberWithBool:YES] forKey:c.id];
    }
    
    // set custom nagivation and tool bars
    self.navigationBar.frame = CGRectMake(0, self.navigationBar.frame.origin.y, self.view.frame.size.width, 50);
    self.customNavigationBar = [[WMNavigationBar alloc] initWithFrame:CGRectMake(0, 0, self.navigationBar.frame.size.width, 50)];
    self.customNavigationBar.delegate = self;
    [self.navigationBar addSubview:self.customNavigationBar];
    self.toolbar.frame = CGRectMake(0, self.toolbar.frame.origin.y, self.view.frame.size.width, 60);
    self.toolbar.backgroundColor = [UIColor whiteColor];
    self.customToolBar = [[WMToolBar alloc] initWithFrame:CGRectMake(0, 0, self.toolbar.frame.size.width, 60)];
    self.customToolBar.delegate = self;
    [self.toolbar addSubview:self.customToolBar];
    
    // set filter popovers.
    wheelChairFilterPopover = [[WMWheelChairStatusFilterPopoverView alloc] initWithOrigin:CGPointMake(self.customToolBar.middlePointOfWheelchairFilterButton-170, self.toolbar.frame.origin.y-60)];
    wheelChairFilterPopover.hidden = YES;
    wheelChairFilterPopover.delegate = self;
    [self.view addSubview:wheelChairFilterPopover];
    
    categoryFilterPopover = [[WMCategoryFilterPopoverView alloc] initWithRefPoint:CGPointMake(self.customToolBar.middlePointOfCategoryFilterButton, self.toolbar.frame.origin.y) andCategories:dataManager.categories];
    categoryFilterPopover.delegate = self;
    categoryFilterPopover.hidden = YES;
    [self.view addSubview:categoryFilterPopover];
    
    
}


- (BOOL) shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return YES; // TODO: prevent upside down on iphone
}

- (void) dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


#pragma mark - Data Manager Delegate

- (void) dataManager:(WMDataManager *)dataManager didReceiveNodes:(NSArray *)nodesParam
{
    nodes = nodesParam;
    
    [self refreshNodeList];
}

- (void) refreshNodeList
{
    if ([self.topViewController conformsToProtocol:@protocol(WMNodeListView)]) {
        [(id<WMNodeListView>)self.topViewController nodeListDidChange];
    }
}

-(void)dataManager:(WMDataManager *)dataManager fetchNodesFailedWithError:(NSError *)error
{
    NSLog(@"error %@", error.localizedDescription);
    [self refreshNodeList];
}

- (void)dataManagerDidFinishSyncingResources:(WMDataManager *)aDataManager
{
    NSLog(@"dataManagerDidFinishSyncingResources");
    [categoryFilterPopover refreshViewWithCategories:aDataManager.categories];
    [self.categoryFilterStatus removeAllObjects];
    for (Category* c in dataManager.categories) {
        [self.categoryFilterStatus setObject:[NSNumber numberWithBool:YES] forKey:c.id];
    }
    
}

-(void)dataManager:(WMDataManager *)dataManager syncResourcesFailedWithError:(NSError *)error
{
    NSLog(@"syncResourcesFailedWithError");
}


#pragma mark - category data source
-(NSArray*) categories
{
    return dataManager.categories;
}

#pragma mark - Node List Data Source

- (NSArray*) nodeList
{
    return nodes;
}

- (NSArray*) filteredNodeList
{
    // filter nodes here
    NSMutableArray* newNodeList = [[NSMutableArray alloc] init];
    for (Node* node in nodes) {
        NSNumber* categoryID = node.category.id;
        NSString* wheelChairStatus = node.wheelchair;
        if ([[self.wheelChairFilterStatus objectForKey:wheelChairStatus] boolValue] == YES &&
            [[self.categoryFilterStatus objectForKey:categoryID] boolValue] == YES) {
            [newNodeList addObject:node];
        }
    }
    
    return newNodeList;
}

-(void)updateNodesNear:(CLLocationCoordinate2D)coord
{
    [dataManager fetchNodesNear:coord];
    
}

-(void)updateNodesWithRegion:(MKCoordinateRegion)region
{
    CLLocationCoordinate2D southWest;
    CLLocationCoordinate2D northEast;
    southWest = CLLocationCoordinate2DMake(region.center.latitude-region.span.latitudeDelta/2.0f, region.center.longitude+region.span.longitudeDelta/2.0f);
    northEast = CLLocationCoordinate2DMake(region.center.latitude+region.span.latitudeDelta/2.0f, region.center.longitude-region.span.longitudeDelta/2.0f);
    
    [dataManager fetchNodesBetweenSouthwest:southWest northeast:northEast];
}

#pragma mark - Node List Delegate

/**
 * Called only on the iPhone
 */
- (void)nodeListView:(id<WMNodeListView>)nodeListView didSelectNode:(Node *)node
{
    // we don"t want to push a detail view when selecting a node on the map view, so
    // we check if this message comes from a table view
    if (node && [nodeListView isKindOfClass:[UITableViewController class]]) {
        [self pushDetailsViewControllerForNode:node];
    }
}

/**
 * Called only on the iPhone
 */
- (void) nodeListView:(id<WMNodeListView>)nodeListView didSelectDetailsForNode:(Node *)node
{
    if (node) {
        [self pushDetailsViewControllerForNode:node];
    }
}

- (void) pushDetailsViewControllerForNode:(Node*)node
{
    WMDetailViewController *detailViewController = [[UIStoryboard storyboardWithName:@"WMDetailView" bundle:nil] instantiateInitialViewController];
    detailViewController.node = node;
    [self pushViewController:detailViewController animated:YES];
}


#pragma mark - Location Manager Delegate

-(void) locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
	UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"No Loc Error Title", @"")
                                                        message:NSLocalizedString(@"No Loc Error Message", @"")
                                                       delegate:nil
                                              cancelButtonTitle:NSLocalizedString(@"OK", @"")
                                              otherButtonTitles:nil];
	[alertView show];
}

-(void) locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    [dataManager fetchNodesNear:newLocation.coordinate];
}


#pragma mark - Application Notifications

- (void) applicationDidBecomeActive:(NSNotification*)notification
{
    if (locationManager) {
        [locationManager startMonitoringSignificantLocationChanges];
    }
}

- (void)applicationWillResignActive:(NSNotification*)notification
{
	[locationManager stopUpdatingLocation];
}

#pragma mark - Push/Pop ViewControllers
- (void)pushFadeViewController:(UIViewController*)vc
{
    CATransition* transition = [CATransition animation];
    transition.duration = 0.3;
    transition.type = kCATransitionFade;
    transition.subtype = kCATransitionFromTop;
    
    [self.view.layer addAnimation:transition forKey:kCATransition];
    [self pushViewController:vc animated:NO];
}

-(void)popFadeViewController
{
    CATransition* transition = [CATransition animation];
    transition.duration = 0.3;
    transition.type = kCATransitionFade;
    transition.subtype = kCATransitionFromTop;
    
    [self.view.layer addAnimation:transition forKey:kCATransition];
    [self popViewControllerAnimated:NO];

}

- (void) pushViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    
    if ([viewController conformsToProtocol:@protocol(WMNodeListView)]) {
        id<WMNodeListView> nodeListViewController = (id<WMNodeListView>)viewController;
        nodeListViewController.dataSource = self;
        nodeListViewController.delegate = self;
    }
    
    [super pushViewController:viewController animated:animated];
    [self changeScreenStatusFor:viewController];
}
-(UIViewController*)popViewControllerAnimated:(BOOL)animated
{
    UIViewController* lastViewController = [super popViewControllerAnimated:animated];
    [self changeScreenStatusFor:[self.viewControllers lastObject]];
    
    return lastViewController;
}

-(NSArray*)popToRootViewControllerAnimated:(BOOL)animated
{
    NSArray* lastViewControllers = [super popToRootViewControllerAnimated:animated];
    
    return lastViewControllers;
}

-(NSArray*)popToViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    NSArray* lastViewControllers = [super popToViewController:viewController animated:animated];
    [self changeScreenStatusFor:[self.viewControllers lastObject]];
    
    return lastViewControllers;
}

-(void)setViewControllers:(NSArray *)viewControllers animated:(BOOL)animated
{
    [super setViewControllers:viewControllers animated:animated];
    [self changeScreenStatusFor:[viewControllers lastObject]];
}

-(void)changeScreenStatusFor:(UIViewController*)vc
{
    // show/hide navigation bar. only hide it on the dashboard!
    [self.customNavigationBar showNavigationBar];
    
    // if the current navigation stack size is 2,then we always show DashboardButton on the left
    WMNavigationBarLeftButtonStyle leftButtonStyle;
    WMNavigationBarRightButtonStyle rightButtonStyle;
    
    if (self.viewControllers.count == 2) {
        leftButtonStyle = kWMNavigationBarLeftButtonStyleDashboardButton;
    } else {
        // otherwise, default left button is BackButton. This will be changed according to the current screen later
        leftButtonStyle = kWMNavigationBarLeftButtonStyleBackButton;
        
    }
    
    // special left buttons and right button should be set according to the current screen
    
    if ([vc isKindOfClass:[WMMapViewController class]]) {
        self.customToolBar.toggleButton.selected = YES;
        if (self.viewControllers.count == 3) {
            leftButtonStyle = kWMNavigationBarLeftButtonStyleDashboardButton;   // single exception. this is the first level!
        }
        rightButtonStyle = kWMNavigationBarRightButtonStyleContributeButton;
    } else if ([vc isKindOfClass:[WMNodeListViewController class]]) {
        WMNodeListViewController* nodeListVC = (WMNodeListViewController*)vc;
        rightButtonStyle = kWMNavigationBarRightButtonStyleContributeButton;
        self.customToolBar.toggleButton.selected = NO;
        switch (nodeListVC.useCase) {
            case kWMNodeListViewControllerUseCaseNormal:
                nodeListVC.navigationBarTitle = @"Orte in deiner Nähe";
                [self.customToolBar showAllButtons];
                break;
            case kWMNodeListViewControllerUseCaseContribute:
                nodeListVC.navigationBarTitle = @"MITHELFEN";
                [self.customToolBar hideButton:kWMToolBarButtonWheelChairFilter];
                [self.customToolBar hideButton:kWMToolBarButtonCategoryFilter];
                rightButtonStyle = kWMNavigationBarRightButtonStyleNone;
                break;
            case kWMNodeListViewControllerUseCaseCategory:
                [self.customToolBar showButton:kWMToolBarButtonWheelChairFilter];
                [self.customToolBar hideButton:kWMToolBarButtonCategoryFilter];
                break;
            default:
                break;
        }
        
    } else if ([vc isKindOfClass:[WMDetailViewController class]]) {
        rightButtonStyle = kWMNavigationBarRightButtonStyleEditButton;
        [self hidePopover:wheelChairFilterPopover];
        [self hidePopover:categoryFilterPopover];
    } else if ([vc isKindOfClass:[WMWheelchairStatusViewController class]]) {
        rightButtonStyle = kWMNavigationBarRightButtonStyleSaveButton;
        leftButtonStyle = kWMNavigationBarLeftButtonStyleCancelButton;
        [self hidePopover:wheelChairFilterPopover];
        [self hidePopover:categoryFilterPopover];
    } else if ([vc isKindOfClass:[WMEditPOIViewController class]]) {
        rightButtonStyle = kWMNavigationBarRightButtonStyleSaveButton;
        leftButtonStyle = kWMNavigationBarLeftButtonStyleCancelButton;
        [self hidePopover:wheelChairFilterPopover];
        [self hidePopover:categoryFilterPopover];
        
    }  else if ([vc isKindOfClass:[WMShareSocialViewController class]]) {
        rightButtonStyle = kWMNavigationBarRightButtonStyleNone;
        leftButtonStyle = kWMNavigationBarLeftButtonStyleCancelButton;
        [self hidePopover:wheelChairFilterPopover];
        [self hidePopover:categoryFilterPopover];
        
    }
    
    self.customNavigationBar.leftButtonStyle = leftButtonStyle;
    self.customNavigationBar.rightButtonStyle = rightButtonStyle;
    if ([vc respondsToSelector:@selector(navigationBarTitle)]) {
        self.customNavigationBar.title = [vc performSelector:@selector(navigationBarTitle)];
    }
}

#pragma mark - WMNavigationBar Delegate
-(void)pressedDashboardButton:(WMNavigationBar *)navigationBar
{
    // In the future, the dashboard would be the root VC.
    [self popToRootViewControllerAnimated:YES];
    [self hidePopover:wheelChairFilterPopover];
    [self hidePopover:categoryFilterPopover];
}

-(void)pressedBackButton:(WMNavigationBar *)navigationBar
{
    [self popViewControllerAnimated:YES];
    [self hidePopover:wheelChairFilterPopover];
    [self hidePopover:categoryFilterPopover];
    
}

-(void)pressedCancelButton:(WMNavigationBar *)navigationBar
{
    [self popViewControllerAnimated:YES];
    
}

-(void)pressedContributeButton:(WMNavigationBar *)navigationBar
{
    NSLog(@"[NavigationControllerBase] pressed contribute button!");
}

-(void)pressedEditButton:(WMNavigationBar *)navigationBar
{
    WMViewController* currentViewController = [self.viewControllers lastObject];
    if ([currentViewController isKindOfClass:[WMDetailViewController class]]) {
        [(WMDetailViewController*)currentViewController pushEditViewController];
    }
}

-(void)pressedSaveButton:(WMNavigationBar *)navigationBar
{
    NSLog(@"[NavigationControllerBase] pressed save button!");
}
#pragma mark - WMToolBar Delegate
-(void)pressedToggleButton:(WMButton *)sender
{
    if ([self.topViewController isKindOfClass:[WMNodeListViewController class]]) {
        //  the node list view is on the screen. push the map view controller
        WMMapViewController* vc = [self.storyboard instantiateViewControllerWithIdentifier:@"WMMapViewController"];
        WMViewController* currentVC = (WMViewController*)self.topViewController;
        vc.navigationBarTitle = currentVC.navigationBarTitle;
        [self pushFadeViewController:vc];
        
    } else if ([self.topViewController isKindOfClass:[WMMapViewController class]]) {
        //  the map view is on the screen. pop the map view controller
        [self popFadeViewController];
    }
    
}

-(void)pressedCurrentLocationButton:(WMToolBar *)toolBar
{
    NSLog(@"[ToolBar] update current location button is pressed!");
    
}
-(void)pressedSearchButton:(WMToolBar *)toolBar
{
    NSLog(@"[ToolBar] global search button is pressed!");
}

-(void)pressedWheelChairStatusFilterButton:(WMToolBar *)toolBar
{
    NSLog(@"[ToolBar] wheelchair status filter buttton is pressed!");
    if (!categoryFilterPopover.hidden) {
        [self hidePopover:categoryFilterPopover];
    }
    
    if (wheelChairFilterPopover.hidden) {
        [self showPopover:wheelChairFilterPopover];
    } else {
        [self hidePopover:wheelChairFilterPopover];
    }
}

-(void)pressedCategoryFilterButton:(WMToolBar *)toolBar
{
    NSLog(@"[ToolBar] category filter button is pressed!");
    
    if (!wheelChairFilterPopover.hidden) {
        [self hidePopover:wheelChairFilterPopover];
    }
    
    if (categoryFilterPopover.hidden) {
        [self showPopover:categoryFilterPopover];
    } else {
        [self hidePopover:categoryFilterPopover];
    }
}

#pragma mark - Popover Management
-(void)showPopover:(UIView*)popover
{
    if (popover.hidden == NO)
        return;
    
    popover.alpha = 0.0;
    popover.transform = CGAffineTransformMakeTranslation(0, 10);
    popover.hidden = NO;
    [UIView animateWithDuration:0.3 animations:^(void)
     {
         popover.alpha = 1.0;
         popover.transform = CGAffineTransformMakeTranslation(0, 0);
     }
                     completion:^(BOOL finished)
     {
         
     }
     ];
}

-(void)hidePopover:(UIView*)popover
{
    if (popover.hidden == YES)
        return;
    
    popover.alpha = 1.0;
    [UIView animateWithDuration:0.3 animations:^(void)
     {
         popover.alpha = 0.0;
         popover.transform = CGAffineTransformMakeTranslation(0, 10);
     }
                     completion:^(BOOL finished)
     {
         popover.hidden = YES;
         popover.transform = CGAffineTransformMakeTranslation(0, 0);
         
     }
     ];
}

#pragma mark - WMWheelchairStatusFilter Delegate
-(void)pressedButtonOfDotType:(DotType)type selected:(BOOL)selected
{
    NSString* wheelchairStatusString = @"unknown";
    switch (type) {
        case kDotTypeGreen:
            self.customToolBar.wheelChairStatusFilterButton.selectedGreenDot = selected;
            wheelchairStatusString = @"yes";
            break;
            
        case kDotTypeYellow:
            self.customToolBar.wheelChairStatusFilterButton.selectedYellowDot = selected;
            wheelchairStatusString = @"limited";
            break;
            
        case kDotTypeRed:
            self.customToolBar.wheelChairStatusFilterButton.selectedRedDot = selected;
            wheelchairStatusString = @"no";
            break;
            
        case kDotTypeNone:
            self.customToolBar.wheelChairStatusFilterButton.selectedNoneDot = selected;
            wheelchairStatusString = @"unknown";
            break;
            
        default:
            break;
    }
    
    if (selected) {
        [self.wheelChairFilterStatus setObject:[NSNumber numberWithBool:YES] forKey:wheelchairStatusString];
    } else {
        [self.wheelChairFilterStatus setObject:[NSNumber numberWithBool:NO] forKey:wheelchairStatusString];
    }
    
    [self refreshNodeList];
    
}

-(void)clearWheelChairFilterStatus
{
    for (NSNumber* key in [self.wheelChairFilterStatus allKeys]) {
        [self.wheelChairFilterStatus setObject:[NSNumber numberWithBool:YES] forKey:key];
    }
}

#pragma mark -WMCategoryFilterPopoverView Delegate
-(void)categoryFilterStatusDidChangeForCategoryID:(NSNumber *)categoryID selected:(BOOL)selected
{
    if (selected) {
        [self.categoryFilterStatus setObject:[NSNumber numberWithBool:YES] forKey:categoryID];
    } else {
        [self.categoryFilterStatus setObject:[NSNumber numberWithBool:NO] forKey:categoryID];
    }
    
    [self refreshNodeList];
}

-(void)clearCategoryFilterStatus
{
    for (NSNumber* key in [self.categoryFilterStatus allKeys]) {
        [self.categoryFilterStatus setObject:[NSNumber numberWithBool:YES] forKey:key];
    }
}
@end




