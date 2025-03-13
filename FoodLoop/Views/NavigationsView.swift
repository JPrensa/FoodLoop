//
//  NavigationsView.swift
//  FoodLoop
//
//  Created by Jefferson Prensa on 21.02.25.
//

import SwiftUI

struct NavigationsView: View {
    @ObservedObject var userViewModel: UserProfileViewModel
    @ObservedObject var userProfileViewModel: UserProfileViewModel
    var body: some View {
        TabView {
            Tab {
                HomeView()
                   // .environmentObject(UserViewModel)
            } label: {
                Label ("Home", systemImage: "house")
            }
            Tab {
                SavedItemsView()
                   // .environmentObject(UserViewModel)
            } label: {
                Label ("Favorites", systemImage: "heart")
            }
            Tab {
                UserView(userViewModel: UserProfileViewModel())
                   // .environmentObject(SnippetViewModel)
            } label: {
                Label ("User", systemImage: "person")
            }
        }
    }
}

#Preview {
    NavigationsView(userViewModel: UserProfileViewModel(), userProfileViewModel: UserProfileViewModel())
}
