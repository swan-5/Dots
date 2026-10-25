import SwiftUI

/// Renders a mapped constellation: reference lines, filled star anchors (with the real
/// Dot behind each one), and dim unfilled placeholders when the group is partial.
/// Tapping a filled star calls `onSelectDot` with the underlying Dot.
struct ConstellationCanvasView: View {
    let mapping: ConstellationMapper.MappingResult
    var onSelectDot: ((Dot) -> Void)?

    @State private var hasAppeared = false
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        GeometryReader { proxy in
            let size = proxy.size
            ZStack {
                linesLayer(size: size)
                    .opacity(hasAppeared ? 1 : 0)
                    .animation(.easeOut(duration: reduceMotion ? 0 : 0.35).delay(reduceMotion ? 0 : 0.35), value: hasAppeared)

                ForEach(mapping.unfilledAnchors, id: \.id) { anchor in
                    placeholderStar
                        .position(point(for: anchor, in: size))
                        .accessibilityHidden(true)
                }

                ForEach(mapping.assignments) { assignment in
                    starButton(for: assignment)
                        .position(point(for: assignment.anchor, in: size))
                }
            }
            .onAppear {
                withAnimation(.easeOut(duration: reduceMotion ? 0 : 0.5)) {
                    hasAppeared = true
                }
            }
        }
    }

    private func point(for anchor: ConstellationStarAnchor, in size: CGSize) -> CGPoint {
        CGPoint(x: anchor.x * size.width, y: anchor.y * size.height)
    }

    private func linesLayer(size: CGSize) -> some View {
        Canvas { context, _ in
            for line in mapping.template.lines {
                guard let from = mapping.template.anchor(withID: line.fromAnchorID),
                      let to = mapping.template.anchor(withID: line.toAnchorID) else { continue }
                var path = Path()
                path.move(to: point(for: from, in: size))
                path.addLine(to: point(for: to, in: size))
                context.stroke(path, with: .color(DotsColor.connector), lineWidth: 1)
            }
        }
    }

    private var placeholderStar: some View {
        Circle()
            .fill(Color.white.opacity(0.12))
            .frame(width: 6, height: 6)
    }

    private func starButton(for assignment: ConstellationMapper.AssignedAnchor) -> some View {
        Button {
            onSelectDot?(assignment.dot)
        } label: {
            ZStack {
                Circle()
                    .fill(DotsColor.lavender.opacity(0.35))
                    .frame(width: 22, height: 22)
                    .blur(radius: 4)
                Circle()
                    .fill(Color.white)
                    .frame(width: 8, height: 8)
            }
            .scaleEffect(hasAppeared ? 1 : 0.4)
            .opacity(hasAppeared ? 1 : 0)
            .animation(.spring(response: 0.5, dampingFraction: 0.8), value: hasAppeared)
        }
        .buttonStyle(.plain)
        .accessibilityLabel("\(assignment.dot.title), \(assignment.anchor.starName)")
        .accessibilityHint("탭하면 경험의 날짜와 세부 내용을 볼 수 있어요")
    }
}
