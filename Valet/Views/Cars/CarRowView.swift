//
//  CarRowView.swift
//  Valet
//
//  Created by Sia Khorsand on 1/14/25.
//

import SwiftUI

struct CarRowView: View {
    @EnvironmentObject var shiftStore: ShiftStore
    var car: Car
       
       var body: some View {
           HStack {
               Image(systemName: "car.fill")
                   .resizable()
                   .scaledToFit()
                   .frame(width: 40, height: 40)
                   .foregroundColor(.blue)
                   .padding(.trailing, 10)
               
               VStack(alignment: .leading) {
                   Text(car.licensePlate)
                       .font(.headline)
                       .foregroundColor(.primary)
                   Text(car.model)
                       .font(.subheadline)
                       .foregroundColor(.secondary)
               }
               Spacer()
           }
           .padding()
           .background(Color(UIColor.systemGray6))
           .cornerRadius(10)
           .shadow(radius: 2)
       }
   }

struct CarRowView_Previews: PreviewProvider {
    static var previews: some View {
        _ = Shift(customerName: "Test Customer", address: "123 Test St")
        let previewCar = Car(
            photo: UIImage(named: "someImage"), licensePlate: "ABC123",
            make: "Toyota",
            model: "Corolla",
            color: "Silver",
            locationParked: "Front Row"
        )
        
        return CarRowView( car: previewCar)
            .environmentObject(ShiftStore())
            .previewLayout(.sizeThatFits)
    }
}
