import SwiftUI
import FirebaseFirestore

// MARK: - NodeCard
struct NodeCard: View {
    let node: DummyNode
    var isTapped: Bool = false
    var isHeld: Bool = false
    var onTap: (() -> Void)? = nil
    var onHold: (() -> Void)? = nil
    var sizeMultiplier: CGFloat = 1.0

    private var backgroundColor: Color {
        if isHeld { return Color.blue.opacity(0.85) }
        else if isTapped { return Color.blue.opacity(0.5) }
        else { return Color(.systemBackground) }
    }
    
    private var borderColor: Color {
        if isHeld || isTapped { return Color.blue.opacity(0.6) }
        else { return Color.gray.opacity(0.2) }
    }

    var body: some View {
        VStack(spacing: 4 * sizeMultiplier) {
            Text(node.descriptionOfRecipeChanges.isEmpty ? "Recipe" : node.descriptionOfRecipeChanges)
                .font(.system(size: 13 * sizeMultiplier, weight: .semibold))
                .multilineTextAlignment(.center)
                .lineLimit(3)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.horizontal, 6 * sizeMultiplier)
            
            Text(node.currNodeID.prefix(5))
                .font(.system(size: 10 * sizeMultiplier, weight: .medium))
                .foregroundColor(.gray.opacity(0.7))
        }
        .padding(.horizontal, 8 * sizeMultiplier)
        .padding(.vertical, 10 * sizeMultiplier)
        .frame(minHeight: 70 * sizeMultiplier)
        .background(
            RoundedRectangle(cornerRadius: 12 * sizeMultiplier)
                .fill(backgroundColor)
                .overlay(
                    RoundedRectangle(cornerRadius: 12 * sizeMultiplier)
                        .stroke(borderColor, lineWidth: 1.5)
                )
                .shadow(color: .black.opacity(0.1), radius: 6, x: 0, y: 3)
        )
        .scaleEffect(isTapped ? 0.95 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isTapped)
        .onTapGesture { onTap?() }
        .onLongPressGesture(minimumDuration: 0.5) { onHold?() }
    }
}

// MARK: - Connection Views
struct SimpleArrowView: View {
    var body: some View {
        VStack(spacing: 0) {
            Rectangle()
                .fill(
                    LinearGradient(
                        colors: [Color.blue.opacity(0.4), Color.blue.opacity(0.2)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .frame(width: 2, height: 20)
            
            Triangle()
                .fill(Color.blue.opacity(0.4))
                .frame(width: 10, height: 8)
                .rotationEffect(.degrees(180))
        }
        .padding(.vertical, 8)
    }
}

struct Triangle: Shape {
    func path(in rect: CGRect) -> Path {
        var p = Path()
        p.move(to: CGPoint(x: rect.midX, y: rect.minY))
        p.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        p.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        p.closeSubpath()
        return p
    }
}

struct BranchConnectorView: View {
    var body: some View {
        GeometryReader { geo in
            Path { path in
                let width = geo.size.width
                let centerX = width / 2
                let startY: CGFloat = 0
                let endY: CGFloat = 40
                let spread: CGFloat = width * 0.35
                
                // Center line
                path.move(to: CGPoint(x: centerX, y: startY))
                path.addLine(to: CGPoint(x: centerX, y: 12))
                
                // Left branch
                path.move(to: CGPoint(x: centerX, y: 12))
                path.addQuadCurve(
                    to: CGPoint(x: centerX - spread, y: endY),
                    control: CGPoint(x: centerX - spread/2, y: 20)
                )
                
                // Right branch
                path.move(to: CGPoint(x: centerX, y: 12))
                path.addQuadCurve(
                    to: CGPoint(x: centerX + spread, y: endY),
                    control: CGPoint(x: centerX + spread/2, y: 20)
                )
            }
            .stroke(
                LinearGradient(
                    colors: [Color.blue.opacity(0.5), Color.blue.opacity(0.25)],
                    startPoint: .top,
                    endPoint: .bottom
                ),
                style: StrokeStyle(lineWidth: 2, lineCap: .round, lineJoin: .round)
            )
        }
        .frame(height: 40)
        .padding(.vertical, 12)
    }
}

// MARK: - Section Header
struct SectionHeaderView: View {
    let title: String
    
    var body: some View {
        HStack(spacing: 8) {
            Rectangle()
                .fill(Color.blue.opacity(0.3))
                .frame(height: 1)
            
            Text(title)
                .font(.system(size: 11, weight: .semibold))
                .foregroundColor(.gray)
                .textCase(.uppercase)
                .tracking(0.5)
            
            Rectangle()
                .fill(Color.blue.opacity(0.3))
                .frame(height: 1)
        }
        .padding(.horizontal, 40)
        .padding(.vertical, 8)
    }
}

// MARK: - Circular Carousel
struct CircularCarouselView: View {
    var nodes: [DummyNode]
    var tappedNodeID: String?
    var heldNodeID: String?
    var onNodeTap: ((DummyNode) -> Void)?
    var onNodeHold: ((DummyNode) -> Void)?
    var onCenterNodeChange: ((DummyNode?) -> Void)?
    @State private var rotation: CGFloat = 0
    @State private var dragOffset: CGFloat = 0
    @ObservedObject private var inertia = InertiaController()
    
    private var centeredNode: DummyNode? {
        guard !nodes.isEmpty else { return nil }
        let totalRotation = rotation + dragOffset
        let normalizedRotation = totalRotation.truncatingRemainder(dividingBy: 360)
        let adjustedRotation = normalizedRotation < 0 ? normalizedRotation + 360 : normalizedRotation
        let anglePerNode = 360.0 / CGFloat(nodes.count)
        let centeredIndex = Int(round(adjustedRotation / anglePerNode)) % nodes.count
        return nodes[centeredIndex]
    }

    var body: some View {
        GeometryReader { geo in
            let radius = min(geo.size.width / 2.5, 140)
            ZStack {
                ForEach(Array(nodes.enumerated()), id: \.1.currNodeID) { index, node in
                    let angle = (CGFloat(index) / CGFloat(nodes.count)) * 360 + rotation + dragOffset
                    let xOffset = cos(angle * .pi / 180) * radius
                    let zOffset = sin(angle * .pi / 180) * radius
                    let scale = 0.7 + 0.3 * ((zOffset / radius) + 1) / 2
                    let opacity = 0.4 + 0.6 * ((zOffset / radius) + 1) / 2
                    
                    NodeCard(
                        node: node,
                        isTapped: tappedNodeID == node.currNodeID,
                        isHeld: heldNodeID == node.currNodeID,
                        onTap: { onNodeTap?(node) },
                        onHold: { onNodeHold?(node) }
                    )
                    .frame(width: 95, height: 90)
                    .scaleEffect(scale)
                    .opacity(opacity)
                    .offset(x: xOffset)
                    .zIndex(zOffset)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
            .gesture(
                DragGesture()
                    .onChanged { value in
                        dragOffset = -value.translation.width / 8
                    }
                    .onEnded { value in
                        rotation += dragOffset
                        dragOffset = 0
                        inertia.start(with: -value.predictedEndTranslation.width / 8) { delta in
                            rotation += delta
                        }
                    }
            )
            .onChange(of: centeredNode?.currNodeID) { newNodeID in
                onCenterNodeChange?(centeredNode)
            }
        }
        .frame(height: 180)
    }

    class InertiaController: ObservableObject {
        private var velocity: CGFloat = 0
        private var displayLink: CADisplayLink?
        private var update: ((CGFloat) -> Void)?
        
        func start(with initialVelocity: CGFloat, update: @escaping (CGFloat) -> Void) {
            stop()
            velocity = initialVelocity
            self.update = update
            displayLink = CADisplayLink(target: self, selector: #selector(tick))
            displayLink?.add(to: .main, forMode: .common)
        }
        
        @objc private func tick() {
            let damping: CGFloat = 0.92
            velocity *= damping
            if abs(velocity) < 0.1 {
                stop()
            } else {
                update?(velocity * 0.016)
            }
        }
        
        func stop() {
            displayLink?.invalidate()
            displayLink = nil
            velocity = 0
        }
    }
}
// MARK: - RemixTreeView
struct RemixTreeView: View {
    let nodeID: String
    
    @ObservedObject private var data = RemixData.shared
    @State private var tappedNodeID: String?
    @State private var heldNodeID: String?
    @State private var navigateToNode: DummyNode?
    @State private var navigateToPostID: String?
    @State private var centeredFirstLayerNode: DummyNode?
    
    private var currentNodeID: String { nodeID }
    
    private var currentNode: DummyNode? {
        data.nodes.first { $0.currNodeID == currentNodeID }
    }
    
    private var parentNode: DummyNode? {
        guard let node = currentNode else { return nil }
        return data.nodes.first { $0.currNodeID == node.parentNodeID }
    }
    
    private var firstLayerChildren: [DummyNode] {
        guard let node = currentNode else { return [] }
        return data.nodes.filter { $0.parentNodeID == node.currNodeID }
    }
    
    private var secondLayerChildren: [DummyNode] {
        guard let centeredNode = centeredFirstLayerNode else { return [] }
        return data.nodes.filter { $0.parentNodeID == centeredNode.currNodeID }
    }

    var body: some View {
        GeometryReader { geo in
            ScrollView {
                VStack(spacing: 0) {
                    // Parent node section
                    if let parent = parentNode {
                        VStack(spacing: 0) {
                            Text("ORIGINAL")
                                .font(.system(size: 10, weight: .semibold))
                                .foregroundColor(.gray.opacity(0.6))
                                .tracking(1)
                                .padding(.top, 16)
                                .padding(.bottom, 8)
                            
                            NodeCard(
                                node: parent,
                                onTap: { navigateToNode = parent },
                                onHold: { navigateToPostID = parent.currNodeID },
                                sizeMultiplier: 0.7
                            )
                            .frame(maxWidth: 100)
                            
                            SimpleArrowView()
                        }
                    }

                    // Current node
                    if let node = currentNode {
                        VStack(spacing: 0) {
                            if parentNode != nil {
                                Text("THIS RECIPE")
                                    .font(.system(size: 10, weight: .semibold))
                                    .foregroundColor(.blue.opacity(0.7))
                                    .tracking(1)
                                    .padding(.bottom, 8)
                            }
                            
                            NodeCard(
                                node: node,
                                isTapped: tappedNodeID == node.currNodeID,
                                isHeld: heldNodeID == node.currNodeID,
                                onTap: { navigateToNode = node },
                                onHold: { navigateToPostID = node.currNodeID }
                            )
                            .frame(maxWidth: 120)
                            .padding(.horizontal, 20)
                        }
                        .padding(.vertical, parentNode == nil ? 20 : 0)
                    }

                    // First layer children
                    if !firstLayerChildren.isEmpty {
                        VStack(spacing: 0) {
                            BranchConnectorView()
                            
                            Text("REMIXES")
                                .font(.system(size: 10, weight: .semibold))
                                .foregroundColor(.gray.opacity(0.6))
                                .tracking(1)
                                .padding(.bottom, 12)
                            
                            layerView(nodes: firstLayerChildren, layerIndex: 1)
                        }
                        .padding(.top, 8)
                    }

                    // Second layer children (of centered first layer node)
                    if !secondLayerChildren.isEmpty {
                        VStack(spacing: 0) {
                            BranchConnectorView()
                            
                            Text("REMIXES OF REMIXES")
                                .font(.system(size: 10, weight: .semibold))
                                .foregroundColor(.gray.opacity(0.6))
                                .tracking(1)
                                .padding(.bottom, 12)
                            
                            layerView(nodes: secondLayerChildren, layerIndex: 2)
                                .id(centeredFirstLayerNode?.currNodeID ?? "")
                                .transition(.opacity)
                        }
                        .padding(.top, 8)
                        .padding(.bottom, 20)
                    }
                }
                .frame(maxWidth: .infinity, minHeight: geo.size.height)
                .animation(.easeInOut(duration: 0.3), value: centeredFirstLayerNode?.currNodeID)
            }
        }
        .background(Color(.systemGroupedBackground).ignoresSafeArea())
        .background(navigationLinks)
        .onAppear {
            data.startListening()
            // Set initial centered node
            if centeredFirstLayerNode == nil {
                centeredFirstLayerNode = firstLayerChildren.first
            }
        }
        .onDisappear { data.stopListening() }
    }

    // MARK: - Layer view
    @ViewBuilder
    private func layerView(nodes: [DummyNode], layerIndex: Int) -> some View {
        if nodes.count >= 3 {
            CircularCarouselView(
                nodes: nodes,
                tappedNodeID: tappedNodeID,
                heldNodeID: heldNodeID,
                onNodeTap: handleTap,
                onNodeHold: handleHold,
                onCenterNodeChange: { centeredNode in
                    if layerIndex == 1 {
                        centeredFirstLayerNode = centeredNode
                    }
                }
            )
        } else {
            HStack(spacing: nodes.count == 1 ? 0 : 20) {
                ForEach(nodes) { node in
                    NodeCard(
                        node: node,
                        isTapped: tappedNodeID == node.currNodeID,
                        isHeld: heldNodeID == node.currNodeID,
                        onTap: { handleTap(node: node) },
                        onHold: { handleHold(node: node) }
                    )
                    .frame(width: nodes.count == 1 ? 120 : 100)
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 110)
            .padding(.horizontal, 20)
        }
    }

    // MARK: - Navigation
    private var navigationLinks: some View {
        Group {
            NavigationLink(
                destination: Group {
                    if let node = navigateToNode {
                        RemixTreeView(nodeID: node.currNodeID)
                    }
                },
                isActive: Binding(
                    get: { navigateToNode != nil },
                    set: { if !$0 { navigateToNode = nil } }
                )
            ) {
                EmptyView()
            }

            NavigationLink(
                destination: Group {
                    if let postID = navigateToPostID {
                        DummyRemixPostView(postID: postID)
                    }
                },
                isActive: Binding(
                    get: { navigateToPostID != nil },
                    set: { if !$0 { navigateToPostID = nil } }
                )
            ) {
                EmptyView()
            }
        }
    }

    // MARK: - Tap/Hold handlers
    private func handleTap(node: DummyNode) {
        tappedNodeID = node.currNodeID
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            tappedNodeID = nil
            navigateToNode = node
        }
    }

    private func handleHold(node: DummyNode) {
        heldNodeID = node.currNodeID
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
            navigateToPostID = node.currNodeID
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            heldNodeID = nil
        }
    }
}

// MARK: - Dummy Post View
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
        .background(Color(.systemBackground))
        .navigationTitle("Post \(postID.prefix(5))")
    }
}

#Preview {
    NavigationView {
        RemixTreeView(nodeID: "10B7EA20-D316-4607-A9D6-401FC751A1AA")
    }
}
