# カスタムビュー

レイアウターやレイアウトビューなどは、すべてデザイン的にニュートラルで、利用するアプリのデザインに干渉しない設計としたが、アコーディオンビュー（MICUiAccordionView）やタブビュー(MICUiTabBarView) などを実装したときに、ちょっと見栄えのよいボタンが欲しくなった。でも、いざ、UIButtonをカスタマイズしようとすると、何やら、やたらと面倒で嫌になってしまった。そこで作ったのがこちら。

    layouter/
      designed/
        MICUiDsCustomButton
        MICUiDsTabButton
        MICUiDsTabView
        MICUiSvgIconButton
        MICUiStatefulResource

* MICUiDsCustomButton

    カスタマイズ可能なボタンクラス（UIButton派生ではなく、UIView派生）。<br>
    アイコン、ラベル、マージンやボーダーなどのプロパティを指定するだけで、さまざまな描画が可能。

    multiLineText=trueとして、ラベル(text属性)に、'\n' 区切りの文字列を与えると、複数行のラベルを持つボタンも作成可能。

    さらに、クラスを派生して、contentRect（アイコン、テキストの位置）, eraseBackground（背景描画）, drawContent（コンテント描画）などをオーバーライドすれば、より高度なスタマイズも可能。

* MICUiDsTabButton

    タブ型（右上に切り欠き）のボタン<br>
    MICUiDsCustomButton を派生し、eraseBackgroundをオーバーライドすることで、ボタンの形をカスタマイズする例として。

* MICUiDsTabView

    タブ耳（MICUiTabBarView)をラベル領域に持つ、AccordionCellView派生クラス。
    AccordionCellView派生なので、タブ耳上の開閉ボタンタップにより、コンテント領域の折り畳み/展開が可能。

* MICUiSvgIconButton

    PNG の代わりに、SVG Path をアイコンとして使えるようにした、MICUiDsCustomButton 派生クラス。

* MICUiStatefulResource

    MICUiDsCustomButton および、その派生クラスの配色やアイコンを定義・供給するためのクラス。
    NORMAL/SELECTED/ACTIVATED/DISABLED の各状態について、個別にリソースを設定できる。





