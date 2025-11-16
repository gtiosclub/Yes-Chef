import SwiftUI
import FirebaseFirestore

// Eesh New Edit: Updated documentation to reflect use of FirebaseRemixTreeNode
/**
 * RemixTreeView displays the remix tree structure using real data from Firebase.
 *
 * This view uses FirebaseRemixTreeNode (a wrapper around RemixTreeNode) which
 * connects to Firebase's "realRemixTreeNodes" collection via RemixData.shared.
 *
 * Features:
 * - Real-time updates from Firestore
 * - Displays parent, current, and child nodes
 * - Tap node to navigate to its RemixTreeView
 * - Long-press node to view the recipe details
 * - 3D carousel for multiple remixes
 */
// End of Eesh New Edit

// MARK: - NodeCard
struct NodeCard: View {
    // Eesh New Edit: Changed to use FirebaseRemixTreeNode
    let node: FirebaseRemixTreeNode
    // End of Eesh New Edit
    var isTapped: Bool = false
    var isHeld: Bool = false
    var onTap: (() -> Void)? = nil
    var onHold: (() -> Void)? = nil
    var sizeMultiplier: CGFloat = 1.0
    var showImage: Bool = true
    @State private var recipeName: String? = nil
    @State private var recipeDescription: String? = nil

    private var backgroundColor: Color {
        if isHeld { return Color.blue.opacity(0.85) }
        else if isTapped { return Color.blue.opacity(0.5) }
        else { return Color(.systemBackground) }
    }
    
    private var borderColor: Color {
        if isHeld || isTapped { return Color.blue.opacity(0.6) }
        else { return Color.gray.opacity(0.2) }
    }
    
    private var shadowColor: Color {
        let opacity = isHeld ? 0.3 : (isTapped ? 0.2 : 0.15)
        return .black.opacity(opacity)
    }
    
    private var shadowRadius: CGFloat {
        isHeld ? 12 : (isTapped ? 8 : 6)
    }
    
    private var shadowY: CGFloat {
        isHeld ? 6 : (isTapped ? 4 : 3)
    }
    
    private var cardBackground: some View {
        RoundedRectangle(cornerRadius: 4 * sizeMultiplier)
            .fill(Color.white)
            .shadow(color: shadowColor, radius: shadowRadius, x: 0, y: shadowY)
    }
    
    private var cardOverlay: some View {
        let strokeColor = isHeld ? Color.blue.opacity(0.6) : (isTapped ? Color.blue.opacity(0.4) : Color.clear)
        return RoundedRectangle(cornerRadius: 4 * sizeMultiplier)
            .stroke(strokeColor, lineWidth: 2)
    }

    var body: some View {
        // Polaroid-style card
        VStack(spacing: 0) {
            // Image section (only show if showImage is true)
            if showImage {
                VStack(spacing: 0) {
                    RecipeNodeImageView(recipeID: node.currNodeID, sizeMultiplier: sizeMultiplier, title: $recipeName, description: $recipeDescription)
                }
                .padding(.top, 8 * sizeMultiplier)
                .padding(.horizontal, 8 * sizeMultiplier)
            }
            
            // White space at bottom (polaroid style) with title
            VStack(spacing: 4 * sizeMultiplier) {
                Text(recipeName ?? nodeDescriptionTitle)
                    .font(.system(size: 12 * sizeMultiplier, weight: .medium))
                    .foregroundColor(.black)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .truncationMode(.tail)
                    .padding(.horizontal, 8 * sizeMultiplier)
                    .frame(height: 32 * sizeMultiplier)
                
                Text(recipeDescription ?? "")
                    .font(.system(size: 9 * sizeMultiplier, weight: .regular))
                    .foregroundColor(.gray.opacity(0.6))
                    .lineLimit(1)
                    .truncationMode(.tail)
                    .padding(.horizontal, 8 * sizeMultiplier)
            }
            .frame(maxWidth: .infinity, maxHeight: 56 * sizeMultiplier)
            .background(Color.white)
        }
        .task(id: node.currNodeID) {
            // Fetch recipe name and description even if not showing image
            if !showImage && recipeName == nil {
                let recipe = await Recipe.fetchById(node.currNodeID)
                recipeName = recipe?.name
                recipeDescription = recipe?.description
            }
        }
        .background(cardBackground)
        .overlay(cardOverlay)
        .scaleEffect(isTapped ? 0.95 : 1.0)
        .rotation3DEffect(
            .degrees(isHeld ? 5 : 0),
            axis: (x: 1, y: 1, z: 0)
        )
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isTapped)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isHeld)
        .onTapGesture { onTap?() }
        .onLongPressGesture(minimumDuration: 0.5) { onHold?() }
    }

    // Prefer showing the recipe name when available, otherwise the node description
    private var nodeDescriptionTitle: String {
        // We don't have a direct Recipe object here; RecipeNodeImageView will fetch the recipe.
        // To keep a sensible fallback title, prefer descriptionOfRecipeChanges when present.
        if !node.descriptionOfRecipeChanges.isEmpty {
            return node.descriptionOfRecipeChanges
        }
        return "Recipe"
    }
}

// Small helper view that fetches a Recipe by ID and displays its first media image (or placeholder)
private struct RecipeNodeImageView: View {
    let recipeID: String
    var sizeMultiplier: CGFloat = 1.0
    @Binding var title: String?
    var description: Binding<String?>? = nil

    @State private var recipe: Recipe? = nil

    var body: some View {
        Group {
            if let mediaURLString = recipe?.media.first, let url = URL(string: mediaURLString) {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .empty:
                        placeholder
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFill()
                            .frame(width: 120 * sizeMultiplier, height: 120 * sizeMultiplier)
                            .clipped()
                    case .failure:
                        placeholder
                    @unknown default:
                        placeholder
                    }
                }
            } else {
                placeholder
            }
        }
        .task(id: recipeID) {
            // Avoid duplicate fetches if already loaded
            if recipe?.recipeId != recipeID {
                recipe = await Recipe.fetchById(recipeID)
                // update parent with recipe name and description when available
                if let fetched = recipe {
                    title = fetched.name
                    description?.wrappedValue = fetched.description
                }
            }
        }
    }

    private var placeholder: some View {
        ZStack {
            Rectangle()
                .fill(
                    LinearGradient(colors: [Color.gray.opacity(0.15), Color.gray.opacity(0.08)], startPoint: .top, endPoint: .bottom)
                )
                .frame(width: 120 * sizeMultiplier, height: 120 * sizeMultiplier)

            Image(systemName: "photo.on.rectangle")
                .font(.system(size: 32 * sizeMultiplier))
                .foregroundColor(.gray.opacity(0.5))
        }
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
    // Eesh New Edit: Changed to use FirebaseRemixTreeNode
    var nodes: [FirebaseRemixTreeNode]
    var tappedNodeID: String?
    var heldNodeID: String?
    var onNodeTap: ((FirebaseRemixTreeNode) -> Void)?
    var onNodeHold: ((FirebaseRemixTreeNode) -> Void)?
    var onCenterNodeChange: ((FirebaseRemixTreeNode?) -> Void)?

    @State private var activeIndex: Int = 0
    @State private var reportedIndex: Int = -1
    @State private var centerNodeID: String?
    @GestureState private var dragTranslation: CGFloat = 0

    private var nodeIdentifiers: [String] {
        nodes.map { $0.currNodeID }
    }

    var body: some View {
        GeometryReader { geo in
            let cardWidth: CGFloat = 136
            let cardSpacing: CGFloat = 20
            let sideOffset = cardWidth + cardSpacing
            let translationProgress = dragTranslation / sideOffset
            let dynamicIndex = wrappedIndex(Int(round(CGFloat(activeIndex) + translationProgress)))

            ZStack {
                ForEach(Array(nodes.enumerated()), id: \.1.currNodeID) { index, node in
                    let rawRelative = CGFloat(index) - CGFloat(activeIndex) - translationProgress
                    // For circular wrapping, find shortest distance
                    let relative = shortestDistance(from: index, to: activeIndex, progress: translationProgress)
                    let limitedRelative = max(min(relative, 3), -3)
                    let isPrimary = abs(relative) < 0.35
                    
                    // Only show cards that are within range
                    let shouldShow = abs(relative) <= 2.5

                    NodeCard(
                        node: node,
                        isTapped: tappedNodeID == node.currNodeID,
                        isHeld: heldNodeID == node.currNodeID,
                        onTap: {
                            if isPrimary {
                                onNodeTap?(node)
                            } else {
                                withAnimation(.spring(response: 0.35, dampingFraction: 0.75)) {
                                    activeIndex = index
                                }
                            }
                        },
                        onHold: { onNodeHold?(node) }
                    )
                    .frame(width: cardWidth)
                    .scaleEffect(scale(for: limitedRelative))
                    .blur(radius: blur(for: limitedRelative))
                    .opacity(shouldShow ? opacity(for: limitedRelative) : 0)
                    .offset(x: relative * sideOffset)
                    .zIndex(shouldShow ? Double(10 - abs(relative)) : -1)
                    .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 6)
                }
            }
            .frame(width: geo.size.width, height: 220)
            .clipped()
            .contentShape(Rectangle())
            .gesture(
                DragGesture()
                    .updating($dragTranslation) { value, state, _ in
                        state = value.translation.width
                    }
                    .onEnded { value in
                        let progress = value.translation.width / sideOffset
                        
                        // Determine direction: only move one card at a time
                        let newIndex: Int
                        if progress > 0.15 {
                            // Swiped right significantly - go to previous
                            newIndex = wrappedIndex(activeIndex - 1)
                        } else if progress < -0.15 {
                            // Swiped left significantly - go to next
                            newIndex = wrappedIndex(activeIndex + 1)
                        } else {
                            // Small swipe - stay on current
                            newIndex = activeIndex
                        }
                        
                        withAnimation(.spring(response: 0.35, dampingFraction: 0.75)) {
                            activeIndex = newIndex
                        }
                    }
            )
            .animation(.spring(response: 0.35, dampingFraction: 0.75), value: activeIndex)
            .animation(.linear(duration: 0.1), value: dragTranslation == 0)
            .onChange(of: nodeIdentifiers) { _ in
                syncActiveIndexWithNodes()
                reportCenterChange(index: wrappedIndex(activeIndex))
            }
            .onChange(of: activeIndex) { newValue in
                reportCenterChange(index: newValue)
            }
            .onChange(of: dynamicIndex) { newValue in
                reportCenterChange(index: newValue)
            }
            .onAppear {
                syncActiveIndexWithNodes()
                reportCenterChange(index: wrappedIndex(activeIndex))
            }
        }
        .frame(height: 220)
    }

    private func wrappedIndex(_ index: Int) -> Int {
        guard !nodes.isEmpty else { return 0 }
        let count = nodes.count
        return ((index % count) + count) % count
    }
    
    private func shortestDistance(from: Int, to: Int, progress: CGFloat) -> CGFloat {
        guard nodes.count > 1 else { return 0 }
        
        let count = CGFloat(nodes.count)
        let directDistance = CGFloat(from) - CGFloat(to) + progress
        
        // Calculate wrapped distances
        let wrapLeft = directDistance + count
        let wrapRight = directDistance - count
        
        // Find the shortest distance
        let distances = [directDistance, wrapLeft, wrapRight]
        return distances.min(by: { abs($0) < abs($1) }) ?? directDistance
    }

    private func syncActiveIndexWithNodes() {
        guard !nodes.isEmpty else {
            if reportedIndex != -1 {
                reportedIndex = -1
                centerNodeID = nil
                onCenterNodeChange?(nil)
            }
            activeIndex = 0
            return
        }

        if let centerNodeID = centerNodeID,
           let existingIndex = nodes.firstIndex(where: { $0.currNodeID == centerNodeID }) {
            if existingIndex != activeIndex {
                activeIndex = existingIndex
            }
        } else {
            // Wrap the active index instead of clamping
            activeIndex = wrappedIndex(activeIndex)
        }
    }

    private func reportCenterChange(index: Int) {
        guard !nodes.isEmpty else {
            if reportedIndex != -1 {
                reportedIndex = -1
                centerNodeID = nil
                onCenterNodeChange?(nil)
            }
            return
        }

        guard nodes.indices.contains(index) else { return }

        if reportedIndex != index {
            reportedIndex = index
            centerNodeID = nodes[index].currNodeID
            onCenterNodeChange?(nodes[index])
        }
    }

    private func scale(for relative: CGFloat) -> CGFloat {
        let distance = min(abs(relative), 2.5)
        if distance < 0.35 { return 1.0 }
        if distance < 1.1 { return 0.9 }
        return 0.8
    }

    private func blur(for relative: CGFloat) -> CGFloat {
        let distance = abs(relative)
        if distance < 0.35 { return 0 }
        if distance < 1.2 { return 2 }
        return 5
    }

    private func opacity(for relative: CGFloat) -> Double {
        let distance = abs(relative)
        if distance < 0.35 { return 1.0 }
        if distance < 1.2 { return 0.7 }
        return 0.4
    }
}
// MARK: - RemixTreeView
struct RemixTreeView: View {
    let nodeID: String

    @ObservedObject private var data = RemixData.shared
    @State private var tappedNodeID: String?
    @State private var heldNodeID: String?
    // Eesh New Edit: Changed to use FirebaseRemixTreeNode
    @State private var navigateToNode: FirebaseRemixTreeNode?
    @State private var navigateToPostID: String?
    @State private var centeredFirstLayerNode: FirebaseRemixTreeNode?
    // End of Eesh New Edit
    // Eesh New Edit: Add explicit navigation state booleans to fix navigation stack issue
    @State private var isNavigatingToNode: Bool = false
    @State private var isNavigatingToPost: Bool = false
    // End of Eesh New Edit
    
    // Animated transition states
    @State private var currentDisplayNodeID: String
    @State private var isTransitioning: Bool = false
    
    @Environment(AuthenticationVM.self) var authVM: AuthenticationVM

    init(nodeID: String) {
        self.nodeID = nodeID
        self._currentDisplayNodeID = State(initialValue: nodeID)
    }

    private var currentNodeID: String { currentDisplayNodeID }

    // Eesh New Edit: Changed to use FirebaseRemixTreeNode
    private var currentNode: FirebaseRemixTreeNode? {
        data.nodes.first { $0.currNodeID == currentNodeID }
    }

    private var parentNode: FirebaseRemixTreeNode? {
        guard let node = currentNode else { return nil }
        return data.nodes.first { $0.currNodeID == node.parentNodeID }
    }

    private var firstLayerChildren: [FirebaseRemixTreeNode] {
        guard let node = currentNode else { return [] }
        return data.nodes.filter { $0.parentNodeID == node.currNodeID }
    }

    private var secondLayerChildren: [FirebaseRemixTreeNode] {
    // End of Eesh New Edit
        guard let centeredNode = centeredFirstLayerNode else { return [] }
        return data.nodes.filter { $0.parentNodeID == centeredNode.currNodeID }
    }

    var body: some View {
        GeometryReader { geo in
            ScrollView {
                VStack(spacing: 24) {
                    // Parent node section - always shown
                    // Eesh New Edit: Updated parent node navigation to use new state booleans
                        VStack(spacing: 12) {
                            Text("ORIGINAL")
                                .font(.system(size: 10, weight: .semibold))
                                .foregroundColor(Color(hex: "#ffa94a"))
                                .tracking(1)
                                .padding(.top, 16)

                            if let parent = parentNode {
                                NodeCard(
                                    node: parent,
                                    onTap: {
                                        animateTransitionToNode(parent)
                                    },
                                    onHold: {
                                        navigateToPostID = parent.currNodeID
                                        isNavigatingToPost = true
                                    },
                                    showImage: true
                                )
                                .frame(width: 136, height: 180)
                                .opacity(isTransitioning ? 0 : 1)
                            } else {
                                // Placeholder for no parent
                                VStack(spacing: 8) {
                                    Image(systemName: "photo.on.rectangle.angled")
                                        .font(.system(size: 24))
                                        .foregroundColor(.gray.opacity(0.3))
                                    Text("No Parent")
                                        .font(.system(size: 12, weight: .medium))
                                        .foregroundColor(.gray.opacity(0.5))
                                }
                                .frame(width: 136, height: 180)
                                .opacity(isTransitioning ? 0 : 1)
                            }
                            
                            // Simple line connector
                            Rectangle()
                                .fill(Color(hex: "#ffa94a"))
                                .frame(width: 2, height: 24)
                        }
                        // End of Eesh New Edit                    // Current node - always shown
                    // Eesh New Edit: Updated current node navigation to use new state booleans
                    VStack(spacing: 12) {
                        Text("CURRENT RECIPE")
                            .font(.system(size: 10, weight: .semibold))
                            .foregroundColor(Color(hex: "#ffa94a"))
                            .tracking(1)

                        if let node = currentNode {
                            NodeCard(
                                node: node,
                                isTapped: tappedNodeID == node.currNodeID,
                                isHeld: heldNodeID == node.currNodeID,
                                onTap: {
                                    // Current node doesn't navigate to itself
                                },
                                onHold: {
                                    navigateToPostID = node.currNodeID
                                    isNavigatingToPost = true
                                }
                            )
                            .frame(width: 136, height: 180)
                            .opacity(isTransitioning ? 0 : 1)
                        } else {
                            // Placeholder for no current node
                            VStack(spacing: 8) {
                                Image(systemName: "photo.on.rectangle.angled")
                                    .font(.system(size: 40))
                                    .foregroundColor(.gray.opacity(0.3))
                                Text("No Recipe")
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(.gray.opacity(0.5))
                            }
                            .frame(width: 136, height: 180)
                            .opacity(isTransitioning ? 0 : 1)
                        }
                        
                        // Simple line connector to children - always shown
                        Rectangle()
                            .fill(Color(hex: "#ffa94a"))
                            .frame(width: 2, height: 24)
                    }
                    // End of Eesh New Edit

                    // First layer children - always shown
                    VStack(spacing: 12) {
                        Text("CHILDREN")
                            .font(.system(size: 10, weight: .semibold))
                            .foregroundColor(Color(hex: "#ffa94a"))
                            .tracking(1)
                        
                        if !firstLayerChildren.isEmpty {
                            layerView(nodes: firstLayerChildren, layerIndex: 1)
                                .opacity(isTransitioning ? 0 : 1)
                        } else {
                            // Placeholder for no children
                            VStack(spacing: 8) {
                                Image(systemName: "photo.stack")
                                    .font(.system(size: 32))
                                    .foregroundColor(.gray.opacity(0.3))
                                Text("No Children")
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(.gray.opacity(0.5))
                            }
                            .frame(height: 220)
                            .opacity(isTransitioning ? 0 : 1)
                        }
                        
                        // Simple line connector to grandchildren - always shown
                        Rectangle()
                            .fill(Color(hex: "#ffa94a"))
                            .frame(width: 2, height: 24)
                    }

                    // Second layer children (of centered first layer node) - always shown
                    VStack(spacing: 16) {
                        Text("GRANDCHILDREN")
                            .font(.system(size: 10, weight: .semibold))
                            .foregroundColor(Color(hex: "#ffa94a"))
                            .tracking(1)
                        
                        if !secondLayerChildren.isEmpty {
                            layerView(nodes: secondLayerChildren, layerIndex: 2)
                                .id(centeredFirstLayerNode?.currNodeID ?? "")
                                .transition(.opacity)
                                .opacity(isTransitioning ? 0 : 1)
                        } else {
                            // Placeholder for no grandchildren
                            VStack(spacing: 8) {
                                Image(systemName: "photo.stack")
                                    .font(.system(size: 32))
                                    .foregroundColor(.gray.opacity(0.3))
                                Text("No Grandchildren")
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(.gray.opacity(0.5))
                            }
                            .frame(height: 220)
                            .id(centeredFirstLayerNode?.currNodeID ?? "empty")
                            .opacity(isTransitioning ? 0 : 1)
                        }
                    }
                    .padding(.bottom, 20)
                }
                .frame(maxWidth: .infinity, minHeight: geo.size.height)
                .animation(.easeInOut(duration: 0.3), value: isTransitioning)
                .animation(.easeInOut(duration: 0.3), value: centeredFirstLayerNode?.currNodeID)
            }
        }
        .background(Color(red: 1.0, green: 0.992, blue: 0.969).ignoresSafeArea())
        .background(navigationLinks)
        .onAppear {
            data.startListening()
            // Initialize centered node on appear
            updateCenteredNode()
        }
        .onChange(of: data.nodes) { _ in
            // Update centered node when data loads or changes
            updateCenteredNode()
        }
        .onChange(of: nodeID) { _ in
            // Reset centered node when navigating to a different tree
            centeredFirstLayerNode = nil
            updateCenteredNode()
        }
        .onDisappear { data.stopListening() }
    }

    // MARK: - Layer view
    @ViewBuilder
    // Eesh New Edit: Changed to use [FirebaseRemixTreeNode]
    private func layerView(nodes: [FirebaseRemixTreeNode], layerIndex: Int) -> some View {
    // End of Eesh New Edit
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
                    .frame(width: 136)
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 220)
            .padding(.horizontal, 20)
        }
    }

    // MARK: - Navigation
    // Eesh New Edit: Fixed navigation bindings to prevent immediate pop-back
    private var navigationLinks: some View {
        Group {
            NavigationLink(
                destination: Group {
                    if let node = navigateToNode {
                        RemixTreeView(nodeID: node.currNodeID)
                            .environment(authVM)
                    } else {
                        EmptyView()
                    }
                },
                isActive: $isNavigatingToNode
            ) {
                EmptyView()
            }

            NavigationLink(
                destination: Group {
                    if let postID = navigateToPostID {
                        RecipeLoadingView(recipeID: postID)
                            .environment(authVM)
                    } else {
                        EmptyView()
                    }
                },
                isActive: $isNavigatingToPost
            ) {
                EmptyView()
            }
        }
    }
    // End of Eesh New Edit

    // MARK: - Tap/Hold handlers
    // Eesh New Edit: Updated handlers to use FirebaseRemixTreeNode
    private func handleTap(node: FirebaseRemixTreeNode) {
        tappedNodeID = node.currNodeID
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            tappedNodeID = nil
            animateTransitionToNode(node)
        }
    }

    private func handleHold(node: FirebaseRemixTreeNode) {
    // End of Eesh New Edit
        heldNodeID = node.currNodeID
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
            navigateToPostID = node.currNodeID
            isNavigatingToPost = true
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            heldNodeID = nil
        }
    }
    // End of Eesh New Edit
    
    // MARK: - Animation Transition
    private func animateTransitionToNode(_ targetNode: FirebaseRemixTreeNode) {
        guard !isTransitioning else { return }
        
        // Phase 1: Fade out all cards
        withAnimation(.easeOut(duration: 0.2)) {
            isTransitioning = true
        }
        
        // Phase 2: Update content while faded out
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            currentDisplayNodeID = targetNode.currNodeID
            centeredFirstLayerNode = nil
            updateCenteredNode()
            
            // Phase 3: Fade in new cards
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                withAnimation(.easeIn(duration: 0.2)) {
                    isTransitioning = false
                }
            }
        }
    }
    
    // MARK: - Helper Methods
    private func updateCenteredNode() {
        if !firstLayerChildren.isEmpty && centeredFirstLayerNode == nil {
            centeredFirstLayerNode = firstLayerChildren.first
        }
    }
}

// MARK: - Recipe Loading View
struct RecipeLoadingView: View {
    let recipeID: String

    @State private var recipe: Recipe?
    @State private var isLoading = true
    @State private var errorMessage: String?

    var body: some View {
        Group {
            if isLoading {
                VStack(spacing: 20) {
                    ProgressView()
                        .scaleEffect(1.5)
                    Text("Loading Recipe...")
                        .font(.headline)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if let recipe = recipe {
                PostView(recipe: recipe)
            } else {
                VStack(spacing: 16) {
                    Image(systemName: "exclamationmark.triangle")
                        .font(.system(size: 50))
                        .foregroundColor(.orange)
                    Text("Recipe Not Found")
                        .font(.title2)
                        .fontWeight(.semibold)
                    if let errorMessage = errorMessage {
                        Text(errorMessage)
                            .font(.body)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding()
            }
        }
        .task {
            await loadRecipe()
        }
    }

    private func loadRecipe() async {
        isLoading = true
        recipe = await Recipe.fetchById(recipeID)
        if recipe == nil {
            errorMessage = "Could not load recipe with ID: \(recipeID)"
        }
        isLoading = false
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
//        RemixTreeView(nodeID: "1E1EE058-180A-4420-9784-F5F36365159E")
//            .environment(AuthenticationVM())
        RemixTreeView(nodeID: "CD816F37-F313-4BB5-BF51-1A229C72806D")
            .environment(AuthenticationVM())
    }
}
