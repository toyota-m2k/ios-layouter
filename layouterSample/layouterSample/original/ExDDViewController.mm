//
//  ExDDViewController.m
//
//  MICUiAccordionView (MICUiAccordionCellView を縦、または、横に並べて配置するビュー）で、AccordionCellView のボディに、
//  MICUiGridViewを配置するデモ
//      複数のMICUiAccordionCellViewを縦に並べる
//      各UMICUiAccordionCellViewのボディには、MICUiGridViewを設定
//      各セルの長押しで編集モードに入り、D&Dで（AccordionCellViewの境界を超えて）並べかえ可能
//
//  AccordingViewController との違いは、ボディに、GridLayout ではなく、GridViewを配置した点。
//  これにより、AccordionCellView毎に内部をスクロールできるようになっている。
//  MICUiAccordionViewはCellDragSupportEx をサポートするので、コンテナ（GridView)境界を超えてD&D可能。
//
//  Created by M.TOYOTA on 2014/11/07.
//  Copyright (c) 2015年 toyota-m2k. All rights reserved.
//

#import "ExDDViewController.h"
#import "MICUiLayout.h"
#import "MICUiAccordionView.h"
#import "MICUiRectUtil.h"
#import "MICUiGridView.h"
#import "MICStringUtil.h"
#import "MICVar.h"
#import "MICAutoLayoutBuilder.h"

@interface ExDDViewController ()

@end

#define LABEL_HEIGHT 20
#define LABEL_MARGIN 5

@implementation ExDDViewController

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
//    [rootView addSubview:back];
    
    MICUiAccordionView* accordion = [[MICUiAccordionView alloc] init];
    [accordion enableScrollSupport:true];
    [accordion beginCustomizingWithLongPress:true endWithTap:true];
    accordion.backgroundColor = [UIColor blueColor];
    //accordion.stackLayout.dropRestrictorDelegate = self;
    
    UIColor* colors[] = {
        //    [UIColor blackColor],      // 0.0 white
        //        [UIColor darkGrayColor],   // 0.333 white
        //        [UIColor lightGrayColor],  // 0.667 white
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
    
    
    
    for(int j=0 ; j<5 ; j++) {
        
        MICUiAccordionCellView* ac = [[MICUiAccordionCellView alloc] init];
        ac.labelAlignment = MICUiAlignExFILL;
        ac.labelMargin = MICEdgeInsets(LABEL_MARGIN,LABEL_MARGIN,LABEL_MARGIN,LABEL_MARGIN);
        ac.backgroundColor = [UIColor whiteColor];
        ac.name = [NSString stringWithFormat:@"AC-%d",j+1];
        
        ac.orientation = MICUiVertical;
        ac.labelPos = MICUiPosTOP|MICUiPosLEFT;
        ac.movableLabel = false;
        ac.bodyMargin = MICEdgeInsets(LABEL_MARGIN,0,LABEL_MARGIN,0);
        
        UIButton* btn =[UIButton buttonWithType:UIButtonTypeRoundedRect];
        btn.frame = CGRectMake(0,0,150,LABEL_HEIGHT);
        [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [btn setTitle:[NSString stringWithFormat:@"Accordion-%d",j+1] forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(fold:) forControlEvents:UIControlEventTouchUpInside];
        btn.backgroundColor = [UIColor greenColor];
        [ac setLabelView:btn];
        
        
        // レイアウターを作成
//        MICUiGridLayout* layouter = [[MICUiGridLayout alloc] initWithCellSize:MICSize(100,100) growingOrientation:MICUiVertical fixedCount:3];
//        layouter.cellSpacingHorz = 5;
//        layouter.cellSpacingVert = 5;
//        layouter.name = MICString(@"AccCell-%d", j+1);
        
        // マージンは、AccordionCellが自動的に設定するので指定不可。
        
        // AccordionCellにlayouter をセットしてから、子ビューを追加する
//        [ac setBodyLayouter:layouter];
        
        
        MICUiGridView* gridview = [[MICUiGridView alloc] init];
        gridview.gridLayout.growingOrientation = MICUiVertical;
        gridview.gridLayout.fixedSideCount = 3;
        gridview.gridLayout.cellSize = MICSize(80,80);
        gridview.gridLayout.cellSpacingHorz =15;
        gridview.gridLayout.cellSpacingVert =15;
        gridview.gridLayout.name = MICString(@"AccCell-%d", j+1);
        gridview.backgroundColor = [UIColor blackColor];
        
        UILabel* label;
        for(int i=0 ; i<10; i++ ) {
            
            label = [[UILabel alloc] initWithFrame:CGRectZero];
            label.backgroundColor = colors[i%colorCount];
            label.textColor = [UIColor whiteColor];
            label.text = [NSString stringWithFormat:@"Item-%d",i];
            [gridview addChild:label unitX:1 unitY:1];
        }
        // アコーディオンセルのサイズは、アコーディオンビューのレイアウターが管理しているので、それを直接変更しても正しく反映されないし、レンダリングが不正になる。
        // 代わりに、スタックレイアウターの　setSizeOfChild:toSizeメソッドを使用する。
        gridview.frame = MICRect(CGPointZero, MICSize([gridview.gridLayout getSize].width, 150));
        [ac setBodyView:gridview];
        
        ac.frame = MICRect(CGPointZero, [ac calcMinSizeOfContents]);
        [ac enableAutoResizing:true minBodySize:150 maxBodySize:500];
        [accordion addChild:ac];
    }
    
    CGSize contentSize = [accordion.layouter getSize];
//    accordion.frame = CGRectMake(20, 100, contentSize.width, 500);
    accordion.contentSize = contentSize;
    [accordion updateLayout:false];
//    [rootView addSubview:accordion];
    
    RALBuilder(rootView)
    .addView(back, RALParams()
            .top().parent(10)
            .left().center(nil))
    .addView(accordion, RALParams()
            .top().adjacent(back,20)
            .bottom().parent(10)
            .vert().free()
            .left().center(nil)
            .horz().fixed(contentSize.width));
}

- (void) goBack:(id)sender {
    [self dismissViewControllerAnimated:true completion:nil];
}

- (void) fold:(id)sender {
    [((MICUiAccordionCellView*)((UIView*)sender).superview) toggleFolding:true onCompleted:nil];
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
