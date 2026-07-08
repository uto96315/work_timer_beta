# work_timer

バイト・仕事の出退勤を記録し、時給ベースの給与をリアルタイムで可視化するFlutterアプリ。

## 主な機能

- 勤務先の時給・勤務スケジュール登録
- 出退勤の記録（自動打刻対応）
- 今日・週・月単位の給与集計
- 残業時間の集計

## セットアップ

Firebase(Auth / Firestore)を利用しています。

1. `.env.example` を `.env` にコピーし、Firebaseコンソールから取得した値を設定
2. Android: `android/app/google-services.json` を配置
3. iOS: `ios/Runner/GoogleService-Info.plist` を配置
4. `flutter pub get`
5. `flutter run`

ローカルでFirebase Emulator Suiteを使う場合は `flutter run --dart-define=USE_FIREBASE_EMULATOR=true`。

## 今後追加したい機能（メモ）

- 同業種・同職種で働く人の平均給与との比較表示
- アカウント画面の設計・実装（プロフィール、ログアウト、退会など）
- 記録（月次）画面の再設計
