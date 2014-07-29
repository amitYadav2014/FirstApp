//
//  ViewController.m
//  TimeLine
//
//  Created by Amit Yadav on 28/07/14.
//  Copyright (c) 2014 creativefisher. All rights reserved.
//

#import "ViewController.h"
#import "CustomCell.h"
#import "AsyncImageView.h"
@interface ViewController ()
{
    NSMutableArray* arrTimeLine;
    NSMutableDictionary* dict;
    BOOL isFirst;
}
@property(nonatomic,strong)CustomCell* customcell;
@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    isFirst = YES;
    [self service];
    
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl addTarget:self action:@selector(refresh:) forControlEvents:UIControlEventValueChanged];
    [self.tblTimeLine addSubview:refreshControl];
    
	// Do any additional setup after loading the view, typically from a nib.
}

#pragma mark
#pragma  mark - tableview

// Required Methods for UitableviewDataSouurce

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSLog(@"Main Array : %@",arrTimeLine);
   return  [arrTimeLine count];
}
-(UITableViewCell*) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    #define IMAGE_VIEW_TAG 99
    CustomCell* cell = [self.tblTimeLine dequeueReusableCellWithIdentifier:@"normalCell"];
    cell.lblName.text = [[arrTimeLine objectAtIndex:indexPath.row] valueForKey:@"name"];
    cell.lblText.text = [[arrTimeLine objectAtIndex:indexPath.row] valueForKey:@"text"];
    cell.lblDate.text = [[arrTimeLine objectAtIndex:indexPath.row] valueForKey:@"created_at"];
    
    NSString* strImgUrl = [[arrTimeLine objectAtIndex:indexPath.row] valueForKey:@"imgUrl"];
    
    
    AsyncImageView *imageView = [[AsyncImageView alloc] initWithFrame:CGRectMake(10.0f, 8.0f, 44.0f, 44.0f)];
    imageView.contentMode = UIViewContentModeScaleAspectFill;
    imageView.clipsToBounds = YES;
    imageView.tag = IMAGE_VIEW_TAG;
    [cell addSubview:imageView];

    
    //get image view
	imageView = (AsyncImageView *)[cell viewWithTag:IMAGE_VIEW_TAG];
	
    //cancel loading previous image for cell
    [[AsyncImageLoader sharedLoader] cancelLoadingImagesForTarget:imageView];
    
    //load the image
    imageView.imageURL = [NSURL URLWithString:strImgUrl];
    
    [cell addSubview:imageView];
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    imageView.layer.cornerRadius=8.0f;
    imageView.layer.masksToBounds = YES;
    return cell;
}


// Variable height support - delegate method
-(float)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat rowHeight=0;
    if(!self.customcell)
    {
        self.customcell = [self.tblTimeLine dequeueReusableCellWithIdentifier:@"normalCell"];
    }

    // configure the cell
   self.customcell.lblText.text = [[arrTimeLine objectAtIndex:indexPath.row] valueForKey:@"text"];
    
    // force layout
    [self.customcell layoutIfNeeded];
    
    // get the fitting size
    rowHeight = [self.customcell.contentView systemLayoutSizeFittingSize: UILayoutFittingCompressedSize].height;

    return rowHeight;

}


#pragma mark
#pragma mark - ServerSide code.

-(void)service
{
   
    
    NSString *url = @"https://alpha-api.app.net/stream/0/posts/stream/global";
    NSMutableURLRequest *request = [NSMutableURLRequest
                                    requestWithURL:[NSURL URLWithString:url]];
    if (isFirst)
         [self StartProgressBar:@"loading..." superView:self.view];
    self.tblTimeLine.delegate = Nil;
    self.tblTimeLine.dataSource = Nil;
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *error)
     {
        if (isFirst)
         [self StopProgressBar:self.view];
         isFirst= NO;
         
         NSError *err = nil ;
         NSDictionary   *responseDict = [NSJSONSerialization JSONObjectWithData :data options : 0 error :&err];
         
         NSArray* arr1 = [responseDict objectForKey : @"data"];
        // NSArray* arr2 = [responseDict objectForKey : @"meta"];
          arrTimeLine = [[NSMutableArray alloc]init];
         for(int i =0 ; i<[arr1 count];i++)
         {
             dict = [[NSMutableDictionary alloc]init];
             NSDictionary* dict1 = [[arr1 objectAtIndex:i]valueForKey:@"source"];
             NSString* strDate = [[arr1 objectAtIndex:i]valueForKey:@"created_at"];
             [dict setValue:[dict1 objectForKey:@"name"] forKey:@"name"];
             [dict setValue:[[arr1 objectAtIndex:i]valueForKey:@"text"] forKey:@"text"];
             [dict setValue:strDate forKey:@"created_at"];
              dict1 = [[arr1 objectAtIndex:i]valueForKey:@"user"];
              dict1 = [dict1 valueForKey:@"avatar_image"];
             [dict setValue:[dict1 objectForKey:@"url"] forKey:@"imgUrl"];
             
             [arrTimeLine addObject:dict];
         }
         
         self.tblTimeLine.delegate = self;
         self.tblTimeLine.dataSource = self;
        [self.tblTimeLine reloadData];
     }];
    
  
}

#pragma mark
#pragma mark - refreshControl-Pulltoreferesh


- (void)refresh:(UIRefreshControl *)refreshControl
{
    [self service];
    [refreshControl endRefreshing];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



#pragma mark
#pragma mark - activityIndicator


-(void)StartProgressBar:(NSString *)strMessgae superView:(UIView *)view
{
    
    UIView *alertView=[[UIView alloc] initWithFrame:CGRectMake((view.frame.size.width/2)-50, (view.frame.size.height/2)-80, 100, 70)];
    alertView.tag=505;
    [alertView setBackgroundColor:[UIColor blackColor]];
    [alertView setAlpha:.7];
    alertView.layer.cornerRadius=8.0f;
    
    UIActivityIndicatorView *activityIndicator = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    [activityIndicator setFrame:CGRectMake((alertView.frame.size.width/2)-25, 20, 55, 30)];
    [activityIndicator startAnimating];
    [alertView addSubview:activityIndicator];
    view.userInteractionEnabled = NO;
    self.navigationController.view.userInteractionEnabled = NO;
    [view addSubview:alertView];
    
    
}

-(void)StopProgressBar:(UIView *)view
{
    //[alertProgressBar dismissWithClickedButtonIndex:0 animated:YES];
    UIView *subView=(UIView *)[view viewWithTag:505];
    
    if (subView)
        [subView removeFromSuperview];
    
    view.userInteractionEnabled = YES;
    self.navigationController.view.userInteractionEnabled = YES;
    
}

@end
