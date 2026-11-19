//
//  HairRegionCondition.swift
//  RedheadLab
//
//  Created by Viviane Fernandes on 12/11/26.
//

import Foundation


enum HairCondition {
    case natural // cor natural
    case colored // colorido
    case bleached // descolorido
    case virgin // totalmente virgem de todas as químicas de transformação
    case other
}

struct HairRegionCondition {
    
    let region: HairRegion // região do cabelo
    let condition: HairCondition // condição atual
    var level: Int? // altura do tom
    var undertone: String? // subtom
    var notes: String? // observações adicionais
}
