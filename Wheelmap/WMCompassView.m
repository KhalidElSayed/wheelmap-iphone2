//
//  WMCompassView.m
//  Wheelmap
//
//  Created by Andrea Gerlach on 10.12.12.
//  Copyright (c) 2012 Sozialhelden e.V. All rights reserved.
//

#import "WMCompassView.h"

#define degreesToRadians(x) (M_PI * x / 180.0)
#define RAD_TO_DEG(r) ((r) * (180 / M_PI))

@implementation WMCompassView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        //Compass Images
        
        UIImage *compass = [UIImage imageNamed:@"details_compass.png"];
        UIImageView *arrowImg = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, compass.size.width, compass.size.height)];
        arrowImg.image = compass;
                                                           
        //Compass Container
                                                           
        self.compassContainer = [[UIView alloc] initWithFrame:CGRectMake(0, 0, compass.size.width, compass.size.height)];
     //   [self.compassContainer.layer  insertSublayer:myCompassLayer atIndex:0];
       

        [self.compassContainer addSubview:arrowImg];
        [self addSubview:self.compassContainer];
        self.locationManager = [[CLLocationManager alloc] init];
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        self.locationManager.delegate=self;
        [self.locationManager startUpdatingLocation];
                                                           
        //Start the compass updates.
        [self.locationManager startUpdatingHeading];
                                                           
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(stopUpdating:) name:UIApplicationDidEnterBackgroundNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(startUpdating:) name:UIApplicationDidBecomeActiveNotification object:nil];

        self.currentLocation = [CLLocation new];
                                                           
    }
    return self;
}

- (void) startUpdating:(NSNotification*)notification {
    NSLog(@"Starting");
    [self.locationManager startUpdatingHeading];
    [self.locationManager startUpdatingLocation];
}
          
- (void) stopUpdating:(NSNotification*)notification {
    NSLog(@"Stopping");
    [self.locationManager stopUpdatingHeading];
    [self.locationManager stopUpdatingLocation];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
    
    self.currentLocation = newLocation;
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    
    self.currentLocation = [locations lastObject];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateHeading:(CLHeading *)newHeading {
    
    self.nodeLocation = [[CLLocation alloc] initWithLatitude:self.node.lat.doubleValue longitude:self.node.lon.doubleValue];
    
    float angle = [self angleFromCoordinate:self.currentLocation.coordinate toCoordinate:self.nodeLocation.coordinate];
    
    CLLocationDegrees oldDegrees = RAD_TO_DEG(angle);
 
    float newDegrees = oldDegrees - 180;
    if (newDegrees < 0) {
        newDegrees = newDegrees + 360;
    }
    
    
	NSInteger magneticAngle = newHeading.magneticHeading;
    NSInteger trueAngle = newHeading.trueHeading;

    
   // NSLog(@"XXXXX name: %@ // degrees: %f // heading: %d \n ", self.node.name, newDegrees, trueAngle);
    
    //This is set by a switch in my apps settings //
    
    NSUserDefaults *prefs= [NSUserDefaults standardUserDefaults];
    BOOL magneticNorth = [prefs boolForKey:@"UseMagneticNorth"];
    
    float newAngle;
    
    if (magneticNorth == YES) {
        //  NSLog(@"using magnetic north");
        
        newAngle = newDegrees-magneticAngle;
        
        CGAffineTransform rotate = CGAffineTransformMakeRotation(degreesToRadians(newAngle));
        [self.compassContainer setTransform:rotate];
    } else {
        // NSLog(@"using true north");
        
        newAngle = newDegrees-trueAngle;
        
        CGAffineTransform rotate = CGAffineTransformMakeRotation(degreesToRadians(newAngle));
        [self.compassContainer setTransform:rotate];
    }

}


- (float)angleFromCoordinate:(CLLocationCoordinate2D)poi toCoordinate:(CLLocationCoordinate2D)user {
    
    float longitudinalDifference    = poi.longitude - user.longitude;
    float latitudinalDifference     = poi.latitude  - user.latitude;
    float possibleAzimuth           = (M_PI * .5f) - atan(latitudinalDifference / longitudinalDifference);
    
    if (longitudinalDifference > 0)
        return possibleAzimuth;
    else if (longitudinalDifference < 0)
        return possibleAzimuth + M_PI;
    else if (latitudinalDifference < 0)
        return M_PI;
    
    return 0.0f;
}




 
@end
