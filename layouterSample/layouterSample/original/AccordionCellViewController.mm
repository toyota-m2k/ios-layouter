//
//  AccordionCekkViewController.m
//
//  MICUiAccordionCellView  ラベル(tab)タップで折りたたみ可能なビュー のデモ
//  - MICUiAccordionCellView のラベルには　MICUiTabBarView（タブ耳ボタンを並べるビュー）を配置
//  - MICUiAccordionCellView のボディには、MICUiGridLayout を配置
//  - 選択中のタブをもう一度タップすると、ボディが開閉する。
//  - タブの選択によるボディの内容の切り替えは実装していない。（タブボタンのタップイベントで表示内容を変更する実装を書けば対応可能）
//
//  MICUiAccordionCellView は、タブ耳の位置（上下左右）、開閉方向（上から下、下から上、右から左、左から右）の組み合わせによって動作が異なる
//  このビューコントローラーを起動するたびに、このモードの組み合わせを変えて動作する。
//
//  Created by M.TOYOTA on 2014/10/29.
//  Copyright (c) 2015年 toyota-m2k. All rights reserved.
//

#import "AccordionCellViewController.h"
#import "MICUiAccordionCellView.h"
#import "MICUiRectUtil.h"
#import "MICUiGridLayout.h"
#import "MICUiTabBarView.h"
#import "MICVar.h"
#import "MICAutoLayoutBuilder.h"

@interface AccordionCellViewController ()

@end

@implementation AccordionCellViewController {
    MICUiTabBarView* _tabview;
}

#define LABEL_HEIGHT 20
#define LABEL_MARGIN 5
static int testMode = 1;

- (void) prevTab:(id)sender {
    [_tabview scrollPrev];
}
- (void) nextTab:(id)sender {
    [_tabview scrollNext];
}


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
    [rootView addSubview:back];


    MICUiAccordionCellView* ac = [[MICUiAccordionCellView alloc] initWithFrame:MICRect(300, 350)];
    ac.labelAlignment = MICUiAlignExFILL;
    ac.labelMargin = MICEdgeInsets(LABEL_MARGIN,LABEL_MARGIN,LABEL_MARGIN,LABEL_MARGIN);

//    testMode = 3;
    switch(testMode%8) {
        case 0:
            ac.orientation = MICUiVertical;
            ac.labelPos = MICUiPosTOP|MICUiPosLEFT;
            ac.movableLabel = true;
            ac.bodyMargin = MICEdgeInsets(LABEL_MARGIN,0,LABEL_MARGIN,LABEL_MARGIN);
            break;
        case 1:
            ac.orientation = MICUiHorizontal;
            ac.labelPos = MICUiPosTOP|MICUiPosLEFT;
            ac.movableLabel = true;
            ac.bodyMargin = MICEdgeInsets(0,LABEL_MARGIN,LABEL_MARGIN,LABEL_MARGIN);
            break;

        case 2: //x
            ac.orientation = MICUiVertical;
            ac.labelPos = MICUiPosRIGHT|MICUiPosBOTTOM;
            ac.movableLabel = true;
            ac.bodyMargin = MICEdgeInsets(LABEL_MARGIN,LABEL_MARGIN,LABEL_MARGIN,0);
            break;
        case 3://x
            ac.orientation = MICUiHorizontal;
            ac.labelPos = MICUiPosRIGHT|MICUiPosBOTTOM;
            ac.movableLabel = true;
            ac.bodyMargin = MICEdgeInsets(LABEL_MARGIN,LABEL_MARGIN,0,LABEL_MARGIN);
            break;


        case 4:
            ac.orientation = MICUiVertical;
            ac.labelPos = MICUiPosTOP|MICUiPosLEFT;
            ac.movableLabel = false;
            ac.bodyMargin = MICEdgeInsets(LABEL_MARGIN,0,LABEL_MARGIN,LABEL_MARGIN);
            break;
        case 5:
            ac.orientation = MICUiHorizontal;
            ac.labelPos = MICUiPosTOP|MICUiPosLEFT;
            ac.movableLabel = false;
            ac.bodyMargin = MICEdgeInsets(0,LABEL_MARGIN,LABEL_MARGIN,LABEL_MARGIN);
            break;
            
        case 6:  //x
            ac.orientation = MICUiVertical;
            ac.labelPos = MICUiPosRIGHT|MICUiPosBOTTOM;
            ac.movableLabel = false;
            ac.bodyMargin = MICEdgeInsets(LABEL_MARGIN,LABEL_MARGIN,LABEL_MARGIN,0);
            break;
        case 7: //
            ac.orientation = MICUiHorizontal;
            ac.labelPos = MICUiPosRIGHT|MICUiPosBOTTOM;
            ac.movableLabel = false;
            ac.bodyMargin = MICEdgeInsets(LABEL_MARGIN,LABEL_MARGIN,0,LABEL_MARGIN);
            break;
    }
    testMode++;
//    testMode = (testMode==3) ? 5 : 3;

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

    
    ac.backgroundColor = [UIColor blueColor];
    
#if 0
    UIButton* btn =[UIButton buttonWithType:UIButtonTypeRoundedRect];
    btn.frame = CGRectMake(0,0,150,LABEL_HEIGHT);
    [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [btn setTitle:@"Label" forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(fold:) forControlEvents:UIControlEventTouchUpInside];
    btn.backgroundColor = [UIColor greenColor];
    
    [ac setLabelView:btn];
#else
    MICUiTabBarView* tabview = [[MICUiTabBarView alloc] init];
    _tabview = tabview;
    
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
    
    for(int i=0 ; i<10 ; i++) {
        UIButton* tab = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [tab setTitle:[NSString stringWithFormat:@"TAB-%d", i+1] forState:UIControlStateNormal];
        tab.backgroundColor = colors[i%colorCount];
        tab.frame=MICRect(0,0,80,30);
        [tab addTarget:self action:@selector(fold:) forControlEvents:UIControlEventTouchUpInside];
        [tabview addTab:tab updateView:false];
    }
    tabview.frame = CGRectMake(0,0,150,30);
    [ac setLabelView:tabview];
    [tabview beginCustomizingWithLongPress:true endWithTap:true];
    
    
    
    
#endif

#if 0
    MICRect rc = ac.bodyBounds;
    rc.inflate(-40, -40);
    UIView* view = [[UIView alloc] initWithFrame:rc];
    view.backgroundColor = [UIColor yellowColor];
    [ac addSubview:view];
#endif
    
   
    // レイアウターを作成
    MICUiGridLayout* layouter = [[MICUiGridLayout alloc] initWithCellSize:MICSize(100,100) growingOrientation:MICUiVertical fixedCount:3];
    layouter.cellSpacingHorz = 5;
    layouter.cellSpacingVert = 5;
    
    // マージンは、AccordionCellが自動的に設定するので指定不可。
    
    // AccordionCellにlayouter をセットしてから、子ビューを追加する
    [ac setBodyLayouter:layouter];
    UILabel* label;
    for(int i=0 ; i<9; i++ ) {
        
        label = [[UILabel alloc] initWithFrame:CGRectZero];
        label.backgroundColor = colors[i%colorCount];
        label.textColor = [UIColor whiteColor];
        label.text = [NSString stringWithFormat:@"LABEL-%d",i];
        
        [layouter addChild:label unitX:1 unitY:1];
    }
    MICSize size = [ac calcMinSizeOfContents];
//    ac.frame = MICRect(ac.frame.origin, size);
    
//    [ac updateLayout];
    
    [rootView addSubview:ac];
    
    RALBuilder(rootView)
    .addView(back,RALParams()
                    .top().parent(10)
                    .left().center(nil))
    .addView(ac, RALParams()
                    .top().adjacent(back, 20)
                    .vert().fixed(size.height)
                    .left().center(nil)
                    .horz().fixed(size.width));
             
    
}

- (void) goBack:(id)sender {
    [self dismissViewControllerAnimated:true completion:nil];
}

- (void) fold:(id)sender {
    UIView* p = ((UIView*)sender).superview;
    while( ![p isKindOfClass:MICUiAccordionCellView.class]) {
        p = p.superview;
        if(p==nil) {
            return;
        }
    }
    [(MICUiAccordionCellView*)p toggleFolding:true onCompleted:nil];
}


@end
