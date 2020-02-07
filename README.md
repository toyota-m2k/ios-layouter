# ios-layouter

## このライブラリについて
さまざまなしがらみがあって、いまだに Objective-C を使い続けざるを得ない不遇なマイノリティのため、レイアウター（子ビューの配置, Observer, Data binding）から、Core Graphics、SVGアイコン, Promise など、iOS + Objective-C でアプリを開発するための、あったら便利、なぜなかったのだろう、を寄せ集めた（寄り集まった）ライブラリです。

## [WPL ... Windows風レイアウター](layouter/doc/wp-layouter.md)

WPL == WPf Layouter<br>
そう、Windows の WPF をリスペクトして実装したレイアウター。<br>
コンテナとして、よく使う Grid, StackPanel（と概ね互換なやつ）を実装。<br>
データや状態の変化を監視するための Observable なデータクラスも作った。<br>
UIView のプロパティと、Observableなデータをバインディングできる。<br>
さすがにXAMLの処理系を作る気力はなかったけど、Obj-C++で、WPFっぽくUIが作れる。

## [NSLayoutConstraintサポート](layoute4r/doc/auto-layout.md)

iOS標準のレイアウト機能である、NSLayoutConstraint を使うと、AndroidのRelativeLayoutやConstraintLayout のようなことができるが、その使い方が、致命的に難しくて面倒。そこで、これをBuilder形式で、簡単に使えるようにしたのが、MICAutoLayoutBuilderとRALBuilder。UIViewの直下を RALBuilder でレイアウトし、その中に（必要に応じて）GridやStackPanelを配置するのがお薦め。

## [旧レイアウター(deprecated)](layouter/doc/original-layouter.md)

はじめての iOSプログラミングの例題として作った子ビューの配置を自動化するレイアウター(GridLayout,StackLayout,RelativeLayout)。

まだ、NSLayoutConstraint がなかった時代に、iOSでのView配置を楽にすることを目標に作った。レイアウター単位でのスクロールやアニメーション、D&Dによる並べ替え、折り畳みなどもサポートする野心的作品で、仕事でも結構使ってきたが、普通のレイアウトに使うには明らかにオーバースペックなので、今後は、wp-layouter (Grid/StackPanel) や、MICAutoLayoutBuilder に移行していく予定。

## [カスタムボタン](layouter/doc/custom-view.md)

SVG Pathをアイコンとして使うことも想定した、簡単にカスタマイズできるボタン。<br>
iOSのボタンカスタマイズは、なにやら面倒なので。。。
<br>
チェックボックスやコンボボックスなども追加。

## [CGRect, CGSize, ...](layouter/doc/rect-size.md)

CGRectとか、CGSizeとか、初期化するだけでも面倒じゃない？<br>
これを、C++ で MFCのCRectみたいな感じにしたら、めっちゃ便利になったんですけど。
<br>ていうか、今となっては、これなしでは、面倒すぎてUIを作る気にならない。


## [Core Graphics サポート](layouter/doc/graphics.md)

CGContextRefとかCGImageRefとかも、C++で。<br>
CGContextRelease(), CGImageRelease(), CGPathRelease(), ... が自動化されるし、これも、CGいぢるなら必須。

## [SVG Path](layouter/doc/svg.md)
さよならPNG。<br>
SVG Path が Objective-Cで扱える。解像度の違いを気にしなくてよくなるし、すでにSVG化が進んでいる、Android や Windowsとアイコン リソースの共通化できる。

## [非同期API・マルチスレッド](layouter/doc/threading.md)

Javascript の Promise にインスパイヤーされた Acom クラスを中心に、マルチスレッド化やスレッド間同期を手軽に実行するための仕掛けを提供。

## [その他](layouter/doc/other.md)

セレクタの実行とか、KeyValue Ovserver の扱いとか、iOS固有の悩みを解消。



