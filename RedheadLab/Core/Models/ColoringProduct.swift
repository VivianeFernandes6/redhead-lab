//
//  ColoringProduct.swift
//  
//
//  Created by Viviane Fernandes on 12/11/26.
//

import Foundation

struct ColoringProduct: Identifiable {
    let id: UUID
    let product: Product // Produto utilizado na receita
    let quantity: Double // Quantidade utilizada
    let unit: MeasurementUnit // Unidade de medida
    var oxidantVolume: Int? // Volumagem do oxidante, quando aplicável
}

enum ProductType {
    case permanentDye
    case semiPermanentDye
    case oxidant
    case other
}

