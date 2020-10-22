//
//  AccrodionViewController.m
//
//  MICUiAccordionView (MICUiAccordionCellView を縦、または、横に並べて配置するビュー）のデモ
//      複数のMICUiAccordionCellViewを縦に並べる
//      各UMICUiAccordionCellViewのボディには、MICUiGridLayoutを設定
//      各セルの長押しで編集モードに入り、D&Dで（AccordionCellViewの境界を超えて）並べかえ可能
//
//  Created by M.TOYOTA on 2014/11/04.
//  Copyright (c) 2015年 toyota-m2k. All rights reserved.
//

#import "AccordionViewController.h"
#import "MICUiAccordionView.h"
#import "MICUiRectUtil.h"
#import "MICUiGridLayout.h"
#import "MICStringUtil.h"
#import "MICVar.h"
#import "MICAutoLayoutBuilder.h"


@interface AccordionViewController ()

@end

#define LABEL_HEIGHT 20
#define LABEL_MARGIN 5

@implementation AccordionViewController

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
    [rootView addSubview:back];
    
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
        MICUiGridLayout* layouter = [[MICUiGridLayout alloc] initWithCellSize:MICSize(100,100) growingOrientation:MICUiVertical fixedCount:3];
        layouter.cellSpacingHorz = 5;
        layouter.cellSpacingVert = 5;
        layouter.name = MICString::format(@"AccCell-%d", j+1);
        
        // マージンは、AccordionCellが自動的に設定するので指定不可。
        
        // AccordionCellにlayouter をセットしてから、子ビューを追加する
        [ac setBodyLayouter:layouter];
        UILabel* label;
        for(int i=0 ; i<10; i++ ) {
            
            label = [[UILabel alloc] initWithFrame:CGRectZero];
            label.backgroundColor = colors[i%colorCount];
            label.textColor = [UIColor whiteColor];
            label.text = [NSString stringWithFormat:@"Item-%d",i];
            [layouter addChild:label unitX:1 unitY:1];
        }
        // アコーディオンセルのサイズは、アコーディオンビューのレイアウターが管理しているので、それを直接変更しても正しく反映されないし、レンダリングが不正になる。
        // 代わりに、スタックレイアウターの　setSizeOfChild:toSizeメソッドを使用する。
        ac.frame = MICRect(CGPointZero, [ac calcMinSizeOfContents]);
//        [accordion.stackLayout  setSizeOfChild:ac toSize:[ac calcMinSizeOfContents]];
        [accordion addChild:ac];
//        [accordion.stackLayout requestRecalcLayout];

    }

    CGSize contentSize = [accordion.layouter getSize];
//    accordion.frame = CGRectMake(20, 100, contentSize.width, 400);
    accordion.contentSize = contentSize;
    [accordion updateLayout:false];
    [rootView addSubview:accordion];
    
    RALBuilder(rootView)
    .addView(back, RALParams().left().center(nil).top().parent(10))
    .addView(accordion, RALParams()
             .left().center(nil)
             .horz().fixed(contentSize.width)
             .top().adjacent(back,20)
             .bottom().parent(10));
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) goBack:(id)sender {
    [self dismissViewControllerAnimated:true completion:nil];
}

- (void) fold:(id)sender {
    [((MICUiAccordionCellView*)((UIView*)sender).superview) toggleFolding:true onCompleted:nil];
}

///**
// * グリッド内のセルを、AccordionView（スタックレイアウト）にドロップできないようにするための仕掛け。
// */
//- (BOOL)canDropView:(UIView *)draggingView toLayout:(id<MICUiDraggableLayoutProtocol>)dstLayout fromLayout:(id<MICUiDraggableLayoutProtocol>)srcLayout {
//    if([dstLayout isKindOfClass:MICUiStackLayout.class]) {
//        if(![draggingView isKindOfClass:MICUiAccordionCellView.class]) {
//            return false;
//        }
//    }
//    return true;
//}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
