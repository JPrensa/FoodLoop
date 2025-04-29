//
//  MyUploadsView.swift
//  FoodLoop
//
//  Created by Jefferson Prensa on 29.04.25.
//

import SwiftUI

struct MyUploadsView: View {
    @ObservedObject var viewModel: UserProfileViewModel
    @Environment(\.dismiss) private var dismiss
    var body: some View {
        NavigationView {
            List {
                if viewModel.userItems.isEmpty {
                    Text("Keine aktiven Uploads")
                } else {
                    ForEach(viewModel.userItems) { item in
                        HStack {
                            Text(item.title)
                            Spacer()
                            Button(role: .destructive) {
                                Task { await viewModel.removeItem(item) }
                            } label: {
                                Image(systemName: "trash")
                            }
                        }
                    }
                }
            }
            .navigationTitle("Meine Uploads")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Schließen") {
                        dismiss()
                    }
                }
            }
        }
        .onAppear {
            Task { await viewModel.fetchUserItems() }
        }
    }
}
