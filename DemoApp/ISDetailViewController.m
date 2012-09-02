//
//  ISDetailViewController.m
//  ISNetwork
//
//  Created by Yosuke Ishikawa on 2012/09/02.
//  Copyright (c) 2012年 Yosuke Ishikawa. All rights reserved.
//

#import "ISDetailViewController.h"

@interface ISDetailViewController ()

@end

@implementation ISDetailViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
