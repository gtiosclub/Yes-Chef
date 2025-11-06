//
//  StepsInputView.swift
//  Yes Chef
//
//  Created by Anushka on 9/24/25.
//

import SwiftUI
import UniformTypeIdentifiers

private let dragUTType: UTType = .plainText

struct StepsInputView: View {
    @Binding var steps: [String]
    @State private var draggingIndex: Int? = nil
    var previewRemoving: [String] = []
    var previewAdding: [String] = []
    
    private func isRemoving(_ step: String) -> Bool {
        previewRemoving.contains { removing in
            step.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() == removing.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        }
    }

    var body: some View {
        VStack(alignment: .leading) {
            SectionHeader(title: "Steps")
                .padding(.leading, 5)

            ScrollView {
                LazyVStack {
                    ForEach(steps.indices, id: \.self) { index in
                        StepRow(
                            index: index,
                            text: binding(for: index),
                            canDelete: steps.count > 1,
                            isRemoving: isRemoving(steps[index]),
                            onDelete: { steps.remove(at: index) }
                        )
                        .padding(.horizontal)
                        .onDrag {
                            draggingIndex = index
                            return NSItemProvider(object: "\(index)" as NSString)
                        }
                        .onDrop(
                            of: [dragUTType],
                            delegate: StepReorderDropDelegate(
                                itemIndex: index,
                                steps: $steps,
                                draggingIndex: $draggingIndex
                            )
                        )
                    }

                    ForEach(Array(previewAdding.enumerated()), id: \.offset) { offset, step in
                        StepRow(
                            index: steps.count + offset,
                            text: .constant(step),
                            canDelete: false,
                            isRemoving: false,
                            isAdding: true,
                            onDelete: {}
                        )
                        .padding(.horizontal)
                    }
                    
                    HStack {
                        Spacer()
                        Button {
                            steps.append("")
                        } label: {
                            Image(systemName: "plus")
                                .foregroundColor(.white)
                                .font(.system(size: 25, weight: .bold))
                                .frame(width: 40, height: 40)
                                .padding(2)
                                .background(Color(hex: "#ffa94a"))
                                .clipShape(Circle())
                        }
                        Spacer()
                    }
                    .padding(.top, 8)
                }
                .padding(.vertical, 4)
            }
        }
    }

    private func binding(for index: Int) -> Binding<String> {
        Binding(
            get: { steps[index] },
            set: { steps[index] = $0 }
        )
    }
}

private struct StepRow: View {
    let index: Int
    @Binding var text: String
    let canDelete: Bool
    var isRemoving: Bool = false
    var isAdding: Bool = false
    var onDelete: () -> Void
    
    private var backgroundColor: Color {
        if isRemoving {
            return Color.red.opacity(0.2)
        } else if isAdding {
            return Color.green.opacity(0.2)
        } else {
            return Color.clear
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(String(format: "%02d", index + 1))
                .font(.custom("Georgia", size: 24))
                .foregroundStyle(Color(hex: "#453736"))
                .fontWeight(.semibold)
                .frame(width: 40, alignment: .center)

            HStack {
                if isAdding {
                    // For preview additions, use a Text view with green background
                    Text(text)
                        .font(.subheadline)
                        .foregroundColor(Color(hex: "#877872"))
                        .frame(maxWidth: .infinity, minHeight: 40, maxHeight: 100, alignment: .topLeading)
                        .padding(EdgeInsets(top: 10, leading: 12, bottom: 5, trailing: 12))
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color.green.opacity(0.2))
                        )
                } else {
                    StepEditor(
                        text: $text,
                        placeholder: "Enter step...",
                        backgroundColor: backgroundColor
                    )
                }
                
                if canDelete && !isAdding {
                    Button(action: onDelete) {
                        Circle()
                            .fill(Color(hex:"#FFA947"))
                            .frame(width: 34, height: 34)
                            .overlay(Image(systemName: "minus").foregroundColor(.white).font(.title3))
                    }
                    .buttonStyle(.plain)
                }
                
                if !isAdding {
                    Circle()
                        .fill(Color.white)
                        .frame(width: 34, height: 34)
                        .overlay(
                            Image(systemName: "line.3.horizontal")
                                .foregroundColor(Color(hex:"#FFA947"))
                                .font(.title3)
                        )
                }
            }
        }
    }
}

private struct StepReorderDropDelegate: DropDelegate {
    let itemIndex: Int
    @Binding var steps: [String]
    @Binding var draggingIndex: Int?

    func dropEntered(info: DropInfo) {
        guard let from = draggingIndex, from != itemIndex else { return }
        let to = (from < itemIndex) ? itemIndex + 1 : itemIndex

        withAnimation(.spring(response: 0.25, dampingFraction: 0.9)) {
            steps.move(fromOffsets: IndexSet(integer: from), toOffset: to)
            let newIndex = (from < itemIndex) ? (to - 1) : to
            draggingIndex = newIndex
        }
    }

    func dropUpdated(info: DropInfo) -> DropProposal? {
        DropProposal(operation: .move)
    }

    func validateDrop(info: DropInfo) -> Bool {
        info.hasItemsConforming(to: [.plainText])
    }

    func performDrop(info: DropInfo) -> Bool {
        draggingIndex = nil
        return true
    }
}

struct StepEditor: View {
    @Binding var text: String
    var placeholder: String
    var keyboardType: UIKeyboardType = .default
    var padding: EdgeInsets = EdgeInsets(top: 10, leading: 12, bottom: 5, trailing: 12)
    var backgroundColor: Color = Color.clear

    var body: some View {
        ZStack(alignment: .leading) {
            if text.isEmpty && backgroundColor == Color.clear {
                Text(placeholder)
                    .foregroundColor(.secondary)
                    .padding(.leading, 8)
            }

            TextEditor(text: $text)
                .scrollContentBackground(.hidden)
                .background(Color.clear)
                .font(.subheadline)
                .frame(minHeight: 40, maxHeight: 100)
                .keyboardType(keyboardType)
                .foregroundColor(Color(hex: "#877872"))
                .padding(padding)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(backgroundColor == Color.clear ? Color(hex: "#F9F5F2") : backgroundColor)
                )
        }
    }
}

#Preview {
    StepsInputView(steps: .constant([
        "Preheat oven to 350°F.",
        "Mix flour and sugar.",
        "Add eggs and whisk."
    ]))
}
