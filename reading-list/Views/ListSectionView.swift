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
            LinearGradient(gradient: Gradient(colors: [Color.blue.opacity(0.6), Color.main.opacity(1)]), startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()
            VStack {
                Text(title)
                    .font(.system(size: 40, weight: .bold))
                    .foregroundColor(.white)
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
    let statuses = ["reading", "has read", "to read"]
    let baseURL = "https://covers.openlibrary.org/b/olid/"
    var refreshUser: () async -> Void
    
    var body: some View {
        VStack {
            Text("Edit Book")
                .font(.system(size: 40, weight: .bold))
                .padding(20)
            HStack(alignment: .top) {
                Group {
                    if book.bookInfo.coverKey != "", let coverURL = URL(string: "\(baseURL)\(book.bookInfo.coverKey)-M.jpg") {
                        CachedAsyncImage(url: coverURL) { image in
                            image.resizable()
                        } placeholder: {
                            Color.gray
                        }
                        .scaledToFit()
                        .frame(maxHeight: 150)
                        .overlay(
                            RoundedRectangle(cornerRadius: 5)
                                .stroke(Color.black, lineWidth: 3)
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 5))
                    } else {
                        Spacer().frame(width: 20)
                    }
                }
                VStack(alignment: .leading) {
                    Text(book.bookInfo.title)
                        .font(.system(size: 40, weight: .bold))
                        .bold()
                        .lineLimit(2)
                        .truncationMode(.tail)
                        .multilineTextAlignment(.leading)
                    Text("By: \(book.bookInfo.author.name)")
                        .bold()
                }
                Spacer()
            }
            .padding(10)
            if let desc = book.bookInfo.description {
                Text(desc)
                    .padding(.horizontal, 10)
            }
            TextField("Notes", text: $notes)
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
                    await onEditBook()
                }
            }) {
                Text("Save Changes")
                    .font(.system(size: 18, weight: .bold))
                    .frame(maxWidth: .infinity, maxHeight: 50)
                    .background(Color.accentColor)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    .padding([.leading, .trailing, .top])
            }
            .disabled(isLoading)
            Button(action: {
                showDeleteConfirmation = true
            }) {
                Text("Remove Book")
                    .font(.system(size: 18, weight: .bold))
                    .frame(maxWidth: .infinity, maxHeight: 50)
                    .background(Color.red)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    .padding([.leading, .trailing, .top])
            }
            .disabled(isLoading)
            .confirmationDialog(
                "Are you sure you want to remove this book?",
                isPresented: $showDeleteConfirmation,
                titleVisibility: .visible
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
