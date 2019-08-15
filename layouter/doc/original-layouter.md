## レイアウター（元祖）

    layouter/
        MICUiStackLayout
        MICUiGridLayout
        MICUiRelativeLayout

初めてのiOSプログラミングとして最初に作ったレイアウターたち。
これらは、任意のビューと組み合わせて利用することを想定した（ビューではない）純粋なレイアウタークラス。
ドラッグ＆ドロップによるセルの並び替え対応など、最初にしては、よく頑張ったほうだと思う。
いろいろ紆余曲折があって、テスト/サンプルプログラムなどは失われてしまったけど、長い間、実務的に利用しており、それなりに重宝している。

* MICUiStackLayout

    子ビューを横、または、縦方向に一列に並べて配置する。
    WindowsのStackPanel, AndroidのLinearLayoutのイメージ。
    シンプルなので、とてもよく使うレイアウター。

* MICUiGridLayout

    子ビューを格子状に配置する。
    あらかじめ、GridLayoutに対して、格子サイズ（ユニットサイズ）を定義しておき、
    子ビューのサイズは、このユニットサイズを基準に１ｘ１とか、２ｘ１といったセルサイズを指定する。
    もともと、Windows 10 のスタートメニュー（Windows 8 のスタート画面）のタイル風の画面を実装する目的で作ったので、WindowsのGridとは、少し考え方が異なる。さらに、目的アプリの開発が途中で頓挫したこともあって、実用にはほとんど使っていない。

* MICUiRelativeLayout

    親ビューのBoundsや、兄弟ビューのFrameに対する相対位置、相対サイズによって子ビューを配置する。WindowsのFormや、AndroidのRelativeLayout, ConstraintLayout に近い考え方で、よく使ってきたのだが、Objective-C の面倒な書式のせいで、定義がとても見づらくなってしまったのが難点。

## レイアウタービュー

レイアウター自身は、ビューを持たず、任意のビューに接続してレンダリングを実行できる設計としていたが、実際に使ってみると、すでに、そのあたりにころがっているビューに接続する、というシチュエーションは、まず存在せず、たいてい、[UIView new] で新しく作ったビューをセットして利用することに気づいた。そこで、ビューとセットになったレイアウターを実装したのが、こちら。

    layouter/view/
        MICUiStackView
        MICUiGridView
        MICUiSimpleLayoutView
        MICUiSimpleStackLayoutView
        MICUiAccordionView
        MICUiAccordionCellView
        MICUiTabBarView


* MICUiStackView

    MICUiStackLayoutのView版。<br>
    UIScrollView 派生クラスで、スクロールと子ビューのスクロールをサポートする。

* MICUiGridView

    MICUiGridLayoutのView版。<br>
    以下略。

* MICUiRelativeView

    作っていない。<br>
    D&Dの仕様が、他のレイアウターと大きく異なること（および、得られるメリットが少なくて、やる気を失ったこと）が理由。

* MICUiSimpleStackLayoutView

    MICUiStackView / MICUiGridView は、どちらも、スクロールやD&Dによる再配置をサポートしているが、実用上、ほとんどのケースで、これらは不要だった。そこで、これらを省略した簡易版のコンテナビューを作ってみた。

    最初、GridLayoutやRelativeLayoutのSimpleLayoutViewも作るつもりだったのだけれど、MICUiSimpleStackLayoutViewを作ってみて、得られるメリットが少ない（思ったほどコーディング量が減らない）のでやめた。

* MICUiAccordionCellView

    UIView派生クラス。<br>
    LabelViewと、BodyViewから構成され、折り畳み(fold)と展開(unfold)の状態を持つ。
    LabelViewには、任意のUIViewを、BodyViewには、UIViewまたは、他のレイアウターを配置可能。

    もともと、AccordionCellViewは、AccordionViewの内部に配置するために実装したが、開閉動作を持つビューとして、単独で使用することも可能。

* MICUiAccordionView

    StackView派生クラス <br>
    AccordionCellViewを縦、または、横に並べて配置し、AccordionCellViewの折り畳み/展開に合わせて、他のAccordionCellViewを再配置する動作が実装されている。

* MICUiTabBarView

    TabBarViewは、任意のビュー（通常はタブボタン）を並べるビュークラス。バーのサイズに応じて、タブのスクロールなどの動作が追加されている。

## D&Dサポート
    
すべてのLayouter（StackLayout/GridLayout/RelativeLayout）は、DraggableLayoutProtocolを実装し、D&Dサポーターを使用することにより、セルのD&Dが可能になる。

D&Dサポーターには、次の２種類が用意されている。

- MICCellDragSupport
    １つのコンテナビュー内でのD&Dをサポート
    
- MICCellDragSupporEx
    複数の（ネストする）コンテナビューにまたがるD&Dをサポート

コンテナビューとして、UIScrollViewを使用した場合は、ドラッグ中の自動スクロールにも対応可能で、StackView, GridView は、デフォルトで、CellDragSupportによるアイテムのD&D（配置変更）をサポートしている。

AccordionViewでは、CellDragSupporEx を使用して、異なるAccordionCellView間でのアイテムのD&Dと、AccordionCellView自体のD&Dによる配置入れ替えが可能。

尚、コンテナビューとして、UIScrollView以外を使用する場合、または、UIScrollView派生クラスでも、
スクロールの方法をカスタマイズしているような場合には、独自のD&Dサポーターを実装する必要があるかもしれない。
    
## RelativeLayout 上でのD&Dについて

現状の実装（永遠に暫定）では、ドロップされたアイテムは、オリジナルの配置指定を破棄して、必ず、親ビューのBoundsの左上隅を基準とする相対位置で配置される。

当初の構想としては、親のフレームにアタッチするとか、他の兄弟ビューをよけるとか、いろいろなルールを作ろうと考えていたが、
時間切れにより挫折。

## SwitchingViewMediator

２つ以上のビューの表示・非表示切り替えに関して、次の３つのルールを定義して登録しておくことにより、ユーザによるビューの表示切り替え動作による画面の状態遷移を自動化できる。

- ペインAが開いた時は、ペインBを閉じる（排他）
- ペインAを閉じたら、ペインBを開く（反転）
- ペインAが開いたら、ペインBも開く（同調）

表示・非表示切り替えのデフォルトの動作は、UIViewのhidden属性に対する操作であるが、ViewVisibilityDelegate を実装することにより、例えば、AccordionCellViewの折り畳み動作などに割り当てることができる。
    
    
