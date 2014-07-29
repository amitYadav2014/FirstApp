//
//  CustomCell.h
//  TimeLine
//
//  Created by Amit Yadav on 29/07/14.
//  Copyright (c) 2014 creativefisher. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CustomCell : UITableViewCell
@property(nonatomic,weak)IBOutlet UILabel* lblName;
@property(nonatomic,weak)IBOutlet UILabel* lblText;
@property(nonatomic,weak)IBOutlet UILabel* lblDate;

@end
