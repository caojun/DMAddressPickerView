//
//  ViewController.m
//  DMAddressPickerViewDemo
//
//  Created by Dream on 15/12/30.
//  Copyright © 2015年 DM. All rights reserved.
//

#import "ViewController.h"
#import "DMAddressPickerView.h"

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UILabel *m_label;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapHandler)];
    [self.view addGestureRecognizer:tap];
}


- (void)tapHandler
{
    [DMAddressPickerView showInView:self.view didSelectAreaBlock:^(NSString *areaString) {
        self.m_label.text = areaString;
        NSLog(@"areaString = %@", areaString);
    }];
}


@end
