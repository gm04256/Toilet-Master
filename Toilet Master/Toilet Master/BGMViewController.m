//
//  BGMViewController.m
//  Toilet Master
//
//  Created by 馬 岩 on 14-7-1.
//  Copyright (c) 2014年 馬 岩. All rights reserved.
//

#import "BGMViewController.h"

@interface BGMViewController ()

@property (weak, nonatomic) IBOutlet UILabel *menLabel;
@property (weak, nonatomic) IBOutlet UILabel *womenLabel;
@property NSTimer* checkTimer;

@property (strong, nonatomic) CLBeaconRegion *myBeaconRegion;
@property (strong, nonatomic) CLLocationManager *locationManager;
@property NSArray* beacons;

@property BOOL isUsingMenToilet, isUsingWomenToilet;

@end

@implementation BGMViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
	
	self.isUsingMenToilet = false;
	self.isUsingWomenToilet = false;
	
	self.checkTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(checkSchedule) userInfo:nil repeats:YES];
	
	// Initialize location manager and set ourselves as the delegate
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    
    // Create a NSUUID with the same UUID as the broadcasting beacon
    NSUUID *uuid = [[NSUUID alloc] initWithUUIDString:@"00000000-1BDB-1001-B000-001C4D0064C5"];
    
    // Setup a new region with that UUID and same identifier as the broadcasting beacon
    self.myBeaconRegion = [[CLBeaconRegion alloc] initWithProximityUUID:uuid identifier:@"com.appcoda.testregion"];
	//	self.myBeaconRegion = [[CLBeaconRegion alloc] initWithProximityUUID:uuid major:1 minor:2 identifier:@"com.appcoda.testregion"];
	
	self.myBeaconRegion.notifyOnEntry = YES;
	self.myBeaconRegion.notifyEntryStateOnDisplay = YES;
	self.myBeaconRegion.notifyOnExit = YES;
    
    // Tell location manager to start monitoring for the beacon region
    [self.locationManager startMonitoringForRegion:self.myBeaconRegion];
	
	// for some unknown reason, ranging cannot start in didEnterRegion when the device is within the region
	[self.locationManager startRangingBeaconsInRegion:self.myBeaconRegion];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Timer Schedule

- (void)checkSchedule
{
	NSLog(@"%@", NSStringFromSelector(_cmd));
	
	// get data from server
	NSURL* url = [NSURL URLWithString:@"http://192.168.14.29:8888/toilet/check.php"];
	
	NSURLRequest *request = [[NSURLRequest alloc]initWithURL:url];
	
	NSData *received = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
	
	// update label
	NSDictionary* dic = [NSJSONSerialization JSONObjectWithData:received options:NSJSONReadingMutableLeaves error:nil];
	
//	NSLog(@"Men: %@, Women: %@", dic[@"men"], dic[@"women"]);
	if([dic[@"men"] isEqualToString:@"yes"])
	{
		[self.menLabel setBackgroundColor:[UIColor redColor]];
	}
	else
	{
		[self.menLabel setBackgroundColor:[UIColor greenColor]];
	}
	
	if ([dic[@"women"] isEqualToString: @"yes"])
	{
		[self.womenLabel setBackgroundColor:[UIColor redColor]];
	}
	else
	{
		[self.womenLabel setBackgroundColor:[UIColor greenColor]];
	}
}


#pragma mark - Location Manager Delegate

- (void)locationManager:(CLLocationManager*)manager didEnterRegion:(CLRegion*)region
{
	NSLog(@"%@", NSStringFromSelector(_cmd));
	[[[UIAlertView alloc] initWithTitle:NSStringFromSelector(_cmd) message:NSStringFromSelector(_cmd) delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil] show];
	
    [self.locationManager startRangingBeaconsInRegion:self.myBeaconRegion];
}

-(void)locationManager:(CLLocationManager*)manager didExitRegion:(CLRegion*)region
{
	NSLog(@"%@", NSStringFromSelector(_cmd));
	[[[UIAlertView alloc] initWithTitle:NSStringFromSelector(_cmd) message:NSStringFromSelector(_cmd) delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil] show];
	
    [self.locationManager stopRangingBeaconsInRegion:self.myBeaconRegion];
}

-(void)locationManager:(CLLocationManager*)manager
       didRangeBeacons:(NSArray*)beacons
              inRegion:(CLBeaconRegion*)region
{
	NSLog(@"%@", NSStringFromSelector(_cmd));
	
	self.beacons = beacons;
	
	[self solveBeaconData];
}

- (void)solveBeaconData
{
	for (int i = 0; i < [self.beacons count]; i++)
	{
		CLBeacon* beacon = self.beacons[i];
		
		switch ([beacon.minor integerValue])
		{
			case 1:// men
			if (beacon.accuracy < 0.5)
			{
				// send enter request with uuid of the user
				NSURL* url = [NSURL URLWithString:@"http://192.168.14.29:8888/toilet/men/enter.php"];
				NSURLRequest *request = [[NSURLRequest alloc]initWithURL:url];
				[NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
				self.isUsingMenToilet = true;
			}
			else
			{
				// if server's uuid is equal to user's uuid, send exit request
				if (self.isUsingMenToilet)
				{
					NSURL* url = [NSURL URLWithString:@"http://192.168.14.29:8888/toilet/men/exit.php"];
					NSURLRequest *request = [[NSURLRequest alloc]initWithURL:url];
					[NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
					self.isUsingMenToilet = false;
				}
			}
			break;
			
			case 2:// women
			if (beacon.accuracy < 0.5)
			{
				// send enter request with uuid of the user
				NSURL* url = [NSURL URLWithString:@"http://192.168.14.29:8888/toilet/women/enter.php"];
				NSURLRequest *request = [[NSURLRequest alloc]initWithURL:url];
				[NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
				self.isUsingWomenToilet = true;
			}
			else
			{
				// if server's uuid is equal to user's uuid, send exit request
				if (self.isUsingWomenToilet)
				{
					NSURL* url = [NSURL URLWithString:@"http://192.168.14.29:8888/toilet/women/exit.php"];
					NSURLRequest *request = [[NSURLRequest alloc]initWithURL:url];
					[NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
					self.isUsingWomenToilet = false;
				}
			}
			break;
			
			default:
			break;
		}
	}
	
//    cell.textLabel.text = beacon.proximityUUID.UUIDString;
//	cell.detailTextLabel.text = [NSString stringWithFormat:@"major: %@, minor: %@, Proximity: %ld, Acc: %f, Rssi: %ld", beacon.major, beacon.minor, beacon.proximity, beacon.accuracy, beacon.rssi];
}

@end
