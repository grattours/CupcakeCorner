//
//  CheckoutView.swift
//  CupcakeCorner
//
//  Created by Luc Derosne on 12/11/2019.
//  Copyright © 2019 Luc Derosne. All rights reserved.
//

import SwiftUI

struct CheckoutView: View {
    @ObservedObject var order: Order
    @State private var confirmationMessage = ""
    @State private var showingConfirmation = false
    @State private var confirmationTitle = ""
    
    var body: some View {
        GeometryReader { geo in
            ScrollView {
                VStack {
                    Image("cupcakes")
                        .resizable()
                        .scaledToFit()
                        .frame(width: geo.size.width)

                    Text("Your total is $\(self.order.cost, specifier: "%.2f")")
                        .font(.title)

                    Button("Place Order") {
                        self.placeOrder()
                    }
                    .padding()
                }
            }
        }
        .navigationBarTitle("Check out", displayMode: .inline)
        .alert(isPresented: $showingConfirmation) {
            Alert(title: Text("Thank you!"), message: Text(confirmationMessage), dismissButton: .default(Text("OK")))
        }
    }
    
    func placeOrder() {
        guard let encoded = try? JSONEncoder().encode(order) else {
            print("Failed to encode order")
            return
        }
        let url = URL(string: "https://reqres.in/api/cupcakes")!
        var request = URLRequest(url: url)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        request.httpBody = encoded
        
        URLSession.shared.dataTask(with: request) { data, response, error in
                    if error != nil {
                        self.confirmationTitle = "Houla, Error !"
                        self.confirmationMessage = error?.localizedDescription ?? "Unknown error"
                        self.showingConfirmation = true
                        return
                    }
                    
                    guard let data = data else {
                        print("No data in response: \(error?.localizedDescription ?? "Unknown error").")
                        return
                    }
                    
                    if let decodedOrder = try? JSONDecoder().decode(Order.self, from: data) {
                        self.confirmationTitle = "Merci !"
                        self.confirmationMessage = "Votre commande de \(decodedOrder.quantity)x \(Order.types[decodedOrder.type].lowercased()) cupcakes est partie !"
                        self.showingConfirmation = true
                    } else {
                        print("Invalid response from server")
                    }
                    
                }.resume()
            }
        }


struct CheckoutView_Previews: PreviewProvider {
    static var previews: some View {
        CheckoutView(order: Order())
    }
}

