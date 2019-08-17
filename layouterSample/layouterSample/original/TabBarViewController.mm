//
//  TabBarViewController.m
//
//  Created by M.TOYOTA on 2014/11/21.
//  Copyright (c) 2015年 toyota-m2k. All rights reserved.
//

#import "TabBarViewController.h"
#import "MICUiTabBarView.h"
#import "MICUiRectUtil.h"
#import "MICUiDsTabButton.h"
#import "MICVar.h"
#import "MICAutoLayoutBuilder.h"

@interface TabBarViewController () {
    MICUiTabBarView* _tabview;
    int _tabCount;
}

@end

@implementation TabBarViewController

- (void) prevTab:(id)sender {
    [_tabview scrollPrev];
}
- (void) nextTab:(id)sender {
    [_tabview scrollNext];
}


static UIColor* colors[] = {
    //    [UIColor blackColor],      // 0.0 white
    //        [UIColor darkGrayColor],   // 0.333 white
    //        [UIColor lightGrayColor],  // 0.667 white
    //    [UIColor whiteColor],      // 1.0 white
    //        [UIColor grayColor],       // 0.5 white
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
static int colorCount = sizeof(colors)/sizeof(colors[0]);

- (void)viewDidLoad {
    [super viewDidLoad];

    let rootView = [UIView new];
    [self.view addSubview:rootView];
    MICAutoLayoutBuilder lb(self.view);
    lb.fitToSafeArea(rootView);

    let back = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    back.frame = MICRect(200, 50);
    back.backgroundColor = [UIColor whiteColor];
    [back setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [back setTitle:@"Back" forState:UIControlStateNormal];
    [back addTarget:self action:@selector(goBack:) forControlEvents:UIControlEventTouchUpInside];
//    [self.view addSubview:back];

    let add = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    add.frame = CGRectMake(10,80, 100, 50);
    add.backgroundColor = [UIColor whiteColor];
    [add setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [add setTitle:@"Add Tab" forState:UIControlStateNormal];
    [add addTarget:self action:@selector(addTab:) forControlEvents:UIControlEventTouchUpInside];
//    [self.view addSubview:add];

    let del = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    del.frame = CGRectMake(120,80, 100, 50);
    del.backgroundColor = [UIColor whiteColor];
    [del setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [del setTitle:@"Delete Tab" forState:UIControlStateNormal];
    [del addTarget:self action:@selector(delTab:) forControlEvents:UIControlEventTouchUpInside];
//    [self.view addSubview:del];

    
//    MICRect frame = self.view.bounds;
    MICUiTabBarView* tabview = [[MICUiTabBarView alloc] init];
    _tabview = tabview;
    tabview.bar.stackLayout.cellSpacing = 0;
    
    UIButton* prev = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [prev setTitle:@"<" forState:UIControlStateNormal];
    prev.frame = MICRect::XYWH(0,400,30,30);
    prev.backgroundColor = [UIColor grayColor];
    [prev setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];

    UIButton* next = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [next setTitle:@">" forState:UIControlStateNormal];
    next.frame = MICRect::XYWH(50,400,30,30);
    next.backgroundColor = [UIColor grayColor];
    [next setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    
    [tabview addLeftFuncButton:prev function:MICUiTabBarFuncButtonSCROLL_PREV];
    [tabview addRightFuncButton:next function:MICUiTabBarFuncButtonSCROLL_NEXT];
    [prev addTarget:self action:@selector(prevTab:) forControlEvents:UIControlEventTouchUpInside];
    [next addTarget:self action:@selector(nextTab:) forControlEvents:UIControlEventTouchUpInside];
  
//    [self.view addSubview:prev];
//    [self.view addSubview:next];
    
    MICUiStatefulResource* resources = [[MICUiStatefulResource alloc] initWithDictionary:
        @{ MICUiStatefulBgColorNORMAL: [UIColor darkGrayColor],
           MICUiStatefulBgColorSELECTED: [UIColor greenColor],
           MICUiStatefulBgColorACTIVATED: [UIColor yellowColor],
           MICUiStatefulBgColorDISABLED: [UIColor darkGrayColor],
           
           MICUiStatefulFgColorNORMAL: [UIColor whiteColor],
           MICUiStatefulFgColorSELECTED: [UIColor blackColor],
           MICUiStatefulFgColorACTIVATED: [UIColor blackColor],
           MICUiStatefulFgColorDISABLED: [UIColor grayColor],
           
           MICUiStatefulBorderColorNORMAL: [UIColor whiteColor],
         }];


    
    
    for(int i=0 ; i<10 ; i++) {
//        UIButton* tab = [UIButton buttonWithType:UIButtonTypeRoundedRect];
//        [tab setTitle:[NSString stringWithFormat:@"TAB-%d", i+1] forState:UIControlStateNormal];
//        tab.backgroundColor = colors[i%colorCount];
//        tab.frame=MICRect(0,0,80,30);

        MICUiDsTabButton* tab = [[MICUiDsTabButton alloc] initWithFrame:MICRect(0,0,100,30)];
        tab.borderWidth = 2.0f;
        tab.contentMargin = MICEdgeInsets(2.0f,2.0f,2.0f,2.0f);
        tab.fontSize = 10.0f;
        tab.text = [NSString stringWithFormat:@"TAB-%d", i+1];
        tab.colorResources = resources;
        tab.attachBottom = false;
        tab.roundRadius = 10.0f;
        [tabview addTab:tab updateView:false];
    }
    
//    [self.view addSubview:tabview];
//    tabview.frame = frame.partialVertCenterRect(30).deflate(30,0);
    tabview.backgroundColor = [UIColor whiteColor];
    [tabview beginCustomizingWithLongPress:true endWithTap:true];
    
    RALBuilder(rootView)
    .addView(back, RALParams()
                    .top().parent(10)
                    .left().center(nil))
    .addView(tabview, RALParams()
                    .top().center(nil)
                    .vert().fixed(30)
                    .left().center(nil)
                    .horz().relative(nil, 0.9))
    .addView(add, RALParams()
                    .bottom().adjacent(tabview, 15)
                    .left().fit(tabview))
    .addView(del, RALParams()
                    .bottom().adjacent(tabview, 15)
                    .left().adjacent(add, 15));
}

- (void) addTab:(id)sender {
    _tabCount++;
    UIButton* tab = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [tab setTitle:[NSString stringWithFormat:@"TAB-%d", _tabCount] forState:UIControlStateNormal];
    tab.backgroundColor = colors[_tabCount%colorCount];
    tab.frame=MICRect(0,0,80,30);
    [_tabview addTab:tab updateView:true];
}

- (void) delTab:(id)sender {
    int i = [_tabview tabCount]-1;
    if(i>=0) {
        UIView* tab = [_tabview tabAt:i];
        [_tabview removeTab:tab updateView:true];
    }
}

- (void) goBack:(id)sender {
    [self dismissViewControllerAnimated:true completion:nil];
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

@end
