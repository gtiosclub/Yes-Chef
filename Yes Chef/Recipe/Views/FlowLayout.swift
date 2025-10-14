//
//  FlowLayougt.swift
//  Yes Chef
//
//  Created by Krish Prasad on 10/10/25.
//
import SwiftUI

public struct FlowLayout: Layout {
    @State var verticalSpacing: CGFloat
    @State var horizontalSpacing: CGFloat
    
    public init(verticalSpacing: CGFloat = 8, horizontalSpacing: CGFloat = 8) {
        self.verticalSpacing = verticalSpacing
        self.horizontalSpacing = horizontalSpacing
    }

    public func sizeThatFits(
        proposal: ProposedViewSize,
        subviews: Subviews,
        cache: inout Void
    ) -> CGSize {
        if let w = proposal.width, w > 0 {
            let h = coordinates(boundsWidth: w, proposal: proposal, subviews: subviews).reduce(0, { max($0, $1.maxY) })
            return CGSize(width: w, height: h)
        }

        return proposal.replacingUnspecifiedDimensions()
    }

    private func coordinates(boundsWidth: CGFloat, proposal: ProposedViewSize, subviews: Subviews) -> [CGRect] {
        var x: CGFloat = 0
        var y: CGFloat = 0
        var rowHeight: CGFloat = 0

        var rectangles = [CGRect]()

        for (_, subview) in subviews.enumerated() {
            let viewDimensions = subview.dimensions(in: proposal)

            if x > 0, x + viewDimensions.width > boundsWidth {
                y += rowHeight + verticalSpacing
                x = 0
                rowHeight = 0
            }

            rowHeight = max(rowHeight, viewDimensions.height)

            rectangles.append(CGRect(x: x, y: y, width: viewDimensions.width, height: viewDimensions.height))

            x += viewDimensions.width + horizontalSpacing
        }

        return rectangles
    }

    public func placeSubviews(
        in bounds: CGRect,
        proposal: ProposedViewSize,
        subviews: Subviews,
        cache: inout Void
    ) {

        var x: CGFloat = 0
        var y: CGFloat = 0
        var rowHeight: CGFloat = 0

        for (_, subview) in subviews.enumerated() {
            let viewDimensions = subview.dimensions(in: proposal)

            if x > 0, x + viewDimensions.width > bounds.width {
                y += rowHeight + verticalSpacing
                x = 0
                rowHeight = 0
            }

            rowHeight = max(rowHeight, viewDimensions.height)

            var point = CGPoint(x: bounds.minX + x, y: bounds.minY + y)
            point.x += viewDimensions.width / 2
            point.y += viewDimensions.height / 2

            subview.place(at: point, anchor: .center, proposal: .unspecified)

            x += viewDimensions.width + horizontalSpacing
        }
    }
}
