//
//  UserBookView.swift
//  reading-list
//
//  Created by Teddy Barzyk on 11/14/24.
//

import SwiftUI
import CachedAsyncImage

struct UserBookView: View {
    let book: UserBook
    let baseURL = "https://covers.openlibrary.org/b/olid/"
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
                        if book.bookInfo.coverKey != "", let coverURL = URL(string: "\(baseURL)\(book.bookInfo.coverKey)-M.jpg") {
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
                        Text(book.bookInfo.title)
                            .font(.headline)
                            .lineLimit(2)
                            .truncationMode(.tail)
                            .multilineTextAlignment(.leading)
                        Text("By: \(book.bookInfo.author.name)")
                            .bold()
                            .lineLimit(2)
                            .truncationMode(.tail)
                            .multilineTextAlignment(.leading)
                    }
                    .padding(.trailing, 10)
                    
                    Spacer()
                }
            }
        })
        .buttonStyle(.plain)
    }
}
