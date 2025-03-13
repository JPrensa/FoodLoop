//
//  FoodDetailView.swift
//  FoodLoop
//
//  Created by Jefferson Prensa on 21.02.25.
//

import SwiftUI

struct FoodDetailView: View {
    let foodId:String
    var body: some View {
            ScrollView {
                VStack(alignment: .leading) {
                    Image("groceries")
                        .resizable()
                        .scaledToFit()
                        .cornerRadius(10)
                    
                    HStack {
                        VStack(alignment: .leading) {
                            Text("Apples")
                                .font(.title)
                                .bold()
                            Text("Daniel Koch")
                                .foregroundColor(.gray)
                            HStack {
                                Image(systemName: "star.fill")
                                    .foregroundColor(.green)
                                Text("4.8 (485)")
                            }
                            HStack {
                                Image(systemName: "clock")
                                Text("Pick up: 10.00 - 14.00")
                            }
                        }
                        Spacer()
                        VStack {
//                            Text("$12.00")
//                                .strikethrough()
//                                .foregroundColor(.gray)
//                            Text("$3.99")
//                                .bold()
//                                .foregroundColor(.green)
                        }
                    }
                    .padding()
                    
                    Text("WHAT YOU COULD GET")
                        .bold()
                        .padding(.horizontal)
                    Text("sie können ein paar Äpfel bekommen")
                        .padding(.horizontal)
                    
                    Text("WHAT OTHER PEOPLE ARE SAYING")
                        .bold()
                        .padding(.horizontal)
                    HStack {
                        Image(systemName: "star.fill")
                            .foregroundColor(.green)
                        Text("4.8 / 5.0")
                    }
                    .padding(.horizontal)
                    
                    VStack(alignment: .leading) {
                        Text("HIGHLIGHTS")
                            .bold()
                        HStack {
                            Image(systemName: "smiley")
                            Text("Friendly staff")
                        }
                       
                        
                        HStack {
                            Image(systemName: "clock")
                            Text("Convenien pickup time")
                        }
                    }
                    .padding(.horizontal)
                    
                    Button(action: {}) {
                        Text("Reserve")
                            .bold()
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.green)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    .padding()
                }
            }
        }
    }

#Preview {
    FoodDetailView(foodId: "asadsd")
}
