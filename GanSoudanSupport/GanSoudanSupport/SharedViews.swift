import SwiftUI
import UIKit

enum AppTheme {
    static let background = Color(red: 1.0, green: 0.95, blue: 0.88)
    static let cardBackground = Color(red: 1.0, green: 0.985, blue: 0.955)
    static let accent = Color(red: 0.64, green: 0.33, blue: 0.12)
    static let accentSoft = Color(red: 0.95, green: 0.72, blue: 0.45).opacity(0.22)
    static let primaryText = Color(red: 0.23, green: 0.16, blue: 0.11)
    static let secondaryText = Color(red: 0.47, green: 0.36, blue: 0.28)
}

struct AppScreenBackgroundModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .scrollContentBackground(.hidden)
            .background(AppTheme.background)
            .foregroundStyle(AppTheme.primaryText)
            .tint(AppTheme.accent)
    }
}

extension View {
    func appScreenBackground() -> some View {
        modifier(AppScreenBackgroundModifier())
    }
}

struct ShareDocument: Identifiable {
    let id = UUID()
    let urls: [URL]

    init(url: URL) {
        self.urls = [url]
    }

    init(urls: [URL]) {
        self.urls = urls
    }
}

struct ActivityShareSheet: UIViewControllerRepresentable {
    let items: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {
    }
}

struct SafetyPositionCard: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("このアプリの位置づけ", systemImage: "shield.lefthalf.filled")
                .font(.headline)
            Text("がんに関する不安や疑問を整理し、医療者・がん相談支援センター等に相談しやすくするための支援ツールです。診断、治療方針、薬剤、緊急性の判断は行いません。")
                .font(.subheadline)
                .foregroundStyle(AppTheme.secondaryText)
        }
        .padding()
        .background(AppTheme.accentSoft, in: RoundedRectangle(cornerRadius: 8))
        .padding(.horizontal)
    }
}

struct SafetyInlineNotice: View {
    var body: some View {
        Label("治療法の推奨や症状の判定はせず、相談内容と質問を整理します。", systemImage: "shield")
            .font(.subheadline)
            .foregroundStyle(AppTheme.secondaryText)
    }
}

struct EmergencyGuideCard: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label("緊急時の案内", systemImage: "exclamationmark.triangle")
                .font(.headline)
                .foregroundStyle(.red)
            Text("急な強い症状、息苦しさ、強い痛み、意識がもうろうとする、危険を感じる場合は、アプリ内で判断せず、医療機関や救急に連絡してください。")
                .font(.subheadline)
                .foregroundStyle(AppTheme.secondaryText)
        }
        .padding(.vertical, 4)
    }
}

struct ActionRow: View {
    var icon: String
    var title: String
    var subtitle: String

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(AppTheme.accent)
                .frame(width: 30)
            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(.body)
                    .foregroundStyle(AppTheme.primaryText)
                Text(subtitle)
                    .font(.caption)
                    .foregroundStyle(AppTheme.secondaryText)
            }
        }
        .padding(.vertical, 4)
    }
}

struct InfoUseStepRow: View {
    var number: Int
    var title: String
    var detail: String

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Text("\(number)")
                .font(.caption.bold())
                .foregroundStyle(.white)
                .frame(width: 24, height: 24)
                .background(AppTheme.accent, in: Circle())
            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(AppTheme.primaryText)
                Text(detail)
                    .font(.caption)
                    .foregroundStyle(AppTheme.secondaryText)
            }
        }
        .padding(.vertical, 3)
    }
}

struct NoteSummaryRow: View {
    var note: ConsultationNote

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Label(note.category.rawValue, systemImage: note.category.symbol)
                .font(.caption)
                .foregroundStyle(AppTheme.accent)
            Label("保存日: \(DateFormatter.consultationSavedDate.string(from: note.createdAt))", systemImage: "tray.and.arrow.down")
                .font(.caption)
                .foregroundStyle(AppTheme.secondaryText)
            if let role = note.role {
                Label(role.rawValue, systemImage: role.symbol)
                    .font(.caption)
                    .foregroundStyle(AppTheme.secondaryText)
            }
            if let recipient = note.recipient {
                Label(recipient.rawValue, systemImage: recipient.symbol)
                    .font(.caption)
                    .foregroundStyle(AppTheme.secondaryText)
            }
            if let nextConsultationDate = note.nextConsultationDate {
                Label(DateFormatter.consultationDate.string(from: nextConsultationDate), systemImage: "calendar")
                    .font(.caption)
                    .foregroundStyle(AppTheme.secondaryText)
            }
            Text(note.title.isEmpty ? "相談メモ" : note.title)
                .font(.headline)
            Text(note.body)
                .font(.subheadline)
                .foregroundStyle(AppTheme.secondaryText)
                .lineLimit(2)
        }
        .padding(.vertical, 4)
    }
}

struct QuestionFocusCard: View {
    var note: ConsultationNote

    private var doctorQuestion: String {
        ConsultationAnalyzer.doctorQuestions(for: note).first ?? "主治医に確認したいことを1つ選ぶ。"
    }

    private var supportQuestion: String {
        ConsultationAnalyzer.supportCenterQuestions(for: note).first ?? "相談支援センターで整理できることを確認する。"
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label(note.title.isEmpty ? note.category.rawValue : note.title, systemImage: note.category.symbol)
                .font(.headline)
                .foregroundStyle(AppTheme.accent)

            ReplyLine(icon: "bubble.left.and.text.bubble.right", title: "まず伝える文", text: ConsultationAnalyzer.briefMessage(for: note))
            ReplyLine(icon: "stethoscope", title: "主治医に聞くこと", text: doctorQuestion)
            ReplyLine(icon: "person.2.wave.2", title: "相談支援センターに聞くこと", text: supportQuestion)
        }
        .padding(.vertical, 4)
    }
}

struct SupportReplyCard: View {
    var reply: SupportReply

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            if reply.isCriticalSafety, let safetyBoundary = reply.safetyBoundary {
                SafetyAlertLine(text: safetyBoundary)
            }

            if !reply.domains.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 6) {
                        ForEach(reply.domains) { domain in
                            Text(domain.rawValue)
                                .font(.caption)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(AppTheme.accentSoft, in: Capsule())
                                .foregroundStyle(AppTheme.accent)
                        }
                    }
                }
            }

            ReplyLine(icon: "ear", title: "受け止め", text: reply.heardConcern)
            ReplyLine(icon: "heart", title: "気持ち", text: reply.feelingReflection)
            ReplyLine(icon: "text.quote", title: "言い換え", text: reply.plainRephrase)
            ReplyLine(icon: "checkmark.bubble", title: "確認", text: reply.confirmationQuestion)
            ReplyLine(icon: "questionmark.circle", title: "次に聞きたいこと", text: reply.minimumNextQuestion)
            ReplyLine(icon: "info.circle", title: "理由", text: reply.whyThisMatters)

            if !reply.isCriticalSafety, let safetyBoundary = reply.safetyBoundary {
                Label(safetyBoundary, systemImage: "shield")
                    .font(.caption)
                    .foregroundStyle(AppTheme.secondaryText)
            }
        }
        .padding(.vertical, 4)
    }
}

struct SafetyAlertLine: View {
    var text: String

    var body: some View {
        Label(text, systemImage: "exclamationmark.triangle.fill")
            .font(.subheadline)
            .foregroundStyle(.red)
            .padding(10)
            .background(.red.opacity(0.1), in: RoundedRectangle(cornerRadius: 8))
    }
}

struct ReplyLine: View {
    var icon: String
    var title: String
    var text: String

    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            Image(systemName: icon)
                .foregroundStyle(AppTheme.accent)
                .frame(width: 20)
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.caption)
                    .foregroundStyle(AppTheme.secondaryText)
                Text(text)
                    .font(.subheadline)
            }
        }
    }
}

struct MessageDraftGroup: View {
    var note: ConsultationNote

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label(note.recipient?.rawValue ?? "伝える相手を整理", systemImage: note.recipient?.symbol ?? "bubble.left.and.text.bubble.right")
                .font(.caption)
                .foregroundStyle(AppTheme.accent)
            Text(ConsultationAnalyzer.briefMessage(for: note))
                .font(.subheadline)
                .textSelection(.enabled)
            Text("そのまま伝えにくい場合は、診察前メモや相談支援センターに見せる文として使えます。")
                .font(.caption)
                .foregroundStyle(AppTheme.secondaryText)
        }
        .padding(.vertical, 4)
    }
}

struct ContextPromptGroup: View {
    var note: ConsultationNote

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            ForEach(ConsultationAnalyzer.contextPrompts(for: note), id: \.self) { prompt in
                Label(prompt, systemImage: "plus.bubble")
                    .font(.subheadline)
            }
            Text("任意です。分からない情報や、書きたくない情報は空欄のままで構いません。")
                .font(.caption)
                .foregroundStyle(AppTheme.secondaryText)
        }
        .padding(.vertical, 4)
    }
}

struct PreVisitChecklist: View {
    var note: ConsultationNote
    var items: [String]

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(note.title.isEmpty ? note.category.rawValue : note.title)
                .font(.headline)
            ForEach(items, id: \.self) { item in
                Label(item, systemImage: "checkmark.circle")
                    .font(.subheadline)
            }
        }
        .padding(.vertical, 4)
    }
}

struct QuestionGroup: View {
    var note: ConsultationNote
    var questions: [String]
    @State private var showsAll = false

    var body: some View {
        let visibleQuestions = showsAll ? questions : Array(questions.prefix(2))

        VStack(alignment: .leading, spacing: 8) {
            Text(note.title.isEmpty ? note.category.rawValue : note.title)
                .font(.headline)
            ForEach(visibleQuestions, id: \.self) { question in
                Label(question, systemImage: "questionmark.circle")
                    .font(.subheadline)
            }
            if questions.count > visibleQuestions.count {
                Button {
                    showsAll = true
                } label: {
                    Label("さらに表示", systemImage: "chevron.down")
                }
                .font(.caption)
            }
        }
        .padding(.vertical, 4)
    }
}

struct SupportCenterGuide: View {
    var note: ConsultationNote
    var items: [String]

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(note.title.isEmpty ? note.category.rawValue : note.title)
                .font(.headline)
            ForEach(items, id: \.self) { item in
                Label(item, systemImage: "person.2.wave.2")
                    .font(.subheadline)
            }
        }
        .padding(.vertical, 4)
    }
}
