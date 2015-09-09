//
//  FJViewController.m
//  FluentJ
//
//  Created by vlad gorbenko on 09/06/2015.
//  Copyright (c) 2015 vlad gorbenko. All rights reserved.
//

#import "FJViewController.h"

#import <AVFoundation/AVFoundation.h>

@interface FJViewController ()

@property (nonatomic, weak) IBOutlet UITextField *textField;
@property (nonatomic, weak) IBOutlet UIImageView *imageView;

@end

@implementation FJViewController

- (void)viewDidLoad {
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Toohgle

- (IBAction)toggle:(id)sender {
    self.textField.secureTextEntry = !self.textField.secureTextEntry;
    NSString *value = self.textField.text;
    [self.textField setText:@""];
    [self.textField setText:value];
}

@end
