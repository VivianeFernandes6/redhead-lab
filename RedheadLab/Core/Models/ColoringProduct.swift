//
//  ColoringProduct.swift
//  
//
//  Created by Viviane Fernandes on 12/11/26.
//
import Foundation

struct ColoringProduct: Identifiable {
    let id: UUID
    let brand: String // marca/fabricante
    let name: String // linha ou nome comercial
    var shade: String? // tonalidade ou numeração da cor
    let type: ProductType // tipo do produto
    let quantity: Double // quantidade usada na fórmula
    let unit: MeasurementUnit // unidade de medida da quanridade
    var oxidantVolume: Int? // volumagem da OX
    
}

enum ProductType {
    case permanentDye
    case semiPermanentDye
    case oxidant
    case other
}


