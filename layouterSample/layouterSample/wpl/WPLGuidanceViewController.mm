//
//  WPLGuidanceViewController.m
//  layouterSample
//
//  Created by @toyota-m2k on 2019/10/28.
//  Copyright (c) 2019 @toyota-m2k. All rights reserved.
//

#import "WPLGuidanceViewController.h"
#import "MICVar.h"
#import "WPLStackPanelView.h"
#import "MICAutoLayoutBuilder.h"
#import "WPLTextCell.h"
#import "WPLSwitchCell.h"
#import "WPLBinder.h"

@interface WPLGuidanceViewController ()

@end

@implementation WPLGuidanceViewController {
    WPLStackPanelView* _hostView;
    WPLBinder* _binder;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // 背景を白にしておく
    self.view.backgroundColor = UIColor.whiteColor;

    //（１）ルートコンテナのStackPanelの属性（WPLStackPanelParams）を定義します。
    // - 横方向は画面サイズに合わせて伸縮
    // - 縦方向は、内部のパーツが収まるサイズに調整し、センタリング
    // - 並べるアイテム（セル）の間隔は20px
    let stackParams = WPLStackPanelParams()
                        .requestViewSize(MICSize(WPL_CELL_SIZING_STRETCH,WPL_CELL_SIZING_AUTO))
                        .align(WPLAlignment(WPLCellAlignmentCENTER))
                        .cellSpacing(20);

    //（２）CellHostingView（WPLStackPanelView）を作成します。
    _hostView =  [WPLStackPanelView stackPanelViewWithName:@"root" // 名前は任意
                                                    params:stackParams];

    //（３）CellHostingView を、親ビューに配置します。
    // UIViewController#view の子ビューにする
    [self.view addSubview:_hostView];

    // UIViewControllerのSafeAreaいっぱいにCellHostingViewを配置
    // MICAutoLayoutBuilderを使って NSLayoutConstraint の設定を行う。
    MICAutoLayoutBuilder(self.view)
        .fitToSafeArea(_hostView,MICUiPosExALL, MICEdgeInsets(50))
        .activate();


    //（４）ビューと、それをラップするセルを作成します。

    // UILabelを持つ WPLTextCellを作成
    // - 左詰を指定（これはデフォルト値だけど）
    // - 縦方向のアラインメントは無視される（StackPanelによってセルの高さ==UILabelの高さ に調整されるため）
    let label = [[UILabel alloc] init];
    let labelCell = [WPLTextCell newCellWithView:label
                                            name:@"label"
                                          params:WPLCellParams()
                                             .align(WPLAlignment(WPLCellAlignmentSTART,WPLCellAlignmentCENTER))];
    
    
    // 同様にUITextField を作成
    // - 左詰を指定
    // - セル幅は画面幅に合わせて伸縮
    // - セル高さは、固定値を指定（AUTOにすると、未入力状態＝初期状態で高さがゼロになってしまう。）
    let textView = [[UITextView alloc] init];
    textView.layer.borderWidth = 0.5;
    let textViewCell = [WPLTextCell newCellWithView:textView
                                               name:@"textView"
                                             params:WPLCellParams()
                                                    .align(WPLAlignment(WPLCellAlignmentSTART,WPLCellAlignmentCENTER))
                                                    .requestViewSize(MICSize(WPL_CELL_SIZING_STRETCH, 36))];

    // UISwitchを作成
    // - センタリングを指定
    let switchView = [[UISwitch alloc] init];
    let switchCell = [WPLSwitchCell newCellWithView:switchView
                                               name:@"switch"
                                             params:WPLCellParams()
                                                    .align(WPLAlignment(WPLCellAlignmentCENTER))];
    
    // TextViewの入力内容をエコーバックするラベルを作成
    // - 右詰を指定
    let echoView = [[UILabel alloc] init];
    let echoCell = [WPLTextCell newCellWithView:echoView
                                            name:@"echo"
                                          params:WPLCellParams()
                                             .align(WPLAlignment(WPLCellAlignmentEND,WPLCellAlignmentCENTER))];

    //（５）作成したセルをコンテナ（スタックパネル）に追加します。

    [_hostView.container addCell:labelCell];
    [_hostView.container addCell:textViewCell];
    [_hostView.container addCell:switchCell];
    [_hostView.container addCell:echoCell];

    //（６）最後に、WPLBinder, WPLBindingBuilder を使ってデータバインドを定義していきます。

    _binder = WPLBinderBuilder()
                // バインド可能なプロパティを登録
                .property(@"labelProperty", @"WPL Demo")   // --> label
                .property(@"inputTextProperty", @"")        // --> text field
                .property(@"switchProperty", true)      // --> switch
                // セルをプロパティにバインド
                .bind(@"labelProperty", labelCell, WPLBindingModeSOURCE_TO_VIEW)
                .bind(@"inputTextProperty", textViewCell, WPLBindingModeTWO_WAY)
                .bind(@"switchProperty", switchCell, WPLBindingModeVIEW_TO_SOURCE_WITH_INIT)
                // UISwitchのon/off で、TextViewの RW/ROを切り替えるためのバインドを作成
                .bind(@"switchProperty", textViewCell, WPLBoolStateActionTypeREADONLY, true)
                // TextViewへの入力内容を、echoCellにエコーバックするためのバインドを作成
                .bind(@"inputTextProperty", echoCell, WPLBindingModeSOURCE_TO_VIEW)
                // 以上の内容で WPLBinderを作成
                .build();

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
