//
//  HMStoreListViewController.m
//  Hangman
//
//  Created by Ray Wenderlich on 7/12/12.
//  Copyright (c) 2012 Ray Wenderlich. All rights reserved.
//

#import "HMStoreListViewController.h"
#import "HMStoreListViewCell.h"

@implementation HMStoreListViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStyleBordered target:self action:@selector(doneTapped:)];
    }
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Restore" style:UIBarButtonItemStyleBordered target:self action:@selector(restoreTapped:)];
            
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    HMStoreListViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    return cell;
}

#pragma mark - Callbacks

- (void)doneTapped:(id)sender {
}

- (void)restoreTapped:(id)sender {
    // Testing purposes only
    [self performSegueWithIdentifier:@"PushDetail" sender:nil];
}

@end
