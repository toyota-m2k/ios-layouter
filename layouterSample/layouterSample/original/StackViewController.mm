//
//  StackViewController.m
//
//  MICStackLayout, MICStackView のデモ
//  - ビューを横幅いっぱいに伸ばして(MICUiAlignExFILL)、縦に並べる(MICUiVertical)
//  - 縦方向にスクロール可能
//  - 各セル（縦に並んだビュー）を長押しすると、編集モードに入り、D&Dで並べ替え可能
//
//  Created by M.TOYOTA on 2014/10/24.
//  Copyright (c) 2015年 toyota-m2k. All rights reserved.
//

#import "StackViewController.h"
#import "MICUiStackView.h"
#import "MICVar.h"
#import "MICAutoLayoutBuilder.h"

//#import "MICUiStackLayout.h"
//#import "MICUiCellDragSupport.h"

@interface StackViewController () {
//    MICUiStackLayout* _stackLayout;
//    MICUiCellDragSupport* _dragSupporter;
    
//    MICUiStackView* _stackView;
}
@end

@implementation StackViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    let rootView = [UIView new];
    [self.view addSubview:rootView];
    MICAutoLayoutBuilder lb(self.view);
    lb.fitToSafeArea(rootView);
    
    let back = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    back.frame = CGRectMake(10, 20, 200, 50);
    back.backgroundColor = [UIColor whiteColor];
    [back setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [back setTitle:@"Back" forState:UIControlStateNormal];
    [back addTarget:self action:@selector(goBack:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:back];

//    CGRect rcFrame = self.view.bounds;
//    rcFrame.origin.y += 100;
//    rcFrame.size.height -= 150;

    let stackView = [[MICUiStackView alloc] initWithFrame:MICRect()];
    [stackView enableScrollSupport:true];
    [stackView beginCustomizingWithLongPress:true endWithTap:true];
    
//    _stackLayout = [[MICUiStackLayout alloc] initWithOrientation:MICUiVertical alignment:MICUiAlignExFILL];
    MICUiStackLayout* stackLayout = stackView.stackLayout;
    
    stackLayout.orientation = MICUiVertical;
    stackLayout.fixedSideSize = 350;
//    stackLayout.marginTop = 0;
//    stackLayout.marginLeft = 10;
    stackLayout.cellSpacing = 20;
    stackLayout.cellAlignment = MICUiAlignExFILL;
    
//    UIScrollView* scrollView = [[UIScrollView alloc] init];
//    scrollView.backgroundColor = [UIColor blackColor];
//    scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    stackView.backgroundColor = [UIColor blackColor];      // これがないと、スクロールビューがタップイベントを受け取らないようだ。
    [self.view addSubview:stackView];
    

//    _dragSupporter = [[MICUiCellDragSupport alloc] initWithContainer:scrollView
//                                                     andLayouter:_stackLayout
//                                         beginCustomizingOnLongPress:true
//                                                 endCustomizingOnTap:true];
    
//    UILabel* label;
//    label = [[UILabel alloc] initWithFrame:CGRectZero];
//    label.backgroundColor = [UIColor blueColor];
//    label.textColor = [UIColor whiteColor];
//    label.text = @"1111";
//    label.frame = CGRectMake(0,0,50,100);
//    
//    [_stackLayout addChild:label];
//    [self.view addSubview:label];
//    
//    label = [[UILabel alloc] initWithFrame:CGRectZero];
//    label.backgroundColor = [UIColor greenColor];
//    label.textColor = [UIColor whiteColor];
//    label.text = @"2222";
//    label.frame = CGRectMake(0,0,200,50);
//    
//    [_stackLayout addChild:label];
//    [self.view addSubview:label];
//    
//    label = [[UILabel alloc] initWithFrame:CGRectZero];
//    label.backgroundColor = [UIColor redColor];
//    label.textColor = [UIColor whiteColor];
//    label.text = @"2222";
//    label.frame = CGRectMake(0,0,100,80);
//    
//    [_stackLayout addChild:label];
//    [self.view addSubview:label];
    
    
    
    UIColor* colors[] = {
        //    [UIColor blackColor],      // 0.0 white
        [UIColor darkGrayColor],   // 0.333 white
        [UIColor lightGrayColor],  // 0.667 white
        //    [UIColor whiteColor],      // 1.0 white
        [UIColor grayColor],       // 0.5 white
        [UIColor redColor],       // 1.0, 0.0, 0.0 RGB
        [UIColor greenColor],      // 0.0, 1.0, 0.0 RGB
        [UIColor blueColor],       // 0.0, 0.0, 1.0 RGB
        [UIColor cyanColor],       // 0.0, 1.0, 1.0 RGB
        [UIColor yellowColor],     // 1.0, 1.0, 0.0 RGB
        [UIColor magentaColor],    // 1.0, 0.0, 1.0 RGB
        [UIColor orangeColor],     // 1.0, 0.5, 0.0 RGB
        [UIColor purpleColor],     // 0.5, 0.0, 0.5 RGB
        [UIColor brownColor],      // 0.6, 0.4, 0.2 RGB
        //    [UIColor clearColor],      // 0.0 white, 0.0 alpha
    };
    int colorCount = sizeof(colors)/sizeof(colors[0]);
    
    for(int i=0 ; i<100; i++ ) {
        
        let label = [[UILabel alloc] initWithFrame:CGRectZero];
        label.backgroundColor = colors[i%colorCount];
        label.textColor = [UIColor whiteColor];
        label.text = [NSString stringWithFormat:@"LABEL-%d",i];
        label.frame = MICRect(200,50);
//        if(i%2==1){
//            label.hidden = true;
//        }
        
//        [_stackView addSubview:label];
        [stackView addChild:label updateLayout:false withAnimation:false];
    }
    
    
    [stackView updateLayout:true];
    stackView.contentSize = stackLayout.getSize;
    
    RALBuilder(rootView)
        .addView(back, RALParams()
                    .left().center(nil)
                    .top().parent(10))
        .addView(stackView, RALParams()
                    .left().parent(10)
                    .right().parent(10)
                    .horz().free()
                    .top().adjacent(back, 25)
                    .bottom().parent(10)
                    .vert().free());
   
//    CGSize layoutSize =[stackLayout getSize];

    //    scrollView.contentSize = layoutSize;

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void) goBack:(id)sender {
    [self dismissViewControllerAnimated:true completion:nil];
}




@end
