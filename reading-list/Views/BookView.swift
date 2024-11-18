//
//  BookView.swift
//  reading-list
//
//  Created by Teddy Barzyk on 11/11/24.
//
import SwiftUI

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
                .fill(Color.main.opacity(0.5))
                .frame(maxWidth: .infinity, minHeight: 120, maxHeight: 120)
                .padding(.horizontal, 10)
                .shadow(color: Color.black.opacity(0.3), radius: 5, x: 0, y: 2)
                HStack {
                    Group {
                        if let coverKey = book.coverKey, let coverURL = URL(string: "\(baseURL)\(coverKey)-M.jpg") {
                            AsyncImage(url: coverURL) { image in
                                image.resizable()
                            } placeholder: {
                                Color.gray
                            }
                            .scaledToFit()
                            .frame(maxHeight: 100)
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
                        .foregroundColor(.textColor)
                        .font(.title3)
                        .bold()
                        .lineLimit(2)
                        .truncationMode(.tail)
                        .multilineTextAlignment(.leading)
                        Text("By: \(book.author)")
                        .foregroundColor(.textColor)
                        .bold()
                    }
                    .padding(.trailing, 10)
                    
                    Spacer()
                    
                    if alreadyAdded {
                        Image(systemName: "checkmark.circle")
                            .font(.title)
                            .foregroundStyle(Color.textColor)
                            .padding(.trailing, 30)
                    }
                }
            }
        })
        .disabled(alreadyAdded)
    }
}
