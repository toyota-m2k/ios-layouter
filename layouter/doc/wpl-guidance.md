# WPLライブラリの使い方

このライブラリはObjCで利用できますが、それよりもObjC++を使って書いた方が、断然シンプルで読みやすくなります。なので、ここでは、C++前提です。

## セル・ホスティング・ビューの準備

UIViewController#viewDidLoad などの中で、コンテナーセルをホストするための、WPLCellHostingViewを用意します。この例では、ルートコンテナとして、WPLStackPanelを使うことにして、ホスティング・ビューには、WPLStackPanelView を使います。

尚、"let" は、MICVar.h で定義しています。__auto_type const と読み替えてください。
### （１）ルートコンテナ属性を定義します。

ここでは、コンテナとして、WPLStackPanel を使用することにして、その属性を、WPLStackPanelParams で定義します。

    let stackParams = WPLStackPanelParams()
                        .requestViewSize(MICSize(WPL_CELL_SIZING_STRETCH,WPL_CELL_SIZING_AUTO))
                        .align(WPLAlignment(WPLCellAlignmentCENTER))
                        .cellSpacing(20);

上の例では、つぎのように設定しています。<br>
 
  ・横方向は画面サイズに合わせて伸縮<br>
  ・縦方向は、内部のパーツが収まるサイズに調整し、センタリング<br>
  ・並べるアイテム（セル）の間隔は20px<br>


### （２）セル・ホスティング・ビューを作成します。

セル・ホスティング・ビューとして、WPLStackPanelViewを使います。


    _hostView =  [WPLStackPanelView stackPanelViewWithName:@"root" // 名前は任意
                                                    params:stackParams];

### （３）セル・ホスティング・ビューを、親ビューに配置します。

    // UIViewController#view の子ビューにする
    [self.view addSubview:_hostView];

    // 親ビュー内での配置は、NSLayoutConstraintに任せる
    MICAutoLayoutBuilder(self.view)
        .fitToSafeArea(_hostView, MICUiPosExALL, MICEdgeInsets(50))
        .activate();

WP Layouter の本質からは逸れますが、UIViewControllerのSafeAreaいっぱいに View を配置する、などの指定には、NSLayoutConstraint を使うのがよいですが、その使い方がかなり面倒です。この面倒を軽減するため、MICAutoLayoutBuilder を使っています。

### （４）ビューと、それをラップするセルを作成します。

ここでは４つのビュー（UILabel, UITextField, UISwitch, UITextView）と、それぞれを保持するセルを作成します。UILabel, UITextField, UITextView の３つは、属性としてテキストを持っているので、WPLTextCell を使います。UISwitchは、on/off状態を持つ専用のセル、WPLSwitchCell を使います。これらにより、テキストやon/offなどの状態を、プロパティ（IWPLObservableData）とをバインドできるようになります。

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

### （５）作成したセルをコンテナ（スタックパネル）に追加します。

    [_hostView.container addCell:labelCell];
    [_hostView.container addCell:textViewCell];
    [_hostView.container addCell:switchCell];
    [_hostView.container addCell:echoCell];


### （６）セルにバインドするためのプロパティを作成します。

バインディングとは、セルとデータソース(IWPLObservableData)の接続情報を持つ、IWPLBinding インスタンスを生成することです。このIWPLBindingインスタンスは、実行中、どこかで保持しておく必要があります。この管理は、独自に実装してもかまいませんが、ここでは、WPL標準のバインド管理機構であり、セル・ホスティング・ビューから提供される、WPLBinder を利用します。

    WPLBinderBuilder(_hostView.binder)
      // バインド可能なプロパティを登録
      .property(@"labelProperty", @"WPL Demo")   // --> label
      .property(@"inputTextProperty", @"")        // --> text field
      .property(@"switchProperty", true)        // --> switch

### （７）プロパティとセルをバインドします。

WPLBinderを使う場合、プロパティには、プロパティ名でアクセスし、プロパティを、セルのどの属性に、どのようにバインドするかを指定します。あらかじめ用意されているバインドでは実現できない動作は、bindCustom()を使ってカスタマイズ可能です。

尚、この例では、セルとして、手順（４）で定義した変数を使っていますが、これも、
WPLContainerCell の findByName: メソッドを使えば、名前でアクセスできるので、あらかじめ定義しておいたstaticなテーブルからビュー、プロパティ、バインドをまとめて構築する、というような処理が書くことが可能になります。

    WPLBinderBuilder(_hostView.binder)
      // セルをプロパティにバインド
      .bind(@"labelProperty", labelCell, WPLBindingModeSOURCE_TO_VIEW)
      .bind(@"inputTextProperty", textViewCell, WPLBindingModeTWO_WAY)
      .bind(@"switchProperty", switchCell, WPLBindingModeVIEW_TO_SOURCE_WITH_INIT)
      // UISwitchのon/off で、TextViewの RW/ROを切り替えるためのバインドを作成
      .bind(@"switchProperty", textViewCell, WPLBoolStateActionTypeREADONLY, true)
      // TextViewへの入力内容を、echoCellにエコーバックするためのバインドを作成
      .bind(@"inputTextProperty", echoCell, WPLBindingModeSOURCE_TO_VIEW)



以上で、ViewController上に、UILabel, UITextView, UISwitch, UILabelが縦に並び、Switch を操作することで、TextViewの、RO/RWが切り替わります。また、TextViewに文字列を入力すると、一番下のUILabelにその文字列が表示されます。



