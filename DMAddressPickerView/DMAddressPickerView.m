/**
 The MIT License (MIT)
 
 Copyright (c) 2015 Jun
 
 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in all
 copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 SOFTWARE.
 */

#import "DMAddressPickerView.h"
#import "DMAddressProvinceItem.h"
#import "DMAddressCountyItem.h"


static const CGFloat kDMAddressPickerViewDuration = 0.3;
static const CGFloat kDMAddressTitleBGViewHeight = 40;

@interface DMAddressPickerView ()  <UIPickerViewDataSource, UIPickerViewDelegate>

@property (nullable, nonatomic, strong) DMAddressPickerViewSelectBlock m_selectBlock;

/// 存放 DMAddressProvinceItem
@property (nullable, nonatomic, strong) NSArray<DMAddressProvinceItem *> *m_cityList;

@property (nullable, nonatomic, strong) UIPickerView *m_pickerView;
@property (nullable, nonatomic, strong) UIButton *m_btn;

@property (nullable, nonatomic, strong) UIView *m_bottomBGView;
@property (nullable, nonatomic, strong) UIView *m_titleBGView;

@end

@implementation DMAddressPickerView

+ (nonnull instancetype)showInView:(nonnull UIView *)superView
                didSelectAreaBlock:(nullable DMAddressPickerViewSelectBlock)block
{
    DMAddressPickerView *view = nil;
    
    if (nil != superView)
    {
        view = [self addressPickerView];
        view.m_selectBlock = [block copy];
        
        [superView addSubview:view];
        
        __block CGRect frame = view.m_bottomBGView.frame;
        frame.origin.y = view.frame.size.height;
        view.m_bottomBGView.frame = frame;
        view.backgroundColor = [UIColor clearColor];

        [UIView animateWithDuration:kDMAddressPickerViewDuration animations:^{
            frame.origin.y = view.frame.size.height - frame.size.height;
            view.m_bottomBGView.frame = frame;
            view.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.4];
        }];
    }
    
    return view;
}

- (void)dismiss
{
    [UIView animateWithDuration:kDMAddressPickerViewDuration animations:^{
        CGRect frame = self.m_bottomBGView.frame;
        frame.origin.y = self.frame.size.height;
        self.m_bottomBGView.frame = frame;
        self.backgroundColor = [UIColor clearColor];
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}

+ (instancetype)addressPickerView
{
    CGRect frame = [UIScreen mainScreen].bounds;
    
    return [[self alloc] initWithFrame:frame];
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        [self defaultSetting];
    }
    
    return self;
}

- (void)defaultSetting
{
    self.backgroundColor = [UIColor clearColor];
    
    UIView *bottomBGView = [[UIView alloc] init];
    self.m_bottomBGView = bottomBGView;
    bottomBGView.backgroundColor = [UIColor whiteColor];
    
    UIPickerView *pickerView = [[UIPickerView alloc] init];
    [bottomBGView addSubview:pickerView];
    self.m_pickerView = pickerView;
    pickerView.backgroundColor = [UIColor whiteColor];

    pickerView.delegate = self;
    pickerView.dataSource = self;
    
    UIView *titleBGView = [[UIView alloc] init];
    [bottomBGView addSubview:titleBGView];
    self.m_titleBGView = titleBGView;
    titleBGView.backgroundColor = [UIColor clearColor];
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [titleBGView addSubview:btn];
    self.m_btn = btn;
    [btn setTitle:@"确定" forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(btnClick) forControlEvents:UIControlEventTouchUpInside];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapHandler:)];
    [self addGestureRecognizer:tap];
    
    [self decodeAddressFile];
    
    [self addSubview:self.m_bottomBGView];
    [self adjustSubViewsFrame];
}

- (void)tapHandler:(UITapGestureRecognizer *)tap
{
    CGPoint point = [tap locationInView:self];
    
    CGFloat viewHeight = CGRectGetHeight(self.bounds);
    CGFloat bottomBGHeight = kDMAddressTitleBGViewHeight + CGRectGetHeight(self.m_pickerView.frame);
    CGFloat beginY = viewHeight - bottomBGHeight;
    if (point.y < beginY)
    {
        [self dismiss];
    }
}

- (void)btnClick
{
    NSInteger column1 = [self.m_pickerView selectedRowInComponent:0];
    NSInteger column2 = [self.m_pickerView selectedRowInComponent:1];
    NSInteger column3 = [self.m_pickerView selectedRowInComponent:2];
    
    NSMutableString *areaString = [NSMutableString string];
    
    if (column1 < self.m_cityList.count)
    {
        DMAddressProvinceItem *cityItem = self.m_cityList[column1];
        
        [areaString appendString:cityItem.provinceName];
        
        if (column2 < cityItem.countyList.count)
        {
            DMAddressCountyItem *countyItem = cityItem.countyList[column2];
            
            [areaString appendString:countyItem.countyName];
            
            if (column3 < countyItem.areaList.count)
            {
                [areaString appendString:countyItem.areaList[column3]];
            }
        }
    }
    
    self.m_selectBlock(areaString);
    
    [self dismiss];
}

- (void)adjustSubViewsFrame
{
    CGFloat viewWidth = CGRectGetWidth([UIScreen mainScreen].bounds);
    CGFloat viewHeight = CGRectGetHeight([UIScreen mainScreen].bounds);
    self.frame = (CGRect){0, 0, viewWidth, viewHeight};
    
    CGFloat titleBGHeight = kDMAddressTitleBGViewHeight;
    CGFloat pickerViewHeight = CGRectGetHeight(self.m_pickerView.frame);
    CGFloat pickerViewWidth = CGRectGetWidth(self.m_pickerView.frame);
    
    CGFloat bottomBGW = viewWidth;
    CGFloat bottomBGH = titleBGHeight + pickerViewHeight;
    CGFloat bottomBGX = 0;
    CGFloat bottomBGY = viewHeight - bottomBGH;
    self.m_bottomBGView.frame = (CGRect){bottomBGX, bottomBGY, bottomBGW, bottomBGH};
    
    self.m_titleBGView.frame = (CGRect){0, 0, bottomBGW, titleBGHeight};
    CGFloat btnW = 60;
    CGFloat btnH = titleBGHeight;
    CGFloat btnX = bottomBGW - 10 - btnW;
    CGFloat btnY = 0;
    self.m_btn.frame = (CGRect){btnX, btnY, btnW, btnH};
    
    self.m_pickerView.frame = (CGRect){(viewWidth - pickerViewWidth) / 2, titleBGHeight, pickerViewWidth, pickerViewHeight};
}

- (void)decodeAddressFile
{
    NSError *error = nil;
    NSString *file = [[NSBundle mainBundle] pathForResource:@"DMAddressPicker" ofType:@"json"];
    NSString *content = [NSString stringWithContentsOfFile:file encoding:NSUTF8StringEncoding error:&error];
    if (content.length > 0)
    {
        NSData *data = [content dataUsingEncoding:NSUTF8StringEncoding];
        
        NSMutableArray *cityListDstArray = [NSMutableArray array];
        self.m_cityList = cityListDstArray;
        
        NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
        NSArray *citylistSrcArray = jsonDict[@"citylist"];
        [citylistSrcArray enumerateObjectsUsingBlock:^(NSDictionary * _Nonnull cityDict, NSUInteger idx, BOOL * _Nonnull stop) {
            DMAddressProvinceItem *provinceItem = [[DMAddressProvinceItem alloc] init];
            [cityListDstArray addObject:provinceItem];
            
            provinceItem.provinceName = cityDict[@"p"];
            NSMutableArray *countyDstArray = [NSMutableArray array];
            provinceItem.countyList = countyDstArray;
            
            NSArray *provinceSrcArray = cityDict[@"c"];
            [provinceSrcArray enumerateObjectsUsingBlock:^(NSDictionary * _Nonnull countyDict, NSUInteger idx, BOOL * _Nonnull stop) {
                DMAddressCountyItem *countyItem = [[DMAddressCountyItem alloc] init];
                [countyDstArray addObject:countyItem];
                
                countyItem.countyName = countyDict[@"n"];
                
                NSMutableArray *areaDstArray = [NSMutableArray array];
                NSArray *areaSrcArray = countyDict[@"a"];
                [areaSrcArray enumerateObjectsUsingBlock:^(NSDictionary * _Nonnull areaDict, NSUInteger idx, BOOL * _Nonnull stop) {
                    NSString *areaString = areaDict[@"s"];
                    
                    if (areaString.length > 0)
                    {
                        [areaDstArray addObject:areaString];
                    }
                }];
                
                countyItem.areaList = areaDstArray;
            }];
        }];
    }
}

#pragma mark - UIPickerViewDelegate
- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(nullable UIView *)view
{
    NSString *title = nil;
    
    if (0 == component)
    {
        DMAddressProvinceItem *item = self.m_cityList[row];
        
        title = item.provinceName;
    }
    else if (1 == component)
    {
        NSInteger column1 = [pickerView selectedRowInComponent:0];
        
        DMAddressProvinceItem *item = self.m_cityList[column1];
        DMAddressCountyItem *countyItem = item.countyList[row];
        
        title = countyItem.countyName;
    }
    else
    {
        NSInteger column1 = [pickerView selectedRowInComponent:0];
        NSInteger column2 = [pickerView selectedRowInComponent:1];
        
        DMAddressProvinceItem *item = self.m_cityList[column1];
        DMAddressCountyItem *countyItem = item.countyList[column2];
        
        title = countyItem.areaList[row];
    }
    
    UILabel *titleLabel = (UILabel *)view;
    if (nil == titleLabel)
    {
        titleLabel = [[UILabel alloc] init];
        titleLabel.adjustsFontSizeToFitWidth = YES;
        
        [titleLabel setTextAlignment:NSTextAlignmentCenter];
        [titleLabel setBackgroundColor:[UIColor clearColor]];
        [titleLabel setFont:[UIFont systemFontOfSize:14]];
    }
    
    titleLabel.text = title;
    
    return titleLabel;
}



- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    if (0 == component)
    {
        [pickerView selectRow:0 inComponent:1 animated:NO];
        [pickerView selectRow:0 inComponent:2 animated:NO];
        
        [pickerView reloadComponent:1];
        [pickerView reloadComponent:2];
    }
    else if (1 == component)
    {
        [pickerView selectRow:0 inComponent:2 animated:NO];
        
        [pickerView reloadComponent:2];
    }
}

- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component
{
    return 30;
}


#pragma mark - UIPickerViewDataSource
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 3;
}

// returns the # of rows in each component..
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    if (0 == component)
    {
        return self.m_cityList.count;
    }
    else if (1 == component)
    {
        NSInteger row = [pickerView selectedRowInComponent:0];
        DMAddressProvinceItem *item = self.m_cityList[row];
        
        return item.countyList.count;
    }
    else
    {
        NSInteger row = [pickerView selectedRowInComponent:0];
        NSInteger column = [pickerView selectedRowInComponent:1];
        
        DMAddressProvinceItem *item = self.m_cityList[row];
        DMAddressCountyItem *countyItem = item.countyList[column];
        
        return countyItem.areaList.count;
    }
}



@end



