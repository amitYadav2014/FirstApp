//
//  ViewController.h
//  TimeLine
//
//  Created by Amit Yadav on 28/07/14.
//  Copyright (c) 2014 creativefisher. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController<UITableViewDataSource,UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tblTimeLine;

@end
