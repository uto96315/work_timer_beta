# イキガイ

バイト・仕事の出退勤を記録し、時給ベースの給与をリアルタイムで可視化するFlutterアプリ。

事業構想・目指す世界観については [docs/VISION.md](docs/VISION.md) を参照。

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

ローカルでFirebase Emulator Suiteを使う場合は、先に別ターミナルで `firebase emulators:start` を起動してから `flutter run --dart-define=USE_FIREBASE_EMULATOR=true` を実行する。エミュレータが起動していない状態でこのフラグを付けても、`localhost:9099`（Auth）や`localhost:8090`（Firestore）に接続できず `network-request-failed` などのエラーになる。

また `--dart-define` の値はコンパイル時に埋め込まれるため、ホットリスタート（`r`）では新しい値が反映されない。フラグを変えたときは `flutter run` をやり直すこと。

## 今後追加したい機能（メモ）

- 同業種・同職種で働く人の平均給与との比較表示
- アカウント画面の設計・実装（ログアウト、退会など。プロフィール項目自体は設定画面に実装済み）
- 記録（月次）画面の再設計
- iOSウィジェットの表示項目を設定画面でカスタマイズできるようにする
- ウィジェットをタップして出退勤を打刻できるようにする（App Intents対応が必要）
- Androidのホーム画面ウィジェット
- 休憩を追加した際の終えるのアイコンが再生なのがおかしいので停止アイコンにする
- 追加した時の休憩のアイコン色がおかしいので修正する
