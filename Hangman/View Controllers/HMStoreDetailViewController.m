//
//  HMStoreDetailViewController.m
//  Hangman
//
//  Created by Ray Wenderlich on 7/12/12.
//  Copyright (c) 2012 Ray Wenderlich. All rights reserved.
//

#import "HMStoreDetailViewController.h"

@interface HMStoreDetailViewController ()
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *priceLabel;
@property (weak, nonatomic) IBOutlet UILabel *versionLabel;
@property (weak, nonatomic) IBOutlet UITextView *descriptionTextView;
@property (weak, nonatomic) IBOutlet UILabel *statusLabel;
@property (weak, nonatomic) IBOutlet UIProgressView *progressView;
@property (weak, nonatomic) IBOutlet UIButton *pauseButton;
@property (weak, nonatomic) IBOutlet UIButton *resumeButton;
@property (weak, nonatomic) IBOutlet UIButton *cancelButton;
@end

@implementation HMStoreDetailViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	
    // Set background color
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"bg.png"]];
        
}

#pragma mark - Callbacks
 
- (void)buyTapped:(id)sender {
}

- (IBAction)pauseTapped:(id)sender {
}

- (IBAction)resumeTapped:(id)sender {
}

- (IBAction)cancelTapped:(id)sender {
}

@end
