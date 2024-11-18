//
//  AccountView.swift
//  reading-list
//
//  Created by Teddy Barzyk on 11/11/24.
//

import SwiftUI

struct AccountView: View {
    @EnvironmentObject var appState: AppState
    @Binding var path: NavigationPath
    @Binding var user: User?
    
    var body: some View {
        ZStack {
            LinearGradient(gradient: Gradient(colors: [Color.blue.opacity(0.6), Color.main.opacity(1)]), startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()
            VStack {
                Image(systemName: "person.crop.circle")
                    .resizable()
                    .frame(width: 200, height: 200)
                    .foregroundColor(.textColor)
                    .padding(.bottom, 20)
                    .padding(.top, 50)
                if let unwrappedUser = user {
                    Text(unwrappedUser.username)
                        .font(.system(size: 48, weight: .bold))
                        .foregroundColor(.textColor)
                        .padding(10)
                    Text("Email:")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.textColor)
                    Text(unwrappedUser.email)
                        //.background(Color.textColor)
                        .foregroundColor(.textColor)
                        .cornerRadius(2)
                        .padding(.bottom, 20)
                    Text("Member since:")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.textColor)
                    Text(formatDate(unwrappedUser.dateCreated))
                        .foregroundColor(.textColor)
                        .padding(.bottom, 20)
                }
                else {
                    Text("Error getting user data")
                        .foregroundColor(.textColor)
                }
                Button(action: {
                    appState.logout()
                    path = NavigationPath()
                }) {
                    Text("Log out")
                        .padding()
                        .foregroundStyle(Color.textColor)
                        .bold()
                        .frame(maxWidth: 120, maxHeight: 50)
                        .background(Color.accent)
                        .cornerRadius(10)
                        .foregroundColor(.white)
                        .shadow(radius: 5)
                        .font(.title3)
                }
                Spacer()
            }
        }
    }
    
    func formatDate(_ isoDateString: String) -> String {
        // Remove the "Z" at the end of the string (it's the UTC indicator, and we can treat it as a simple time zone)
        let cleanDateString = isoDateString.replacingOccurrences(of: "Z", with: "+0000")
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"  // Specify the exact format including fractional seconds and time zone
        formatter.timeZone = TimeZone(secondsFromGMT: 0)  // Explicitly set the time zone to GMT (UTC)
        
        if let date = formatter.date(from: cleanDateString) {
            let outputFormatter = DateFormatter()
            outputFormatter.dateFormat = "yyyy-MM-dd"  // Desired format
            return outputFormatter.string(from: date)
        } else {
            return "Invalid date"
        }
    }

}

#Preview {
    ContentView()
        .environmentObject(AppState())
}
