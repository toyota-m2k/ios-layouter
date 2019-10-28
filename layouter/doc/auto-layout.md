# NSLayoutConstraint を使いやすくする

NSLayoutConstraintをプログラムから操作するのは、かなり面倒だし、一度書いたものを読み解くのも一苦労です。そこで、MICAutoLayoutBuilderや、RALBuilder (どちらもC++クラス)を使うと、かなり簡潔にレイアウトを定義できます。

## MICAutoLayoutBuilder

ビルダー形式のAPIでNSLayoutConstraint の配列を構築し、activateする動作を提供します。

### コンストラクタ

MICAutoLayoutBuilder(UIView* parentView, bool autoActivate=true)

    parentView: 親ビュー（このビューにサブビューを配置し、NSLayoutConstraintでレイアウトする）
    autoActivate: （ビルダーのデストラクタで）NSLayoutConstraintをactivateする。
    


