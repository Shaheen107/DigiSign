//
//  ContentView.swift
//  DigiSign
//
//  Created by Dev Reptech on 29/02/2024.
//

import SwiftUI


struct ContentView: View {
    @Environment(\.colorScheme) var colorScheme
    @State private var currentSignature: Signature?
    @State private var showCanvas = true
    @State private var isDarkMode = false
    @State private var showNotepad = false

    var body: some View {
        NavigationView {
            VStack {
                if showCanvas {
                    SignatureCanvas(currentSignature: $currentSignature)
                        .frame(width: 300, height: 150)
                        .border(Color.black)
                }

                HStack {
                    Button("Clear") {
                        currentSignature = nil
                        showCanvas = true
                    }
                    .padding()
                    .background(Color.red)
                    .foregroundColor(.white)
                    .cornerRadius(8)

                    Button("Copy Signature") {
                        if let signature = currentSignature {
                            // Implement copy functionality here
                            UIPasteboard.general.image = signatureImage(from: signature)
                        }
                    }
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
                }
                .padding()
            }
            .background(colorScheme == .dark ? Color.black : Color.white)
            .navigationBarTitle("Digital Signatures")
            .navigationBarItems(leading:
                Button(action: {
                    isDarkMode.toggle()
                }) {
                    Image(systemName: isDarkMode ? "moon.fill" : "sun.max.fill")
                        .padding()
                        .foregroundColor(.primary)
                },
                trailing: NavigationLink(destination: NotepadView(), isActive: $showNotepad) {
                    Image(systemName: "note.text")
                        .padding()
                        .foregroundColor(.primary)
                }
            )
        }
        .preferredColorScheme(isDarkMode ? .dark : .light)
    }

    private func signatureImage(from signature: Signature) -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: 300, height: 150))
        let image = renderer.image { ctx in
            ctx.cgContext.setStrokeColor(UIColor.black.cgColor)
            ctx.cgContext.setLineWidth(2)
            for line in signature.lines {
                for (index, point) in line.points.enumerated() {
                    if index == 0 {
                        ctx.cgContext.move(to: point)
                    } else {
                        ctx.cgContext.addLine(to: point)
                    }
                }
            }
            ctx.cgContext.strokePath()
        }
        return image
    }
}


struct NotepadView: View {
    @State private var notes: String = ""
    @State private var allNotes: [String] = []
    @State private var isPlaceholderVisible = true

    var body: some View {
        NavigationView {
            VStack {
                HStack {
                  //  Spacer()
                    Button(action: {
                        if !notes.isEmpty {
                            allNotes.append(notes)
                            notes = ""
                            isPlaceholderVisible = true
                            dismissKeyboard()
                        }
                    }) {
                        
                    }
                    .frame(maxWidth: .infinity)
                //    .padding()
                }

                TextEditorWithPlaceholder(text: $notes, placeholder: "Add notes here", isPlaceholderVisible: $isPlaceholderVisible)
                    .padding()
                    .background(Color.secondary.opacity(0.1))
                    .cornerRadius(8)
                    .padding()

                HStack {
                    Spacer()
                    Button(action: {
                        if !notes.isEmpty {
                            allNotes.append(notes)
                            notes = ""
                            isPlaceholderVisible = true
                            dismissKeyboard()
                        }
                    })
                    {
                        Text("Add Notes")
                            .padding()
                            .foregroundColor(.white)
                            .background(Color.blue)
                            .cornerRadius(8)
                    }
                    .frame(maxWidth: .infinity)
                 //   .padding()
                    .disabled(notes.isEmpty)
                }

                List {
                    ForEach(allNotes, id: \.self) { note in
                        Text(note)
                    }
                    .onDelete(perform: deleteNote)
                }
            }
            .navigationBarTitle("Notepad")
         
        }
    }

    private func dismissKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
    
    
      private func deleteNote(at offsets: IndexSet) {
          allNotes.remove(atOffsets: offsets)
      }
}





struct TextEditorWithPlaceholder: View {
    @Binding var text: String
    var placeholder: String
    @Binding var isPlaceholderVisible: Bool

    var body: some View {
        ZStack(alignment: .topLeading) {
            if text.isEmpty && isPlaceholderVisible {
                Text(placeholder)
                    .foregroundColor(.blue) // Placeholder color
                    .padding(.horizontal, 8)
                    .padding(.top, 8) // Adjust the top padding here
                    .padding(.leading, 5)
            }
            TextEditor(text: $text)
                .padding(.top, 40) // Adjust the top padding here
                .border(Color.gray.opacity(0.7), width: 1) // Add border with darker gray color
                .cornerRadius(8) // Add corner radius for better appearance
        }
    }
}




struct SignatureCanvas: View {
    @Binding var currentSignature: Signature?
    @State private var currentLine: Line?

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Color.white
                    .gesture(
                        DragGesture(minimumDistance: 0)
                            .onChanged { value in
                                let newPoint = value.location
                                if var lastPoint = self.currentLine?.points.last {
                                    if distance(from: lastPoint, to: newPoint) > 1 {
                                        self.currentLine?.points.append(newPoint)
                                    }
                                } else {
                                    self.currentLine = Line(points: [newPoint])
                                }
                            }
                            .onEnded { _ in
                                if let line = self.currentLine {
                                    if var signature = self.currentSignature {
                                        signature.lines.append(line)
                                        self.currentSignature = signature
                                    } else {
                                        self.currentSignature = Signature(lines: [line])
                                    }
                                    self.currentLine = nil
                                }
                            }
                    )

                if let currentSignature = currentSignature {
                    ForEach(currentSignature.lines) { line in
                        Path { path in
                            path.addLines(line.points)
                        }
                        .stroke(Color.black, lineWidth: 2)
                    }
                }
            }
        }
    }

    private func distance(from point1: CGPoint, to point2: CGPoint) -> CGFloat {
        return sqrt(pow(point2.x - point1.x, 2) + pow(point2.y - point1.y, 2))
    }
}

struct SignatureDetailView: View {
    var signature: Signature

    var body: some View {
        VStack {
            SignatureCanvas(currentSignature: .constant(nil))
                .frame(width: 300, height: 150)
                .border(Color.black, width: 1)

            Button(action: {
                // Implement copy functionality here
                UIPasteboard.general.image = signatureImage(from: signature)
            }) {
                Text("Copy Signature")
            }
        }
        .navigationBarTitle("Signature")
    }

    func signatureImage(from signature: Signature) -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: 300, height: 150))
        let image = renderer.image { ctx in
            ctx.cgContext.setStrokeColor(UIColor.black.cgColor)
            ctx.cgContext.setLineWidth(2)
            for line in signature.lines {
                for (index, point) in line.points.enumerated() {
                    if index == 0 {
                        ctx.cgContext.move(to: point)
                    } else {
                        ctx.cgContext.addLine(to: point)
                    }
                }
            }
            ctx.cgContext.strokePath()
        }
        return image
    }
}

// Struct to represent a single line in the signature
struct Line: Identifiable {
    var id = UUID()
    var points: [CGPoint]
}

// Struct to represent a complete signature
struct Signature: Identifiable {
    var id = UUID()
    var lines: [Line]
}
