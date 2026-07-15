# 課題一覧

このアプリ（イキガイ）の発展途上の課題をジャンルごとに管理する。
完了した課題は都度このファイルから削除する（履歴はgitログに残る）。

## デザイン・ペット

- [ ] ペットのデザインを作成する（`assets/dog_emoji/` に複数候補を配置済み、採用デザインの決定・統合が未完了）
- [ ] ペット育成の成長段階・見た目差分の設計

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
- [ ] `month_entries_screen.dart`の記録修正で休憩時間（`breakMinutes`）を編集できない（出退勤時刻のみ）。休憩を考慮した給与計算のためには修正できるようにすべき
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
