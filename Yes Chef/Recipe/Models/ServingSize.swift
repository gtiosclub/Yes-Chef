//
//  ServingSize.swift
//  Yes Chef
//
//  Created by Asutosh Mishra on 9/30/25.
//
enum ServingSize: String ,CaseIterable, Identifiable {
    var id: String { self.rawValue }
    
    case one = "1"
    case two = "2"
    case three = "3"
    case four = "4"
    case five = "5"
    case six = "6"
    case sevenPlus = "+7"
}
