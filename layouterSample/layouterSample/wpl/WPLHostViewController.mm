//
//  WPLHostViewController.m
//  layouterSample
//
//  Created by toyota-m2k on 2019/08/08.
//  Copyright © 2019 toyota-m2k. All rights reserved.
//

#import "WPLHostViewController.h"
#import "WPLCellHostingView.h"
#import "WPLGrid.h"
#import "WPLFrame.h"
#import "WPLContainersL.h"
#import "WPLStackPanel.h"
#import "WPLBinder.h"
#import "MICVar.h"
#import "MICAutoLayoutBuilder.h"
#import "WPLConstraintController.h"

@interface WPLHostViewController ()

@end

@implementation WPLHostViewController {
    WPLCellHostingView* _hostView;
    UIViewController* _prev;
}

- (instancetype) initWithPrev:(UIViewController*) prev {
    self = [super init];
    if(nil!=self) {
        _prev = prev;
    }
    return self;
}

- (UIView*) viewInColor:(UIColor*)color {
    let v = [[UIView alloc] initWithFrame:MICRect(MICPoint(), MICSize(20,20))];
    v.backgroundColor = color;
    return v;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor = UIColor.whiteColor;
    _hostView = [WPLCellHostingView new];
//    MICEdgeInsets sa(30,30);
//    MICRect rc(self.view.frame);
//    rc.deflate(sa);

//    _hostView.frame = rc;
//    _hostView.translatesAutoresizingMaskIntoConstraints = false;
//    _hostView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:_hostView];

    MICAutoLayoutBuilder(self.view)
    .fitToSafeArea(_hostView,MICUiPosExALL, MICEdgeInsets(50))
    .activate();
    

    let grid = [WPLGrid gridWithName:@"rootGrid"
                              params:WPLGridParams()
                                .rowDefs(@[AUTO,AUTO,STRC,AUTO])
                                .colDefs(@[STRC,AUTO,AUTO])
                                .requestViewSize(-1, -1)
                                .cellSpacing(10, 10)];
    
    let c1 = [WPLCell newCellWithView:[self viewInColor:UIColor.cyanColor] name:@"v1" params:WPLCellParams().requestViewSize(-1,0)];
    [grid addCell:c1 row:0 column:0];

    let c2 = [WPLCell newCellWithView:[self viewInColor:UIColor.orangeColor] name:@"v2" params:WPLCellParams()];
    [grid addCell:c2 row:0 column:1];

    let c3 = [WPLCell newCellWithView:[self viewInColor:UIColor.yellowColor] name:@"v3" params:WPLCellParams()];
    [grid addCell:c3 row:0 column:2];

    let c4 = [WPLCell newCellWithView:[self viewInColor:UIColor.greenColor] name:@"v4" params:WPLCellParams().requestViewSize(-1,0)];
    [grid addCell:c4 row:3 column:0];

    let c5 = [WPLCell newCellWithView:[self viewInColor:UIColor.purpleColor] name:@"v5" params:WPLCellParams()];
    [grid addCell:c5 row:3 column:1];

    let c6 = [WPLCell newCellWithView:[self viewInColor:UIColor.redColor] name:@"v6" params:WPLCellParams()];
    [grid addCell:c6 row:3 column:2];
    
    let stack = [WPLStackPanel stackPanelWithName:@"stack" params:WPLStackPanelParams().requestViewSize(-1,-1).cellSpacing(10)];
    stack.view.backgroundColor = UIColor.lightGrayColor;
//    stack.visibility = WPLVisibilityCOLLAPSED;
    [grid addCell:stack row:1 column:0 rowSpan:1 colSpan:3];
    
    let s1 = [WPLCell newCellWithView:[self viewInColor:UIColor.blueColor] name:@"s1" params:WPLCellParams().requestViewSize(-1,0)];
    let s2 = [WPLCell newCellWithView:[self viewInColor:UIColor.brownColor] name:@"s2" params:WPLCellParams().requestViewSize(-1,0)];
    let s3 = [WPLCell newCellWithView:[self viewInColor:UIColor.darkGrayColor] name:@"s3" params:WPLCellParams().requestViewSize(-1,0)];
    
    let btn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [btn setTitle:@"Back" forState:UIControlStateNormal];
    [btn sizeToFit];
    [btn addTarget:self action:@selector(backToPrev:) forControlEvents:UIControlEventTouchUpInside];
    let bc = [WPLCell newCellWithView:btn name:@"backBtn" params:WPLCellParams().horzAlign(WPLCellAlignmentCENTER)];
    
    let next = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [next setTitle:@"Next" forState:UIControlStateNormal];
    [next sizeToFit];
    [next addTarget:self action:@selector(goAhead:) forControlEvents:UIControlEventTouchUpInside];
    let nc = [WPLCell newCellWithView:next name:@"nextBtn" params:WPLCellParams().horzAlign(WPLCellAlignmentCENTER)];
    
    [stack addCell:s1];
    [stack addCell:s2];
    [stack addCell:s3];
    [stack addCell:nc];
    [stack addCell:bc];

    let frame = [WPLFrame frameWithName:@"sframe" params:WPLCellParams().requestViewSize(-1,-1)];
    frame.view.backgroundColor = UIColor.orangeColor;
    let s4 = [WPLCell newCellWithView:[self constraintView] name:@"s4" params:WPLCellParams().requestViewSize(-1,-1)];
    [grid addCell:frame row:2 column:0 rowSpan:1 colSpan:2];
    [frame addCell:s4];
    
    _hostView.containerCell = grid;
}

- (void) backToPrev:(id)_ {
    [self dismissViewControllerAnimated:false completion:nil];
}

- (void)goAhead:(id)_ {
    let vc = [[WPLConstraintController alloc] init];
    [self presentViewController:vc animated:true completion:nil];
}

- (UIView*) constraintView {
//    return [self viewInColor:UIColor.greenColor];

    let view = [[UIView alloc] initWithFrame:MICRect(MICSize(100))];
    
    // ここで　LayoutConstraint を使って、
    // view のNSLayoutAttributeTop|Right|Left にconstraintを設定すると、
    // ランタイムに次のようなエラーがデバッグ出力される（レイアウトは正しく実行される）。
    // ---------
    // [LayoutConstraints] Unable to simultaneously satisfy constraints.
    //    Probably at least one of the constraints in the following list is one you don't want.
    //    Try this:
    //    (1) look at each constraint and try to figure out which you don't expect;
    //    (2) find the code that added the unwanted constraint or constraints and fix it.
    //    (Note: If you're seeing NSAutoresizingMaskLayoutConstraints that you don't understand,
    //     refer to the documentation for the UIView property translatesAutoresizingMaskIntoConstraints)
    //    (
    //     "<NSAutoresizingMaskLayoutConstraint:0x600003621f40 h=--& v=--& UIView:0x7f8699302dc0.width == 0   (active)>",
    //     "<NSLayoutConstraint:0x60000367bd90 H:|-(5)-[UIView:0x7f8699302fa0](LTR)   (active, names: '|':UIView:0x7f8699302dc0 )>",
    //     "<NSLayoutConstraint:0x60000367b160 UIView:0x7f8699302fa0.right == UIView:0x7f8699302dc0.right - 5   (active)>"
    //     )
    // ---------
    //
    // view.translatesAutoresizingMaskIntoConstraints = false;
    // とすると、このエラーは出力されなくなるが、今度は、レイアウトされなくなる。
    // つまり、このフラグをfalseにすると、ビューのレイアウトがAutoLayoutの管理下に入るため、WPLContainerによるレンダリングが効かなくなるようだ。
    //
    // それはさておき、エラーメッセージから、NSAutoresizingMaskLayoutConstraint がなにか悪さをしている印象があり、
    // AutoLayoutとそうでないビュー(AutoResizing)とを混ぜると面倒なことになるのかと諦めかけたが、このエラーメッセージが言っているのは、
    // 親(view) のwidthがゼロなのに、それを基準に、Left/Rightを、内側に配置しようとして（サイズが負値になるので）エラーになっていると
    // 主張しているだけなのだ。だから、親(view)の初期サイズを、ゼロにならないよう指定してやると、なんと、エラーは出なくなった。
    // 多分、無視しても大丈夫なエラーということだと思う。
    //
    // 実験中に、「NSLayoutAttributeTopなどの代わりに、UIView#topAnchor などのアンカーを使って配置すると、
    // このエラーは出力されなくなる」と思い込んだが、それは、たまたま、top/left だけを指定して、right を指定していなかったからだったと判明。
    // どちらを使っても同じ結果になるようだ。

    
//    view.translatesAutoresizingMaskIntoConstraints = false;
//    view.autoresizingMask = UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleBottomMargin;//UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    MICAutoLayoutBuilder builder(view);
    
    let v1 = [UIView new]; //[self viewInColor:UIColor.purpleColor];
    v1.backgroundColor = UIColor.purpleColor;
    v1.translatesAutoresizingMaskIntoConstraints = false;
    [view addSubview:v1];
//    builder.constraintFitParent(v1, MICUiPosExUPPER, MICEdgeInsets(5));

    builder.anchorConstraint(v1.topAnchor, view.topAnchor, 5);
    builder.anchorConstraint(v1.leftAnchor, view.leftAnchor, 5);
    builder.anchorConstraint(v1.rightAnchor, view.rightAnchor, -5);
    builder.constraint(v1, NSLayoutAttributeHeight, nil, NSLayoutAttributeHeight, 20);
//    builder.constraint(v1, NSLayoutAttributeWidth, nil, NSLayoutAttributeWidth, 100);

    
    let v2 = [self viewInColor:UIColor.greenColor];
    [view addSubview:v2];
    builder.putBelow(v2, v1, 5, MICUiAlignExFILL);
    builder.constraint(v2, NSLayoutAttributeHeight, nil, NSLayoutAttributeHeight, 20);

        let v3 = [self viewInColor:UIColor.cyanColor];
    [view addSubview:v3];
    builder.putBelow(v3, v2, 5, MICUiAlignExFILL);
    builder.constraint(v3, NSLayoutAttributeHeight, nil, NSLayoutAttributeHeight, 20);

    let v4 = [self viewInColor:UIColor.redColor];
    [view addSubview:v4];
    builder.putBelow(v4, v3, 5, MICUiAlignExFILL);
    builder.constraint(v4, NSLayoutAttributeHeight, nil, NSLayoutAttributeHeight, 20);

    builder.activate();
    
    return view;
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
