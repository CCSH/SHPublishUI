//
//  ViewController.m
//  发布界面（带图片，文字）
//
//  Created by CSH on 16/7/4.
//  Copyright © 2016年 CSH. All rights reserved.
//

#import "ViewController.h"
#import "CSHTextView.h"
#import "ZLPhoto.h"
#import "UIImage+ZLPhotoLib.h"

#define HEIGHT ([UIScreen mainScreen].bounds.size.height)
#define WIDTH ([UIScreen mainScreen].bounds.size.width)

@interface ViewController ()<UITextViewDelegate,ZLPhotoPickerBrowserViewControllerDelegate>
//输入框
@property (nonatomic, weak) CSHTextView *textView;
//字数提示
@property (nonatomic, strong) UILabel * promptLabel;
//图片位置
@property (nonatomic, weak) UIScrollView *scrollView;
//图片数组
@property (nonatomic, strong) NSMutableArray *assets;
//图片数量
@property (nonatomic, assign) int phoneIndex;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    //初始化数组
    self.assets = [NSMutableArray new];
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    self.phoneIndex = 9;
    
    //添加提交按钮
    [self setSubmitBtn];
    //添加输入框
    [self setTextView];
    //添加提示文字
    [self setPromptLabel];
    //添加图片选择
    [self setPictureView];
    //刷新scroll
    [self reloadScrollView];

}
#pragma mark - 提交
- (void)setSubmitBtn{
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake(0, 20, self.view.frame.size.width, 64);
    [btn setTitle:@"提交" forState:0];
    [btn setTitleColor:[UIColor blackColor] forState:0];
    [btn addTarget:self action:@selector(SubmitBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];
    
}
- (void)SubmitBtnClick{
    NSLog(@"提交");
    //如果获取数组图片用[self.assets[0] thumbImage]
    NSLog(@"\n 图片数组：%@ \n 输入文字：%@",self.assets,self.textView.text);
}
#pragma mark - 输入框
- (void)setTextView{
    // 添加输入控件
    // 1.创建输入控件
    CSHTextView *textView = [[CSHTextView alloc] init];
    textView.alwaysBounceVertical = YES; // 垂直方向上拥有有弹簧效果
    textView.frame = CGRectMake(15,64,WIDTH-30,140);
    textView.layer.cornerRadius = 1;
    textView.layer.borderColor = [UIColor lightGrayColor].CGColor;
    textView.layer.borderWidth = 1;
    textView.delegate = self;
    // 2.设置提醒文字（占位文字）
    textView.placehoder = @"说点什么吧...";
    // 3.设置字体
    textView.font = [UIFont systemFontOfSize:15];
    self.textView = textView;
    [self.view addSubview:textView];
    
}
#pragma mark - 提示文字
- (void)setPromptLabel{
    //提示文字
    UILabel *promptLabel = [[UILabel alloc]initWithFrame:CGRectMake(15, self.textView.frame.origin.y+self.textView.frame.size.height+10, WIDTH-30, 18)];
    promptLabel.textColor = [UIColor blackColor];
    promptLabel.textAlignment = NSTextAlignmentRight;
    promptLabel.font = [UIFont systemFontOfSize:15];
    promptLabel.text = @"0/400字";
    self.promptLabel = promptLabel;
    [self.view addSubview:promptLabel];
}
#pragma mark - 图片
- (void)setPictureView{
    //图片展示
    UIScrollView *scrollView = [[UIScrollView alloc] init];
    scrollView.showsHorizontalScrollIndicator = NO;
    scrollView.showsVerticalScrollIndicator = NO;
    scrollView.frame = CGRectMake(0, self.promptLabel.frame.origin.y+self.promptLabel.frame.size.height+10, self.view.frame.size.width, self.view.frame.size.height - (self.promptLabel.frame.origin.y+self.promptLabel.frame.size.height+10));
    [self.view addSubview:scrollView];
    scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.scrollView = scrollView;
}
#pragma mark - 绘制图片
- (void)reloadScrollView{
    // 先移除，后添加
    [[self.scrollView subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    // 一行的最大列数
    int maxColsPerRow = 5;
    
    // 每个图片之间的间距
    CGFloat margin = 15;
    
    // 每个图片的宽高
    CGFloat imageViewW = ( self.view.frame.size.width- (maxColsPerRow + 1) * margin) / maxColsPerRow;
    CGFloat imageViewH = imageViewW;
    
    // 加一是为了有个添加button
    NSUInteger assetCount = self.assets.count + 1;
    
    for (NSInteger i = 0; i < assetCount; i++) {
        
        NSInteger row = i / maxColsPerRow;
        NSInteger col = i % maxColsPerRow;
        
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.imageView.contentMode = UIViewContentModeScaleAspectFill;
        btn.layer.masksToBounds=YES;
        btn.layer.cornerRadius=8.0;
        btn.frame = CGRectMake(col * (imageViewW + margin) + margin, row * (imageViewH + margin), imageViewW, imageViewH);
        
        
        // UIButton
        if (i == self.assets.count){
            // 最后一个Button
            [btn setImage:[UIImage imageNamed:@"sendMessage_normal"] forState:UIControlStateNormal];
            [btn addTarget:self action:@selector(photoSelectet) forControlEvents:UIControlEventTouchUpInside];
        }else{
            [btn setTitle:@"" forState:1];
            // 如果是本地ZLPhotoAssets就从本地取，否则从网络取
            if ([[self.assets objectAtIndex:i] isKindOfClass:[ZLPhotoAssets class]]) {
                [btn setImage:[self.assets[i] thumbImage] forState:UIControlStateNormal];
            }else if ([[self.assets objectAtIndex:i] isKindOfClass:[UIImage class]]){
                [btn setImage:self.assets[i] forState:UIControlStateNormal];
            }
            [btn addTarget:self action:@selector(tapBrowser:) forControlEvents:UIControlEventTouchUpInside];
            btn.tag = i;
        }
        [self.scrollView addSubview:btn];
    }
    self.scrollView.contentSize = CGSizeMake(self.view.frame.size.width, CGRectGetMaxY([[self.scrollView.subviews lastObject] frame]));
}
#pragma mark - 选择图片
- (void)photoSelectet{
    ZLPhotoPickerViewController *pickerVc = [[ZLPhotoPickerViewController alloc] init];
    // MaxCount, Default = 9
    pickerVc.maxCount = self.phoneIndex - self.assets.count;
    // Jump AssetsVc
    pickerVc.status = PickerViewShowStatusCameraRoll;
    // Filter: PickerPhotoStatusAllVideoAndPhotos, PickerPhotoStatusVideos, PickerPhotoStatusPhotos.
    pickerVc.photoStatus = PickerPhotoStatusPhotos;
    // Recoder Select Assets
//    pickerVc.selectPickers = self.assets;
    // Desc Show Photos, And Suppor Camera
    pickerVc.topShowPhotoPicker = YES;
    pickerVc.isShowCamera = YES;
    // CallBack
    pickerVc.callBack = ^(NSArray<ZLPhotoAssets *> *status){
        
        [self.assets addObjectsFromArray: status.mutableCopy];
        [self reloadScrollView];
    };
    [pickerVc showPickerVc:self];
}
#pragma mark - 图片预览
- (void)tapBrowser:(UIButton *)btn{
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:btn.tag inSection:0];
    // 图片游览器
    ZLPhotoPickerBrowserViewController *pickerBrowser = [[ZLPhotoPickerBrowserViewController alloc] init];
    // 淡入淡出效果
    // pickerBrowser.status = UIViewAnimationAnimationStatusFade;
    // 数据源/delegate
    pickerBrowser.editing = YES;
    pickerBrowser.photos = self.assets;
    // 能够删除
    pickerBrowser.delegate = self;
    // 当前选中的值
    pickerBrowser.currentIndex = indexPath.row;
    // 展示控制器
    [pickerBrowser showPickerVc:self];
}
#pragma mark - 图片删除
- (void)photoBrowser:(ZLPhotoPickerBrowserViewController *)photoBrowser removePhotoAtIndex:(NSInteger)index{
    if (self.assets.count > index) {
        [self.assets removeObjectAtIndex:index];
        [self reloadScrollView];
    }
}

/**
 *  当textView的文字改变就会调用
 */
- (void)textViewDidChange:(UITextView *)textView{
    
    self.promptLabel.text = [NSString stringWithFormat:@"%lu/400字",(unsigned long)textView.text.length];
    if (textView.text.length > 400) {
        self.promptLabel.text = @"超出字数限制";
    }
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
