import SwiftUI

struct FeedbackView: View {
    
    @Environment(\.dismiss) var dismiss
    
    @State private var rating: Int = 0 // звезды
    @State private var feedbackText: String = ""
    
    var onSubmit: (_ rating: Int, _ text: String) -> Void
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                
                Text("Rate the app")
                    .font(.headline)
                
                // Звёзды
                HStack {
                    ForEach(1...5, id: \.self) { index in
                        Image(systemName: index <= rating ? "star.fill" : "star")
                            .foregroundColor(.yellow)
                            .font(.largeTitle)
                            .onTapGesture {
                                rating = index
                            }
                    }
                }
                
                // Текстовое поле
                TextEditor(text: $feedbackText)
                    .frame(height: 150)
                    .padding(4)
                    .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.gray))
                
                Spacer()
                
                Button("Submit") {
                    onSubmit(rating, feedbackText)
                    dismiss()
                }
                .buttonStyle(.borderedProminent)
                .disabled(rating == 0 || feedbackText.isEmpty)
            }
            .padding()
            .navigationTitle("Feedback")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }
}
