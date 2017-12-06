レイアウター関連ソースファイルの構成
2015.04.28 M.TOYOTA

layouter/
	MICUiLayout.h								レイアウター（ビューを持たないレンダリングロジックi/f）の宣言・共通定義
	MICUiBaseLayout.h							レイアウターの共通実装
	MICUiBaseLayout.m
	MICUiStackLayout.h							スタック型レイアウター(縦、または、横向きに並べて配置）
	MICUiStackLayout.mm
	MICUiGridLayout.h							グリッド型レイアウター（格子状に配置）
	MICUiGridLayout.mm
	MICUiRelativeLayout.h						親ビュー相対、または、兄弟ビュー相対で配置（Windows Formのイメージ）
	MICUiRelativeLayout.mm

	MICUiSwitchingViewMediator.h				複数の子ビューの開閉/表示・非表示を、排他/連動などのルールに従って切り替える仕掛け
	MICUiSwitchingViewMediator.m
	MICUiAccordionCellViewSwicherProc.h			アコーディオンセルで、MICUiSwitchingViewMediatorの動作を実現するための実装クラス
	MICUiAccordionCellViewSwicherProc.m
	MICUiVirtualView.h							レイアウターに別のレイアウターを入れ子にするためのアダプタクラス（未実装）
	MICUiVirtualView.mm

	view/									レイアウターを適用した、デザインに依存しないビューを実装
		MICUiLayoutView.h						レイアウターを適用するビューの基底クラス
		MICUiLayoutView.m
		MICUiGridView.h							GridLayoutを適用したビュークラス
		MICUiGridView.m
		MICUiStackView.h						StackLayoutを適用したビュークラス
		MICUiStackView.m
		MICUiAccordionView.h					アコーディオンビュークラス（内部にアコーディオンセルを配置）
		MICUiAccordionView.mm
		MICUiAccordionCellView.h				アコーディオンビュー内に配置されるセルクラス（ラベル部分タップによる開閉動作などを実装）
		MICUiAccordionCellView.mm
		MICUiTabBarView.h						タブを並べるバー（履歴タブみたいなやつ）・・・アコーディオンセルのラベル部に配置することを想定
		MICUiTabBarView.mm

		designed/							デザインに依存するビューを実装
			MICUiDsDefaults.h					配色/サイズなどデザインに関する定義
			MICUiDsDefaults.m
			MICUiDsCustomButton.h				オーナードローなボタンの基底クラス
			MICUiDsCustomButton.mm
			MICUiDsTabButton.h					タブバーに配置されるタブボタン
			MICUiDsTabButton.mm
			MICUiDsTabView.h					タブバーとコンテント領域から構成される開閉可能なビュー
			MICUiDsTabView.mm
			MICUiStatefulResource.h				状態依存の配色/アイコンなどを保持するクラス
			MICUiStatefulResource.m
	dd/										レイアウター上でのD&D
		MICUiCellDragHandler.h					D&Dに関するイベントのハンドラ共通実装
		MICUiCellDragHandler.m
		MICUiCellDragSupport.h					１つのコンテナビューの中だけでのD&D動作を提供するクラス
		MICUiCellDragSupport.mm
		MICUiCellDragSupportEx.h				複数のコンテナビューにまたがったD&D動作を提供するクラス。
		MICUiCellDragSupportEx.mm
		MICUiDragView.h							D&D中のイベントをハンドリングするオーバーレイビュー
		MICUiDragView.m

	ut/										ユーティリティクラス
		MICUiRectUtil.h							CGRect, CGSize, CGPoint, CGVector, UIEdgeInsetsなどのイケてない構造体をC++のクラスにラップして超便利にする定義群
		MICArray.h								タイプセーフなNSArrayを提供しようとした企画倒れなクラス。CGRectの配列のみ実装。
		MICArray.m
		MICCGContext.h							CGContext, CGImageRef, CGFontRef, CGColorRef, CGPathRef などのリソースの解放を自動化するとともに、簡潔なC++の記法で扱えるようにする定義群
		MICDelegates.h							C#のデリゲートみたいに、add/removeできるコールバック群を実現するクラス（実際に使ったかどうか覚えていない）
		MICDelegates.m
		MICImageUtil.h							画像に対する操作（サイズ変更、マスクの色変更など）
		MICImageUtil.mm
		MICMatrix.h								２次元配列クラス(x行y列マトリックス）
		MICMatrix.m
		MICSpan.h								最小値、最大値を管理するC++テンプレートクラス + NSRangeをラップするC++クラス
		MICStringUtil.h							NSStringの連結/Formatなどを簡略化するC++ラッパクラス
		MICTree.h								ツリー型コレクションクラス
		MICTree.m
