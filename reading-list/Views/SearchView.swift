//
//  SearchView.swift
//  reading-list
//
//  Created by Teddy Barzyk on 11/11/24.
//

import SwiftUI
import CachedAsyncImage

struct SearchView: View {
    @StateObject private var viewModel = SearchViewModel()
    @State private var isLoading: Bool = false
    @State private var addingBook: Bool = false
    @State var bookToAdd: Book?
    @Binding var user: User?
    var refreshUser: () async -> Void
    
    var body: some View {
        ZStack {
            LinearGradient(gradient: Gradient(colors: [Color.blue.opacity(0.6), Color.main.opacity(1)]), startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()
            VStack {
                HStack {
                    CustomTextField(placeholder: "Search for books", text: $viewModel.searchQuery)
                    Button(action: {
                        Task {
                            await performSearch()
                        }
                    }) {
                        Text("Search")
                            .font(.system(size: 15, weight: .bold))
                            .frame(maxWidth: 100, maxHeight: 40)
                            .background(Color.accent)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                            .shadow(color: .black.opacity(0.2), radius: 5, x: 0, y: 5)
                    }
                }
                .padding(15)
                if isLoading {
                    ProgressView("Searching...")
                        .padding()
                } else {
                    ScrollView {
                        LazyVStack (spacing: 15) {
                            ForEach(viewModel.books) { book in
                                let alreadyAdded = user?.books.contains(where: { $0.key == book.id }) ?? false
                                BookView(book: book, alreadyAdded: alreadyAdded, onTap: {
                                    bookToAdd = book
                                    addingBook = true
                                })
                            }
                        }
                    }
                }
                Spacer()
            }
        }
        .popover(isPresented: Binding(
            get: { addingBook && bookToAdd != nil },
            set: { newValue in addingBook = newValue }
        )) {
            if let book = bookToAdd {
                AddView(isPresented: $addingBook, book: .constant(book), refreshUser: refreshUser)
            } else {
                Text("No book selected")
            }
        }
    }
    
    private func performSearch() async {
        isLoading = true
        await viewModel.performSearch()
        isLoading = false
    }
}

struct AddView: View {
    @Binding var isPresented: Bool
    @Binding var book: Book
    @State var isLoading: Bool = false
    @State private var notes: String = ""
    @State private var selectedStatus: String = "to read"
    @State var addStatus: String = ""
    @State var addBookSuccess: Bool = false
    let statuses = ["reading", "has read", "to read"]
    let baseURL = "https://covers.openlibrary.org/b/olid/"
    var refreshUser: () async -> Void
    
    var body: some View {
        VStack {
            Text("Add Book")
                .font(.system(size: 40, weight: .bold))
                .padding(20)
            HStack (alignment: .top) {
                Group {
                    if let coverKey = book.coverKey, let coverURL = URL(string: "\(baseURL)\(coverKey)-M.jpg") {
                        CachedAsyncImage(url: coverURL) { image in
                            image.resizable()
                        } placeholder: {
                            Color.gray
                        }
                        .scaledToFit()
                        .frame(maxHeight: 200)
                        .overlay(
                            RoundedRectangle(cornerRadius: 5)
                                .stroke(Color.black, lineWidth: 3)
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 5))
                    } else {
                        Spacer().frame(width:30)
                    }
                }
                VStack (alignment: .leading) {
                    Text(book.title)
                        .font(.system(size: 40, weight: .bold))
                        .bold()
                        .lineLimit(2)
                        .truncationMode(.tail)
                        .multilineTextAlignment(.leading)
                    Text("By: \(book.author)")
                        .bold()
                }
            }
            .padding(.horizontal, 10)
            TextField("Enter notes", text: $notes)
                .padding()
                .background(Color.gray.opacity(0.2))
                .cornerRadius(8)
                .frame(height: 100)
                .padding([.leading, .trailing])
            
            Picker("Book Status", selection: $selectedStatus) {
                ForEach(statuses, id: \.self) { status in
                    Text(status).tag(status)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding([.leading, .trailing])
            
            Button(action: {
                Task {
                    await onAddBook()
                }
            }) {
                Text("Add Book")
                    .font(.system(size: 18, weight: .bold))
                    .frame(maxWidth: .infinity, maxHeight: 50)
                    .background(Color.accentColor)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    .padding([.leading, .trailing, .top])
            }
            .disabled(isLoading)
            Text(addStatus)
        }
        .onChange(of: addBookSuccess) {
            if addBookSuccess {
                isPresented = false
            }
        }
        Spacer()
    }
    private func onAddBook() async {
        let bookListService = BookListService()
        isLoading = true
        do {
            if let token = KeychainHelper.shared.retrieve(forKey: "jwtToken") {
                if let coverKey = book.coverKey
                {
                    let _ = try await bookListService.addNewBook(token: token, key: $book.id, notes: notes, status: selectedStatus, coverKey: coverKey)
                }
                else {
                    let _ = try await bookListService.addNewBook(token: token, key: $book.id, notes: notes, status: selectedStatus, coverKey: "")
                }
                await refreshUser()
            }
            addBookSuccess = true
            isLoading = false
            addStatus = ""
        } catch {
            addBookSuccess = false
            isLoading = false
            addStatus = "Add Book Failed: \(error.localizedDescription)"
        }
    }
}
