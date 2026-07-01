# がん相談サポート Web

テスターを増やすためのブラウザ版です。iOS版と同じ安全境界を保ち、診断・治療判断は行いません。

## 使い方

```sh
cd web
python3 -m http.server 5173
```

ブラウザで `http://localhost:5173` を開きます。

## スマホで確認する場合

同じWi-Fiにつないだスマホから確認する場合、スマホのブラウザでは `localhost` ではなくMacのIPアドレスを使います。

```sh
ipconfig getifaddr en0
```

例: MacのIPが `192.168.1.23` の場合、スマホのSafari/Chromeで `http://192.168.1.23:5173` を開きます。

iPhone Safariでは共有ボタンから「ホーム画面に追加」を選ぶと、アプリのように起動できます。Chrome/Androidではブラウザメニューから「ホーム画面に追加」を選びます。

## 現在の仕様

- ログインなし
- 相談メモはブラウザ内の `localStorage` に保存
- 外部サーバー、AIサービス、広告、分析基盤へ相談内容を送信しない
- 相談メモ作成、質問整理、信頼情報の要点表示、公式情報への確認付き外部リンク
- テキストコピー、JSONテストデータ書き出し
- Safari / Chrome のスマホブラウザ向けレスポンシブ表示
- PWA manifest とオフラインキャッシュ用 Service Worker

公開URLでテストする場合は、HTTPSで配信できる静的ホスティングにこの `web/` フォルダを配置してください。

## 公開前チェック

```sh
node --check web/app.js
node --check web/sw.js
node web/check-web-app.mjs
node web/mock-consultation-scenarios.mjs
node web/pdca-120-simulations.mjs
python3 -m json.tool web/manifest.webmanifest >/dev/null
```

`mock-consultation-scenarios.mjs` は、副作用、お金と職場復帰、家族、気持ちのつらさ、セカンドオピニオン、緩和ケア、見た目の変化、緊急時、自傷表現などの模擬相談で、危険な医療判断表現が出ていないか確認します。

`pdca-120-simulations.mjs` は、10代から80代、患者本人、家族、付き添い者、支える人などを組み合わせた120人分の模擬相談で、要約、分類、質問案、安全表示が崩れていないか確認します。

## インターネット公開テスト

GitHub Pagesで公開する場合は、プロジェクトをGitHubへpushし、`Settings > Pages` で `GitHub Actions` を選びます。`.github/workflows/pages.yml` が `web/` フォルダを公開します。

詳しい配布文面と感想回収の準備は [public-test-guide.md](./public-test-guide.md) を見てください。

知り合い以外にもURLで広く試してもらう場合は、[open-beta-guide.md](./open-beta-guide.md) を見てください。

感想フォームを使う場合は、`app.js` の `FEEDBACK_FORM_URL` にGoogleフォーム等のURLを設定します。

テスト段階では、個人名、病院名、主治医名、患者番号、連絡先、詳しい診断情報、相談メモ本文を感想フォームに送らない運用にしてください。Googleフォーム等ではメールアドレス収集をオフにし、ログイン必須にしない設定を推奨します。
