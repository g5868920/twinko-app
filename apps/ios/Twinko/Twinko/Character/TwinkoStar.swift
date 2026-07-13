import SwiftUI

/// The Twinko silhouette: a rounded five-point star with soft, full
/// proportions and no sharp points (Brand Character Guide §3). Corner
/// rounding is applied with tangent arcs at every outer tip and inner
/// valley so the outline reads plush rather than geometric.
struct TwinkoStar: Shape {
    /// Inner-vertex radius as a fraction of the outer radius. Higher
    /// values make the star fuller; the reference art is quite plump.
    var innerRatio: CGFloat = 0.50
    /// Tip rounding as a fraction of the outer radius.
    var tipRounding: CGFloat = 0.14
    /// Valley rounding as a fraction of the outer radius.
    var valleyRounding: CGFloat = 0.10

    func path(in rect: CGRect) -> Path {
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let outer = min(rect.width, rect.height) / 2
        let inner = outer * innerRatio

        var vertices: [(point: CGPoint, radius: CGFloat)] = []
        for i in 0..<10 {
            let angle = (CGFloat(i) * .pi / 5) - .pi / 2
            let r = i.isMultiple(of: 2) ? outer : inner
            let rounding = i.isMultiple(of: 2) ? outer * tipRounding : outer * valleyRounding
            vertices.append((
                CGPoint(x: center.x + cos(angle) * r, y: center.y + sin(angle) * r),
                rounding
            ))
        }

        var path = Path()
        let last = vertices[vertices.count - 1].point
        let first = vertices[0].point
        path.move(to: CGPoint(x: (last.x + first.x) / 2, y: (last.y + first.y) / 2))

        for i in 0..<vertices.count {
            let current = vertices[i]
            let next = vertices[(i + 1) % vertices.count].point
            let mid = CGPoint(x: (current.point.x + next.x) / 2, y: (current.point.y + next.y) / 2)
            path.addArc(tangent1End: current.point, tangent2End: mid, radius: current.radius)
        }
        path.closeSubpath()
        return path
    }
}

#Preview {
    TwinkoStar()
        .fill(Color.twinkoGold)
        .frame(width: 240, height: 240)
        .padding()
}
