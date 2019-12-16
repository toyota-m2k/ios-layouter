# Contents

## [WPL ... Windows風レイアウター](wp-layouter.md)

WPL == WPf Layouter<br>
そう、Windows の WPF をリスペクトして実装したレイアウター。<br>
コンテナとして、よく使う Grid, StackPanel を実装。<br>
reactiveっぽい、Observable なデータクラスも作った。<br>
UIView のプロパティと、Observableなデータをバインディングできる。
さすがに、xamlを作る気力はなかったけど、ObjC++で、WPFっぽいコーディングができる。

## [レイアウター(元祖)](original-layouter.md)

はじめての iOSプログラミングの例題として作った子ビューの配置を自動化するレイアウター(GridLayout,StackLayout,RelativeLayout)。

レイアウター単位でのスクロールやアニメーション、D&Dによる並べ替えなどもサポートしているが、単なるレイアウトに使うには明らかにオーバースペックなので、
今後は、wp-layouter (Grid/StackPanel) に移行していく予定。
とくにRelativeLayout相当のレンダリングには、NSLayoutConstraintベースの MICAutoLayouBuilder が使えるし、その方が使いやすいと思う（そもそもNSLayoutConstraint登場以前の産物）。

## [カスタムビュー](custom-view.md)

簡単にカスタマイズできるボタンたち。<br>
iOSのボタンカスタマイズは、とにかく面倒なので。SVG Pathをアイコンとして使うことも可能。

## [CGRect, CGSize, ...](rect-size.md)

CGRectとか、CGSizeとか、初期化するだけでも面倒じゃない？<br>
これを、C++ で MFCのCRectみたいな感じにしたら、めっちゃ便利になったんですけど。<br>

## [Core Graphics サポート](graphics.md)

CGContextRefとかCGImageRefとかも、C++で。<br>
薄いラッパーだけど、可読性が断然違う。

## [SVG Path](svg.md)
さよならPNG。<br>
SVG Path が Objective-Cで扱える。

## [非同期API・マルチスレッド](threading.md)

Javascript の Promise にインスパイヤーされた Acom クラスを中心に、マルチスレッド化やスレッド間同期を手軽に実行するための仕掛けを提供。

## [その他](other.md)

セレクタの実行とか、KeyValue Ovserver の扱いとか、iOS固有の悩みを解消。
