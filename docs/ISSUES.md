# 課題一覧

このアプリ（イキガイ）の発展途上の課題をジャンルごとに管理する。
完了した課題は都度このファイルから削除する（履歴はgitログに残る）。

## デザイン・ペット

- [ ] ペットのデザインを作成する（`assets/dog_emoji/` に複数候補を配置済み、採用デザインの決定・統合が未完了）
- [ ] ペット育成の成長段階・見た目差分の設計

## 勤務ルール・打刻ロジック

- [ ] 早出したときの扱いをどうするか検討（時給換算・カウンター表示への反映方法）
- [ ] エクストラブレイク（一時休憩）との整合性の再確認

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

- [ ] 実際の支給額入力から未払い額を試算する機能
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
