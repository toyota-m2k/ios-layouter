# カスタムボタン

タブビューの「タブ」とか、リストの開閉ボタンとか、iOS標準のUIButtonでは、なにかと不自由で、UIViewから派生したボタン風のビューを作ってしまった。

    layouter/
      designed/
        MICUiDsCustomButton
        MICUiSvgIconButton
        MICUiStatefulResource

## MICUiDsCustomButton

カスタマイズ可能なボタンクラス（UIButton派生ではなく、UIView派生）。<br>
アイコン、ラベル、マージンやボーダーなどのプロパティを指定するだけで、さまざまな描画が可能。

### プロパティ
|名前|型|RW|説明|
|:--|:--|:--|:--|
|text|NSString*|RW|ボタンのキャプション|
|colorResources|id<MICUiStatefulResourceProtocol>|RW|色指定・背景画像指定用リソース|
|iconResources|id<MICUiStatefulResourceProtocol>|RW|アイコン定義用リソース|
|textHorzAlignment|MICUiAlign|RW|キャプションの横方向アラインメント|
|borderWidth|CGFloat|RW|枠線の幅|
|fontSize|CGFloat|RW|フォントサイズ|
|contentMargin|UIEdgeInsets|RW|ボタン矩形とコンテント（アイコン・キャプション）とのマージン|
|iconTextMargin|CGFloat|RW|アイコンとキャプションの間のマージン|
|roundRadius|CGFloat|RW|角丸の半径（ゼロなら直角）|
|turnOver|bool|RW|上下逆転（１８０度回転）|
|buttonState|MICUiViewState|RO|ボタンの状態
|enabled|bool|RW|有効／無効状態|
|selected|bool|RW|選択状態|
|activated|bool|RW|アクティブ化状態（タップされた状態）|
|inert|bool|RW|不活性状態（主に内部利用のみ：D&D操作中のタップ動作を禁止する場合に使用）|
|multiLineText|bool|RW|true:改行コード('\n')による複数行文字列表示を有効にする (default:false)|
|lineSpacing|CGFloat|RW|複数行表示の場合の行間（行の高さに対する比率で指定）|
|customButtonDelegate|id<MICUiDsCustomButtonDelegate>|RW|イベントリスナー|
|key|NSString*|RW|任意の文字列|

### カスタムドローのためのメソッド

```
- (void) getContentRect:(UIImage*)icon 
               iconRect:(CGRect*)prcIcon 
               textRect:(CGRect*)prcText;
```
|引数|型|in/out|説明|
|:--|:--|:--|:--|
|icon|UIImage*|in|アイコン（サイズ取得用）|
|prcIcon|CGRect*|out|アイコン描画領域|
|prcText|CGRect*|out|テキスト描画領域|

ボタンのBounds内に、アイコン、および、テキストを描画するため、それぞれの描画領域を取得する。
テキスト、または、アイコンの描画位置を変更する場合は、サブクラスでオーバーライドする。デフォルトの実装は、
- 左端にアイコン、その右にiconTextMarginをあけてテキストを表示する。
- アイコンだけ、または、テキストだけのときは、それぞれセンタリングする。

```
- (void) drawText:(CGContextRef)rctx 
             rect:(CGRect)rect 
           halign:(NSTextAlignment)halign 
           valign:(MICUiAlign)valign;
```
|引数|型|in/out|説明|
|:--|:--|:--|:--|
|rctx|CGContextRef|in|描画先 CGContext|
|rect|CGRect|in|テキスト描画領域|
|halign|NSTextAlignment|in|横方向アラインメント|
|valign|MICUiAlign|in|縦方向アラインメント|

指定された描画領域に、テキストを描画する。
通常はオーバーライド不要。
drawContentをオーバーライドする場合にも、テキスト出力のユーティリティとして利用可。

```
- (void) drawIcon:(CGContextRef)rctx 
             icon:(UIImage*)icon 
             rect:(CGRect)rect;
```
|引数|型|in/out|説明|
|:--|:--|:--|:--|
|rctx|CGContextRef|in|描画先 CGContext|
|icon|UIImage*|in|アイコン|
|rect|CGRect|in|アイコン描画領域|

指定された描画領域に、アイコン(UIImage*)を描画する。
通常はオーバーライド不要。

```
- (UIFont*) getFont;
```

ラベル描画用フォントを取得する。
デフォルトの実装では、boldSystemFont を使用。これを変更する場合はサブクラスでオーバーライドする。

```
- (void) eraseBackground:(CGContextRef)ctx 
                    rect:(CGRect)rect;
```
|引数|型|in/out|説明|
|:--|:--|:--|:--|
|rctx|CGContextRef|in|描画先 CGContext|
|rect|CGRect|in|ボタン描画領域|

ボタンの背景を描画する。
背景の描画方法を変更する場合は、サブクラスでオーバーライドする。
 デフォルトでは、
 - 画像を使用
 - 背景色、ボーダー色を指定した矩形または、角丸矩形で描画
 の２種類の描画をサポートする。

```
- (void) drawContent:(CGContextRef)ctx 
                rect:(CGRect)rect;
```
|引数|型|in/out|説明|
|:--|:--|:--|:--|
|rctx|CGContextRef|in|描画先 CGContext|
|rect|CGRect|in|ボタン描画領域|

ボタンのコンテント（アイコンとテキスト）を描画する。
- 背景（塗りとボーダー）の描画方法を変更する場合はeraseBackgroundをオーバーライド
- アイコンとテキストの位置を変える→　getContentRect をオーバーライド
- テキストのフォントを変える→　getFontをオーバーライド

これら以外（例えば、アイコンを２つ重ねるとか、SVGを使うとか）のカスタマイズを行う場合には、このメソッドをオーバーライドする。
 
## MICUiSvgIconButton

PNG の代わりに、SVG Path をアイコンとして使えるようにした、MICUiDsCustomButton 派生クラス。

### プロパティ
|名前|型|RW|説明|
|:--|:--|:--|:--|
|iconSize|CGSize|RW|アイコンの描画サイズ|
|viewboxSize|CGSize|RW|SVG Pathのアイコンの描画サイズ|
|stretchIcon|bool|RW|true: frame.height に合わせてアイコンを拡大する.<br>false: iconSize に従って描画（デフォルト）|

## ボタンの状態毎にアイコン、配色を指定する

### __MICUiStatefulResourceProtocol__

MICUiDsCustomButton および、その派生クラスの配色やアイコンを定義・供給するためのi/f。
MICUiResType x MICUiViewState に対して、それぞれリソースを定義できる。


__enum MICUiResType__

リソースタイプ（＝ボタンの部品・部位）を指定するための定義。

|名前|説明|
|:--|:--|
|MICUiResTypeBGCOLOR|背景色|
|MICUiResTypeFGCOLOR|文字色|
|MICUiResTypeBORDERCOLOR|枠線の色|
|MICUiResTypeBGIMAGE|背景イメージ|
|MICUiResTypeICON|アイコン(UIImage)|
|MICUiResTypeSVG_PATH|アイコン(SVG Path)|
|MICUiResTypeSVG_COLOR|SVG PathのFill Color|

__enum MICUiViewState__

ボタンの状態を表すフラグ

|名前|値|説明|
|:--|--:|:--|
|MICUiViewStateNORMAL|0|通常|
|MICUiViewStateSELECTED_|0x01|選択/チェック中|
|MICUiViewStateACTIVATED_|0x02|タップ中|
|MICUiViewStateDISABLED_|0x04|無効化|
|MICUiViewStateDISABLED_SELECTED|0x04\|0x01|選択/チェックされた状態で無効化|
|MICUiViewStateACTIVATED_SELECTED|0x02\|0x01|選択/チェックされた状態でタップ|

__定義済みリソースの取得__

```
- (id)resourceOf:(MICUiResType)type 
        forState:(MICUiViewState)state;

- (id)resourceOf:(MICUiResType)type 
        forState:(MICUiViewState)state 
   fallbackState:(MICUiViewState)fallback;
```

|引数|型|in/out|説明|
|:--|:--|:--|:--|
|type|MICUiResType|in|リソースタイプ|
|state|MICUiViewState|in|ボタンの状態
|fallback|MICUiViewState|in|stateに対するリソースが指定されていないときの代替（デフォルト：NORMAL）|

|戻り値|説明| 
|:--|:--|
|id| リソース <br>UIColor*\|UIImage*\|MICSvgPath*|

### __MICUiStatefulResource__

状態管理に辞書(NSDictionary)を用いた、MICUiStatefulResourceProtocol i/fの汎用的な実装。

この実装では、リソースを指定するために、MICUiResType + MICUiViewState の代わりに、MICUiStatefulResource.h で#defineされた状態名(MICUiStatefulXxxxYYYY)を使う。（この状態名を、状態管理辞書のキーとして利用する。）

あらかじめ、NSDictionaryとして定義された状態とリソースの関係から、インスタンスが作成できるので、宣言的なリソース定義が可能。

例）
```
MICUiStatefulResource* resources = [[MICUiStatefulResource alloc] initWithDictionary:
    @{  MICUiStatefulBgColorNORMAL: [UIColor darkGrayColor],
        MICUiStatefulBgColorSELECTED: [UIColor greenColor],
        MICUiStatefulBgColorACTIVATED: [UIColor yellowColor],
        MICUiStatefulBgColorDISABLED: [UIColor darkGrayColor],
        
        MICUiStatefulFgColorNORMAL: [UIColor whiteColor],
        MICUiStatefulFgColorSELECTED: [UIColor blackColor],
        MICUiStatefulFgColorACTIVATED: [UIColor blackColor],
        MICUiStatefulFgColorDISABLED: [UIColor grayColor],
        
        MICUiStatefulBorderColorNORMAL: [UIColor whiteColor],
     }];
```

#### 動的なリソース作成・変更

```
- (void)setResource:(id)res 
            forName:(NSString *)name;
```
|引数|型|in/out|説明|
|:--|:--|:--|:--|
|res|NSString*|in|リソース|
|name|NSString*|in|状態名|

状態名で指定される(MICUiResType x MICUiViewState)リソースを設定する。
すでに定義されていれば上書きされる。

```
- (void)complementResource:(id)res 
                   forName:(NSString *)name;
```
|引数|型|in/out|説明|
|:--|:--|:--|:--|
|res|NSString*|in|リソース|
|name|NSString*|in|状態名|

状態名で指定される(MICUiResType x MICUiViewState)リソースが未定義なら設定する。すでに定義されていれば何もしない。

```
- (void)mergeResource:(MICUiStatefulResource*) src 
            overwrite:(bool)overwrite;

- (void)mergeResource:(NSDictionary*) src 
            overwrite:(bool)overwrite;
```
|引数|型|in/out|説明|
|:--|:--|:--|:--|
|src|MICUiStatefulResource*|in|マージするMICUiStatefulResourceインスタンス|
|src|MICUiStatefulResource*|in|マージする状態定義辞書|
|overwrite|bool|in|true: 定義済みのリソースも上書きする。<br>false: 定義済みリソースには上書きしない。|

