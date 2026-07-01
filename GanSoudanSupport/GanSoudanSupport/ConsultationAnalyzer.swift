import Foundation

enum ConsultationAnalyzer {
    static func summaryPoints(for note: ConsultationNote) -> [String] {
        let reply = supportReply(for: note)
        return [
            reply.heardConcern,
            reply.plainRephrase,
            reply.minimumNextQuestion
        ]
    }

    static func supportReply(for note: ConsultationNote) -> SupportReply {
        let domains = domains(for: note)
        let primaryDomain = domains.first ?? domain(for: note.category)
        let topic = topicText(for: note)
        let safetyBoundary = safetyNotice(for: note.searchText)
        let isCriticalSafety = containsSelfHarmWords(note.searchText) || containsAcuteUrgentWords(note.searchText)

        return SupportReply(
            domains: domains,
            heardConcern: heardConcern(for: note, domain: primaryDomain, topic: topic),
            feelingReflection: feelingReflection(for: primaryDomain),
            plainRephrase: plainRephrase(for: primaryDomain),
            confirmationQuestion: "この理解で合っていますか？",
            minimumNextQuestion: minimumNextQuestion(for: note, domain: primaryDomain),
            whyThisMatters: whyThisMatters(for: primaryDomain),
            safetyBoundary: safetyBoundary,
            isCriticalSafety: isCriticalSafety
        )
    }

    static func doctorQuestions(for note: ConsultationNote) -> [String] {
        switch domain(for: note) {
        case .appearanceChange:
            return [
                "治療に伴う髪、眉、肌、爪、体型、服装などの変化について相談できますか？",
                "帽子、ウィッグ、眉メイク、スキンケアなどを準備する時期や注意点はありますか？",
                "実際にどの変化が起きるかは、治療内容ごとにどのように確認すればよいですか？"
            ]
        case .symptomsAndSideEffects:
            return [
                "この症状を、副作用の可能性も含めてどのように伝えればよいですか？",
                "どの程度の症状が出たら病院へ連絡すべきですか？",
                "日常生活で気をつけることはありますか？"
            ]
        case .treatmentSelection:
            return [
                "治療の目的、期待できる効果、起こり得る副作用をもう一度確認できますか？",
                "他の選択肢がある場合、それぞれの違いは何ですか？",
                "次回までに家族と整理しておく点はありますか？"
            ]
        case .medicalCostAndBenefits, .employmentAndSchool, .familyAndRelationships, .emotionalDistress, .socialResources:
            return [
                "治療スケジュールや体調面で、生活上配慮した方がよいことはありますか？",
                "病院内で相談できる窓口はありますか？",
                "相談支援センターに共有してよい情報はどこまでですか？"
            ]
        case .secondOpinion:
            return [
                "セカンドオピニオンを受ける場合、紹介状や検査資料は準備できますか？",
                "確認しておくべき治療の選択肢や目的は何ですか？",
                "次回までに家族と整理しておく点はありますか？"
            ]
        case .palliativeCare:
            return [
                "緩和ケアでは、今の痛みやつらさについて何を相談できますか？",
                "治療と並行して受けられる支援はありますか？",
                "家族も一緒に説明を聞くことはできますか？"
            ]
        case .lifeStage:
            return [
                "治療が学校、仕事、将来子どもが欲しいと思っていること、見た目、将来に与える影響について相談できますか？",
                "若い世代として相談できる院内外の窓口はありますか？",
                "家族や学校・職場に伝える前に確認すべきことはありますか？"
            ]
        case .emergencyOrSafety:
            return [
                "今の症状で、すぐ病院へ連絡すべき目安は何ですか？",
                "夜間や休日に連絡する窓口はどこですか？",
                "自宅で様子を見る場合、記録しておく症状は何ですか？"
            ]
        default:
            return [
                "今回の相談内容について、主治医に確認すべき点は何ですか？",
                "次回診察までに記録しておく症状や変化はありますか？",
                "急いで連絡すべき状態の目安はありますか？"
            ]
        }
    }

    static func supportCenterQuestions(for note: ConsultationNote) -> [String] {
        switch domain(for: note) {
        case .appearanceChange:
            return ["見た目の変化への不安や準備について相談できますか？", "帽子、ウィッグ、眉メイク、職場や家族への伝え方、助成制度を一緒に整理できますか？"]
        case .medicalCostAndBenefits:
            return ["利用できる医療費支援制度はありますか？", "収入、休職、職場復帰について相談できる制度や窓口はありますか？", "申請先や必要書類を確認できますか？"]
        case .employmentAndSchool:
            return ["治療と仕事・学校を両立するために相談できる制度はありますか？", "職場や学校に伝える内容を一緒に整理できますか？"]
        case .familyAndRelationships:
            return ["家族へどのように伝えるか相談できますか？", "付き添い者が相談できる窓口はありますか？"]
        case .emotionalDistress:
            return ["気持ちのつらさを相談できる院内外の窓口はありますか？", "緊急時に頼れる連絡先を整理できますか？"]
        case .secondOpinion:
            return ["セカンドオピニオンの進め方や資料準備を相談できますか？", "主治医へ伝える言葉を一緒に整理できますか？"]
        case .palliativeCare:
            return ["緩和ケアについて誤解している点を一緒に確認できますか？", "痛みや生活のつらさを相談できる窓口はありますか？"]
        case .communicationSupport:
            return ["診察で聞きたいことを短く整理できますか？", "説明が分からなかった点を医療者に伝える言葉を一緒に考えられますか？"]
        case .lifeStage:
            return ["学校、将来子どもが欲しいと思っていること、見た目、将来、友人関係などを分けて相談できますか？", "若い世代向けの情報や院内外の相談先を確認できますか？"]
        default:
            return ["相談内容を整理するために、どの情報を持参するとよいですか？", "公的な情報源や制度を一緒に確認できますか？"]
        }
    }

    static func briefMessage(for note: ConsultationNote) -> String {
        let reply = supportReply(for: note)
        let concern = note.body.trimmingCharacters(in: .whitespacesAndNewlines)
        let shortConcern = concern.isEmpty ? topicText(for: note) : String(concern.prefix(70))
        let rolePrefix = rolePrefix(for: note.role)

        switch note.recipient {
        case .physician, .nurse:
            return "\(rolePrefix)今日は「\(shortConcern)」について相談したいです。特に、\(reply.minimumNextQuestion) また、どの状態なら病院へ連絡すべきか確認したいです。"
        case .consultationCenter:
            return "\(rolePrefix)がんの治療や生活のことで「\(shortConcern)」が整理できずにいます。医師に聞くこと、使える制度や相談先、家族や職場への伝え方を一緒に整理したいです。"
        case .family:
            return "がんのことで「\(shortConcern)」が気になっています。すぐ答えを出したいというより、今困っていることと病院で確認することを一緒に整理したいです。"
        case .workplace:
            return "治療に伴い、勤務や休み方について相談したいです。現時点で確定していることと、まだ主治医に確認が必要なことを分けてお伝えしたいです。"
        case .other, .none:
            return "「\(shortConcern)」について、誰に何を相談すればよいか整理したいです。まず確認したいことは、\(reply.minimumNextQuestion)"
        }
    }

    private static func rolePrefix(for role: ConsultationRole?) -> String {
        switch role {
        case .family:
            return "家族として、本人の気持ちを尊重しながら、"
        case .companion:
            return "付き添い者として、本人が確認したいことを支えながら、"
        case .bereavedOrSupporter:
            return "支える人として、本人の意思決定を代わりに行わない形で、"
        default:
            return ""
        }
    }

    static func supportCenterGuide(for note: ConsultationNote) -> [String] {
        let domain = domain(for: note)
        var items: [String] = [
            "診断や治療を決めてもらう場所ではなく、相談内容を整理して次の確認先につなぐ場所として使えます。"
        ]

        switch domain {
        case .appearanceChange:
            items.append("髪、眉、肌、爪、体型、服装などの変化への不安、帽子・ウィッグ・メイクの準備、周囲への伝え方を整理できます。")
        case .medicalCostAndBenefits:
            items.append("医療費、収入減、休職、職場復帰、制度、申請先、必要書類を一緒に確認できます。")
        case .employmentAndSchool:
            items.append("治療と仕事・学校の両立、職場や学校への伝え方、利用できる制度を相談できます。")
        case .familyAndRelationships:
            items.append("家族への伝え方、付き添う人の不安、相談者が家族の場合の整理にも使えます。")
        case .emotionalDistress:
            items.append("気持ちのつらさを言葉にし、院内外の相談先へつなぐ準備ができます。")
        case .secondOpinion:
            items.append("セカンドオピニオンの目的、資料準備、主治医への伝え方を整理できます。")
        case .palliativeCare:
            items.append("緩和ケアの意味、痛みやつらさの相談先、治療と並行できる支援を確認できます。")
        case .communicationSupport:
            items.append("説明が分からなかった点や聞き直したい質問を、短く整理できます。")
        case .lifeStage:
            items.append("学校、仕事、将来子どもが欲しいと思っていること、見た目、将来の不安など、若い世代で話しにくい内容も整理できます。")
        case .symptomsAndSideEffects:
            items.append("症状を医療者に伝えるメモや、連絡の目安を聞く質問を整理できます。")
        default:
            items.append("主治医に聞くこと、相談員に聞くこと、家族に共有することを分けて整理できます。")
        }

        items.append("相談時は、診断名や病期が分からなくても、困っていることから話し始められます。")
        return items
    }

    static func contextPrompts(for note: ConsultationNote) -> [String] {
        var prompts = [
            "次の診察日や、相談したい相手が決まっていればメモできます。",
            "医師からすでに説明された言葉で、分からなかった部分だけ残せます。"
        ]

        switch domain(for: note) {
        case .appearanceChange:
            prompts.append("髪、眉、肌、爪、体型、服装、帽子、ウィッグ、メイクのうち、いちばん不安なものを分けて残せます。")
        case .symptomsAndSideEffects:
            prompts.append("症状が始まった時期、強くなる時間、生活で困っていることを分けると伝えやすくなります。")
        case .treatmentSelection:
            prompts.append("選択肢、決める期限、家族と相談したい点を分けておくと診察で確認しやすくなります。")
        case .medicalCostAndBenefits:
            prompts.append("入院費、通院費、薬代、収入減、休職、職場復帰、申請手続きのどれが重いかだけでも整理できます。")
        case .employmentAndSchool:
            prompts.append("職場・学校に伝えてよいこと、まだ主治医に確認が必要なことを分けられます。")
        case .familyAndRelationships:
            prompts.append("患者本人としての相談か、家族・付き添い者としての相談かを書いておくと相談先で伝わりやすくなります。")
        case .emotionalDistress:
            prompts.append("不安が強くなる場面、眠れない日、ひとりで抱えにくい時間帯を残せます。")
        case .secondOpinion:
            prompts.append("確認したい目的、資料準備、主治医への伝え方を分けて書けます。")
        case .palliativeCare:
            prompts.append("痛み、息苦しさ、不眠、食欲、家族の負担など、和らげたいことから書けます。")
        case .communicationSupport:
            prompts.append("家に帰ってから分からなくなった説明、聞き直したい言葉をそのまま残せます。")
        case .lifeStage:
            prompts.append("学校、将来子どもが欲しいと思っていること、見た目、将来、友人関係など、若い世代で気になることを分けて残せます。")
        case .emergencyOrSafety:
            prompts.append("強い症状や危険を感じる場合は、記録より先に医療機関や救急へ連絡してください。")
        default:
            prompts.append("誰に相談すればよいか分からない場合は、その迷い自体を相談メモにできます。")
        }

        return prompts
    }

    static func preVisitChecklist(for note: ConsultationNote) -> [String] {
        var items = [
            "いちばん伝えたいことを1つ選ぶ。",
            "短く伝える文を診察前に見返す。",
            "診断・治療・薬・緊急性はアプリでは決めず、医療者に確認する。"
        ]

        if let nextConsultationDate = note.nextConsultationDate {
            items.insert("\(DateFormatter.consultationDate.string(from: nextConsultationDate))の前に、このメモと質問リストを見返す。", at: 1)
        }

        switch domain(for: note) {
        case .appearanceChange:
            items.append("どの見た目の変化が不安か、誰にどう見られることが気になるかを分ける。")
            items.append("帽子、ウィッグ、眉メイク、服装、助成制度について相談したいことを選ぶ。")
        case .symptomsAndSideEffects:
            items.append("症状の始まり、強さ、続く時間、生活への影響をメモして持参する。")
            items.append("夜間・休日に連絡する目安と連絡先を確認する。")
        case .treatmentSelection:
            items.append("治療の目的、選択肢、効果、副作用、決める期限を聞く。")
            items.append("家族と相談したい点を先に書き出す。")
        case .medicalCostAndBenefits:
            items.append("領収書、限度額認定証、収入、休職、職場復帰に関する困りごとを分けておく。")
            items.append("相談支援センターで制度、申請先、職場復帰前に確認することを整理する。")
        case .employmentAndSchool:
            items.append("勤務・通学で困っている場面と、配慮してほしい内容を分ける。")
            items.append("職場・学校へ伝える前に、治療予定と体調の見通しを確認する。")
        case .familyAndRelationships:
            items.append("誰に、どこまで、いつ伝えたいかを分ける。")
            items.append("家族や付き添い者自身が相談したい内容もメモに入れる。")
        case .emotionalDistress:
            items.append("不安が強くなる時間帯、眠れない日、支えになる人をメモする。")
            items.append("つらさを相談できる院内外の窓口を確認する。")
        case .secondOpinion:
            items.append("セカンドオピニオンで確認したい目的を1つに絞る。")
            items.append("紹介状、画像、検査結果など必要資料を確認する。")
        case .palliativeCare:
            items.append("和らげたい症状や生活のつらさを、優先順に書く。")
            items.append("治療と並行して受けられる支援か確認する。")
        case .communicationSupport:
            items.append("家に帰ってから分からなくなった説明を、言葉のまま書いて持参する。")
            items.append("聞き直したい点を、効果・副作用・選択肢・見通しに分ける。")
        case .lifeStage:
            items.append("学校、将来子どもが欲しいと思っていること、見た目、将来、友人関係で気になることを分ける。")
            items.append("若い世代として相談できる窓口や情報源を確認する。")
        case .emergencyOrSafety:
            items.append("危険を感じる場合は、診察日を待たず医療機関や救急へ連絡する。")
            items.append("夜間・休日の連絡先を控える。")
        default:
            items.append("主治医に聞くこと、相談支援センターに聞くこと、家族に共有することを分ける。")
        }

        return items
    }

    private static func domains(for note: ConsultationNote) -> [ConsultationDomain] {
        var domains: [ConsultationDomain] = [domain(for: note.category)]
        let text = note.searchText

        add(.symptomsAndSideEffects, to: &domains, if: text.containsAny(["だる", "しびれ", "痛", "吐き気", "副作用", "眠れ", "息苦", "発熱"]))
        add(.appearanceChange, to: &domains, if: text.containsAny(["見た目", "外見", "髪", "脱毛", "眉", "まゆ", "まつ毛", "肌", "爪", "ウィッグ", "かつら", "帽子", "タオル帽子", "服装", "体型"]))
        add(.treatmentSelection, to: &domains, if: text.containsAny(["治療", "手術", "抗がん剤", "放射線", "決め", "選", "方針"]))
        add(.medicalCostAndBenefits, to: &domains, if: text.containsAny(["お金", "費用", "医療費", "支払", "制度", "収入", "傷病手当", "高額", "職場復帰", "復職"]))
        add(.employmentAndSchool, to: &domains, if: text.containsAny(["仕事", "職場", "休職", "学校", "働", "職場復帰", "復職"]))
        add(.familyAndRelationships, to: &domains, if: text.containsAny(["家族", "子ども", "妻", "夫", "親", "伝え", "付き添"]))
        add(.emotionalDistress, to: &domains, if: text.containsAny(["不安", "怖", "つら", "泣", "眠れ", "弱い", "気持ち"]))
        add(.secondOpinion, to: &domains, if: text.containsAny(["セカンドオピニオン", "別の病院", "他の先生"]))
        add(.palliativeCare, to: &domains, if: text.containsAny(["緩和", "痛み", "和らげ"]))
        add(.communicationSupport, to: &domains, if: text.containsAny(["説明", "分から", "質問", "聞け", "信用", "不信", "納得"]))
        add(.lifeStage, to: &domains, if: text.containsAny(["若い", "若年", "学校", "子どもが欲しい", "子どもがほしい", "子どものこと", "将来", "友人"]))
        add(.emergencyOrSafety, to: &domains, if: containsSelfHarmWords(text) || containsAcuteUrgentWords(text))

        return Array(domains.prefix(3))
    }

    private static func domain(for note: ConsultationNote) -> ConsultationDomain {
        domains(for: note).first ?? domain(for: note.category)
    }

    private static func domain(for category: ConsultationCategory) -> ConsultationDomain {
        switch category {
        case .treatment, .test:
            return .treatmentSelection
        case .sideEffect:
            return .symptomsAndSideEffects
        case .appearanceChange:
            return .appearanceChange
        case .cost:
            return .medicalCostAndBenefits
        case .workSchool:
            return .employmentAndSchool
        case .family:
            return .familyAndRelationships
        case .secondOpinion:
            return .secondOpinion
        case .palliativeCare:
            return .palliativeCare
        case .emotionalPain:
            return .emotionalDistress
        case .other:
            return .healthLiteracy
        }
    }

    private static func heardConcern(for note: ConsultationNote, domain: ConsultationDomain, topic: String) -> String {
        switch domain {
        case .appearanceChange:
            return "\(topic)について、見た目が変わるかもしれない不安や、自分らしさをどう保つかが気になっているのですね。"
        case .symptomsAndSideEffects:
            return "\(topic)について、体のつらさが生活にも影響しているのですね。"
        case .treatmentSelection:
            return "\(topic)について、説明を聞いても決めきれない感じがあるのですね。"
        case .medicalCostAndBenefits:
            return "治療に加えて、お金、制度、仕事や職場復帰のことが気になっているのですね。"
        case .employmentAndSchool:
            return "治療と仕事・学校をどう両立するかが引っかかっているのですね。"
        case .familyAndRelationships:
            return "ご家族や身近な方への伝え方が気になっているのですね。"
        case .emotionalDistress:
            return "不安やつらさが強くなっていて、ひとりで抱えにくい状況なのですね。"
        case .secondOpinion:
            return "セカンドオピニオンについて、言い出し方や進め方に迷いがあるのですね。"
        case .palliativeCare:
            return "緩和ケアという言葉に戸惑いや怖さがあるのですね。"
        case .communicationSupport:
            return "説明が十分に伝わっていない感じがあり、納得しきれないのですね。"
        case .lifeStage:
            return "治療だけでなく、学校、仕事、将来や人間関係のことも一緒に重なっているのですね。"
        case .emergencyOrSafety:
            return "急いで確認した方がよいかもしれない不安があるのですね。"
        default:
            return "\(topic)について、何から整理すればよいか迷っているのですね。"
        }
    }

    private static func feelingReflection(for domain: ConsultationDomain) -> String {
        switch domain {
        case .appearanceChange:
            return "見た目の変化は、体のことだけでなく、人に会うこと、仕事や学校、家族との過ごし方にもつながりやすい不安です。"
        case .symptomsAndSideEffects:
            return "症状が続くと、治療への不安も生活の負担も大きくなりやすいと思います。"
        case .treatmentSelection:
            return "大事な選択ほど、説明を聞いてもすぐ決められないのは自然なことです。"
        case .medicalCostAndBenefits:
            return "お金の心配は言い出しにくく、ひとりで抱えると苦しくなりやすいと思います。"
        case .employmentAndSchool:
            return "治療のことをどこまで伝えるか、続けられるかを考えるだけでも負担があります。"
        case .familyAndRelationships:
            return "大切な相手だからこそ、心配をかけたくない気持ちも出てくると思います。"
        case .emotionalDistress:
            return "はっきりしない不安が続く時間は、とても消耗しやすいと思います。"
        case .secondOpinion:
            return "主治医に悪い気がする、という迷いが出る方も少なくありません。"
        case .palliativeCare:
            return "言葉の印象だけで、もう治療をあきらめる話のように感じてしまうことがあります。"
        case .communicationSupport:
            return "分からないまま進んでいるように感じると、不信感や焦りが残りやすいです。"
        case .lifeStage:
            return "若い時期の治療は、からだのこと以外にも生活や将来への影響を考える負担があります。"
        case .emergencyOrSafety:
            return "危険かもしれないと感じる時は、不安だけで判断するのは難しい状況です。"
        default:
            return "まだ言葉にならない部分があっても、少しずつ分けて整理できます。"
        }
    }

    private static func plainRephrase(for domain: ConsultationDomain) -> String {
        switch domain {
        case .appearanceChange:
            return "今の相談は、実際の変化を予測するのではなく、不安な場面と準備したいことを整理する内容に見えます。"
        case .symptomsAndSideEffects:
            return "今の相談は、症状の程度と病院へ伝える目安を整理したい内容に見えます。"
        case .treatmentSelection:
            return "今の相談は、治療をここで決めるのではなく、確認すべき点を整理する内容に見えます。"
        case .medicalCostAndBenefits:
            return "今の相談は、使える制度や窓口を知り、治療を続ける見通しを立てたい内容に見えます。"
        case .employmentAndSchool:
            return "今の相談は、治療と生活を両立するために、職場や学校へ何を伝えるか整理する内容に見えます。"
        case .familyAndRelationships:
            return "今の相談は、誰に、何を、どの順番で伝えるかを整理したい内容に見えます。"
        case .emotionalDistress:
            return "今の相談は、気持ちのつらさを受け止めつつ、医療者や相談先に伝える言葉を探す内容に見えます。"
        case .secondOpinion:
            return "今の相談は、別の医師に確認したい点と、主治医への伝え方を整理する内容に見えます。"
        case .palliativeCare:
            return "今の相談は、緩和ケアの意味と、今のつらさについて相談できることを確認する内容に見えます。"
        case .communicationSupport:
            return "今の相談は、説明で分からなかった点と、次に聞き直す質問を整理する内容に見えます。"
        case .lifeStage:
            return "今の相談は、治療と学校・仕事・将来子どもが欲しいと思っていること・見た目・将来の不安を分けて相談する内容に見えます。"
        case .emergencyOrSafety:
            return "今の相談は、アプリ内で判断せず、医療機関へ確認する目安を整理する内容に見えます。"
        default:
            return "今の相談は、次に誰へ何を確認するかを整理する内容に見えます。"
        }
    }

    private static func minimumNextQuestion(for note: ConsultationNote, domain: ConsultationDomain) -> String {
        switch domain {
        case .appearanceChange:
            return "まず整理したいのは、髪、眉、肌、爪、体型、服装、帽子・ウィッグのどれに近いですか？"
        case .symptomsAndSideEffects:
            return "今いちばん困っているのは、痛み・だるさ・しびれ・吐き気・眠れないことのどれに近いですか？"
        case .treatmentSelection:
            return "次の診察までに、どちらかを決める必要があると言われていますか？"
        case .medicalCostAndBenefits:
            return "今いちばん重いのは、治療費、収入、休職、職場復帰、制度の手続きのどれですか？"
        case .employmentAndSchool:
            return "まず整理したいのは、休み方、職場・学校への伝え方、使える制度のどれですか？"
        case .familyAndRelationships:
            return "まず伝えたい相手は、配偶者、親、子ども、きょうだい、その他のどなたですか？"
        case .emotionalDistress:
            return "その不安は、症状、検査結果、次の診察、過去の経験のどれと関係していそうですか？"
        case .secondOpinion:
            return "確認したいのは、治療方針、診断、他の選択肢、主治医への伝え方のどれに近いですか？"
        case .palliativeCare:
            return "緩和ケアは、痛みやつらさを和らげる話として説明されましたか？"
        case .communicationSupport:
            return "特に分からなかったのは、効果、副作用、他の選択肢、今後の見通しのどれですか？"
        case .lifeStage:
            return "まず整理したいのは、学校・仕事、将来子どもが欲しいと思っていること、見た目、将来、家族や友人への伝え方のどれですか？"
        case .emergencyOrSafety:
            return "強い症状や危険を感じる場合は、今すぐ医療機関や救急に連絡できる状況ですか？"
        default:
            return "今いちばん整理したいのは、治療、症状、お金、家族、仕事、気持ちのどれに近いですか？"
        }
    }

    private static func whyThisMatters(for domain: ConsultationDomain) -> String {
        switch domain {
        case .appearanceChange:
            return "不安な変化と生活場面を分けると、主治医、看護師、相談支援センターに聞くことを具体化できます。"
        case .symptomsAndSideEffects:
            return "症状の種類を分けると、主治医に伝える内容と連絡の目安を確認しやすくなります。"
        case .treatmentSelection:
            return "決める期限と選択肢を分けると、診察で確認する質問を作りやすくなります。"
        case .medicalCostAndBenefits:
            return "困りごとの中心が分かると、医療費制度、収入支援、相談窓口を探しやすくなります。"
        case .employmentAndSchool:
            return "伝える相手と目的を分けると、職場や学校に話す内容を短くできます。"
        case .familyAndRelationships:
            return "相手によって伝える量や順番が変わるため、最初に相手を確認します。"
        case .emotionalDistress:
            return "不安のきっかけを分けると、医療者に確認することと相談先につなぐことを整理できます。"
        case .secondOpinion:
            return "確認したい目的がはっきりすると、資料準備や主治医への伝え方を考えやすくなります。"
        case .palliativeCare:
            return "言葉の誤解をほどくと、治療と並行して受けられる支援を確認しやすくなります。"
        case .communicationSupport:
            return "分からなかった点を分けると、次の診察で聞き直す質問にできます。"
        case .lifeStage:
            return "生活や将来の心配を分けると、主治医、相談支援センター、学校・職場に聞くことを整理できます。"
        case .emergencyOrSafety:
            return "急な症状はアプリで判断せず、連絡先と確認内容を優先して整理します。"
        default:
            return "相談の入口を分けると、主治医に聞くことと相談支援センターに聞くことを分けられます。"
        }
    }

    private static func topicText(for note: ConsultationNote) -> String {
        if !note.title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return note.title
        }
        return note.category.rawValue
    }

    private static func safetyNotice(for text: String) -> String? {
        if containsSelfHarmWords(text) {
            return "今すぐ一人で抱えず、身近な人、医療機関、救急、または地域の緊急相談窓口に連絡してください。このアプリでは安全確認や緊急判断はできません。"
        }

        if containsAcuteUrgentWords(text) {
            return "強い症状や危険を感じる場合は、アプリで判断せず、医療機関や救急に連絡してください。"
        }

        if containsDecisionWords(text) {
            return "診断・治療方針・薬・緊急性はアプリ内で判断せず、医療者に確認する質問として整理します。"
        }

        return nil
    }

    private static func containsDecisionWords(_ text: String) -> Bool {
        text.containsAny(["再発", "余命", "治る", "治療をやめ", "薬をやめ", "薬を減ら", "不要", "効かない"])
    }

    private static func containsSelfHarmWords(_ text: String) -> Bool {
        text.containsAny(["死にたい", "消えたい", "自殺", "自死", "自分を傷つけ", "もう生きたくない", "生きていたくない"])
    }

    private static func containsAcuteUrgentWords(_ text: String) -> Bool {
        text.containsAny(["救急", "今すぐ", "急に", "意識", "危ない", "耐えられない", "息苦", "呼吸困難", "胸痛", "強い痛み", "出血", "高熱", "けいれん"])
    }

    private static func add(_ domain: ConsultationDomain, to domains: inout [ConsultationDomain], if condition: Bool) {
        guard condition, !domains.contains(domain) else { return }
        domains.append(domain)
    }
}
