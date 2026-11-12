//
//  Coloring.swift
//  RedheadLab
//
//  Created by Viviane Fernandes on 12/11/26.
//

import Foundation

struct Coloring: Identifiable {
    let id: UUID
    let date: Date // data da aplicação
    var hairBase: HairBase // condição do cabelo antes da coloração
    var products: [ColoringProduct] // produts utilizados
    var mixingRatio: String? // proporção da mistura
    var applicationTime: Int // tempo de pausa
    var photos: [Data] // fotos do resultado
    var notes: String? // observações
}
