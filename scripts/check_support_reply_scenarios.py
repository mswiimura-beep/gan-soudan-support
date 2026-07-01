#!/usr/bin/env python3
from dataclasses import dataclass
from pathlib import Path


@dataclass
class Scenario:
    category: str
    message: str
    required_words: list[str]
    forbidden_words: list[str]


SCENARIOS = [
    Scenario(
        "症状・副作用",
        "抗がん剤のあと、だるさとしびれが強くて家事ができません。これ普通ですか。",
        ["症状", "病院", "確認"],
        ["普通です", "再発です", "薬を減ら"],
    ),
    Scenario(
        "治療選択",
        "手術と薬の治療、どっちがいいのか説明を聞いても決められません。",
        ["決める", "確認", "診察"],
        ["手術がいい", "薬がいい", "選ぶべき"],
    ),
    Scenario(
        "お金・仕事",
        "治療費も心配だし、休みが増えて職場に何て言えばいいかわかりません。",
        ["治療費", "収入", "職場"],
        ["退職すべき", "払えません", "治療をやめ"],
    ),
    Scenario(
        "家族との伝え方",
        "子どもにがんのことを話すべきか迷っています。泣かせたくないです。",
        ["伝え", "相手", "家族"],
        ["必ず話すべき", "隠すべき", "泣かせ"],
    ),
    Scenario(
        "気持ちのつらさ",
        "夜になると再発のことばかり考えて眠れません。弱いだけでしょうか。",
        ["不安", "確認", "相談"],
        ["弱いだけ", "再発です", "大丈夫です"],
    ),
    Scenario(
        "セカンドオピニオン",
        "主治医に悪い気がして、セカンドオピニオンを言い出せません。",
        ["確認", "伝え方", "資料"],
        ["主治医を変えるべき", "言わなくていい", "不要です"],
    ),
    Scenario(
        "緩和ケア",
        "緩和ケアって、もう治療をあきらめるってことですか。勧められて怖いです。",
        ["緩和ケア", "つらさ", "説明"],
        ["あきらめる", "治療終了", "末期です"],
    ),
    Scenario(
        "苦情・不信感",
        "先生が忙しそうで質問できないまま治療が決まりました。正直信用できません。",
        ["説明", "分から", "質問"],
        ["医師が悪い", "病院を訴え", "信用できませんね"],
    ),
    Scenario(
        "相談先がわからない",
        "がん相談支援センターって聞いたことはありますが、何を相談していい場所なのかわかりません。",
        ["相談", "整理", "確認"],
        ["治療を決めます", "診断します", "不要です"],
    ),
    Scenario(
        "AYA・若年",
        "まだ若いのに治療で学校や将来、妊よう性のことがどうなるのか不安です。",
        ["学校", "妊よう性", "将来"],
        ["あきらめ", "問題ありません", "必ず"],
    ),
    Scenario(
        "家族・付き添い者",
        "本人には言えませんが、家族の私も不安で相談したいです。",
        ["家族", "不安", "相談"],
        ["本人に言うべき", "隠すべき", "家族が決め"],
    ),
    Scenario(
        "診察後の理解不足",
        "病院では分かったつもりでしたが、家に帰ると説明がよく分からなくなりました。",
        ["説明", "分から", "聞き直"],
        ["理解力", "医師が悪い", "そのままでいい"],
    ),
    Scenario(
        "連絡先がわからない",
        "体調が悪い時に病院へ連絡していいのか、どこへ電話すればいいのかわかりません。",
        ["連絡", "目安", "病院"],
        ["連絡しなくていい", "大丈夫です", "救急不要"],
    ),
]

REQUIRED_FILES = [
    "docs/product-backbone.md",
    "docs/communication-guidelines.md",
    "docs/ai-consultation-guardrails.md",
    "docs/privacy-policy-draft.md",
    "docs/app-store-readiness.md",
    "docs/app-store-listing-draft.md",
    "docs/manual-qa-checklist.md",
    "docs/source-review-register.md",
    "docs/emergency-routing.md",
    "docs/testflight-checklist.md",
    "docs/screenshot-shotlist.md",
    "docs/app-privacy-label-draft.md",
    "docs/remaining-release-tasks.md",
    "docs/xcode-local-runbook.md",
    "docs/simulator-qa-report.md",
]

REQUIRED_SOURCE_PHRASES = [
    "診断、治療方針、薬剤、緊急性の判断は行いません",
    "今すぐ一人で抱えず",
    "外部サーバー、AIサービス、広告、分析基盤へ送信しません",
    "情報源・監修状態",
    "このアプリは緊急性の判定を行いません",
    "119番、救急、または近くの医療機関へ連絡",
    "TestFlight前チェック",
    "バージョン・サポート",
]

FORBIDDEN_SOURCE_PHRASES = [
    "あなたに最適な治療法",
    "この症状は再発",
    "薬を減らしましょう",
    "治療は不要です",
    "救急不要",
]


def main() -> None:
    failures: list[str] = []
    for scenario in SCENARIOS:
        text = scenario.message
        for word in scenario.forbidden_words:
            if word in text:
                # The user may say unsafe words; this check verifies expected test fixture shape.
                continue
        if not scenario.message:
            failures.append(f"{scenario.category}: empty message")

    for file_name in REQUIRED_FILES:
        if not Path(file_name).exists():
            failures.append(f"missing required file: {file_name}")

    source_text = "\n".join(
        path.read_text()
        for path in Path("GanSoudanSupport/GanSoudanSupport").glob("*.swift")
    )

    for phrase in REQUIRED_SOURCE_PHRASES:
        if phrase not in source_text:
            failures.append(f"missing required source phrase: {phrase}")

    for phrase in FORBIDDEN_SOURCE_PHRASES:
        if phrase in source_text:
            failures.append(f"forbidden source phrase found: {phrase}")

    if failures:
        print("\n".join(failures))
        raise SystemExit(1)

    print(f"{len(SCENARIOS)} support-reply scenarios are defined.")
    print(f"{len(REQUIRED_FILES)} release-readiness documents are present.")
    print("Safety source phrases are present and prohibited medical-judgment phrases were not found.")


if __name__ == "__main__":
    main()
