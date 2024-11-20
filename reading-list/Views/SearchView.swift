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
    @FocusState private var fieldIsFocused: Bool
    @State private var isLoading: Bool = false
    @State private var hasSearched: Bool = false
    @State private var addingBook: Bool = false
    @State var bookToAdd: Book?
    @Binding var user: User?
    var refreshUser: () async -> Void
    
    var body: some View {
        ZStack {
            VStack {
                HStack {
                    TextField("Search for books", text: $viewModel.searchQuery)
                        .textFieldStyle(.roundedBorder)
                        .focused($fieldIsFocused)
                        .onSubmit {
                            Task {
                                if (!isLoading) {
                                    await performSearch()
                                }
                            }
                        }
                    Button(action: {
                        Task {
                            fieldIsFocused = false
                            await performSearch()
                        }
                    }) {
                        Text("Search")
                            .bold()
                    }
                    .buttonStyle(.borderless)
                    .disabled(isLoading)
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 15)
                if isLoading {
                    ProgressView("Searching...")
                        .padding()
                }
                else if (hasSearched && viewModel.books.count == 0) {
                    Text("No results found")
                        .padding(.top, 20)
                }
                else {
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
                    .scrollDismissesKeyboard(.immediately)
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
        hasSearched = true
        isLoading = false
    }
}

struct AddView: View {
    @Binding var isPresented: Bool
    @Binding var book: Book
    @State var isLoading: Bool = false
    @State private var notes: String = ""
    @State private var selectedStatus: String = "reading"
    @State var addStatus: String = ""
    @State var addBookSuccess: Bool = false
    let statuses = ["has read", "reading", "to read"]
    let baseURL = "https://covers.openlibrary.org/b/olid/"
    var refreshUser: () async -> Void
    
    var body: some View {
        VStack (alignment: .leading) {
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
                        .font(.title)
                        .bold()
                        .lineLimit(2)
                        .truncationMode(.tail)
                        .multilineTextAlignment(.leading)
                    Text("By: \(book.author)")
                        .bold()
                        .lineLimit(2)
                        .truncationMode(.tail)
                        .multilineTextAlignment(.leading)
                }
            }
            .padding(.top, 20)
            
            Text("Notes")
                .font(.headline)
                .padding(.top, 20)
            
            TextEditor(text: $notes)
                .frame(height: 100)
                .scrollContentBackground(.hidden)
                .background(.background.secondary)
                .cornerRadius(5)
            
            Picker("Book Status", selection: $selectedStatus) {
                ForEach(statuses, id: \.self) { status in
                    Text(status).tag(status)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding(.top, 20)
            
            Button(action: {
                Task {
                    await onAddBook()
                }
            }) {
                Text("Add Book")
                    .font(.title3)
                    .bold()
                    .frame(maxWidth: .infinity, maxHeight: 30)
            }
            .padding(.top, 20)
            .buttonStyle(.borderedProminent)
            .disabled(isLoading)
            Text(addStatus)
        }
        .padding(.horizontal, 15)
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

#Preview {
    ContentView()
        .environmentObject(AppState())
}
