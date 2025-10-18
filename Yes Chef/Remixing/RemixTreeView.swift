import SwiftUI
import Foundation
import FirebaseFirestore

// MARK: - Wrapper for Identifiable
class UniqueNode: Identifiable {
    let node: DummyNode
    let id: String
    
    init(_ node: DummyNode) {
        self.node = node
        self.id = node.currNodeID
    }
}

// MARK: - Tree Structure
struct Tree<A> {
    var value: A
    var children: [Tree<A>] = []
    
    init(_ value: A, children: [Tree<A>] = []) {
        self.value = value
        self.children = children
    }
    
    func map<B>(_ transform: (A) -> B) -> Tree<B> {
        Tree<B>(
            transform(value),
            children: children.map { $0.map(transform) }
        )
    }
}

// MARK: - Diagram View (Recursive)
struct Diagram<A: Identifiable, V: View>: View {
    let tree: Tree<A>
    let nodeView: (A) -> V
    typealias Key = CollectDict<A.ID, Anchor<CGPoint>>
    
    var body: some View {
        VStack(alignment: .center, spacing: 60) {
            nodeView(tree.value)
                .anchorPreference(key: Key.self, value: .center) { [tree.value.id: $0] }
            
            HStack(alignment: .top, spacing: 60) {
                ForEach(tree.children, id: \.value.id) { child in
                    Diagram(tree: child, nodeView: nodeView)
                }
            }
        }
        .backgroundPreferenceValue(Key.self) { centers in
            GeometryReader { proxy in
                ZStack {
                    ForEach(tree.children, id: \.value.id) { child in
                        if let fromAnchor = centers[tree.value.id],
                           let toAnchor = centers[child.value.id] {
                            Line(from: proxy[fromAnchor], to: proxy[toAnchor])
                                .stroke(
                                    LinearGradient(
                                        colors: [Color.blue.opacity(0.4), Color.blue.opacity(0.2)],
                                        startPoint: .top,
                                        endPoint: .bottom
                                    ),
                                    style: StrokeStyle(lineWidth: 2, lineCap: .round)
                                )
                        }
                    }
                }
            }
        }
    }
}

// MARK: - PreferenceKey
struct CollectDict<Key: Hashable, Value>: PreferenceKey {
    static var defaultValue: [Key: Value] { [:] }
    static func reduce(value: inout [Key: Value], nextValue: () -> [Key: Value]) {
        value.merge(nextValue(), uniquingKeysWith: { $1 })
    }
}

// MARK: - Line Shape
struct Line: Shape {
    var from: CGPoint
    var to: CGPoint
    
    var animatableData: AnimatablePair<
        AnimatablePair<CGFloat, CGFloat>,
        AnimatablePair<CGFloat, CGFloat>
    > {
        get {
            AnimatablePair(
                AnimatablePair(from.x, from.y),
                AnimatablePair(to.x, to.y)
            )
        }
        set {
            from = CGPoint(x: newValue.first.first, y: newValue.first.second)
            to = CGPoint(x: newValue.second.first, y: newValue.second.second)
        }
    }
    
    func path(in rect: CGRect) -> Path {
        Path { path in
            path.move(to: from)
            path.addLine(to: to)
        }
    }
}

// MARK: - Node Card View
struct NodeCard: View {
    let node: DummyNode
    var onFrameChange: ((CGRect) -> Void)? = nil
    var isTapped: Bool = false
    var isHeld: Bool = false

    private var backgroundColor: Color {
        if isHeld { return Color.blue.opacity(0.8) }       // dark blue for hold
        else if isTapped { return Color.blue.opacity(0.4) } // light blue for tap
        else { return Color.white }
    }
    
    var body: some View {
        VStack(spacing: 6) {
            Text(node.descriptionOfRecipeChanges.isEmpty ? "Recipe" : node.descriptionOfRecipeChanges)
                .font(.callout)
                .fontWeight(.semibold)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 8)
            
            Text(node.currNodeID.prefix(5))
                .font(.caption2)
                .foregroundColor(.gray)
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(backgroundColor)
                .shadow(color: Color.black.opacity(0.15), radius: 6, x: 0, y: 4)
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(Color.blue.opacity(0.4), lineWidth: 1)
                )
        )
        .background(
            GeometryReader { proxy in
                Color.clear
                    .onChange(of: proxy.frame(in: .global)) { newFrame in
                        onFrameChange?(newFrame)
                    }
            }
        )
    }
}

// MARK: - Pinch + Pan + Tap + Hold Recognizer
struct PinchPanRecognizerView: UIViewRepresentable {
    @Binding var scale: CGFloat
    @Binding var offset: CGSize
    @Binding var lastPinchLocation: CGPoint?
    
    var nodeFrames: [String: CGRect] = [:]
    var onNodeTap: ((String) -> Void)? = nil
    var onNodeHold: ((String) -> Void)? = nil
    
    var minScale: CGFloat = 0.5
    var maxScale: CGFloat = 3.0
    var onEndGesture: (() -> Void)? = nil
    
    func makeUIView(context: Context) -> UIView {
        let view = UIView()
        view.backgroundColor = .clear
        view.isUserInteractionEnabled = true
        
        let pinch = UIPinchGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handlePinch(_:)))
        let pan = UIPanGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handlePan(_:)))
        let tap = UITapGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handleTap(_:)))
        let hold = UILongPressGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handleHold(_:)))
        
        pinch.delegate = context.coordinator
        pan.delegate = context.coordinator
        tap.delegate = context.coordinator
        hold.delegate = context.coordinator
        hold.minimumPressDuration = 0.5
        
        [pinch, pan, tap, hold].forEach { view.addGestureRecognizer($0) }
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
        context.coordinator.nodeFrames = nodeFrames
    }
    
    func makeCoordinator() -> Coordinator { Coordinator(self) }
    
    class Coordinator: NSObject, UIGestureRecognizerDelegate {
        var parent: PinchPanRecognizerView
        var nodeFrames: [String: CGRect] = [:]
        private var lastScale: CGFloat = 1.0
        private var startOffset: CGPoint = .zero
        private var velocity: CGSize = .zero
        private var displayLink: CADisplayLink?
        
        init(_ parent: PinchPanRecognizerView) { self.parent = parent }
        
        @objc func handlePinch(_ gr: UIPinchGestureRecognizer) {
            switch gr.state {
            case .began:
                stopInertia(); lastScale = parent.scale
            case .changed:
                guard let view = gr.view else { return }
                let loc = gr.location(in: view)
                parent.lastPinchLocation = loc
                var newScale = lastScale * gr.scale
                newScale = clamp(newScale, min: parent.minScale, max: parent.maxScale)
                parent.scale = newScale
            case .ended, .cancelled:
                parent.onEndGesture?()
            default: break
            }
        }
        
        @objc func handlePan(_ gr: UIPanGestureRecognizer) {
            switch gr.state {
            case .began:
                stopInertia(); startOffset = CGPoint(x: parent.offset.width, y: parent.offset.height)
            case .changed:
                let translation = gr.translation(in: gr.view)
                parent.offset = CGSize(width: startOffset.x + translation.x, height: startOffset.y + translation.y)
            case .ended:
                velocity = CGSize(width: gr.velocity(in: gr.view).x, height: gr.velocity(in: gr.view).y)
                startInertia(); parent.onEndGesture?()
            default: break
            }
        }
        
        @objc func handleTap(_ gr: UITapGestureRecognizer) {
            guard let view = gr.view else { return }
            let tapLoc = gr.location(in: view)
            let global = view.convert(tapLoc, to: nil)
            for (id, frame) in nodeFrames where frame.contains(global) {
                parent.onNodeTap?(id)
                break
            }
        }
        
        @objc func handleHold(_ gr: UILongPressGestureRecognizer) {
            guard gr.state == .began, let view = gr.view else { return }
            let loc = gr.location(in: view)
            let global = view.convert(loc, to: nil)
            for (id, frame) in nodeFrames where frame.contains(global) {
                parent.onNodeHold?(id)
                break
            }
        }
        
        private func startInertia() {
            stopInertia()
            displayLink = CADisplayLink(target: self, selector: #selector(inertiaStep))
            displayLink?.add(to: .main, forMode: .common)
        }
        
        private func stopInertia() {
            displayLink?.invalidate()
            displayLink = nil
        }
        
        @objc private func inertiaStep() {
            let friction: CGFloat = 0.90
            velocity.width *= friction
            velocity.height *= friction
            if abs(velocity.width) < 0.5 && abs(velocity.height) < 0.5 {
                stopInertia(); return
            }
            parent.offset = CGSize(
                width: parent.offset.width + velocity.width / 60,
                height: parent.offset.height + velocity.height / 60
            )
        }
        
        func gestureRecognizer(_ g1: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith g2: UIGestureRecognizer) -> Bool { true }
        private func clamp(_ v: CGFloat, min: CGFloat, max: CGFloat) -> CGFloat { Swift.min(Swift.max(v, min), max) }
    }
}

// MARK: - RemixTreeView
struct RemixTreeView: View {
    @StateObject private var data = RemixData()
    @State private var currentRootNode: DummyNode? = nil
    @State private var scale: CGFloat = 1.0
    @State private var offset: CGSize = .zero
    @State private var nodeCenters: [String: CGRect] = [:]
    @State private var lastPinchLocation: CGPoint? = nil
    @State private var isLoading: Bool = false
    @State private var hasZoomedIntoNode: Bool = false
    @State private var tappedNodeID: String? = nil
    @State private var heldNodeID: String? = nil
    @State private var navigateToNode: DummyNode? = nil
    @State private var navigateToPostID: String? = nil
    
    var enteredByTap: Bool = false
    
    init(rootNode: DummyNode? = nil, enteredByTap: Bool = false) {
        self._currentRootNode = State(initialValue: rootNode)
        self.enteredByTap = enteredByTap
    }
    
    var trees: [Tree<UniqueNode>] {
        if let root = currentRootNode {
            return [buildTree(root)]
        }
        let roots = data.nodes.filter { $0.parentNodeID == "none" }
        return roots.map { buildTree($0) }
    }
    
    func buildTree(_ node: DummyNode) -> Tree<UniqueNode> {
        let children = data.nodes.filter { $0.parentNodeID == node.currNodeID }
        return Tree(UniqueNode(node), children: children.map { buildTree($0) })
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                GeometryReader { geo in
                    ScrollView([.vertical, .horizontal], showsIndicators: false) {
                        ZStack(alignment: .top) {
                            VStack(spacing: 120) {
                                ForEach(trees.indices, id: \.self) { index in
                                    Diagram(tree: trees[index]) { uniqueNode in
                                        NodeCard(
                                            node: uniqueNode.node,
                                            onFrameChange: { newFrame in
                                                nodeCenters[uniqueNode.node.currNodeID] = newFrame
                                            },
                                            isTapped: tappedNodeID == uniqueNode.node.currNodeID,
                                            isHeld: heldNodeID == uniqueNode.node.currNodeID
                                        )
                                    }
                                }
                            }
                            .padding(60)
                            .scaleEffect(scale)
                            .offset(offset)
                            .frame(minWidth: geo.size.width, minHeight: geo.size.height)
                        }
                        .onAppear { data.startListening() }
                        .onDisappear { data.stopListening() }
                    }
                    
                    PinchPanRecognizerView(
                        scale: $scale,
                        offset: $offset,
                        lastPinchLocation: $lastPinchLocation,
                        nodeFrames: nodeCenters,
                        onNodeTap: { id in
                            tappedNodeID = id
                            heldNodeID = nil
                            if let node = data.nodes.first(where: { $0.currNodeID == id }) {
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                                    navigateToNode = node
                                }
                            }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                tappedNodeID = nil
                            }
                        },
                        onNodeHold: { id in
                            heldNodeID = id
                            tappedNodeID = nil
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                                navigateToPostID = id
                            }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                heldNodeID = nil
                            }
                        },
                        onEndGesture: { handleZoom(geo) }
                    )
                    .frame(width: geo.size.width, height: geo.size.height)
                }
                
                if isLoading {
                    VStack {
                        Spacer()
                        ProgressView("Loading tree...")
                            .progressViewStyle(CircularProgressViewStyle())
                            .scaleEffect(1.5)
                        Spacer()
                    }
                    .background(Color.white.opacity(0.5))
                }
            }
            .animation(.easeInOut(duration: 0.4), value: currentRootNode?.currNodeID)
            // Tap navigation → subtree
            .navigationDestination(item: $navigateToNode) { node in
                RemixTreeView(rootNode: node, enteredByTap: true)
            }
            // Hold navigation → DummyRemixPostView
            .navigationDestination(item: $navigateToPostID) { id in
                DummyRemixPostView(postID: id)
            }
        }
    }
    
    private func handleZoom(_ geo: GeometryProxy) {
        if scale > 2.0, !hasZoomedIntoNode {
            if let node = mostVisibleNode(in: geo),
               let targetNode = nearestParentWithChildren(for: node) {
                animateZoomInto(node: targetNode, in: geo)
                hasZoomedIntoNode = true
            }
        } else if scale < 0.75, !enteredByTap {
            zoomOutToRoot()
        }
    }
    
    private func zoomOutToRoot() {
        withAnimation(.easeInOut(duration: 0.5)) {
            currentRootNode = nil
            scale = 1
            offset = .zero
        }
    }
    
    private func nearestParentWithChildren(for node: DummyNode) -> DummyNode? {
        var current = node
        while true {
            let children = data.nodes.filter { $0.parentNodeID == current.currNodeID }
            if !children.isEmpty { return current }
            if let parent = data.nodes.first(where: { $0.currNodeID == current.parentNodeID }) {
                current = parent
            } else { return nil }
        }
        return nil
    }
    
    private func mostVisibleNode(in geo: GeometryProxy) -> DummyNode? {
        var maxArea: CGFloat = 0
        var best: DummyNode? = nil
        for node in data.nodes {
            guard let frame = nodeCenters[node.currNodeID] else { continue }
            let scaled = CGRect(
                x: frame.minX * scale + offset.width,
                y: frame.minY * scale + offset.height,
                width: frame.width * scale,
                height: frame.height * scale
            )
            let visible = geo.frame(in: .global)
            let intersection = scaled.intersection(visible)
            let area = intersection.width * intersection.height
            if area > maxArea { maxArea = area; best = node }
        }
        return best
    }
    
    private func animateZoomInto(node: DummyNode, in geo: GeometryProxy) {
        guard let frame = nodeCenters[node.currNodeID] else { return }
        let viewportCenter = CGPoint(x: geo.size.width / 2, y: geo.size.height / 2)
        let nodeCenter = CGPoint(
            x: frame.midX * scale + offset.width,
            y: frame.midY * scale + offset.height
        )
        let deltaX = viewportCenter.x - nodeCenter.x
        let deltaY = viewportCenter.y - nodeCenter.y
        
        withAnimation(.easeInOut(duration: 0.4)) {
            offset.width += deltaX
            offset.height += deltaY
            scale = 2.5
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.45) {
            withAnimation(.easeInOut(duration: 0.5)) {
                let children = data.nodes.filter { $0.parentNodeID == node.currNodeID }
                if !children.isEmpty {
                    currentRootNode = node
                    scale = 1
                    offset = .zero
                }
            }
        }
    }
}

private extension CGRect {
    var center: CGPoint { CGPoint(x: midX, y: midY) }
}

// MARK: - DummyRemixPostView
struct DummyRemixPostView: View {
    let postID: String
    
    var body: some View {
        VStack {
            Spacer()
            Text("Dummy Post View For Post with ID \(postID)")
                .font(.title2)
                .multilineTextAlignment(.center)
                .padding()
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemBackground))
        .navigationTitle("Post \(postID.prefix(5))")
    }
}

#Preview {
    RemixTreeView()
}
