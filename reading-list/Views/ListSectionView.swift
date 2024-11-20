//
//  ListSectionView.swift
//  reading-list
//
//  Created by Teddy Barzyk on 11/11/24.
//

import SwiftUI
import CachedAsyncImage

struct ListSectionView: View {
    @Binding var books: [UserBook]
    @State private var editingBook: Bool = false
    @State var bookToEdit: UserBook?
    let title: String
    var refreshUser: () async -> Void
    
    var body: some View {
        ZStack {
            VStack {
                Text(title)
                    .font(.system(size: 40, weight: .bold))
                    .padding(.top, 10)
                ScrollView {
                    VStack (spacing: 15) {
                        ForEach(books) { book in UserBookView(book: book, onTap: {
                            bookToEdit = book
                            editingBook = true
                        }) }
                    }
                }
                Spacer()
            }
        }
        .sheet(isPresented: Binding(
            get: { editingBook && bookToEdit != nil },
            set: { newValue in editingBook = newValue }
        )) {
            if let book = bookToEdit {
                EditView(isPresented: $editingBook, book: .constant(book), refreshUser: refreshUser)
            } else {
                Text("No book selected")
            }
        }
    }
}

struct EditView: View {
    @Binding var isPresented: Bool
    @Binding var book: UserBook
    @State var isLoading: Bool = false
    @State private var notes: String = ""
    @State private var selectedStatus: String = "to read"
    @State var editStatus: String = ""
    @State var editBookSuccess: Bool = false
    @State private var showDeleteConfirmation: Bool = false
    let statuses = ["has read", "reading", "to read"]
    let baseURL = "https://covers.openlibrary.org/b/olid/"
    var refreshUser: () async -> Void
    
    var body: some View {
        VStack (alignment: .leading) {
            HStack(alignment: .top) {
                Group {
                    if book.bookInfo.coverKey != "", let coverURL = URL(string: "\(baseURL)\(book.bookInfo.coverKey)-M.jpg") {
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
                        Spacer().frame(width: 20)
                    }
                }
                VStack (alignment: .leading) {
                    Text(book.bookInfo.title)
                        .font(.title)
                        .bold()
                        .lineLimit(2)
                        .truncationMode(.tail)
                        .multilineTextAlignment(.leading)
                    Text("By: \(book.bookInfo.author.name)")
                        .bold()
                        .lineLimit(2)
                        .truncationMode(.tail)
                        .multilineTextAlignment(.leading)
                }
            }
            .padding(.top, 20)
            
            if let desc = book.bookInfo.description {
                Text(desc)
                    .padding(.top, 20)
                    .lineLimit(5)
                    .truncationMode(.tail)
                    .multilineTextAlignment(.leading)
            }
            
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
                    await onEditBook()
                }
            }) {
                Text("Save Changes")
                    .font(.title3)
                    .bold()
                    .frame(maxWidth: .infinity, maxHeight: 30)
            }
            .padding(.top, 20)
            .buttonStyle(.borderedProminent)
            .disabled(isLoading)
            
            Button(action: {
                showDeleteConfirmation = true
            }) {
                Text("Remove Book")
                    .font(.title3)
                    .bold()
                    .frame(maxWidth: .infinity, maxHeight: 30)
            }
            .padding(.top, 20)
            .buttonStyle(.borderedProminent)
            .tint(.red)
            .disabled(isLoading)
            .alert(
                "Are you sure you want to remove this book?",
                isPresented: $showDeleteConfirmation
                //titleVisibility: .visible
            ) {
                Button("Remove", role: .destructive) {
                    Task {
                        await onDeleteBook()
                    }
                }
                Button("Cancel", role: .cancel) {}
            }
            
            Text(editStatus)
        }
        .padding(.horizontal, 15)
        .onAppear {
            notes = book.userInfo.notes
            selectedStatus = book.userInfo.status
        }
        .onChange(of: editBookSuccess) {
            if editBookSuccess {
                isPresented = false
            }
        }
        Spacer()
    }
    private func onEditBook() async {
        let bookListService = BookListService()
        isLoading = true
        do {
            if let token = KeychainHelper.shared.retrieve(forKey: "jwtToken") {
                let _ = try await bookListService.editBook(token: token, id: book.id, notes: notes, status: selectedStatus)
                await refreshUser()
            }
            editBookSuccess = true
            isLoading = false
            editStatus = ""
        } catch {
            editBookSuccess = false
            isLoading = false
            editStatus = "Edit Book Failed: \(error.localizedDescription)"
        }
    }
    
    private func onDeleteBook() async {
        let bookListService = BookListService()
        isLoading = true
        do {
            if let token = KeychainHelper.shared.retrieve(forKey: "jwtToken") {
                let _ = try await bookListService.deleteBook(token: token, id: book.id)
                await refreshUser()
            }
            editBookSuccess = true
            isLoading = false
            editStatus = ""
        } catch {
            editBookSuccess = false
            isLoading = false
            editStatus = "Edit Book Failed: \(error.localizedDescription)"
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(AppState())
}
