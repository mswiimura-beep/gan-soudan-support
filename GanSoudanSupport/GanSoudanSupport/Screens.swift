import SwiftUI
import UIKit

struct ConsentGateView: View {
    @EnvironmentObject private var store: ConsultationStore
    @State private var confirmsBoundary = false
    @State private var confirmsSensitiveData = false

    var body: some View {
        NavigationStack {
            List {
                Section {
                    SafetyPositionCard()
                        .listRowInsets(EdgeInsets())
                        .listRowBackground(Color.clear)
                }

                Section("利用前の確認") {
                    Label("相談メモには病歴、治療、症状、家族や仕事の悩みなど要配慮情報が含まれる可能性があります。", systemImage: "lock")
                    Label("このアプリでは相談メモを端末内に保存し、外部サーバーには送信しません。", systemImage: "iphone")
                    Label("強い症状や危険を感じる時は、アプリで判断せず医療機関や救急へ連絡してください。", systemImage: "exclamationmark.triangle")
                }

                Section("同意") {
                    Toggle("診断・治療判断を行わない支援ツールとして利用します", isOn: $confirmsBoundary)
                    Toggle("相談内容がセンシティブな情報になり得ることを理解しました", isOn: $confirmsSensitiveData)
                }

                Section {
                    Button {
                        store.hasAcceptedConsent = true
                    } label: {
                        Label("同意してはじめる", systemImage: "checkmark.shield")
                            .frame(maxWidth: .infinity)
                    }
                    .disabled(!confirmsBoundary || !confirmsSensitiveData)
                } footer: {
                    Text("同意内容は設定画面で確認できます。相談履歴はアプリ内から削除できます。")
                }
            }
            .appScreenBackground()
            .navigationTitle("はじめる前に")
        }
        .tint(AppTheme.accent)
    }
}

struct HomeView: View {
    @EnvironmentObject private var store: ConsultationStore

    private var upcomingNotes: [ConsultationNote] {
        let today = Calendar.current.startOfDay(for: .now)
        return store.notes
            .filter { note in
                guard let date = note.nextConsultationDate else { return false }
                return Calendar.current.startOfDay(for: date) >= today
            }
            .sorted { first, second in
                (first.nextConsultationDate ?? .distantFuture) < (second.nextConsultationDate ?? .distantFuture)
            }
    }

    private var latestNote: ConsultationNote? {
        store.notes.first
    }

    var body: some View {
        List {
            Section {
                SafetyPositionCard()
                    .listRowInsets(EdgeInsets())
                    .listRowBackground(Color.clear)
            }

            if store.notes.isEmpty {
                Section("はじめて使うなら") {
                    InfoUseStepRow(number: 1, title: "まず書き出す", detail: "まとまっていなくても、頭にあることをそのまま残します。")
                    InfoUseStepRow(number: 2, title: "質問に変える", detail: "主治医や相談支援センターに聞くことを整理します。")
                    InfoUseStepRow(number: 3, title: "必要な情報を見る", detail: "要点を読んでから、必要な時だけ公式情報を開きます。")
                }
            }

            Section("次にやること") {
                NavigationLink {
                    ConsultationEditorView()
                } label: {
                    ActionRow(icon: "square.and.pencil", title: "頭にあることを書き出す", subtitle: "短いメモや音声入力から始められます")
                }

                NavigationLink {
                    QuestionListView()
                } label: {
                    ActionRow(icon: "checklist", title: "聞くことを確認する", subtitle: "主治医・相談員向けの質問案を見る")
                }

                NavigationLink {
                    TrustedInfoView()
                } label: {
                    ActionRow(icon: "book.closed", title: "困りごと別に情報を見る", subtitle: "要点を読んでから公式情報へ進む")
                }

                NavigationLink {
                    EmergencyActionGuideView()
                } label: {
                    ActionRow(icon: "exclamationmark.triangle", title: "急ぐ時の連絡先を確認", subtitle: "強い症状や危険を感じる時")
                }
            }

            if !upcomingNotes.isEmpty {
                Section("次の診察・相談予定") {
                    ForEach(upcomingNotes.prefix(3)) { note in
                        NavigationLink {
                            NoteDetailView(note: note)
                        } label: {
                            NoteSummaryRow(note: note)
                        }
                    }
                }
            }

            Section("最近の相談メモ") {
                if store.notes.isEmpty {
                    ContentUnavailableView("まだ相談メモがありません", systemImage: "note.text", description: Text("まずは「頭にあることを書き出す」から、気になっていることを1つ残してください。"))
                } else {
                    if let latestNote {
                        NavigationLink {
                            NoteDetailView(note: latestNote)
                        } label: {
                            ActionRow(icon: "sparkles", title: "最後に保存したメモを整理する", subtitle: latestNote.title.isEmpty ? latestNote.category.rawValue : latestNote.title)
                        }
                    }
                    ForEach(Array(store.notes.dropFirst().prefix(2))) { note in
                        NavigationLink {
                            NoteDetailView(note: note)
                        } label: {
                            NoteSummaryRow(note: note)
                        }
                    }
                    NavigationLink {
                        NotesListView()
                    } label: {
                        Label("すべての相談メモを見る", systemImage: "tray.full")
                    }
                }
            }

            Section {
                NavigationLink {
                    EmergencyActionGuideView()
                } label: {
                    EmergencyGuideCard()
                }
            }
        }
        .appScreenBackground()
        .navigationTitle("がん相談サポート")
    }
}

struct NotesListView: View {
    @EnvironmentObject private var store: ConsultationStore
    @State private var searchText = ""

    private var visibleNotes: [ConsultationNote] {
        let trimmedSearch = searchText.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        guard !trimmedSearch.isEmpty else { return store.notes }
        return store.notes.filter { $0.searchText.contains(trimmedSearch) }
    }

    var body: some View {
        List {
            Section {
                SafetyInlineNotice()
            }

            if visibleNotes.isEmpty {
                ContentUnavailableView("該当する相談メモがありません", systemImage: "magnifyingglass", description: Text("カテゴリ、伝える相手、本文の言葉で検索できます。"))
            } else {
                Section("相談メモ") {
                    ForEach(visibleNotes) { note in
                        NavigationLink {
                            NoteDetailView(note: note)
                        } label: {
                            NoteSummaryRow(note: note)
                        }
                    }
                }
            }
        }
        .appScreenBackground()
        .navigationTitle("相談メモ")
        .searchable(text: $searchText, prompt: "カテゴリ、相手、本文で検索")
    }
}

struct ConsultationEditorView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var store: ConsultationStore
    private let existingNote: ConsultationNote?
    @State private var category: ConsultationCategory = .treatment
    @State private var role: ConsultationRole = .patient
    @State private var recipient: CommunicationRecipient = .physician
    @State private var title = ""
    @State private var bodyText = ""
    @State private var personContext = ""
    @State private var diagnosis = ""
    @State private var treatmentStatus = ""
    @State private var usesNextConsultationDate = false
    @State private var nextConsultationDate = Date()
    @State private var didSave = false
    @State private var savedNote: ConsultationNote?

    init(note: ConsultationNote? = nil) {
        existingNote = note
        _category = State(initialValue: note?.category ?? .treatment)
        _role = State(initialValue: note?.role ?? .patient)
        _recipient = State(initialValue: note?.recipient ?? .physician)
        _title = State(initialValue: note?.title ?? "")
        _bodyText = State(initialValue: note?.body ?? "")
        _personContext = State(initialValue: note?.personContext ?? "")
        _diagnosis = State(initialValue: note?.diagnosis ?? "")
        _treatmentStatus = State(initialValue: note?.treatmentStatus ?? "")
        _usesNextConsultationDate = State(initialValue: note?.nextConsultationDate != nil)
        _nextConsultationDate = State(initialValue: note?.nextConsultationDate ?? .now)
    }

    var body: some View {
        Form {
            Section {
                SafetyInlineNotice()
            }

            if existingNote == nil, let lastSavedNote = savedNote {
                Section("保存後にできること") {
                    Text("端末内の相談メモに保存しました。写真アプリには保存されません。保存日: \(DateFormatter.consultationSavedDate.string(from: lastSavedNote.createdAt))")
                        .font(.subheadline)
                        .foregroundStyle(AppTheme.secondaryText)

                    NavigationLink {
                        NoteDetailView(note: lastSavedNote)
                    } label: {
                        ActionRow(icon: "doc.text.magnifyingglass", title: "保存したメモを見る", subtitle: "保存内容、保存日、質問案を確認")
                    }

                    NavigationLink {
                        QuestionListView()
                    } label: {
                        ActionRow(icon: "checklist", title: "質問リストで確認する", subtitle: "主治医や相談支援センターに聞くことを見る")
                    }

                    Button {
                        savedNote = nil
                    } label: {
                        Label("続けて別の相談を書く", systemImage: "plus.bubble")
                    }
                }
            }

            Section {
                Text("まとまっていなくて大丈夫です。キーボードのマイクを使って、頭に浮かんだ言葉をそのまま音声入力しても構いません。")
                    .font(.subheadline)
                    .foregroundStyle(AppTheme.secondaryText)
                TextField("見出し（あとで変更できます）", text: $title)
                TextEditor(text: $bodyText)
                    .frame(minHeight: 180)
                    .accessibilityLabel("思いつくままに入力")
            } header: {
                Text("まず、思いつくままに")
            } footer: {
                Text("保存後も編集できます。病名や治療名が分からなくても、今困っていることから書けます。")
            }

            Section {
                Text("病気だけでなく、その人が何を大切にしているか、どんな暮らしを守りたいかも相談の大切な情報です。書ける範囲で構いません。")
                    .font(.subheadline)
                    .foregroundStyle(AppTheme.secondaryText)
                TextEditor(text: $personContext)
                    .frame(minHeight: 130)
                    .accessibilityLabel("その人らしさ")
            } header: {
                Text("その人らしさ・大切にしたいこと")
            } footer: {
                Text("例: 家で過ごす時間を大切にしたい、仕事を続けたい、家族に心配をかけたくない、自分で決める時間がほしい。")
            }

            if existingNote == nil {
                Section("よくある相談から選ぶ") {
                    ForEach(ConsultationTemplate.defaultTemplates) { template in
                        Button {
                            apply(template)
                        } label: {
                            ActionRow(icon: template.symbol, title: template.title, subtitle: template.subtitle)
                        }
                    }
                }
            }

            Section("カテゴリ") {
                Picker("相談カテゴリ", selection: $category) {
                    ForEach(ConsultationCategory.allCases) { category in
                        Label(category.rawValue, systemImage: category.symbol)
                            .tag(category)
                    }
                }
            }

            Section {
                Picker("誰のこと", selection: $role) {
                    ForEach(ConsultationRole.allCases) { role in
                        Label(role.rawValue, systemImage: role.symbol)
                            .tag(role)
                    }
                }
            } header: {
                Text("誰のことで相談しますか")
            } footer: {
                Text("患者さん本人、家族、付き添い者など、誰のこととして整理しているかを残せます。")
            }

            Section {
                Picker("誰に伝えるか", selection: $recipient) {
                    ForEach(CommunicationRecipient.allCases) { recipient in
                        Label(recipient.rawValue, systemImage: recipient.symbol)
                            .tag(recipient)
                    }
                }
            } header: {
                Text("伝える相手")
            } footer: {
                Text("相手によって、短く伝える文と質問の形を変えます。まだ決まっていない場合は後で整理できます。")
            }

            Section("任意情報") {
                TextField("診断名・がん種など（任意）", text: $diagnosis)
                TextField("治療中、経過観察中など（任意）", text: $treatmentStatus)
            }

            Section {
                Toggle("次回診察・相談予定日を入れる", isOn: $usesNextConsultationDate)
                if usesNextConsultationDate {
                    DatePicker("予定日", selection: $nextConsultationDate, displayedComponents: .date)
                }
            } header: {
                Text("診察・相談予定")
            } footer: {
                Text("診断や治療判断のためではなく、診察前にメモを見返しやすくするための任意項目です。")
            }

            Section {
                Button {
                    save()
                } label: {
                    Label(existingNote == nil ? "相談メモを保存" : "変更を保存", systemImage: "tray.and.arrow.down")
                        .frame(maxWidth: .infinity)
                }
                .disabled(trimmedBody.isEmpty)
            }

            if !trimmedBody.isEmpty {
                Section("相談整理プレビュー") {
                    SupportReplyCard(reply: ConsultationAnalyzer.supportReply(for: draftNote))
                }

                Section("追加で整理できること") {
                    ContextPromptGroup(note: draftNote)
                }
            }
        }
        .appScreenBackground()
        .navigationTitle(existingNote == nil ? "相談を書く" : "相談メモを編集")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button(existingNote == nil ? "保存" : "更新") {
                    save()
                }
                .disabled(trimmedBody.isEmpty)
            }
        }
        .alert(existingNote == nil ? "保存しました" : "更新しました", isPresented: $didSave) {
            Button("OK", role: .cancel) {
                if existingNote != nil {
                    dismiss()
                }
            }
        } message: {
            if let savedNote {
                Text("端末内の相談メモに保存しました。写真アプリには保存されません。保存日: \(DateFormatter.consultationSavedDate.string(from: savedNote.createdAt))")
            } else {
                Text("端末内の相談メモを更新しました。写真アプリには保存されません。")
            }
        }
    }

    private var trimmedBody: String {
        bodyText.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private var draftNote: ConsultationNote {
        ConsultationNote(
            id: existingNote?.id ?? UUID(),
            category: category,
            role: role,
            recipient: recipient,
            title: title.trimmingCharacters(in: .whitespacesAndNewlines),
            body: trimmedBody,
            personContext: personContext.trimmingCharacters(in: .whitespacesAndNewlines),
            diagnosis: diagnosis.trimmingCharacters(in: .whitespacesAndNewlines),
            treatmentStatus: treatmentStatus.trimmingCharacters(in: .whitespacesAndNewlines),
            nextConsultationDate: usesNextConsultationDate ? nextConsultationDate : nil,
            createdAt: existingNote?.createdAt ?? .now
        )
    }

    private func save() {
        let noteToSave = draftNote
        if existingNote == nil {
            store.add(noteToSave)
            savedNote = noteToSave
            title = ""
            bodyText = ""
            personContext = ""
            diagnosis = ""
            treatmentStatus = ""
            usesNextConsultationDate = false
            nextConsultationDate = .now
            category = .treatment
            role = .patient
            recipient = .physician
        } else {
            store.update(noteToSave)
            savedNote = noteToSave
        }
        didSave = true
    }

    private func apply(_ template: ConsultationTemplate) {
        category = template.category
        role = template.role
        recipient = template.recipient
        if title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            title = template.title
        }
        if trimmedBody.isEmpty {
            bodyText = template.bodyDraft
        }
    }
}

struct QuestionListView: View {
    @EnvironmentObject private var store: ConsultationStore
    @State private var shareDocument: ShareDocument?
    @State private var copiedNotice = false

    var body: some View {
        List {
            Section {
                SafetyInlineNotice()
            }

            if store.notes.isEmpty {
                ContentUnavailableView("質問リストはまだありません", systemImage: "checklist", description: Text("相談メモを保存すると、主治医や相談員に聞く質問案を作れます。"))
            } else {
                if let latestNote = store.notes.first {
                    Section {
                        QuestionFocusCard(note: latestNote)
                    } header: {
                        Text("まず見る")
                    } footer: {
                        Text("診察前や相談前は、まずこの3つを確認してください。詳しい質問は下にあります。")
                    }
                }

                Section("メモ別の整理") {
                    ForEach(store.notes) { note in
                        VStack(alignment: .leading, spacing: 10) {
                            Text(note.title.isEmpty ? note.category.rawValue : note.title)
                                .font(.headline)
                            SupportReplyCard(reply: ConsultationAnalyzer.supportReply(for: note))
                        }
                        .padding(.vertical, 4)
                    }
                }

                Section("そのまま見せる・伝える文") {
                    ForEach(store.notes) { note in
                        MessageDraftGroup(note: note)
                    }
                }

                Section("診察前チェック") {
                    ForEach(store.notes) { note in
                        PreVisitChecklist(note: note, items: ConsultationAnalyzer.preVisitChecklist(for: note))
                    }
                }

                Section("主治医に聞くこと") {
                    ForEach(store.notes) { note in
                        QuestionGroup(note: note, questions: ConsultationAnalyzer.doctorQuestions(for: note))
                    }
                }

                Section("がん相談支援センターに相談できること") {
                    ForEach(store.notes) { note in
                        QuestionGroup(note: note, questions: ConsultationAnalyzer.supportCenterQuestions(for: note))
                    }
                }

                Section("相談先で整理できること") {
                    ForEach(store.notes) { note in
                        SupportCenterGuide(note: note, items: ConsultationAnalyzer.supportCenterGuide(for: note))
                    }
                }

                Section {
                    Button {
                        if let url = PDFExporter.makeConsultationPDF(notes: store.notes) {
                            shareDocument = ShareDocument(url: url)
                        }
                    } label: {
                        Label("PDFを共有", systemImage: "doc.richtext")
                    }

                    Button {
                        if let url = TextExporter.makeConsultationText(notes: store.notes) {
                            shareDocument = ShareDocument(url: url)
                        }
                    } label: {
                        Label("テキストを共有", systemImage: "doc.plaintext")
                    }

                    Button {
                        let urls = ImageExporter.makeConsultationImages(notes: store.notes)
                        shareDocument = ShareDocument(urls: urls)
                    } label: {
                        Label("画像を共有", systemImage: "photo")
                    }

                    Button {
                        UIPasteboard.general.string = TextExporter.consultationText(notes: store.notes)
                        copiedNotice = true
                    } label: {
                        Label("内容をコピー", systemImage: "doc.on.clipboard")
                    }
                } footer: {
                    Text("PDF、テキスト、画像に、保存済みの相談メモと質問案をまとめます。画像共有は写真アプリへ自動保存せず、共有先を自分で選びます。")
                }
            }
        }
        .appScreenBackground()
        .navigationTitle("質問リスト")
        .alert("コピーしました", isPresented: $copiedNotice) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("相談メモと質問リストをクリップボードにコピーしました。")
        }
        .sheet(item: $shareDocument) { document in
            ActivityShareSheet(items: document.urls)
        }
    }
}

struct NoteDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var store: ConsultationStore
    var note: ConsultationNote
    @State private var shareDocument: ShareDocument?
    @State private var showingDeleteConfirmation = false
    @State private var copiedNotice = false

    private var displayedNote: ConsultationNote {
        store.notes.first { $0.id == note.id } ?? note
    }

    var body: some View {
        let currentNote = displayedNote

        List {
            Section {
                SafetyInlineNotice()
            }

            Section("相談メモ") {
                Label(currentNote.category.rawValue, systemImage: currentNote.category.symbol)
                    .foregroundStyle(AppTheme.accent)
                LabeledContent("保存日", value: DateFormatter.consultationSavedDate.string(from: currentNote.createdAt))
                if let role = currentNote.role {
                    Label(role.rawValue, systemImage: role.symbol)
                        .foregroundStyle(AppTheme.secondaryText)
                }
                if let recipient = currentNote.recipient {
                    Label(recipient.rawValue, systemImage: recipient.symbol)
                        .foregroundStyle(AppTheme.secondaryText)
                }
                if !currentNote.diagnosis.isEmpty {
                    LabeledContent("任意情報", value: currentNote.diagnosis)
                }
                if !currentNote.treatmentStatus.isEmpty {
                    LabeledContent("状況", value: currentNote.treatmentStatus)
                }
                if let nextConsultationDate = currentNote.nextConsultationDate {
                    LabeledContent("予定日", value: DateFormatter.consultationDate.string(from: nextConsultationDate))
                }
                Text(currentNote.body)
                    .textSelection(.enabled)
            }

            if let personContext = currentNote.personContext, !personContext.isEmpty {
                Section("その人らしさ・大切にしたいこと") {
                    Text(personContext)
                        .textSelection(.enabled)
                    Text("相談員や家族に共有すると、病気だけでなく、その人の背景や希望を含めて理解してもらいやすくなります。")
                        .font(.caption)
                        .foregroundStyle(AppTheme.secondaryText)
                }
            }

            Section("相談整理") {
                SupportReplyCard(reply: ConsultationAnalyzer.supportReply(for: currentNote))
            }

            Section("短く伝える文") {
                Text(ConsultationAnalyzer.briefMessage(for: currentNote))
                    .textSelection(.enabled)
                Button {
                    UIPasteboard.general.string = ConsultationAnalyzer.briefMessage(for: currentNote)
                    copiedNotice = true
                } label: {
                    Label("この文をコピー", systemImage: "doc.on.clipboard")
                }
            }

            Section("診察前チェック") {
                PreVisitChecklist(note: currentNote, items: ConsultationAnalyzer.preVisitChecklist(for: currentNote))
            }

            Section("主治医に聞くこと") {
                QuestionGroup(note: currentNote, questions: ConsultationAnalyzer.doctorQuestions(for: currentNote))
            }

            Section("相談支援センターに相談できること") {
                QuestionGroup(note: currentNote, questions: ConsultationAnalyzer.supportCenterQuestions(for: currentNote))
            }

            Section {
                NavigationLink {
                    ConsultationEditorView(note: currentNote)
                } label: {
                    Label("このメモを編集", systemImage: "square.and.pencil")
                }

                Button {
                    if let url = PDFExporter.makeConsultationPDF(notes: [currentNote]) {
                        shareDocument = ShareDocument(url: url)
                    }
                } label: {
                    Label("このメモのPDFを共有", systemImage: "doc.richtext")
                }

                Button {
                    if let url = TextExporter.makeConsultationText(notes: [currentNote]) {
                        shareDocument = ShareDocument(url: url)
                    }
                } label: {
                    Label("このメモのテキストを共有", systemImage: "doc.plaintext")
                }

                Button {
                    if let url = ImageExporter.makeConsultationImage(note: currentNote) {
                        shareDocument = ShareDocument(url: url)
                    }
                } label: {
                    Label("このメモの画像を共有", systemImage: "photo")
                }

                Button {
                    UIPasteboard.general.string = TextExporter.textBlock(for: currentNote)
                    copiedNotice = true
                } label: {
                    Label("このメモをコピー", systemImage: "doc.on.clipboard")
                }
            }

            Section {
                Button(role: .destructive) {
                    showingDeleteConfirmation = true
                } label: {
                    Label("この相談メモを削除", systemImage: "trash")
                }
            }
        }
        .appScreenBackground()
        .navigationTitle(currentNote.title.isEmpty ? "相談メモ" : currentNote.title)
        .confirmationDialog("この相談メモを削除しますか", isPresented: $showingDeleteConfirmation, titleVisibility: .visible) {
            Button("削除", role: .destructive) {
                store.delete(currentNote)
                dismiss()
            }
            Button("キャンセル", role: .cancel) { }
        }
        .alert("コピーしました", isPresented: $copiedNotice) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("相談メモの内容をクリップボードにコピーしました。")
        }
        .sheet(item: $shareDocument) { document in
            ActivityShareSheet(items: document.urls)
        }
    }
}

struct TrustedInfoView: View {
    private let resources: [TrustedResource] = [
        TrustedResource(
            title: "まず何を調べるか整理する",
            subtitle: "病名や治療の一般情報を見る前に、知りたいことを分ける",
            group: .firstStep,
            url: "https://ganjoho.jp/public/index.html",
            symbol: "book.closed",
            overview: "がんの情報は量が多く、いきなり外部サイトを読むだけでは不安が増えることがあります。まず、病気の説明、検査、治療、副作用、生活、お金、家族への伝え方のどれを知りたいのかを分けます。",
            useWhen: [
                "説明を聞いたが、どこから確認すればよいか分からない",
                "検索結果が多すぎて、信頼できる情報を選べない",
                "主治医に聞く前に、一般的な言葉を確認したい"
            ],
            questions: [
                "私がまず理解しておくべき病気や治療の言葉は何ですか？",
                "自分の場合に当てはまる情報と、一般情報の違いはどこですか？",
                "次回までに読んでおくとよい資料はありますか？"
            ],
            nextActions: [
                "知りたいことを1つだけ相談メモに書く",
                "分からない言葉をそのままメモに残す",
                "一般情報を読んだ後、自己判断せず主治医に確認する"
            ],
            sourceName: "国立がん研究センター がん情報サービス"
        ),
        TrustedResource(
            title: "がん相談支援センターに相談する",
            subtitle: "治療以外の不安も相談できる窓口として使う",
            group: .firstStep,
            url: "https://hospdb.ganjoho.jp/kyotendb.nsf/xpConsultantSearchTop.xsp",
            symbol: "person.2.wave.2",
            overview: "がん相談支援センターは、患者さん本人だけでなく家族も相談できる窓口です。治療方針を決めてもらう場所ではなく、困りごとを整理し、必要な情報や相談先につなげてもらうために使います。",
            useWhen: [
                "医師に聞くほどではないと思って我慢している",
                "お金、仕事、家族、制度の話を誰に聞けばよいか分からない",
                "セカンドオピニオンや緩和ケアの相談の仕方を整理したい"
            ],
            questions: [
                "この内容は相談支援センターで相談できますか？",
                "主治医に確認した方がよいことは何ですか？",
                "医療費、仕事、家族のことで使える制度や窓口はありますか？"
            ],
            nextActions: [
                "相談メモをPDFまたはテキストで出す",
                "病院内または近隣の相談支援センターを探す",
                "相談時に、今一番困っていることを1つ目に伝える"
            ],
            sourceName: "がん相談支援センター検索"
        ),
        TrustedResource(
            title: "医療費・制度の不安を整理する",
            subtitle: "高額療養費、休職、収入減などを相談しやすくする",
            group: .dailyLife,
            url: "https://www.mhlw.go.jp/stf/seisakunitsuite/bunya/kenkou_iryou/iryouhoken/juuyou/kougakuiryou/index.html",
            symbol: "yensign.circle",
            overview: "医療費の不安は、制度名を読むだけでは自分に使えるか分かりにくい領域です。加入している保険、収入、治療予定、仕事の状況を分けて、相談支援センターや保険者に確認する形にします。",
            useWhen: [
                "治療費がどのくらいになるか不安",
                "高額療養費制度や限度額適用認定証が分からない",
                "休職や収入減で生活が心配"
            ],
            questions: [
                "高額療養費制度や限度額適用認定証の対象になりますか？",
                "相談先は病院、保険者、職場のどこがよいですか？",
                "治療予定を踏まえて、いつ手続きすればよいですか？"
            ],
            nextActions: [
                "保険証の種類、勤務先、治療予定をメモする",
                "病院の相談支援センターで制度相談を予約する",
                "保険者や職場に確認する前に聞きたいことを整理する"
            ],
            sourceName: "厚生労働省 高額療養費制度"
        ),
        TrustedResource(
            title: "仕事・学校との両立を相談する",
            subtitle: "休み方、伝え方、治療予定の調整を整理する",
            group: .dailyLife,
            url: "https://chiryoutoshigoto.mhlw.go.jp/",
            symbol: "briefcase",
            overview: "治療と仕事・学校の両立は、病状だけでなく、勤務形態、通院頻度、副作用、職場や学校にどこまで伝えるかが関わります。診断書や配慮の相談が必要になることもあります。",
            useWhen: [
                "仕事や学校を続けられるか不安",
                "職場や学校にどう伝えるか迷っている",
                "治療予定と休み方を整理したい"
            ],
            questions: [
                "治療中に避けた方がよい作業や予定はありますか？",
                "職場や学校に伝えるための診断書や説明書は必要ですか？",
                "治療スケジュールの相談は可能ですか？"
            ],
            nextActions: [
                "勤務・授業・通院予定をメモに並べる",
                "伝える相手を、主治医、相談員、職場・学校に分ける",
                "職場や学校へ出す前に、相談支援センターで言い方を確認する"
            ],
            sourceName: "厚生労働省 治療と仕事の両立支援"
        ),
        TrustedResource(
            title: "家族・付き添い者として相談する",
            subtitle: "本人への伝え方、自分の不安、支える限界を整理する",
            group: .dailyLife,
            url: "https://ganjoho.jp/public/support/family/index.html",
            symbol: "person.2",
            overview: "家族は、本人を支えたい気持ちと、自分自身の不安を同時に抱えやすくなります。本人の意思を尊重しながら、家族自身が相談できることも整理します。",
            useWhen: [
                "本人にどう声をかければよいか分からない",
                "家族として医師に何を聞いてよいか迷う",
                "付き添いや介護の負担が大きくなっている"
            ],
            questions: [
                "家族として診察時に確認してよいことは何ですか？",
                "本人の意思決定を支えるために、家族ができることは何ですか？",
                "家族自身の不安や負担を相談できる窓口はありますか？"
            ],
            nextActions: [
                "本人に確認したいことと、家族自身の不安を分けて書く",
                "診察に同席する場合は、本人の同意を確認する",
                "相談支援センターへ家族として相談する"
            ],
            sourceName: "がん情報サービス 家族向け情報"
        ),
        TrustedResource(
            title: "若い世代の心配",
            subtitle: "学校、仕事、将来子どもが欲しい気持ちを分ける",
            group: .bodyAndLifeStage,
            url: "https://ganjoho.jp/public/life_stage/aya/index.html",
            symbol: "figure.2.and.child.holdinghands",
            overview: "若い世代では、治療だけでなく、学校、仕事、恋愛、結婚、将来子どもが欲しいと思っていること、見た目、将来設計などが同時に問題になります。聞きにくいことも、相談項目として分けておくことが大切です。",
            useWhen: [
                "将来子どもが欲しいと思っていることや、見た目の変化が不安",
                "学校や仕事への説明に迷っている",
                "同世代の情報や相談先を探したい"
            ],
            questions: [
                "将来子どもが欲しいと思っていることへの影響について、どこで相談できますか？",
                "学校や職場へ伝える時、どの範囲まで説明すればよいですか？",
                "同世代向けの相談先や支援情報はありますか？"
            ],
            nextActions: [
                "聞きにくいこともメモに書き出す",
                "主治医に聞くことと、相談支援センターに聞くことを分ける",
                "必要なら家族や信頼できる人と一緒に相談する"
            ],
            sourceName: "がん情報サービス 若い世代のがん情報"
        ),
        TrustedResource(
            title: "見た目の変化に備える",
            subtitle: "髪、眉、肌、爪、帽子、ウィッグの不安を整理する",
            group: .bodyAndLifeStage,
            url: "https://ganjoho.jp/public/support/condition/appearance/index.html",
            symbol: "person.crop.square",
            overview: "治療に伴う見た目の変化は、体の変化だけでなく、人に会うこと、仕事や学校、家族との過ごし方、自分らしさにも関わります。この画面では、実際にどの変化が起きるかを予測せず、不安な場面と準備したいことを整理します。",
            useWhen: [
                "髪、眉、まつ毛、肌、爪、体型、服装の変化が不安",
                "帽子、タオル帽子、ウィッグ、眉メイクなどを試すか迷っている",
                "職場、学校、家族、友人にどう見られるか気になる"
            ],
            questions: [
                "治療に伴う見た目の変化について、どの時期に何を確認すればよいですか？",
                "帽子、ウィッグ、眉メイク、スキンケアについて相談できる窓口はありますか？",
                "見た目の変化を職場や家族に伝える時、どのように話せばよいですか？"
            ],
            nextActions: [
                "いちばん不安な変化を1つ選んで相談メモに書く",
                "試したいものを、帽子、ウィッグ、眉メイク、服装に分ける",
                "助成制度や購入先は、相談支援センターや自治体に確認する"
            ],
            sourceName: "がん情報サービス アピアランスケア"
        ),
        TrustedResource(
            title: "強い症状・危険を感じる時",
            subtitle: "アプリで判断せず、医療機関・救急へつなぐ",
            group: .urgent,
            url: "https://www.fdma.go.jp/mission/enrichment/appropriate/appropriate001.html",
            symbol: "exclamationmark.triangle",
            overview: "息苦しさ、胸痛、意識がもうろうとする、強い痛み、出血、高熱などがある時は、情報を読むより先に連絡が必要です。このアプリは緊急性を判定しません。",
            useWhen: [
                "急な強い症状がある",
                "危険かもしれないと感じている",
                "死にたい、消えたい気持ちがある"
            ],
            questions: [
                "今すぐ病院や救急へ連絡する状態ですか？",
                "治療中の病院から案内された夜間・休日連絡先はありますか？",
                "一人でいないために、今連絡できる人は誰ですか？"
            ],
            nextActions: [
                "119番、救急、医療機関、身近な人へ連絡する",
                "病院から案内された連絡先を優先する",
                "落ち着いた後で、症状の始まり、体温、薬、連絡先をメモする"
            ],
            sourceName: "総務省消防庁 救急車利用案内"
        )
    ]

    var body: some View {
        List {
            Section {
                SafetyInlineNotice()
            }

            Section {
                InfoUseStepRow(number: 1, title: "困りごとを選ぶ", detail: "病名ではなく、今困っている場面から選べます。")
                InfoUseStepRow(number: 2, title: "要点を読む", detail: "短い解説、聞くこと、次の行動だけを確認します。")
                InfoUseStepRow(number: 3, title: "必要なら公式情報へ", detail: "同意してから外部サイトを開きます。")
            } header: {
                Text("この画面の使い方")
            } footer: {
                Text("外部ページをただ読むための画面ではありません。困りごとを選ぶと、何を確認するか、誰に相談するか、次に何をするかを整理します。")
            }

            Section {
                NavigationLink {
                    EmergencyActionGuideView()
                } label: {
                    EmergencyGuideCard()
                }
            } footer: {
                Text("急な強い症状や危険を感じる時は、記録や情報収集より連絡を優先してください。")
            }

            ForEach(TrustedInfoGroup.allCases.filter { $0 != .urgent }) { group in
                let groupedResources = resources.filter { $0.group == group }
                if !groupedResources.isEmpty {
                    Section {
                        ForEach(groupedResources) { resource in
                            NavigationLink {
                                TrustedResourceDetailView(resource: resource)
                            } label: {
                                ActionRow(icon: resource.symbol, title: resource.title, subtitle: resource.subtitle)
                            }
                        }
                    } header: {
                        Text(group.rawValue)
                    } footer: {
                        Text(group.description)
                    }
                }
            }

            Section("制度を確認したい時") {
                NavigationLink {
                    SupportProgramGuideView()
                } label: {
                    ActionRow(icon: "list.clipboard", title: "制度の確認リスト", subtitle: "使える制度を断定せず、相談前に確認することを整理")
                }
            }

            Section("大切な境界") {
                Label("この画面は公的・専門機関への導線です。個別の診断、治療選択、薬の調整は主治医に確認してください。", systemImage: "shield")
            }
        }
        .appScreenBackground()
        .navigationTitle("信頼できる情報")
    }
}

struct SupportProgramGuideView: View {
    private let categories = SupportProgramCategory.allCases

    var body: some View {
        List {
            Section {
                Text("この画面は制度の対象者を判定するものではありません。医療費、仕事、保険、家族の休み方などについて、相談支援センターや窓口に確認する項目を整理します。")
                    .font(.subheadline)
                    .foregroundStyle(AppTheme.secondaryText)
            }

            ForEach(categories) { category in
                let items = SupportProgramGuideItem.defaultItems.filter { $0.category == category }
                if !items.isEmpty {
                    Section(category.rawValue) {
                        ForEach(items) { item in
                            NavigationLink {
                                SupportProgramDetailView(item: item)
                            } label: {
                                ActionRow(icon: category.symbol, title: item.title, subtitle: item.confirmWith)
                            }
                        }
                    }
                }
            }

            Section("使い方") {
                Label("気になる制度名を覚えるより、確認先と質問を持って相談することを優先してください。", systemImage: "bubble.left.and.text.bubble.right")
                Label("自治体、保険者、勤務先、保険会社で手続きや条件が変わることがあります。", systemImage: "building.2")
            }
        }
        .appScreenBackground()
        .navigationTitle("制度の確認リスト")
    }
}

struct SupportProgramDetailView: View {
    var item: SupportProgramGuideItem

    var body: some View {
        List {
            Section {
                VStack(alignment: .leading, spacing: 12) {
                    Label(item.title, systemImage: item.category.symbol)
                        .font(.headline)
                    Text(item.summary)
                        .font(.subheadline)
                        .foregroundStyle(AppTheme.secondaryText)
                }
                .padding(.vertical, 4)
            }

            Section("確認先") {
                Label(item.confirmWith, systemImage: "person.crop.circle.badge.questionmark")
            }

            Section("相談前にメモすること") {
                ForEach(item.beforeAsking, id: \.self) { point in
                    Label(point, systemImage: "square.and.pencil")
                }
            }

            Section("窓口で聞くこと") {
                ForEach(item.questions, id: \.self) { question in
                    Label(question, systemImage: "questionmark.circle")
                }
            }

            Section("注意") {
                Text("制度の対象になるか、申請できるか、必要書類は個別の状況で変わります。この画面だけで判断せず、相談支援センター、保険者、勤務先、自治体などに確認してください。")
                    .font(.subheadline)
                    .foregroundStyle(AppTheme.secondaryText)
            }
        }
        .appScreenBackground()
        .navigationTitle(item.title)
    }
}

struct TrustedResourceDetailView: View {
    @Environment(\.openURL) private var openURL
    var resource: TrustedResource
    @State private var showingExternalConfirmation = false

    var body: some View {
        List {
            Section {
                VStack(alignment: .leading, spacing: 12) {
                    Label(resource.title, systemImage: resource.symbol)
                        .font(.headline)
                    Text(resource.overview)
                        .font(.subheadline)
                        .foregroundStyle(AppTheme.secondaryText)
                }
                .padding(.vertical, 4)
            }

            Section("こういう時に使う") {
                ForEach(resource.useWhen, id: \.self) { item in
                    Label(item, systemImage: "checkmark.circle")
                }
            }

            Section("相談時に聞くこと") {
                ForEach(resource.questions, id: \.self) { question in
                    Label(question, systemImage: "questionmark.circle")
                }
            }

            Section("次の行動") {
                ForEach(resource.nextActions, id: \.self) { action in
                    Label(action, systemImage: "arrow.forward.circle")
                }
            }

            Section("情報源") {
                Text("この要点は、診断・治療判断ではなく、相談内容を整理するための案内です。制度や医療情報は変更されることがあるため、必要な時だけ公式情報で確認してください。")
                    .font(.subheadline)
                    .foregroundStyle(AppTheme.secondaryText)

                Button {
                    showingExternalConfirmation = true
                } label: {
                    ActionRow(icon: "safari", title: "公式情報を読んでみますか？", subtitle: "はいを押すと外部サイトを開きます")
                }
            }
        }
        .appScreenBackground()
        .navigationTitle(resource.title)
        .confirmationDialog("公式情報を読んでみますか？", isPresented: $showingExternalConfirmation, titleVisibility: .visible) {
            Button("はい、公式情報を開く") {
                openURL(resource.url)
            }
            Button("今は開かない", role: .cancel) { }
        } message: {
            Text("\(resource.sourceName)をSafariで開きます。外部サイトの内容は提供元が更新します。")
        }
    }
}

struct SettingsView: View {
    @EnvironmentObject private var store: ConsultationStore
    @State private var showingDeleteConfirmation = false

    var body: some View {
        List {
            Section {
                Toggle("相談整理ツールとして利用することに同意", isOn: $store.hasAcceptedConsent)
                Toggle("端末内で相談内容を整理する", isOn: $store.allowsLocalAnalysis)
            } header: {
                Text("同意")
            } footer: {
                Text("このアプリは端末内に相談メモを保存します。診断、治療方針、薬剤、緊急性の判断は行いません。")
            }

            Section("安全・プライバシー") {
                Label("診断名、病期、病院名は任意入力です。不要な情報は入力しないでください。", systemImage: "lock")
                Label("AIやサーバー連携を追加する場合は、利用目的、第三者提供、保存期間、削除方法を明示します。", systemImage: "person.badge.shield.checkmark")
                NavigationLink {
                    PrivacySummaryView()
                } label: {
                    Label("プライバシー要点を見る", systemImage: "doc.text.magnifyingglass")
                }
                NavigationLink {
                    PrivacyPolicyDraftView()
                } label: {
                    Label("プライバシーポリシー案", systemImage: "doc.text")
                }
                NavigationLink {
                    AppPositionStatementView()
                } label: {
                    Label("アプリの位置づけ", systemImage: "shield.lefthalf.filled")
                }
            }

            Section("情報の信頼性") {
                NavigationLink {
                    SourceAndReviewStatusView()
                } label: {
                    Label("情報源・監修状態", systemImage: "checkmark.seal")
                }
            }

            Section("データ") {
                Button(role: .destructive) {
                    showingDeleteConfirmation = true
                } label: {
                    Label("相談履歴をすべて削除", systemImage: "trash")
                }
                .disabled(store.notes.isEmpty)
            }

            Section("緊急時") {
                NavigationLink {
                    EmergencyActionGuideView()
                } label: {
                    EmergencyGuideCard()
                }
            }

            Section("開発・公開前確認") {
                NavigationLink {
                    ReleaseReadinessView()
                } label: {
                    Label("TestFlight前チェック", systemImage: "checklist.checked")
                }
                NavigationLink {
                    AppSupportInfoView()
                } label: {
                    Label("バージョン・サポート", systemImage: "info.circle")
                }
            }
        }
        .appScreenBackground()
        .navigationTitle("設定")
        .confirmationDialog("相談履歴をすべて削除しますか", isPresented: $showingDeleteConfirmation, titleVisibility: .visible) {
            Button("すべて削除", role: .destructive) {
                store.deleteAll()
            }
            Button("キャンセル", role: .cancel) { }
        }
    }
}

struct PrivacySummaryView: View {
    var body: some View {
        List {
            Section("このアプリで扱う情報") {
                Label("相談メモ、任意の診断名・治療状況、相談カテゴリ、伝える相手を端末内に保存します。", systemImage: "internaldrive")
                Label("病院名、病期、治療歴などは必須入力にしません。", systemImage: "text.badge.checkmark")
            }

            Section("利用しないこと") {
                Label("現時点では外部サーバー、LLM、広告、分析基盤へ相談内容を送信しません。", systemImage: "network.slash")
                Label("健康・医療情報を広告やマーケティング目的に使いません。", systemImage: "megaphone.slash")
            }

            Section("ユーザーができること") {
                Label("相談履歴は設定画面からすべて削除できます。", systemImage: "trash")
                Label("PDF共有はユーザー操作で作成・共有した場合だけ行われます。", systemImage: "square.and.arrow.up")
            }

            Section("今後サーバーやAIを追加する場合") {
                Label("利用目的、第三者提供、保存期間、削除方法、ログ制御、出力安全確認を事前に明示します。", systemImage: "checkmark.shield")
            }
        }
        .appScreenBackground()
        .navigationTitle("プライバシー要点")
    }
}

struct PrivacyPolicyDraftView: View {
    var body: some View {
        List {
            Section("目的") {
                Text("本アプリは、がんに関する不安や疑問を整理し、医療者・がん相談支援センター等に相談しやすくするための支援ツールです。診断、治療方針、薬剤、緊急性の判断は行いません。")
            }

            Section("保存する情報") {
                Label("相談メモ本文、相談カテゴリ、誰のことで相談するか、伝える相手、任意の診断名・治療状況、任意の診察・相談予定日を端末内に保存します。", systemImage: "internaldrive")
                Label("診断名、病期、病院名、治療歴などは必須入力ではありません。", systemImage: "text.badge.checkmark")
            }

            Section("外部送信") {
                Label("このアプリでは、相談内容を外部サーバー、AIサービス、広告、分析基盤へ送信しません。", systemImage: "network.slash")
                Label("PDF・テキスト共有は、ユーザーが作成して共有操作を行った場合だけ発生します。", systemImage: "square.and.arrow.up")
            }

            Section("利用目的") {
                Label("相談メモの保存、質問リスト作成、診察前チェック、PDF・テキスト出力のために利用します。", systemImage: "checklist")
                Label("健康・医療情報を広告やマーケティング目的に利用しません。", systemImage: "megaphone.slash")
            }

            Section("削除") {
                Label("相談メモは、メモ詳細画面で1件ごとに削除できます。", systemImage: "trash")
                Label("設定画面から相談履歴をすべて削除できます。", systemImage: "trash.fill")
            }

            Section("今後の変更") {
                Text("サーバー同期、AI相談整理、アカウント機能、分析機能を追加する場合は、利用目的、第三者提供、保存期間、削除方法、同意撤回方法を明示したうえで、同意設計を更新します。")
            }

            Section("注意") {
                Text("この画面は初版開発用のポリシー案です。公開前には、実際のデータ処理、運営者情報、問い合わせ先、適用日、法務確認を反映した正式なプライバシーポリシーとして整備してください。")
                    .foregroundStyle(AppTheme.secondaryText)
            }
        }
        .appScreenBackground()
        .navigationTitle("プライバシーポリシー案")
    }
}

struct AppPositionStatementView: View {
    var body: some View {
        List {
            Section("このアプリがすること") {
                Label("不安や疑問を言葉にする手助けをします。", systemImage: "pencil.and.list.clipboard")
                Label("主治医や相談支援センターに聞く質問を整理します。", systemImage: "questionmark.bubble")
                Label("公的・専門機関の信頼できる情報への導線を示します。", systemImage: "book.closed")
            }

            Section("このアプリがしないこと") {
                Label("診断名、再発、病状、緊急性を判定しません。", systemImage: "xmark.shield")
                Label("治療法、薬剤、薬の量、中止を判断しません。", systemImage: "pills")
                Label("医療者や相談員の代わりに意思決定しません。", systemImage: "person.crop.circle.badge.exclamationmark")
            }

            Section("緊急時") {
                NavigationLink {
                    EmergencyActionGuideView()
                } label: {
                    EmergencyGuideCard()
                }
            }
        }
        .appScreenBackground()
        .navigationTitle("アプリの位置づけ")
    }
}

struct EmergencyActionGuideView: View {
    var body: some View {
        List {
            Section {
                Label("このアプリは緊急性の判定を行いません。強い症状や危険を感じる場合は、記録や相談整理より先に連絡してください。", systemImage: "exclamationmark.triangle.fill")
                    .foregroundStyle(.red)
            }

            Section("今すぐ危険を感じる場合") {
                Label("119番、救急、または近くの医療機関へ連絡してください。", systemImage: "phone.fill")
                Label("ひとりで移動せず、身近な人に助けを求めてください。", systemImage: "person.2.fill")
                Label("意識がもうろうとする、息苦しい、胸痛、強い痛み、出血、高熱などは、アプリ内で様子見判断をしません。", systemImage: "waveform.path.ecg")
            }

            Section("治療中・通院中の場合") {
                Label("病院から案内されている夜間・休日の連絡先を優先してください。", systemImage: "building.2")
                Label("連絡時は、診断名よりも、今の症状、始まった時刻、治療中の薬、体温などを短く伝えてください。", systemImage: "list.bullet.clipboard")
            }

            Section("死にたい・消えたい気持ちがある場合") {
                Label("今すぐ一人で抱えず、身近な人、医療機関、救急、または地域の緊急相談窓口に連絡してください。", systemImage: "heart.fill")
                Label("このアプリでは安全確認や緊急判断はできません。", systemImage: "shield.slash")
            }

            Section("あとで整理すること") {
                Label("落ち着いてから、何が起きたか、いつからか、誰へ連絡したかを相談メモに残せます。", systemImage: "square.and.pencil")
                Label("次回診察では、どの状態なら連絡するべきかを主治医に確認してください。", systemImage: "questionmark.circle")
            }

            Section("参考") {
                Link(destination: URL(string: "https://www.fdma.go.jp/mission/enrichment/appropriate/appropriate001.html")!) {
                    ActionRow(icon: "exclamationmark.triangle", title: "総務省消防庁 救急車利用案内", subtitle: "救急時の公的情報")
                }
            }
        }
        .appScreenBackground()
        .navigationTitle("緊急時の案内")
    }
}

struct SourceAndReviewStatusView: View {
    var body: some View {
        List {
            Section("情報源の扱い") {
                Label("アプリ内で独自の医療記事は作成せず、公的・専門機関へのリンクを表示します。", systemImage: "link")
                Label("リンク先の内容は各提供元の責任で更新されます。利用前にリンク先で最新情報を確認してください。", systemImage: "arrow.triangle.2.circlepath")
            }

            Section("参照している主な情報源") {
                Link(destination: URL(string: "https://ganjoho.jp/public/index.html")!) {
                    ActionRow(icon: "book.closed", title: "国立がん研究センター がん情報サービス", subtitle: "一般向けがん情報")
                }
                Link(destination: URL(string: "https://hospdb.ganjoho.jp/kyotendb.nsf/xpConsultantSearchTop.xsp")!) {
                    ActionRow(icon: "person.2.wave.2", title: "がん相談支援センター検索", subtitle: "相談先を探す")
                }
                Link(destination: URL(string: "https://chiryoutoshigoto.mhlw.go.jp/")!) {
                    ActionRow(icon: "briefcase", title: "治療と仕事の両立支援", subtitle: "厚生労働省の支援情報")
                }
            }

            Section("監修状態") {
                Label("現在のアプリは、相談内容を整理するための初期版です。", systemImage: "hammer")
                Label("公開前に、がん相談支援、医療安全、個人情報保護の観点で文言レビューが必要です。", systemImage: "person.badge.shield.checkmark")
                Label("診断、治療判断、薬剤判断、緊急性判断を行わない境界を維持します。", systemImage: "shield")
            }

            Section("更新時の確認") {
                Label("新しい医療情報や制度説明をアプリ内に書く場合は、出典、監修者、更新日を表示してください。", systemImage: "calendar.badge.clock")
                Label("リンク切れや制度変更がないか、公開前と更新時に確認してください。", systemImage: "checkmark.circle")
            }
        }
        .appScreenBackground()
        .navigationTitle("情報源・監修状態")
    }
}

struct ReleaseReadinessView: View {
    private let sections: [(title: String, items: [String])] = [
        (
            "操作確認",
            [
                "初回同意からホームへ進める",
                "相談メモを作成、編集、検索、削除できる",
                "予定日つきメモがホームに表示される",
                "PDF、テキスト、コピーが動作する"
            ]
        ),
        (
            "安全境界",
            [
                "診断、治療、薬剤、緊急性の判断をしない",
                "緊急時の案内画面へ移動できる",
                "自傷表現では一人で抱えない案内が出る",
                "治療法を選ぶ・薬を調整する表現がない"
            ]
        ),
        (
            "プライバシー",
            [
                "相談内容は端末内保存であると説明している",
                "外部サーバー、AI、広告、分析基盤へ送信しないと説明している",
                "1件削除と全件削除ができる",
                "正式なプライバシーポリシーURLを公開前に用意する"
            ]
        ),
        (
            "公開準備",
            [
                "正常なXcode環境でAsset Catalogを登録する",
                "実機または正常なSimulatorで手動QAを実施する",
                "スクリーンショットを5枚準備する",
                "医療安全・相談支援・個人情報保護の文言レビューを受ける"
            ]
        ),
        (
            "スクリーンショット",
            [
                "実在の患者名、病院名、診断詳細を入れない",
                "緊急・自傷例をApp Store画像に使わない",
                "診断・治療判断をしない文言が見える画面を含める",
                "ホーム、相談入力、相談整理、質問リスト、プライバシー/安全の5枚を準備する"
            ]
        )
    ]

    var body: some View {
        List {
            Section {
                Label("この画面は開発・TestFlight前の確認用です。ユーザー向けの医療助言ではありません。", systemImage: "hammer")
                    .foregroundStyle(AppTheme.secondaryText)
            }

            ForEach(sections, id: \.title) { section in
                Section(section.title) {
                    ForEach(section.items, id: \.self) { item in
                        Label(item, systemImage: "checkmark.circle")
                    }
                }
            }
        }
        .appScreenBackground()
        .navigationTitle("TestFlight前チェック")
    }
}

struct AppSupportInfoView: View {
    private var appVersion: String {
        Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "1.0"
    }

    private var buildNumber: String {
        Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String ?? "1"
    }

    var body: some View {
        List {
            Section("アプリ") {
                LabeledContent("名称", value: "がん相談サポート")
                LabeledContent("バージョン", value: appVersion)
                LabeledContent("ビルド", value: buildNumber)
            }

            Section("サポート") {
                Label("公開前に、正式なサポートURLと問い合わせ先を設定してください。", systemImage: "person.crop.circle.badge.questionmark")
                Label("緊急時や強い症状の相談先ではありません。緊急時は医療機関・救急へ連絡してください。", systemImage: "exclamationmark.triangle")
            }

            Section("データとAI") {
                Label("このアプリは端末内保存です。", systemImage: "iphone")
                Label("このアプリは外部AIサービスへ相談内容を送信しません。", systemImage: "network.slash")
                Label("広告・分析SDKは利用していません。", systemImage: "megaphone.slash")
            }

            Section("公開前に差し替える項目") {
                Label("運営者名", systemImage: "building")
                Label("問い合わせ先", systemImage: "envelope")
                Label("サポートURL", systemImage: "link")
                Label("正式なプライバシーポリシーURL", systemImage: "doc.text")
            }
        }
        .appScreenBackground()
        .navigationTitle("バージョン・サポート")
    }
}
