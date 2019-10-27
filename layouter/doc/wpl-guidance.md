# WPLライブラリの使い方

このライブラリはObjCで利用できますが、それよりもObjC++を使って書いた方が、断然シンプルで読みやすくなります。なので、ここでは、C++前提です。

## セル・ホスティング・ビューの準備

UIViewController#viewDidLoad などの中で、コンテナーセルをホストするための、WPLCellHostingViewを用意します。この例では、ルートコンテナとして、WPLStackPanelを使うことにして、ホスティング・ビューには、WPLStackPanelView を使います。

（１）ルートコンテナのStackPanelの属性（WPLStackPanelParams）を定義します。

    // alignとcellSpacingだけ設定して、残りはすべてデフォルトのまま。
    WPLStackPanelParams stackParams()
                        .align(WPLAlignment(WPLCellAlignmentCENTER))
                        .cellSpacing(20);

（２）CellHostingView（WPLStackPanelView）を作成します。
        
    _hostView =  [WPLView gridViewWithName:@"root" // 名前は任意 
                                    params:stackParams];

（３）CellHostingView を、親ビューに配置します。

    // UIViewController#view の子ビューにする
    [self.view addSubview:_hostView];

    // UIViewControllerのSafeAreaいっぱいにCellHostingViewを配置
    // MICAutoLayoutBuilderを使って NSLayoutConstraint の設定を行う。
    MICAutoLayoutBuilder(self.view)
        .fitToSafeArea(_hostView,MICUiPosExALL, MICEdgeInsets(50))
        .activate();

（４）ビューと、それをラップするセルを作成します。

    // UILabelを持つ WPLTextCellを作成（パラメータはすべてデフォルト）し、
    let label = [[UILabel alloc] init];
    let labelCell = [WPLTextCell newCellWithView:label 
                                            name:@"label" 
                                            params:WPLCellParams()];
    // 同様にUITextField を作成
    let textView = [[UITextField alloc] init];
    let textViewCell = [WPLTextCell newCellWithView:textView
                                                name:@"textview"
                                                param:WPLCellParams()];

    // UISwitchを作成
    let switchView = [[UISwitch alloc] init];
    let switchCell = [WPLSwitchCell newCellWithView:switchView
                                                name:@"sw"
                                                param:WPLCellParams()];

（５）作成したセルをコンテナ（スタックパネル）に追加します。                                            

    [_hostView.container addCell:labelCell];
    [_hostView.container addCell:textViewCell];
    [_hostView.container addCell:switchCell];

（６）続いて、WPLBinder, WPLBindingBuilder を使ってデータバインドを定義していきます。


    _binder = WPLBindingBuilder()
                // バインド可能なプロパティを登録
                .property(@"labelProperty", ＠”WPL Demo”)   // --> label
                .property(@"inputTextProperty", @"")        // --> text field
                .property(@"switchProperty", @true)      // --> switch
                // セルをプロパティにバインド
                .bindValue(@"labelProperty", labelCell)
                .bindValue(@"inputTextProperty", textViewCell, WPLBindingModeTWO_WAY)
                .bindValue(@"switchProperty", switchCell, WPLBindingModeTWO_WAY)
                // UISwitchのon/off で、TextViewの RW/ROを切り替えるためのバインドを作成
                .bindState(@"switchProperty", textViewCell, WPLBoolStateActionTypeREADONLY)
                // 以上の内容で WPLBinderを作成
                .build();

以上で、ViewController上に、UILabel, UITextView, UISwitchが縦に並び、Switch を操作することで、TextViewの、RO/RWが切り替わります。



