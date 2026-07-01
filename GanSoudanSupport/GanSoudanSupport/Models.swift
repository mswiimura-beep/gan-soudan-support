import SwiftUI

final class ConsultationStore: ObservableObject {
    @Published var notes: [ConsultationNote] = [] {
        didSet { saveNotes() }
    }

    @Published var hasAcceptedConsent: Bool = false {
        didSet { UserDefaults.standard.set(hasAcceptedConsent, forKey: Self.consentKey) }
    }

    @Published var allowsLocalAnalysis: Bool = true {
        didSet { UserDefaults.standard.set(allowsLocalAnalysis, forKey: Self.localAnalysisKey) }
    }

    private static let notesKey = "consultation.notes.v1"
    private static let consentKey = "consultation.consent.v1"
    private static let localAnalysisKey = "consultation.localAnalysis.v1"

    init() {
        hasAcceptedConsent = UserDefaults.standard.bool(forKey: Self.consentKey)
        allowsLocalAnalysis = UserDefaults.standard.object(forKey: Self.localAnalysisKey) as? Bool ?? true
        loadNotes()
#if DEBUG
        seedSafetyQANotesIfNeeded()
#endif
    }

    func add(_ note: ConsultationNote) {
        notes.insert(note, at: 0)
    }

    func update(_ note: ConsultationNote) {
        guard let index = notes.firstIndex(where: { $0.id == note.id }) else { return }
        notes[index] = note
    }

    func delete(at offsets: IndexSet) {
        notes.remove(atOffsets: offsets)
    }

    func delete(_ note: ConsultationNote) {
        notes.removeAll { $0.id == note.id }
    }

    func deleteAll() {
        notes.removeAll()
    }

    private func loadNotes() {
        guard let data = UserDefaults.standard.data(forKey: Self.notesKey) else { return }
        notes = (try? JSONDecoder().decode([ConsultationNote].self, from: data)) ?? []
    }

    private func saveNotes() {
        guard let data = try? JSONEncoder().encode(notes) else { return }
        UserDefaults.standard.set(data, forKey: Self.notesKey)
    }

#if DEBUG
    private func seedSafetyQANotesIfNeeded() {
        guard ProcessInfo.processInfo.arguments.contains("--seed-safety-qa") else { return }
        hasAcceptedConsent = true

        let qaTitles = Set(notes.map(\.title))
        var seededNotes = notes

        if !qaTitles.contains("QA 自傷表現") {
            seededNotes.insert(
                ConsultationNote(
                    category: .emotionalPain,
                    role: .patient,
                    recipient: .consultationCenter,
                    title: "QA 自傷表現",
                    body: "夜になるとつらくて、死にたい、消えたいと思うことがあります。一人でいるのが怖いです。",
                    diagnosis: "",
                    treatmentStatus: "",
                    createdAt: .now
                ),
                at: 0
            )
        }

        if !qaTitles.contains("QA 緊急症状") {
            seededNotes.insert(
                ConsultationNote(
                    category: .sideEffect,
                    role: .patient,
                    recipient: .physician,
                    title: "QA 緊急症状",
                    body: "胸痛、呼吸困難、強い痛みが急に出た時に、どこへ連絡すればよいか確認したいです。",
                    diagnosis: "",
                    treatmentStatus: "",
                    createdAt: .now
                ),
                at: 0
            )
        }

        notes = seededNotes
    }
#endif
}

struct ConsultationNote: Identifiable, Codable, Hashable {
    let id: UUID
    var category: ConsultationCategory
    var role: ConsultationRole?
    var recipient: CommunicationRecipient?
    var title: String
    var body: String
    var personContext: String?
    var diagnosis: String
    var treatmentStatus: String
    var nextConsultationDate: Date?
    var createdAt: Date

    init(
        id: UUID = UUID(),
        category: ConsultationCategory,
        role: ConsultationRole? = nil,
        recipient: CommunicationRecipient? = nil,
        title: String,
        body: String,
        personContext: String = "",
        diagnosis: String,
        treatmentStatus: String,
        nextConsultationDate: Date? = nil,
        createdAt: Date = .now
    ) {
        self.id = id
        self.category = category
        self.role = role
        self.recipient = recipient
        self.title = title
        self.body = body
        self.personContext = personContext.isEmpty ? nil : personContext
        self.diagnosis = diagnosis
        self.treatmentStatus = treatmentStatus
        self.nextConsultationDate = nextConsultationDate
        self.createdAt = createdAt
    }
}

enum ConsultationRole: String, Codable, CaseIterable, Identifiable {
    case patient = "患者本人"
    case family = "家族"
    case companion = "付き添い者"
    case bereavedOrSupporter = "支える人"
    case undecided = "まだ決めていない"

    var id: String { rawValue }

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let value = try container.decode(String.self)

        if value == "支援する立場" {
            self = .bereavedOrSupporter
            return
        }

        guard let role = ConsultationRole(rawValue: value) else {
            throw DecodingError.dataCorruptedError(
                in: container,
                debugDescription: "Unknown consultation role: \(value)"
            )
        }
        self = role
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(rawValue)
    }

    var symbol: String {
        switch self {
        case .patient: "person"
        case .family: "person.2"
        case .companion: "figure.2.and.child.holdinghands"
        case .bereavedOrSupporter: "hands.sparkles"
        case .undecided: "questionmark.circle"
        }
    }
}

enum ConsultationCategory: String, Codable, CaseIterable, Identifiable {
    case treatment = "治療について"
    case test = "検査について"
    case sideEffect = "副作用・体調について"
    case appearanceChange = "見た目の変化について"
    case cost = "医療費・制度について"
    case workSchool = "仕事・学校について"
    case family = "家族・人間関係について"
    case secondOpinion = "セカンドオピニオンについて"
    case palliativeCare = "緩和ケアについて"
    case emotionalPain = "気持ちのつらさについて"
    case other = "その他"

    var id: String { rawValue }

    var symbol: String {
        switch self {
        case .treatment: "cross.case"
        case .test: "doc.text.magnifyingglass"
        case .sideEffect: "heart.text.square"
        case .appearanceChange: "person.crop.square"
        case .cost: "yensign.circle"
        case .workSchool: "briefcase"
        case .family: "person.2"
        case .secondOpinion: "arrow.triangle.branch"
        case .palliativeCare: "hands.sparkles"
        case .emotionalPain: "heart"
        case .other: "ellipsis.circle"
        }
    }
}

enum CommunicationRecipient: String, Codable, CaseIterable, Identifiable {
    case physician = "主治医"
    case nurse = "看護師"
    case consultationCenter = "がん相談支援センター"
    case family = "家族"
    case workplace = "職場・学校"
    case other = "まだ決めていない"

    var id: String { rawValue }

    var symbol: String {
        switch self {
        case .physician: "stethoscope"
        case .nurse: "cross.case"
        case .consultationCenter: "person.2.wave.2"
        case .family: "person.2"
        case .workplace: "briefcase"
        case .other: "questionmark.circle"
        }
    }
}

enum ConsultationDomain: String, CaseIterable, Identifiable {
    case treatmentSelection = "治療選択"
    case symptomsAndSideEffects = "症状・副作用"
    case appearanceChange = "見た目の変化"
    case medicalCostAndBenefits = "医療費・制度"
    case employmentAndSchool = "仕事・学校"
    case familyAndRelationships = "家族・人間関係"
    case emotionalDistress = "気持ちのつらさ"
    case secondOpinion = "セカンドオピニオン"
    case palliativeCare = "緩和ケア"
    case socialResources = "社会資源"
    case healthLiteracy = "情報の整理"
    case lifeStage = "ライフステージ"
    case communicationSupport = "伝え方・聞き方"
    case emergencyOrSafety = "緊急・安全"

    var id: String { rawValue }
}

struct SupportReply: Hashable {
    var domains: [ConsultationDomain]
    var heardConcern: String
    var feelingReflection: String
    var plainRephrase: String
    var confirmationQuestion: String
    var minimumNextQuestion: String
    var whyThisMatters: String
    var safetyBoundary: String?
    var isCriticalSafety: Bool
}

struct ConsultationTemplate: Identifiable, Hashable {
    var id: String
    var title: String
    var subtitle: String
    var category: ConsultationCategory
    var role: ConsultationRole
    var recipient: CommunicationRecipient
    var bodyDraft: String
    var symbol: String

    static let defaultTemplates: [ConsultationTemplate] = [
        ConsultationTemplate(
            id: "side-effect",
            title: "副作用・体調を相談したい",
            subtitle: "症状と連絡の目安を整理",
            category: .sideEffect,
            role: .patient,
            recipient: .physician,
            bodyDraft: "治療後の体調について相談したいです。いつから、どの症状が、生活にどのくらい影響しているかを整理したいです。",
            symbol: "heart.text.square"
        ),
        ConsultationTemplate(
            id: "appearance-change",
            title: "見た目の変化が不安",
            subtitle: "髪、眉、肌、爪、帽子、ウィッグ",
            category: .appearanceChange,
            role: .patient,
            recipient: .consultationCenter,
            bodyDraft: "治療に伴う髪、眉、肌、爪、体型、服装などの見た目の変化が不安です。実際にどうなるかを決めつけず、準備したいことや相談したいことを整理したいです。",
            symbol: "person.crop.square"
        ),
        ConsultationTemplate(
            id: "cost-work",
            title: "お金・仕事が心配",
            subtitle: "制度、収入、休職・職場復帰",
            category: .cost,
            role: .patient,
            recipient: .consultationCenter,
            bodyDraft: "治療費、収入、休職や職場復帰のことが心配です。使える制度、職場への伝え方、復帰する時期や配慮してほしいことを整理したいです。",
            symbol: "yensign.circle"
        ),
        ConsultationTemplate(
            id: "family-supporter",
            title: "家族として相談したい",
            subtitle: "本人への伝え方と家族の不安",
            category: .family,
            role: .family,
            recipient: .consultationCenter,
            bodyDraft: "家族として、本人をどう支えればよいか、自分の不安をどこへ相談すればよいか整理したいです。",
            symbol: "person.2"
        ),
        ConsultationTemplate(
            id: "explanation-gap",
            title: "説明が分からなくなった",
            subtitle: "聞き直したい点を整理",
            category: .treatment,
            role: .patient,
            recipient: .physician,
            bodyDraft: "病院で説明を聞いた時は分かったつもりでしたが、家に帰ってから分からない点が出てきました。聞き直したい内容を整理したいです。",
            symbol: "text.bubble"
        ),
        ConsultationTemplate(
            id: "second-opinion",
            title: "セカンドオピニオン",
            subtitle: "目的、資料、伝え方",
            category: .secondOpinion,
            role: .patient,
            recipient: .consultationCenter,
            bodyDraft: "セカンドオピニオンを考えています。何を確認したいのか、必要な資料、主治医への伝え方を整理したいです。",
            symbol: "arrow.triangle.branch"
        ),
        ConsultationTemplate(
            id: "aya-life",
            title: "学校・将来・子どものこと",
            subtitle: "若い世代の心配",
            category: .workSchool,
            role: .patient,
            recipient: .consultationCenter,
            bodyDraft: "治療が学校、仕事、将来子どもが欲しいと思っていること、見た目、将来にどう影響するのか不安です。相談できることを整理したいです。",
            symbol: "figure.2.and.child.holdinghands"
        )
    ]
}

enum TrustedInfoGroup: String, CaseIterable, Identifiable {
    case firstStep = "まず整理する"
    case dailyLife = "暮らし・制度"
    case bodyAndLifeStage = "からだ・生活の変化"
    case urgent = "急ぐ時"

    var id: String { rawValue }

    var description: String {
        switch self {
        case .firstStep:
            "調べる前に、何を相談したいかを分けます。"
        case .dailyLife:
            "お金、仕事、家族など生活に関わる心配を整理します。"
        case .bodyAndLifeStage:
            "見た目、若い世代の悩み、将来のことを分けます。"
        case .urgent:
            "強い症状や危険を感じる時は、情報収集より連絡を優先します。"
        }
    }
}

struct TrustedResource: Identifiable {
    let id = UUID()
    var title: String
    var subtitle: String
    var group: TrustedInfoGroup
    var url: URL
    var symbol: String
    var overview: String
    var useWhen: [String]
    var questions: [String]
    var nextActions: [String]
    var sourceName: String

    init(
        title: String,
        subtitle: String,
        group: TrustedInfoGroup,
        url: String,
        symbol: String,
        overview: String,
        useWhen: [String],
        questions: [String],
        nextActions: [String],
        sourceName: String
    ) {
        self.title = title
        self.subtitle = subtitle
        self.group = group
        self.url = URL(string: url)!
        self.symbol = symbol
        self.overview = overview
        self.useWhen = useWhen
        self.questions = questions
        self.nextActions = nextActions
        self.sourceName = sourceName
    }
}

enum SupportProgramCategory: String, CaseIterable, Identifiable {
    case medicalCost = "医療費"
    case workIncome = "仕事・収入"
    case disabilityLife = "障害・生活"
    case insuranceLoan = "民間保険・住宅"
    case familyCare = "家族・介護"

    var id: String { rawValue }

    var symbol: String {
        switch self {
        case .medicalCost: "yensign.circle"
        case .workIncome: "briefcase"
        case .disabilityLife: "figure.roll"
        case .insuranceLoan: "shield"
        case .familyCare: "person.2"
        }
    }
}

struct SupportProgramGuideItem: Identifiable, Hashable {
    var id: String
    var title: String
    var category: SupportProgramCategory
    var summary: String
    var confirmWith: String
    var beforeAsking: [String]
    var questions: [String]

    static let defaultItems: [SupportProgramGuideItem] = [
        SupportProgramGuideItem(
            id: "monthly-cost-limit",
            title: "医療費が高くなりそうな時",
            category: .medicalCost,
            summary: "月ごとの医療費負担が大きくなる場合は、加入している医療保険で自己負担の上限や事前手続きの有無を確認します。制度名だけで判断せず、保険証の種類と治療予定を合わせて相談します。",
            confirmWith: "病院の相談支援センター、加入している医療保険の窓口",
            beforeAsking: [
                "保険証の種類",
                "入院・外来・薬局の予定",
                "直近の領収書や支払い見込み"
            ],
            questions: [
                "自分の場合、医療費の上限や事前手続きはありますか？",
                "病院、薬局、保険者のどこに先に確認するとよいですか？",
                "次回の治療までに準備する書類はありますか？"
            ]
        ),
        SupportProgramGuideItem(
            id: "sick-leave-income",
            title: "働けない期間の収入が心配な時",
            category: .workIncome,
            summary: "治療や体調不良で仕事を休む場合、勤務先の休暇制度や健康保険からの給付を確認できることがあります。雇用形態や加入保険で変わるため、会社と保険者の両方に分けて確認します。",
            confirmWith: "勤務先の総務・人事、加入している健康保険、相談支援センター",
            beforeAsking: [
                "雇用形態と勤務先の休暇制度",
                "休み始めた日と復職見込み",
                "給与が出る期間、出ない期間"
            ],
            questions: [
                "病気で休む間に使える会社制度や給付はありますか？",
                "主治医の証明や診断書は必要ですか？",
                "退職を考える前に確認すべき制度はありますか？"
            ]
        ),
        SupportProgramGuideItem(
            id: "leaving-work",
            title: "退職を考えている時",
            category: .workIncome,
            summary: "退職後は健康保険、年金、雇用保険、収入の見通しが同時に変わります。退職日を決める前に、使える可能性のある制度と手続きの順番を確認します。",
            confirmWith: "勤務先、ハローワーク、市区町村、年金事務所、相談支援センター",
            beforeAsking: [
                "退職予定日または退職日",
                "雇用保険の加入状況",
                "退職後すぐ働ける体調かどうか"
            ],
            questions: [
                "退職前に確認しておくべき健康保険と年金の手続きは何ですか？",
                "すぐ働けない場合、雇用保険で確認することはありますか？",
                "退職日を決める前に相談した方がよい窓口はどこですか？"
            ]
        ),
        SupportProgramGuideItem(
            id: "disability-pension-card",
            title: "後遺症や生活上の制限が残った時",
            category: .disabilityLife,
            summary: "治療後に身体機能や日常生活への影響が残る場合、障害年金、障害者手帳、福祉サービスなどを確認できることがあります。診断名だけでなく、生活で何が困っているかを具体的に伝えます。",
            confirmWith: "主治医、病院の相談支援センター、市区町村の福祉窓口、年金事務所",
            beforeAsking: [
                "困っている動作や生活場面",
                "初めて受診した時期",
                "主治医に書類作成を相談できるか"
            ],
            questions: [
                "今の状態で確認した方がよい年金や手帳はありますか？",
                "申請にはどの診断書や証明が必要になりますか？",
                "医療者に先に確認すべき生活上の困りごとは何ですか？"
            ]
        ),
        SupportProgramGuideItem(
            id: "medical-devices-life",
            title: "ストーマ・声・日常生活用具で困る時",
            category: .disabilityLife,
            summary: "手術や治療の影響で日常生活用具が必要になる場合、市区町村の福祉制度で購入費などを相談できることがあります。必要な用具名と生活上の困りごとを整理して確認します。",
            confirmWith: "主治医、看護師、相談支援センター、市区町村の福祉窓口",
            beforeAsking: [
                "必要になった用具や装具",
                "退院後の生活で困っていること",
                "医療者から説明された用具名"
            ],
            questions: [
                "この用具について自治体で相談できる制度はありますか？",
                "購入前に確認した方がよい手続きはありますか？",
                "病院側で書いてもらう書類はありますか？"
            ]
        ),
        SupportProgramGuideItem(
            id: "private-insurance",
            title: "民間保険・がん保険を確認したい時",
            category: .insuranceLoan,
            summary: "加入している生命保険や医療保険に、診断、入院、手術、通院、就業不能などに関する給付が含まれることがあります。保険会社に連絡する前に、証券や契約者情報を用意します。",
            confirmWith: "加入している保険会社、保険代理店、相談支援センター",
            beforeAsking: [
                "保険証券や契約者番号",
                "診断日、入院・手術・通院の予定",
                "主治医に証明書を依頼する必要があるか"
            ],
            questions: [
                "自分の契約で確認すべき給付や特約はありますか？",
                "請求に必要な診断書や証明書は何ですか？",
                "病院へ書類を依頼する前に確認することはありますか？"
            ]
        ),
        SupportProgramGuideItem(
            id: "housing-loan",
            title: "住宅ローンが心配な時",
            category: .insuranceLoan,
            summary: "住宅ローンに団体信用生命保険や特約が付いている場合、契約内容によって確認先や必要書類が変わります。病状だけで判断せず、ローン契約と保険内容を金融機関に確認します。",
            confirmWith: "住宅ローンを組んだ金融機関、保険会社、相談支援センター",
            beforeAsking: [
                "住宅ローン契約書",
                "団体信用生命保険や特約の有無",
                "診断日と治療状況"
            ],
            questions: [
                "契約しているローンに確認すべき保険や特約はありますか？",
                "病院に依頼する書類はありますか？",
                "支払いが不安な場合、早めに相談できる窓口はどこですか？"
            ]
        ),
        SupportProgramGuideItem(
            id: "family-care-leave",
            title: "家族が介護や付き添いで休む時",
            category: .familyCare,
            summary: "家族が付き添いや介護のために仕事を休む場合、勤務先の休暇・休業制度や雇用保険の給付を確認できることがあります。患者本人の制度と家族側の制度を分けて整理します。",
            confirmWith: "家族の勤務先、ハローワーク、相談支援センター",
            beforeAsking: [
                "誰が付き添いや介護を担うか",
                "休む期間の見込み",
                "勤務先に伝える必要がある範囲"
            ],
            questions: [
                "家族側が使える休暇や休業制度はありますか？",
                "勤務先に出す書類や証明は必要ですか？",
                "患者本人の同意を確認しておくことはありますか？"
            ]
        )
    ]
}


extension ConsultationNote {
    var searchText: String {
        [
            title,
            body,
            personContext ?? "",
            diagnosis,
            treatmentStatus,
            category.rawValue,
            role?.rawValue ?? "",
            recipient?.rawValue ?? "",
            nextConsultationDate.map { DateFormatter.consultationDate.string(from: $0) } ?? ""
        ]
            .joined(separator: " ")
            .lowercased()
    }
}

extension DateFormatter {
    static let consultationDate: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ja_JP")
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter
    }()

    static let consultationSavedDate: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ja_JP")
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter
    }()
}

extension String {
    func containsAny(_ needles: [String]) -> Bool {
        needles.contains { contains($0.lowercased()) }
    }
}
