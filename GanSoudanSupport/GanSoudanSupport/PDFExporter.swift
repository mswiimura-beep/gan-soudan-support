import UIKit

enum PDFExporter {
    static func makeConsultationPDF(notes: [ConsultationNote]) -> URL? {
        let page = CGRect(x: 0, y: 0, width: 595, height: 842)
        let renderer = UIGraphicsPDFRenderer(bounds: page)
        let url = FileManager.default.temporaryDirectory.appending(path: "consultation-notes.pdf")

        do {
            try renderer.writePDF(to: url) { context in
                context.beginPage()
                var y: CGFloat = 36
                draw("がん相談サポート 相談メモ", at: &y, font: .boldSystemFont(ofSize: 20))
                draw("診断、治療方針、薬剤、緊急性の判断を行うものではありません。", at: &y, font: .systemFont(ofSize: 11), color: .darkGray)

                for note in notes {
                    if y > 720 {
                        context.beginPage()
                        y = 36
                    }

                    draw(note.title.isEmpty ? note.category.rawValue : note.title, at: &y, font: .boldSystemFont(ofSize: 15))
                    draw("保存日: \(DateFormatter.consultationSavedDate.string(from: note.createdAt))", at: &y, font: .systemFont(ofSize: 11), color: .darkGray)
                    draw("カテゴリ: \(note.category.rawValue)", at: &y, font: .systemFont(ofSize: 11), color: .darkGray)
                    if let role = note.role {
                        draw("誰のことで相談: \(role.rawValue)", at: &y, font: .systemFont(ofSize: 11), color: .darkGray)
                    }
                    if let recipient = note.recipient {
                        draw("伝える相手: \(recipient.rawValue)", at: &y, font: .systemFont(ofSize: 11), color: .darkGray)
                    }
                    if let nextConsultationDate = note.nextConsultationDate {
                        draw("予定日: \(DateFormatter.consultationDate.string(from: nextConsultationDate))", at: &y, font: .systemFont(ofSize: 11), color: .darkGray)
                    }
                    draw(note.body, at: &y, font: .systemFont(ofSize: 12))
                    if let personContext = note.personContext, !personContext.isEmpty {
                        draw("その人らしさ・大切にしたいこと:", at: &y, font: .boldSystemFont(ofSize: 12))
                        draw(personContext, at: &y, font: .systemFont(ofSize: 11))
                    }
                    draw("短く伝える文:", at: &y, font: .boldSystemFont(ofSize: 12))
                    draw(ConsultationAnalyzer.briefMessage(for: note), at: &y, font: .systemFont(ofSize: 11))
                    draw("主治医に聞くこと:", at: &y, font: .boldSystemFont(ofSize: 12))
                    for question in ConsultationAnalyzer.doctorQuestions(for: note) {
                        draw("- \(question)", at: &y, font: .systemFont(ofSize: 11))
                    }
                    draw("相談支援センターで整理できること:", at: &y, font: .boldSystemFont(ofSize: 12))
                    for item in ConsultationAnalyzer.supportCenterGuide(for: note) {
                        draw("- \(item)", at: &y, font: .systemFont(ofSize: 11))
                    }
                    y += 12
                }
            }
            return url
        } catch {
            return nil
        }
    }

    private static func draw(_ text: String, at y: inout CGFloat, font: UIFont, color: UIColor = .black) {
        let paragraph = NSMutableParagraphStyle()
        paragraph.lineBreakMode = .byWordWrapping
        let attributes: [NSAttributedString.Key: Any] = [
            .font: font,
            .foregroundColor: color,
            .paragraphStyle: paragraph
        ]
        let rect = CGRect(x: 36, y: y, width: 523, height: 1000)
        let height = text.boundingRect(with: rect.size, options: [.usesLineFragmentOrigin], attributes: attributes, context: nil).height
        text.draw(with: CGRect(x: rect.minX, y: y, width: rect.width, height: height), options: [.usesLineFragmentOrigin], attributes: attributes, context: nil)
        y += ceil(height) + 8
    }
}

enum TextExporter {
    static func makeConsultationText(notes: [ConsultationNote]) -> URL? {
        let url = FileManager.default.temporaryDirectory.appending(path: "consultation-notes.txt")
        let text = consultationText(notes: notes)

        do {
            try text.write(to: url, atomically: true, encoding: .utf8)
            return url
        } catch {
            return nil
        }
    }

    static func consultationText(notes: [ConsultationNote]) -> String {
        notes.map(textBlock(for:)).joined(separator: "\n\n---\n\n")
    }

    static func textBlock(for note: ConsultationNote) -> String {
        var lines = [
            "がん相談サポート 相談メモ",
            "診断、治療方針、薬剤、緊急性の判断を行うものではありません。",
            "",
            "見出し: \(note.title.isEmpty ? note.category.rawValue : note.title)",
            "保存日: \(DateFormatter.consultationSavedDate.string(from: note.createdAt))",
            "カテゴリ: \(note.category.rawValue)"
        ]

        if let role = note.role {
            lines.append("誰のことで相談: \(role.rawValue)")
        }

        if let recipient = note.recipient {
            lines.append("伝える相手: \(recipient.rawValue)")
        }

        if let nextConsultationDate = note.nextConsultationDate {
            lines.append("予定日: \(DateFormatter.consultationDate.string(from: nextConsultationDate))")
        }

        if !note.diagnosis.isEmpty {
            lines.append("任意情報: \(note.diagnosis)")
        }

        if !note.treatmentStatus.isEmpty {
            lines.append("状況: \(note.treatmentStatus)")
        }

        lines.append(contentsOf: [
            "",
            "相談したいこと:",
            note.body
        ])

        if let personContext = note.personContext, !personContext.isEmpty {
            lines.append(contentsOf: [
                "",
                "その人らしさ・大切にしたいこと:",
                personContext
            ])
        }

        lines.append(contentsOf: [
            "",
            "短く伝える文:",
            ConsultationAnalyzer.briefMessage(for: note),
            "",
            "主治医に聞くこと:"
        ])

        lines.append(contentsOf: ConsultationAnalyzer.doctorQuestions(for: note).map { "- \($0)" })

        lines.append(contentsOf: [
            "",
            "相談支援センターで整理できること:"
        ])

        lines.append(contentsOf: ConsultationAnalyzer.supportCenterGuide(for: note).map { "- \($0)" })

        return lines.joined(separator: "\n")
    }
}
