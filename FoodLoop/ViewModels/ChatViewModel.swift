//
//  ChatViewModel.swift
//  FoodLoop
//
//  Created by Jefferson Prensa on 28.02.25.
//


class ChatViewModel: ObservableObject {
    @Published var messages: [Message] = []
    @Published var conversations: [String: [Message]] = [:]
    @Published var currentReceiverId: String?
    @Published var isLoading = false
    
    func sendMessage(to receiverId: String, content: String, foodItemId: String?) {
        // Senden einer Nachricht
    }
    
    func fetchMessages(for receiverId: String) {
        // Laden von Nachrichten für einen bestimmten Empfänger
    }
    
    func fetchConversations() {
        // Laden aller Konversationen
    }
}