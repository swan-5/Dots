import SwiftUI

struct OnboardingView: View {
    let onFinish: () -> Void

    @State private var pageIndex = 0
    @State private var isPresentingFirstDot = false

    private struct Page {
        let symbol: String
        let title: String
        let body: String
    }

    private let pages = [
        Page(symbol: "circle.fill", title: "모든 경험은 하나의 점이에요", body: "작은 성공, 실패, 배움 — 그 어떤 경험도 하나의 \"Dot\"로 남길 수 있어요."),
        Page(symbol: "list.bullet.rectangle", title: "점들은 시간순으로 쌓여요", body: "타임라인에서 내가 겪은 일들을 날짜 그대로 다시 볼 수 있어요."),
        Page(symbol: "sparkles", title: "점을 이어 별자리를 만들어요", body: "의미 있다고 느껴지는 경험들을 골라 연결하고, 실제 별자리 모양으로 묶어보세요.")
    ]

    var body: some View {
        ZStack(alignment: .bottom) {
            TabView(selection: $pageIndex) {
                ForEach(Array(pages.enumerated()), id: \.offset) { index, page in
                    pageView(page)
                        .tag(index)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .always))

            VStack(spacing: DotsSpacing.md) {
                if pageIndex < pages.count - 1 {
                    HStack {
                        Button("건너뛰기") { onFinish() }
                            .foregroundStyle(DotsColor.mutedSlate)
                        Spacer()
                        Button("다음") { withAnimation { pageIndex += 1 } }
                            .buttonStyle(.borderedProminent)
                            .tint(DotsColor.periwinkle)
                    }
                } else {
                    Button("첫 경험 기록하기") { isPresentingFirstDot = true }
                        .buttonStyle(.borderedProminent)
                        .tint(DotsColor.periwinkle)
                        .frame(maxWidth: .infinity)
                    Button("나중에 할게요") { onFinish() }
                        .foregroundStyle(DotsColor.mutedSlate)
                }
            }
            .padding(DotsSpacing.lg)
        }
        .sheet(isPresented: $isPresentingFirstDot, onDismiss: onFinish) {
            DotEditorView(mode: .create)
        }
    }

    private func pageView(_ page: Page) -> some View {
        VStack(spacing: DotsSpacing.lg) {
            Spacer()
            Image(systemName: page.symbol)
                .font(.system(size: 54))
                .foregroundStyle(DotsColor.periwinkle)
            Text(page.title)
                .font(.system(size: 22, weight: .semibold))
                .multilineTextAlignment(.center)
            Text(page.body)
                .font(.system(size: 15))
                .foregroundStyle(DotsColor.mutedSlate)
                .multilineTextAlignment(.center)
                .padding(.horizontal, DotsSpacing.lg)
            Spacer()
            Spacer()
        }
        .padding(DotsSpacing.lg)
    }
}
