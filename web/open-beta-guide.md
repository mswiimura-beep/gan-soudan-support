# オープンベータ公開手順

目的は、知り合い以外の人でもURLだけで試せる状態にし、感想を集めて改善することです。

## 推奨方針

- 公開方法: GitHub Pages
- 代替公開: Netlify Drop
- 公開範囲: URLを知っている人ならアクセス可能
- 検索対策: `noindex` と `robots.txt` で検索エンジンに拾われにくくする
- 個人情報: テスターに実名、病院名、主治医名、患者番号、連絡先、詳しい診断情報を書かないよう明示する
- 感想回収: Googleフォームなどで、使いやすさ・迷った場所・改善希望だけを集める

## いちばん簡単な公開方法

GitHub認証やpushで止まる場合は、まずNetlify Dropで試験公開できます。

1. [Netlify Drop](https://app.netlify.com/drop) を開く。
2. `web/` フォルダの中身をアップロードする。
3. 発行された `https://...netlify.app/` のURLをテスターに共有する。

注意: `web/` フォルダそのものではなく、`index.html`、`app.js`、`styles.css` などが入っている中身を公開対象にします。

## GitHub Pagesで公開する

1. GitHubで新しいリポジトリを作成する。
2. このプロジェクトをGitHubへpushする。
3. GitHubのリポジトリで `Settings > Pages` を開く。
4. `Build and deployment` の `Source` を `GitHub Actions` にする。
5. `main` ブランチへpushする。
6. `Actions` の `Deploy Web App to GitHub Pages` が完了するのを待つ。
7. 完了後に表示される `https://...github.io/.../` のURLを共有する。

このプロジェクトには、すでに `.github/workflows/pages.yml` があるため、`web/` フォルダがそのまま公開されます。

## GitHub CLIで公開する場合

認証が終わって、ターミナルに `%` が戻ってきたら以下を実行します。

```sh
cd "/Users/iimurakenji/Documents/がん相談サポートアプリ"
git add .
git commit -m "Initial open beta web app"
gh repo create gan-soudan-support --public --source=. --remote=origin --push
```

`gh auth login` の途中で止まった場合は、次を選びます。

```text
Where do you use GitHub? GitHub.com
What is your preferred protocol for Git operations on this host? SSH
Upload your SSH public key to your GitHub account? Skip
How would you like to authenticate GitHub CLI? Login with a web browser
```

表示されたワンタイムコードをGitHubの認証画面に入力し、認証を許可します。

## 公開前に必ず確認すること

```sh
node --check web/app.js
node --check web/sw.js
node web/check-web-app.mjs
node web/mock-consultation-scenarios.mjs
node web/pdca-120-simulations.mjs
python3 -m json.tool web/manifest.webmanifest >/dev/null
```

## オープンベータで集める感想

- どこから始めればよいか分かったか
- 「自分のコア」を書き出しやすかったか
- モヤモヤの要約は納得できたか
- 主治医・相談支援センターに聞く質問は使えそうか
- 文字が読みにくい、押しにくい、迷った画面はあるか
- 不安を強める表現、冷たく感じる表現はあるか

## テスターへ送る文面

```text
がん相談サポート Webのオープンベータ版です。
URLを開くだけで、スマホやPCのブラウザから試せます。

このアプリは、診断や治療判断をするものではありません。
がんに関する不安、モヤモヤ、大切にしたいことを整理し、
主治医やがん相談支援センターに相談しやすくするための試作です。

試してほしいこと:
1. 「自分のことから書き出す」から、大事にしていることやモヤモヤを書く
2. 「整理」で、モヤモヤの要約と質問案を見る
3. 「情報」で、困りごと別の要点を見る
4. 「感想を送る」から、迷った場所や改善点を教える

注意:
個人名、病院名、主治医名、患者番号、住所、電話番号、詳しい診断情報は入力しないでください。
感想フォームにも、相談メモ本文や個人が分かる情報は書かないでください。
強い症状や危険を感じる場合は、アプリではなく医療機関や救急へ連絡してください。
```
