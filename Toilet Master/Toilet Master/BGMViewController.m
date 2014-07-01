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
@end

@implementation BGMViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
	
	self.checkTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(checkSchedule) userInfo:nil repeats:YES];
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
	
	NSLog(@"Men: %@, Women: %@", dic[@"men"], dic[@"women"]);
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

@end
