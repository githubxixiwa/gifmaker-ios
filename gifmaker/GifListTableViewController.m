//
//  GifListTableViewController.m
//  gifmaker
//
//  Created by Sergio on 11/23/15.
//  Copyright © 2015 Cayugasoft. All rights reserved.
//

// View Controllers
#import "GifListTableViewController.h"

// Models
#import "GifManager.h"
#import "FLAnimatedImage.h"
#import "GifTableViewCell.h"

@interface GifListTableViewController()

@property (nonatomic, strong) NSMutableArray<GifElement *> *gifElements;

@end

@implementation GifListTableViewController

- (void)viewDidLoad {
    self.navigationItem.title = @"GifMaker";
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCamera target:self action:@selector(shootGIFFromCamera:)];
    
    // Refresh GIF-files from storage
    [self refresh];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.gifElements.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    GifTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"reuseIdentifier" forIndexPath:indexPath];
    cell.gifView.animatedImage = [FLAnimatedImage animatedImageWithGIFData:[NSData dataWithContentsOfURL:[self.gifElements[indexPath.row] gifURL]]];
    return cell;
}

- (void)shootGIFFromCamera:(id)sender {
    [self performSegueWithIdentifier:@"toRecordSegue" sender:self];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    ((RecordViewController*)segue.destinationViewController).delegate = self;
}

- (void)refresh {
    self.gifElements = [NSMutableArray array];
    
    // Load GIF-metadata files
    NSArray<NSURL *> *metadataFilesFromStorage = [GifManager localMetadataFilesPaths];
    for (NSURL *metadataFileURL in metadataFilesFromStorage) {
        GifElement *gifElement = [[GifElement alloc] initWithMetadataFile:metadataFileURL];
        [self.gifElements addObject:gifElement];
    }
    
    self.gifElements = [NSMutableArray arrayWithArray:[self.gifElements sortedArrayUsingComparator:^NSComparisonResult(GifElement *a, GifElement *b) {
        return a.datePosted < b.datePosted;
    }]];
    
    [self.tableView reloadData];
}

@end
