import UIKit

enum ImageExporter {
    static func makeConsultationImages(notes: [ConsultationNote]) -> [URL] {
        notes.compactMap { note in
            makeConsultationImage(note: note)
        }
    }

    static func makeConsultationImage(note: ConsultationNote) -> URL? {
        let width: CGFloat = 1170
        let horizontalPadding: CGFloat = 72
        let maxTextWidth = width - horizontalPadding * 2
        let blocks = imageTextBlocks(for: note)
        let height = measuredHeight(for: blocks, maxTextWidth: maxTextWidth) + 96
        let format = UIGraphicsImageRendererFormat()
        format.scale = 1
        format.opaque = true
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: width, height: height), format: format)

        let image = renderer.image { context in
            UIColor(red: 1.0, green: 0.95, blue: 0.88, alpha: 1.0).setFill()
            context.fill(CGRect(x: 0, y: 0, width: width, height: height))

            UIColor(red: 1.0, green: 0.985, blue: 0.955, alpha: 1.0).setFill()
            UIBezierPath(roundedRect: CGRect(x: 36, y: 36, width: width - 72, height: height - 72), cornerRadius: 28).fill()

            var y: CGFloat = 72
            for block in blocks {
                y += block.topSpacing
                draw(block.text, at: &y, x: horizontalPadding, width: maxTextWidth, font: block.font, color: block.color)
            }
        }

        let safeTitle = note.title.isEmpty ? note.category.rawValue : note.title
        let filename = "consultation-note-\(safeTitle.replacingOccurrences(of: "/", with: "-")).png"
        let url = FileManager.default.temporaryDirectory.appending(path: filename)

        guard let data = image.pngData() else { return nil }
        do {
            try data.write(to: url, options: .atomic)
            return url
        } catch {
            return nil
        }
    }

    private static func imageTextBlocks(for note: ConsultationNote) -> [ImageTextBlock] {
        var blocks: [ImageTextBlock] = [
            ImageTextBlock("がん相談サポート 相談メモ", .boldSystemFont(ofSize: 34), .primaryText),
            ImageTextBlock("診断、治療方針、薬剤、緊急性の判断を行うものではありません。", .systemFont(ofSize: 22), .secondaryText),
            ImageTextBlock(note.title.isEmpty ? note.category.rawValue : note.title, .boldSystemFont(ofSize: 30), .primaryText),
            ImageTextBlock("保存日: \(DateFormatter.consultationSavedDate.string(from: note.createdAt))", .systemFont(ofSize: 22), .secondaryText),
            ImageTextBlock("カテゴリ: \(note.category.rawValue)", .systemFont(ofSize: 22), .secondaryText)
        ]

        if let role = note.role {
            blocks.append(ImageTextBlock("誰のことで相談: \(role.rawValue)", .systemFont(ofSize: 22), .secondaryText))
        }

        if let recipient = note.recipient {
            blocks.append(ImageTextBlock("伝える相手: \(recipient.rawValue)", .systemFont(ofSize: 22), .secondaryText))
        }

        if let nextConsultationDate = note.nextConsultationDate {
            blocks.append(ImageTextBlock("予定日: \(DateFormatter.consultationDate.string(from: nextConsultationDate))", .systemFont(ofSize: 22), .secondaryText))
        }

        blocks.append(ImageTextBlock("相談したいこと", .boldSystemFont(ofSize: 26), .primaryText, topSpacing: 22))
        blocks.append(ImageTextBlock(note.body, .systemFont(ofSize: 24), .primaryText))

        if let personContext = note.personContext, !personContext.isEmpty {
            blocks.append(ImageTextBlock("その人らしさ・大切にしたいこと", .boldSystemFont(ofSize: 26), .primaryText, topSpacing: 22))
            blocks.append(ImageTextBlock(personContext, .systemFont(ofSize: 24), .primaryText))
        }

        blocks.append(ImageTextBlock("短く伝える文", .boldSystemFont(ofSize: 26), .primaryText, topSpacing: 22))
        blocks.append(ImageTextBlock(ConsultationAnalyzer.briefMessage(for: note), .systemFont(ofSize: 24), .primaryText))

        blocks.append(ImageTextBlock("主治医に聞くこと", .boldSystemFont(ofSize: 26), .primaryText, topSpacing: 22))
        blocks.append(contentsOf: ConsultationAnalyzer.doctorQuestions(for: note).map {
            ImageTextBlock("・\($0)", .systemFont(ofSize: 23), .primaryText)
        })

        blocks.append(ImageTextBlock("相談支援センターで整理できること", .boldSystemFont(ofSize: 26), .primaryText, topSpacing: 22))
        blocks.append(contentsOf: ConsultationAnalyzer.supportCenterGuide(for: note).map {
            ImageTextBlock("・\($0)", .systemFont(ofSize: 23), .primaryText)
        })

        return blocks
    }

    private static func measuredHeight(for blocks: [ImageTextBlock], maxTextWidth: CGFloat) -> CGFloat {
        blocks.reduce(CGFloat.zero) { height, block in
            height + block.topSpacing + textHeight(block.text, width: maxTextWidth, font: block.font) + 16
        }
    }

    private static func draw(_ text: String, at y: inout CGFloat, x: CGFloat, width: CGFloat, font: UIFont, color: UIColor) {
        let attributes = attributes(font: font, color: color)
        let height = textHeight(text, width: width, font: font)
        text.draw(with: CGRect(x: x, y: y, width: width, height: height), options: [.usesLineFragmentOrigin], attributes: attributes, context: nil)
        y += ceil(height) + 16
    }

    private static func textHeight(_ text: String, width: CGFloat, font: UIFont) -> CGFloat {
        text.boundingRect(
            with: CGSize(width: width, height: .greatestFiniteMagnitude),
            options: [.usesLineFragmentOrigin],
            attributes: attributes(font: font, color: .black),
            context: nil
        ).height
    }

    private static func attributes(font: UIFont, color: UIColor) -> [NSAttributedString.Key: Any] {
        let paragraph = NSMutableParagraphStyle()
        paragraph.lineBreakMode = .byWordWrapping
        paragraph.lineSpacing = 5
        return [
            .font: font,
            .foregroundColor: color,
            .paragraphStyle: paragraph
        ]
    }
}

private struct ImageTextBlock {
    var text: String
    var font: UIFont
    var color: UIColor
    var topSpacing: CGFloat

    init(_ text: String, _ font: UIFont, _ color: UIColor, topSpacing: CGFloat = 0) {
        self.text = text
        self.font = font
        self.color = color
        self.topSpacing = topSpacing
    }
}

private extension UIColor {
    static let primaryText = UIColor(red: 0.23, green: 0.16, blue: 0.11, alpha: 1.0)
    static let secondaryText = UIColor(red: 0.47, green: 0.36, blue: 0.28, alpha: 1.0)
}
