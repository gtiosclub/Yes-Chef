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
    @State private var isEditing = false
    @State private var draggingIndex: Int? = nil

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Spacer()
                SectionHeader(title: "Steps").padding(.leading, 35)
                Spacer()
                Button {
                    withAnimation(.easeInOut(duration: 0.15)) {
                        isEditing.toggle()
                        if isEditing, steps.isEmpty { steps = [""] }
                    }
                } label: {
                    if isEditing {
                        Text("Done")
                            .font(.subheadline).bold()
                            .padding(.horizontal, 10).padding(.vertical, 6)
                            .cornerRadius(10)
                            .foregroundColor(.primary)
                    } else {
                        Image(systemName: "square.and.pencil")
                            .font(.title3).bold()
                            .foregroundColor(.black)
                            .frame(width: 34, height: 34)
                }
                }
            }
            .padding(.horizontal)

            ScrollView {
                LazyVStack(spacing: 8) {
                    ForEach(steps.indices, id: \.self) { index in
                        StepRow(
                            index: index,
                            text: binding(for: index),
                            isEditing: isEditing,
                            canDelete: steps.count > 1,
                            onDelete: { steps.remove(at: index) }
                        )
                        .padding(.horizontal)
//                        .onDrag {
//                            draggingIndex = index
//                            return NSItemProvider(object: "\(index)" as NSString)
//                        }
//                        .onDrop(
//                            of: [dragUTType],
//                            delegate: StepReorderDropDelegate(
//                                itemIndex: index,
//                                steps: $steps,
//                                draggingIndex: $draggingIndex
//                            )
//                        )
                    }

                    if isEditing {
                        HStack {
                            Spacer()
                            Button {
                               steps.append("")
                            } label: {
                                Circle()
                                    .fill(Color(hex:"#FFA947"))
                                    .frame(width: 34, height: 34)
                                    .overlay(Image(systemName: "plus").foregroundColor(.white).font(.title3))
                            }
                            Spacer()
                        }
                        .padding(.top, 8)
                    }
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
    let isEditing: Bool
    let canDelete: Bool
    var onDelete: () -> Void

    var body: some View {
        HStack(alignment: .center, spacing: 10) {
            Text(String(format: "%02d", index + 1))
                .font(.custom("Georgia", size: 24))
                .foregroundStyle(Color(hex: "#453736"))
                .fontWeight(.semibold)
                .frame(width: 40, alignment: .center)

            StepEditor(
                text: $text,
                placeholder: "Enter step...",
                isEditing: isEditing
            )

            if isEditing && canDelete {
                Button(action: onDelete) {
                    Circle()
                        .fill(Color(hex:"#FFA947"))
                        .frame(width: 34, height: 34)
                        .overlay(Image(systemName: "minus").foregroundColor(.white).font(.title3))
                }
                .buttonStyle(.plain)
            }

            if isEditing {
                Circle()
                    .fill(Color(hex:"#FFA947"))
                    .frame(width: 34, height: 34)
                    .overlay(Image(systemName: "line.3.horizontal").foregroundColor(.white).font(.title3))
            }
        }
    }
}

//private struct StepReorderDropDelegate: DropDelegate {
//    let itemIndex: Int
//    @Binding var steps: [String]
//    @Binding var draggingIndex: Int?
//
//    func dropEntered(info: DropInfo) {
//        guard let from = draggingIndex, from != itemIndex else { return }
//        let to = (from < itemIndex) ? itemIndex + 1 : itemIndex
//
//        withAnimation(.spring(response: 0.25, dampingFraction: 0.9)) {
//            steps.move(fromOffsets: IndexSet(integer: from), toOffset: to)
//            let newIndex = (from < itemIndex) ? (to - 1) : to
//            draggingIndex = newIndex
//        }
//    }
//
//    func dropUpdated(info: DropInfo) -> DropProposal? {
//        DropProposal(operation: .move)
//    }
//
//    func validateDrop(info: DropInfo) -> Bool {
//        info.hasItemsConforming(to: [.plainText])
//    }
//
//    func performDrop(info: DropInfo) -> Bool {
//        draggingIndex = nil
//        return true
//    }
//}

struct StepEditor: View {
    @Binding var text: String
    var placeholder: String
    var isEditing: Bool
    var keyboardType: UIKeyboardType = .default
    var padding: EdgeInsets = EdgeInsets(top: 10, leading: 12, bottom: 5, trailing: 12)

    var body: some View {
        ZStack(alignment: .leading) {
            if text.isEmpty {
                Text(placeholder)
                    .foregroundColor(.secondary)
                    .padding(.leading, 8)
            }

            TextEditor(text: $text)
                .scrollContentBackground(.hidden)
                .background(Color.clear)
                .font(.subheadline)
                .frame(minHeight: 40, maxHeight: 100)
                .disabled(!isEditing)
                .opacity(isEditing ? 1 : 0.6)
                .keyboardType(keyboardType)
                .foregroundColor(Color(hex: "#877872"))
                .padding(padding)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color(hex: "#F9F5F2"))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.black.opacity(0.3), lineWidth: 1)
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
