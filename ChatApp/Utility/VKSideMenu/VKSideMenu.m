//
//  VKSideMenu.m
//
//  Created by Vladislav Kovalyov on 2/7/16.
//  Copyright © 2016 WOOPSS.com (http://woopss.com/)
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import "VKSideMenu.h"
#import <FirebaseAuth/FirebaseAuth.h>

#define SYSTEM_VERSION_LESS_THAN(v) ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)
#define ROOTVC [[[[UIApplication sharedApplication] delegate] window] rootViewController]
#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

@implementation VKSideMenuItem

@synthesize icon;
@synthesize title;
@synthesize tag;

@end

@interface VKSideMenu() <UITableViewDelegate, UITableViewDataSource>
{
    UITapGestureRecognizer *tapGesture;
}

@property (nonatomic, strong) UIView *overlay;

@end

@implementation VKSideMenu

#pragma mark - Initialization

-(instancetype)init
{
    if (self = [super init])
    {
        [self baseInit];
    }
    
    return self;
}

-(instancetype)initWithWidth:(CGFloat)width andDirection:(VKSideMenuDirection)direction
{
    if ((self = [super init]))
    {
        [self baseInit];
        
        self.width      = width;
        self.direction  = direction;
    }
    
    return self;
}

-(void)baseInit
{
    self.width                      = 220;
    self.direction                  = VKSideMenuDirectionLeftToRight;
    self.enableOverlay              = YES;
    self.automaticallyDeselectRow   = YES;
    self.hideOnSelection            = YES;
    
    self.sectionTitleFont   = [UIFont systemFontOfSize:15.];
    self.selectionColor     = [UIColor colorWithWhite:1. alpha:.5];
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    self.backgroundColor    = [UIColor colorWithWhite:1. alpha:.8];
#pragma clang diagnostic pop
    self.textColor          = UIColorFromRGB(0x252525);
    self.iconsColor         = UIColorFromRGB(0x8f8f8f);
    self.sectionTitleColor  = UIColorFromRGB(0x8f8f8f);
    
    if(!SYSTEM_VERSION_LESS_THAN(@"8.0"))
        self.blurEffectStyle = UIBlurEffectStyleExtraLight;
}

-(void)initViews
{
    self.overlay = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.overlay.alpha = 0;
    self.overlay.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    if (self.enableOverlay)
        self.overlay.backgroundColor = [UIColor colorWithWhite:0. alpha:.4];
    
    tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTap:)];
    [self.overlay addGestureRecognizer:tapGesture];
    
    CGRect frame = [self frameHidden];
    
    if(SYSTEM_VERSION_LESS_THAN(@"8.0"))
    {
        self.view = [[UIView alloc] initWithFrame:frame];
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        self.view.backgroundColor = self.backgroundColor;
#pragma clang diagnostic pop
    }
    else
    {
        UIVisualEffect *blurEffect = [UIBlurEffect effectWithStyle:self.blurEffectStyle];
        self.view = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
        self.view.frame = frame;
    }
    
    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    
    self.tableView.delegate         = self;
    self.tableView.dataSource       = self;
    self.tableView.scrollEnabled = false;
    self.tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    [self.view addSubview:self.tableView];

    UIButton *btnClose = [[UIButton alloc]initWithFrame:CGRectMake(0,[UIScreen mainScreen].bounds.size.height-40 , self.width, 40)];
    [btnClose setTitle:@"Log out" forState:UIControlStateNormal];
    [btnClose addTarget:self action:@selector(closeMenu:) forControlEvents:UIControlEventTouchUpInside];
    btnClose.titleLabel.font = [UIFont systemFontOfSize:14.0];
    [btnClose setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    
   // [self.view addSubview:btnClose];
}
-(void)closeMenu:(UIButton *)sender
{
    if (_delegate && [_delegate respondsToSelector:@selector(logoutButtonAction)])
        [_delegate logoutButtonAction];

    [self hide];
}


#pragma mark - Appearance

-(void)show
{
    [self initViews];
    
    [ROOTVC.view addSubview:self.overlay];
    [ROOTVC.view addSubview:self.view];
    
    CGRect frame = [self frameShowed];
    
    [UIView animateWithDuration:0.275 animations:^
     {
         self.view.frame = frame;
         self.overlay.alpha = 1.0;
     }
                     completion:^(BOOL finished)
     {
         if (_delegate && [_delegate respondsToSelector:@selector(sideMenuDidShow:)])
             [_delegate sideMenuDidShow:self];
     }];
}

-(void)showWithWidth:(CGFloat)width
{
    self.width = width;
    [self show];
}

-(void)hide
{
    [UIView animateWithDuration:0.275 animations:^
     {
         self.view.frame = [self frameHidden];
         self.overlay.alpha = 0.;
     }
                     completion:^(BOOL finished)
     {
         if (_delegate && [_delegate respondsToSelector:@selector(sideMenuDidHide:)])
             [_delegate sideMenuDidHide:self];
         
         [self.view removeFromSuperview];
         [self.overlay removeFromSuperview];
         [self.overlay removeGestureRecognizer:tapGesture];
         
         self.overlay = nil;
         self.tableView = nil;
         self.view = nil;
     }];
}

#pragma mark - UITableViewDataSource

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [self.dataSource numberOfSectionsInSideMenu:self];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.dataSource sideMenu:self numberOfRowsInSection:section];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    UIImageView *imageViewIcon;
    UILabel *title;
    tableView.separatorStyle = UITableViewCellSelectionStyleNone;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
      /*  if(indexPath.row % 2 == 0){
                    cell.backgroundColor = [UIColor whiteColor];
        }else{
                    cell.backgroundColor = [UIColor blackColor];
        }
*/
        
       // UIView *bgColorView = [[UIView alloc] init];
       // [bgColorView setBackgroundColor:self.selectionColor];
       // [cell setSelectedBackgroundView:bgColorView];
    }
    
    VKSideMenuItem *item = [self.dataSource sideMenu:self itemForRowAtIndexPath:indexPath];
    
    CGFloat contentHeight = cell.frame.size.height * .8;
    CGFloat contentTopBottomPadding = cell.frame.size.height * .1;
    
    if (item.icon)
    {
        imageViewIcon = [cell.contentView viewWithTag:100];
        
        if (!imageViewIcon)
        {
           // imageViewIcon = [[UIImageView alloc] initWithFrame:CGRectMake(20, contentTopBottomPadding, contentHeight, contentHeight)];
            
            
         imageViewIcon = [[UIImageView alloc] initWithFrame:CGRectMake(self.width/3, 20, contentHeight, contentHeight)];
            
            imageViewIcon.center = CGPointMake(self.width/2, imageViewIcon.center.y);
            
            imageViewIcon.tag = 100;
            [cell.contentView addSubview:imageViewIcon];
        }
        
        imageViewIcon.image = item.icon;
      //  imageViewIcon.backgroundColor = [UIColor redColor];
        [imageViewIcon setContentMode:UIViewContentModeCenter];
        
        if (self.iconsColor)
        {
            imageViewIcon.image = [imageViewIcon.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
            imageViewIcon.tintColor = self.iconsColor;
        }
    }
    
    title = [cell.contentView viewWithTag:200];
    
    if (!title)
    {
       /* CGFloat titleX = item.icon ? CGRectGetMaxX(imageViewIcon.frame) + 12 : 12;
        
        title = [[UILabel alloc] initWithFrame:CGRectMake(titleX, contentTopBottomPadding, cell.frame.size.width - titleX - 12, contentHeight)];
        */
        CGFloat titleX = item.icon ? CGRectGetMaxX(imageViewIcon.frame) + 12 : 12;
        
        title = [[UILabel alloc] initWithFrame:CGRectMake(0, imageViewIcon.frame.origin.y+imageViewIcon.frame.size.width, self.width , contentHeight)];
        
        //[title setTextAlignment:NSTextAlignmentCenter];
        title.textAlignment = NSTextAlignmentCenter;
      //  title.backgroundColor = [UIColor redColor] ;
        title.tag = 200;
        title.font = [UIFont systemFontOfSize:14.0];
        title.adjustsFontSizeToFitWidth = YES;
        [cell.contentView addSubview:title];
        
        
        UIImageView *line = [[UIImageView alloc]initWithFrame:CGRectMake(0, title.frame.origin.y+title.frame.size.height+15, self.width, 1)];
        line.backgroundColor =[[UIColor lightGrayColor]colorWithAlphaComponent:0.2];
       // line.backgroundColor =[UIColor colorWithRed:242 green:242 blue:242 alpha:1];
        [cell.contentView addSubview:line];
        
        
    }
    
    title.text      = item.title;
    title.textColor = [UIColor blackColor];
    
    
    return cell;
}

#pragma mark - UITableViewDelegate

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (_delegate && [_delegate respondsToSelector:@selector(sideMenu:didSelectRowAtIndexPath:)])
        [_delegate sideMenu:self didSelectRowAtIndexPath:indexPath];
    
    if (self.automaticallyDeselectRow)
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (self.hideOnSelection)
        [self hide];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 100;
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(sideMenu:titleForHeaderInSection:)])
        return [self.delegate sideMenu:self titleForHeaderInSection:section].uppercaseString;
    
    return nil;
}

- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section
{
    view.tintColor = [UIColor clearColor];
    
    UITableViewHeaderFooterView *header = (UITableViewHeaderFooterView *)view;
    [header.textLabel setTextColor:self.sectionTitleColor];
    [header.textLabel setFont:self.sectionTitleFont];
}

#pragma mark - UITapGestureRecognition

-(void)didTap:(UIGestureRecognizer *)gesture
{
    if (gesture.state == UIGestureRecognizerStateEnded)
        [self hide];
}

#pragma mark - Helpers

-(CGRect)frameHidden
{
    CGFloat x = self.direction == VKSideMenuDirectionLeftToRight ? -self.width : [UIScreen mainScreen].bounds.size.width + self.width;
    return CGRectMake(x, 0, self.width, [UIScreen mainScreen].bounds.size.height);
}

-(CGRect)frameShowed
{
    CGFloat x = self.direction == VKSideMenuDirectionLeftToRight ? 0 : [UIScreen mainScreen].bounds.size.width - self.width;
    return CGRectMake(x, 0, self.width, self.view.frame.size.height);
}

@end
