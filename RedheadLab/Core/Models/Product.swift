//
//  Product.swift
//  RedheadLab
//
//  Created by Viviane Fernandes on 12/11/26.
//

import Foundation

struct Product: Identifiable {
    let id: UUID
    let brand: String // Marca/fabricante
    let name: String // Nome comercial ou linha
    var shade: String? // Tonalidade, quando aplicável
    let type: ProductType // Categoria do produto
}
