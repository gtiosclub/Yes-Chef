//
//  EditableFields.swift
//  Yes Chef
//
//  Created by Anushka Jain on 10/2/25.
//

import SwiftUI

private struct EditButtonStyle: View {
    var body: some View {
        Image(systemName: "square.and.pencil")
            .font(.title3)
            .foregroundColor(.black)
            .frame(width: 34, height: 34)
            .background(Circle().fill(Color.gray.opacity(0.3)))
    }
}

private struct DoneButtonStyle: View {
    var body: some View {
        Text("Done")
            .font(.subheadline).bold()
            .padding(.horizontal, 10).padding(.vertical, 6)
            .background(Color.gray.opacity(0.2))
            .cornerRadius(10)
            .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.black, lineWidth: 1))
            .foregroundColor(.primary)
    }
}

struct EditableTextField: View {
    let title: String
    let placeholder: String
    @Binding var text: String

    @State private var isEditing = false
    @State private var draft = ""

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(title)
                    .font(.title)
                Spacer()
                Button {
                    withAnimation(.easeInOut(duration: 0.15)) {
                        if isEditing { text = draft } else { draft = text }
                        isEditing.toggle()
                    }
                } label: {
                    if isEditing { DoneButtonStyle() } else { EditButtonStyle() }
                }
            }
            .padding(.horizontal)
            .padding(.bottom, -2)

            Group {
                if isEditing {
                    TextField(placeholder, text: $draft)
                        .font(.subheadline)
                        .padding(10)
                        .foregroundColor(.primary) // black while editing
                } else {
                    Text(text.isEmpty ? placeholder : text)
                        .font(.subheadline)
                        .foregroundColor(text.isEmpty ? .secondary : Color(UIColor.secondaryLabel)) // gray afterwards
                        .padding(10)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.gray.opacity(0.2))
            .cornerRadius(10)
            .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.black, lineWidth: 1))
            .padding(.horizontal)
        }
    }
}

struct EditableTextEditor: View {
    let title: String
    let placeholder: String
    @Binding var text: String
    var minHeight: CGFloat = 140

    @State private var isEditing = false
    @State private var draft = ""

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(title)
                    .font(.title)
                Spacer()
                Button {
                    withAnimation(.easeInOut(duration: 0.15)) {
                        if isEditing { text = draft } else { draft = text }
                        isEditing.toggle()
                    }
                } label: {
                    if isEditing {
                        Text("Done")
                            .font(.subheadline).bold()
                            .padding(.horizontal, 10).padding(.vertical, 6)
                            .background(Color.gray.opacity(0.2))
                            .cornerRadius(10)
                            .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.black, lineWidth: 1))
                            .foregroundColor(.primary)
                    } else {
                        Image(systemName: "square.and.pencil")
                            .font(.title3)
                            .foregroundColor(.black)
                            .frame(width: 34, height: 34)
                            .background(Circle().fill(Color.gray.opacity(0.3)))
                    }
                }
            }
            .padding(.horizontal)
            .padding(.bottom, -2)

            ZStack(alignment: .topLeading) {
                if (isEditing ? draft.isEmpty : text.isEmpty) {
                    Text(placeholder)
                        .foregroundColor(.secondary)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 10)
                }

                if isEditing {
                    editorView
                } else {
                    Text(text)
                        .font(.subheadline)
                        .foregroundColor(text.isEmpty ? .secondary : Color(UIColor.secondaryLabel)) // gray afterwards
                        .padding(.horizontal, 10)
                        .padding(.vertical, 10)
                        .frame(maxWidth: .infinity, alignment: .topLeading)
                }
            }
            .frame(maxWidth: .infinity, minHeight: minHeight, alignment: .topLeading)
            .background(Color.gray.opacity(0.2))
            .cornerRadius(10)
            .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.black, lineWidth: 1))
            .padding(.horizontal)
        }
    }

    @ViewBuilder
    private var editorView: some View {
        if #available(iOS 16.0, *) {
            TextEditor(text: $draft)
                .scrollContentBackground(.hidden)
                .foregroundColor(.primary) // black while editing
                .font(.subheadline)
                .padding(.horizontal, 10)
                .padding(.vertical, 10)
                .frame(maxWidth: .infinity, minHeight: minHeight, alignment: .topLeading)
                .background(Color.clear)
        } else {
            TextEditor(text: $draft)
                .foregroundColor(.primary) // black while editing
                .font(.subheadline)
                .padding(.horizontal, 10)
                .padding(.vertical, 10)
                .frame(maxWidth: .infinity, minHeight: minHeight, alignment: .topLeading)
                .background(Color.clear)
                .onAppear { UITextView.appearance().backgroundColor = .clear }
        }
    }
}
