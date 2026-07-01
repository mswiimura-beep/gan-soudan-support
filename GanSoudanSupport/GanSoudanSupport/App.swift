import SwiftUI
import UIKit

@main
struct GanSoudanSupportApp: App {
    @StateObject private var store = ConsultationStore()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(store)
                .preferredColorScheme(.light)
        }
    }
}

enum AppTab: String, CaseIterable, Identifiable {
    case home
    case write
    case questions
    case info
    case settings

    var id: String { rawValue }

    @ViewBuilder
    var content: some View {
        switch self {
        case .home:
            HomeView()
        case .write:
            ConsultationEditorView()
        case .questions:
            QuestionListView()
        case .info:
            TrustedInfoView()
        case .settings:
            SettingsView()
        }
    }

    var label: Label<Text, Image> {
        switch self {
        case .home:
            Label("ホーム", systemImage: "house")
        case .write:
            Label("相談を書く", systemImage: "square.and.pencil")
        case .questions:
            Label("質問リスト", systemImage: "checklist")
        case .info:
            Label("情報", systemImage: "book.closed")
        case .settings:
            Label("設定", systemImage: "gearshape")
        }
    }
}

struct RootView: View {
    @EnvironmentObject private var store: ConsultationStore
    @State private var selectedTab: AppTab = .home

    var body: some View {
        Group {
            if store.hasAcceptedConsent {
                TabView(selection: $selectedTab) {
                    ForEach(AppTab.allCases) { tab in
                        NavigationStack {
                            tab.content
                        }
                        .tabItem { tab.label }
                        .tag(tab)
                    }
                }
                .tint(AppTheme.accent)
            } else {
                ConsentGateView()
            }
        }
    }
}


struct RootView_Previews: PreviewProvider {
    static var previews: some View {
        RootView()
            .environmentObject(ConsultationStore())
    }
}
