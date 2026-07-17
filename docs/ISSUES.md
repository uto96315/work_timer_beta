# 課題一覧

このアプリ（イキガイ）の発展途上の課題をジャンルごとに管理する。
完了した課題は都度このファイルから削除する（履歴はgitログに残る）。

## デザイン・ペット

- [x] ペットの見た目を静的SVG（`assets/dog_emoji/fluent_dog.svg`）から、コードで描いた動くコーギー（`widgets/animated_dog.dart`の`AnimatedCorgiFace`）に置き換え。呼吸・尻尾振り・まばたきをアニメーションさせ、静止画より「生きている」感を出す方向にした
  - きっかけ：3Dクレイ風の犬アイコン参考画像（親子犬が時計を抱くデザイン）を見て「画像ではなく動く犬がいい」という要望
  - 画像生成手段がないため、Canvas描画＋AnimationControllerによるベクター表現で対応。本物のイラスト・Lottie等への差し替えは別途検討の余地あり
  - `_PetHeaderCard`（`home_design_b.dart`）で最高成長段階（伝説の犬）のときだけ`sparkle`を有効化
  - クラス名は当初`AnimatedDog`だったが、`widgets/dog_track.dart`（`dog_painter.dart`）に既存の走る/寝るアニメーション犬が同名で存在していたため`AnimatedCorgiFace`に改名して衝突を解消
  - 初回実装は不気味な見た目になっており、プロポーション・配色・シェーディングを修正済み
- [ ] ペット育成の成長段階・見た目差分の設計（現状は`AnimatedDog`が単一デザイン＋伝説段階のスパークルのみ。段階ごとの体型・アクセサリー差分は未着手）
- [x] アプリ全体のテーマを「ふわふわで可愛い」方向に刷新（3Dクレイ風の犬アイコン参考画像がきっかけ）
  - 配色：シード色をミント系（`#6FBFA0`）に変更、背景をクリーム色（`#FBF7EE`）に変更（`app.dart`）
  - フォント：M PLUS Rounded 1c（丸ゴシック）をアプリ全体のデフォルトフォントに設定。ライセンス上バンドル可能なため`assets/fonts/`にTTFを直接配置し`pubspec.yaml`の`fonts:`で登録（Google Fontsパッケージの実行時ダウンロードは避けた）
  - 角丸：カード28px・入力欄/ボタン20pxに拡大、ナビゲーションバーの枠線色もクリーム系に統一（`floating_nav_bar.dart`）
  - カードの縁取り（枠線）を廃止し、色付きソフトシャドウ（elevation+shadowColor、ミント系半透明）に変更してふわっと浮いた見た目にした（`app.dart`のCardTheme）
  - なつき度／お腹の空き具合のメーターを、フラットな`LinearProgressIndicator`から丸みのあるグラデーション塗り＋ソフトシャドウの`_SoftMeter`（`home_design_b.dart`）に変更
  - 数値表示（今週/今月/残業等の`StatTile`）を黒地から温かみのある茶色（`#6E5236`）に変更し、木製トイっぽい質感に寄せた（`widgets/home_cards.dart`）
  - アプリアイコン本体：`assets/icon/wrtm_icon.png`が参考画像（親子犬が時計を抱く3Dクレイ風）に差し替え済み、`flutter_launcher_icons`でiOS/Android各サイズに反映済み（このAI側では画像生成できないため、素材自体は別途用意されたもの）
- [x] ホーム画面デザインBへの一本化（デザインAの機能をBに統合し、Bをデフォルトに変更）
  - 元々デザインA（`_HomeContent`）にしかなかった機能をBに移植：出退勤操作（`EarningsHeroCard`）、休憩追加・一時休憩ボタン（`dog_track.dart`の`AddBreakButton`/`ExtraBreakButton`を公開クラス化して再利用）、残業承認プロンプト（`OvertimePromptCard`）、休日表示（`HolidayRestCard`）、今週/今月/残業/未払い可能性の集計タイル（`StatTile`）、Pull-to-refresh、自動出勤トリガー
  - 共通化のため、日次/週次/月次の集計・残業警告・休日判定ロジックを`util/home_snapshot.dart`の`buildHomeSnapshot()`に抽出し、A・B両方から呼び出す形にした（重複実装によるA/Bのズレを防ぐため）
  - 共通UIパーツ（`Greeting`/`EarningsHeroCard`/`StatTile`/`HolidayRestCard`/`OvertimePromptCard`）を`widgets/home_cards.dart`に公開クラスとして抽出し、A・Bで共用
  - `_HomeDesign`のデフォルトを`a`から`b`に変更（`home_screen.dart`）。A/Cの切り替え自体はまだ残しているが、実質的にBが本採用
  - **デザインC**：空のプレースホルダー（`home_design_c.dart`）、未着手
  - 方向性が完全に固まったら、A/Cの実装とデザイン切り替えUI自体を削除する

## 勤務ルール・打刻ロジック

- [ ] 早出したときの扱いをどうするか検討（時給換算・カウンター表示への反映方法）
- [ ] エクストラブレイク（一時休憩）との整合性の再確認
- [x] 月給制（正社員）対応：時給前提の計算モデルを拡張する

  **実装した設計：表（モチベ用）と裏（未払い判定用）で別の時給を使う2階建て**

  - `SalaryType`（`lib/src/models/salary_type.dart`）を追加し、`Workplace.salaryType`で時給制/月給制を切り替え
  - **表**：`Workplace.hourlyWage`（既存フィールドをそのまま流用）＝月給制の場合は`WorkplaceForm._monthlyEffectiveHourlyWage()`が「(基本給+固定残業手当)÷(所定労働時間+見込み残業時間)」で自動算出してフォーム保存時に書き込む。既存のカウンター表示・ウィジェット同期（`widget_sync_service.dart`／iOS `WorkTimerWidget.swift`）は無改修で動く
  - **裏**：`earnings_calculator.dart`に`baseHourlyWage()`（基本給÷所定内労働時間、見込み残業時間は含めない）と`unpaidOvertimeYen()`（当月残業が見込み時間を超えた分だけ割増計算）を追加
  - `Workplace`に`baseMonthlySalary`／`fixedOvertimeAllowance`／`fixedOvertimeHours`／`standardMonthlyHours`を追加（すべてnullable、時給制では未使用）
  - `workplace_form.dart`：給与形態ピッカー＋月給制用の入力欄（基本給・月平均所定労働時間・固定残業手当・見込み残業時間）と、実質時給のリアルタイムプレビューを追加
  - `home_screen.dart`：月給制ワークプレイスの場合、「見込み残業を超えた分（未払いの可能性）」カードを追加（`monthTotals.overtimeSeconds`を既存の36協定警告と共用）

  **未対応（follow-up）**：
  - オンボーディング初回登録時の月給制フィールドの見せ方（現状`workplace_form.dart`にそのまま出るが、UXの調整余地あり）
  - 給料日サイクルでの月次集計（現状は暦月＝`monthStart`〜`monthEnd`で計算、`Workplace.payday`基準の期間には未対応）
  - Firestoreスキーマの実データでの動作確認（テストディレクトリに単体テストなし）

## ホーム画面表示

- [ ] 「給料日まであと◯日！」をホーム画面に表示する（`Workplace.payday`は既にあるが未活用）

## ウィジェット

- [x] ウィジェットがアプリを開かないと反映されない（バックグラウンドで自動更新されない）
  - 対応：`ios/Runner/AppDelegate.swift`にBGAppRefreshTaskを追加し、バックグラウンド移行時に予約→発火時に`WidgetCenter.shared.reloadAllTimelines()`でタイムライン強制リロード。`ios/Runner/Info.plist`に`BGTaskSchedulerPermittedIdentifiers`/`UIBackgroundModes`を追加
  - 残る制約（OS都合・解消不可）：BGAppRefreshTaskの実行タイミングはiOSがバッテリー状況等で決めるため、即時性は保証されない。実機でのTestFlight/App Distribution検証がまだ未実施
  - Androidウィジェットは未実装（iOS専用機能）
- [ ] Push to Update（WidgetKit専用push token）の導入検討（BGAppRefreshTaskより信頼性が高いApple推奨方式）
  - 必要要件：Apple Developer側でAPNs Auth Key発行、ウィジェットがpush tokenを取得してサーバーへ登録する処理（Swift側追加実装）、サーバー側で定期的にAPNsへpush送信する仕組み
  - サーバー未整備のため保留中。候補：Firebase Cloud Functions + Firestore（push token保存）+ Cloud Scheduler（定期送信）。既に`firebase_core`/`firebase_auth`を使用中なので相性は良い
  - 進める場合は運用コスト（Cloud Functions実行料、送信頻度の検討）を先に見積もる

## 通知・アラート

- [ ] 36協定超過・過労死ラインに近づいた際の通知機能（閾値・通知文言・UI設計が未定, VISION.md参照）

## 未払い額の可視化・請求支援

- [x] 実際の支給額入力から未払い額を試算する機能（記録画面）
  - `MonthlyPayment`モデル（既存だが未使用だった）を使い、`monthly_payment_repository.dart`／`monthly_payment_providers.dart`を新設
  - `records_screen.dart`：月ごとに想定給与（`sumEarnings()`で実際の打刻データから積算、Home画面の「今月」と同じロジック）・実際の受取額（ユーザー入力、手取り/総支給を選択）・差額（未払いの可能性）を表示。想定vs実際の月次バーチャート（`monthly_pay_chart.dart`）も追加
  - 表示範囲は勤務先の登録月（`Workplace.createdAt`）から現在月まで（最大12ヶ月）。登録前の月は表示しない
  - 月ごとの記録一覧・打刻修正画面（`month_entries_screen.dart`）も追加。「記録を修正」から出退勤時刻を修正可能、修正すると既存の`isModified`フラグで「修正済み」バッジ表示
  - **未対応（follow-up）**：証拠画像添付（本人も「難しそう」と認識、要検討）、給料日サイクル基準の集計（現状は暦月）
- [x] `month_entries_screen.dart`の記録修正で休憩時間（`breakMinutes`）を編集できるようにする
  - `TimeEntryRepository.correct()`に`newBreakMinutes`を追加し、出退勤時刻と一緒に修正可能に
- [x] 修正していない記録にも「修正済み」と表示される不具合
  - 原因：`TimeEntryRepository.correct()`が、実際に値が変わったかどうかに関わらず呼ばれるたびに無条件で`isModified: true`をセットしていた。編集シートを開いて時刻を変えずに保存すると誤って「修正済み」になっていた
  - 対応：新しい値が既存値と異なる場合のみ`isModified`をセット・Firestoreへの書き込みも行うように修正（分単位で比較、ピッカーの精度に合わせる）
- [x] 実際の受取額を記録しても記録画面に反映されず、アプリ再起動後に反映される不具合
  - 対応：`_MonthCard._editPayment`で保存後に`ref.invalidate(monthlyPaymentsProvider)`を呼び、強制的に最新データを再取得するように修正
  - あわせてHome/Records画面に`RefreshIndicator`（下に引いて更新）を追加し、同種の反映漏れが起きた場合の手動リカバリ手段を用意
- [ ] 証拠として使えるログ（GPS・タイムスタンプ）の暗号化保存の実装方針
- [ ] 打刻証明書（公式PDFレポート）の出力機能

## オンボーディング・ストア訴求

- [ ] 「証拠にもなる」ことを薄く伝えるオンボーディング文言の設計（前面に出しすぎない温度感）
- [ ] アプリ名の最終決定（イキガイ／Ikigai／Boramの字面・信頼感の検証）
- [ ] ストア説明・アイコンの信頼感向上

## マネタイズ

- [ ] 弁護士向けSaaS/掲載モデルなど、非弁行為規制をクリアした収益化案の精査

## その他

- [ ] docs/ 以下の整理（README.mdとの記載重複の解消）
