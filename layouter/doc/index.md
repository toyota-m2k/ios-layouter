# Contents

## [レイアウター(元祖)](original-layouter.md)

はじめての iOSプログラミングの例題として作った子ビューの配置を自動化するレイアウター(GridLayout,StackLayout,RelativeLayout)。

スクロールやアニメーション、D&Dによる並べ替えなどもサポートしているが、単なるレイアウトに使うにはオーバースペックなので、
今後は、wp-layouter (Grid/StackPanel) に移行していく予定。
また、RelativeLayout相当のレンダリングには、AutoLayoutベースの MICAutoLayouBuilder も使える（こっちのほうが使いやすい）。

## [カスタムビュー](custom-view.md)

簡単にカスタマイズできるボタンたち。<br>
iOSのボタンカスタマイズは、とにかく面倒なので。SVG Pathをアイコンとして使うことも可能。

## [WPL == WPf Layouter](wp-layouter.md)

Windows の WPF をリスペクトして実装。<br>
コンテナとして、よく使う Grid, StackPanel を実装。
UIView のプロパティと、Observableなデータをバインディングできる。

### [CGRect, CGSize, ...](rect-size.md)

CGRectとか、CGSizeとか、初期化するだけでも面倒じゃない？
これを、C++ で書いたら、めっちゃ便利になったんですけど。

### [Core Graphics サポート](graphics.md)

CGContextRefとかCGImageRefとかも、C++で。<br>
薄いラッパーだけど、可読性が断然違う。

### [SVG Path](svg.md)
さよならPNG。SVG Path が Objective-Cで扱える。

### [コレクション](collection.md)

SortedArray, Queue, Matrix, Tree, ...<br>

### [非同期API・マルチスレッド](threading.md)

Javascript の Promise にインスパイヤーされた Acom クラスを中心に、マルチスレッド化やスレッド間同期を手軽に実行するための仕掛けを提供。

### [その他](other.md)

セレクタの実行とか、KeyValue Ovserver の扱いとか、iOS固有の悩みを解消。
