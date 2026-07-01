# 現在の状態

## できていること

- iOS SwiftUI版の基本実装
- Web版の静的アプリ化
- 初回同意、個人情報注意、緊急時注意
- 自分のコア、モヤモヤ、相談内容の自由入力
- 治療と暮らしのデザインとして、保ちたい暮らし、避けたいこと、譲れないことを出す導線
- モヤモヤの要約
- 主治医に聞くこと、がん相談支援センターに相談できることの整理
- 信頼情報の要点表示と確認付き外部リンク
- 相談メモの端末内保存、コピー、削除
- Safari / Chrome / スマホブラウザ対応
- PWA manifest と Service Worker
- オープンベータ配布文面
- GitHub Pages用 workflow
- 検索エンジンに拾われにくくする `noindex` と `robots.txt`

## 確認済み

```sh
node --check web/app.js
node --check web/sw.js
node web/check-web-app.mjs
node web/mock-consultation-scenarios.mjs
node web/pdca-120-simulations.mjs
python3 -m json.tool web/manifest.webmanifest >/dev/null
python3 scripts/release_readiness_check.py
python3 scripts/check_support_reply_scenarios.py
```

確認結果:

- Web app checks: 18 passed
- 模擬相談: 15 scenarios passed
- PDCA: 120 simulations passed
- Release readiness: passed

## 次にやること

1. 公開URLを作る。
2. 感想フォームを作る。
3. `web/app.js` の `FEEDBACK_FORM_URL` にフォームURLを入れる。
4. オープンベータURLをテスターへ共有する。
5. 集まった感想から、迷った場所、冷たく感じる表現、書き出しにくい場所を直す。

## 公開方法

GitHub Pagesで公開する場合:

```sh
cd "/Users/iimurakenji/Documents/がん相談サポートアプリ"
git add .
git commit -m "Initial open beta web app"
gh repo create gan-soudan-support --public --source=. --remote=origin --push
```

GitHub認証がうまくいかない場合は、[Netlify Drop](https://app.netlify.com/drop) で `web/` の中身を公開します。

## 注意

オープンベータでは、実名、病院名、主治医名、患者番号、住所、電話番号、詳しい診断情報、相談メモ本文を感想フォームに送らない運用にします。
