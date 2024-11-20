//
//  BookView.swift
//  reading-list
//
//  Created by Teddy Barzyk on 11/11/24.
//
import SwiftUI
import CachedAsyncImage

struct BookView: View {
    let book: Book
    let baseURL = "https://covers.openlibrary.org/b/olid/"
    let alreadyAdded: Bool
    @State var selected: Bool = false
    var onTap: (() -> Void)?
    
    var body: some View {
        Button(action: {
            selected.toggle()
            onTap?()
        }, label: {
            ZStack {
                RoundedRectangle(cornerRadius: 15)
                    .fill(.background.secondary)
                    .frame(maxWidth: .infinity, minHeight: 100, maxHeight: 100)
                    .padding(.horizontal, 10)
                HStack {
                    Group {
                        if let coverKey = book.coverKey, let coverURL = URL(string: "\(baseURL)\(coverKey)-M.jpg") {
                            CachedAsyncImage(url: coverURL) { image in
                                image.resizable()
                            } placeholder: {
                                Color.gray
                            }
                            .scaledToFit()
                            .frame(maxHeight: 90)
                            .overlay(
                                RoundedRectangle(cornerRadius: 5)
                                    .stroke(Color.black, lineWidth: 3)
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 5))
                        } else {
                            Spacer().frame(width:20)
                        }
                    }
                    .padding(.leading, 20)
                    VStack (alignment: .leading) {
                        Text(book.title)
                            .font(.headline)
                            .lineLimit(2)
                            .truncationMode(.tail)
                            .multilineTextAlignment(.leading)
                        Text("By: \(book.author)")
                            .bold()
                            .lineLimit(2)
                            .truncationMode(.tail)
                            .multilineTextAlignment(.leading)
                    }
                    .padding(.trailing, 10)
                    
                    Spacer()
                    
                    if alreadyAdded {
                        Image(systemName: "checkmark.circle")
                            .font(.title)
                            .padding(.trailing, 30)
                    }
                }
            }
        })
        .buttonStyle(.plain)
        .disabled(alreadyAdded)
    }
}

#Preview {
    ContentView()
        .environmentObject(AppState())
}
