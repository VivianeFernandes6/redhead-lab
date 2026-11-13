//
//  ColoringMockData.swift
//  RedheadLab
//
//  Created by Viviane Fernandes on 12/11/26.
//



import Foundation

enum ColoringMockData {

    // MARK: - Products

    static let koleston = Product(
        id: UUID(),
        brand: "Wella",
        name: "Koleston Perfect",
        shade: "7/4",
        type: .permanentDye
    )

    static let majirel = Product(
        id: UUID(),
        brand: "L'Oréal",
        name: "Majirel",
        shade: "8.1",
        type: .permanentDye
    )

    static let welloxon = Product(
        id: UUID(),
        brand: "Wella",
        name: "Welloxon",
        shade: nil,
        type: .oxidant
    )

    static let raposinha = Product(
        id: UUID(),
        brand: "Kamaleão Color",
        name: "Raposinha",
        shade: "Ruivo Acobreado",
        type: .semiPermanentDye
    )

    static let desejo = Product(
        id: UUID(),
        brand: "Beleza Ruiva",
        name: "Desejo",
        shade: "Ruivo Cobre Intenso",
        type: .semiPermanentDye
    )
    
    
    // MARK: - Coloring Products

    static let firstColoringProducts: [ColoringProduct] = [
        ColoringProduct(
            id: UUID(),
            product: koleston,
            quantity: 30,
            unit: .grams,
            oxidantVolume: nil
        ),
        ColoringProduct(
            id: UUID(),
            product: welloxon,
            quantity: 30,
            unit: .milliliters,
            oxidantVolume: 20
        )
    ]

    static let secondColoringProducts: [ColoringProduct] = [
        ColoringProduct(
            id: UUID(),
            product: raposinha,
            quantity: 50,
            unit: .grams,
            oxidantVolume: nil
        ),
        ColoringProduct(
            id: UUID(),
            product: desejo,
            quantity: 50,
            unit: .grams,
            oxidantVolume: nil
        )
    ]
    
    
    // MARK: - Colorings

    static let colorings: [Coloring] = [
        Coloring(
            id: UUID(),
            date: Date(),
            hairBase: HairBase(
                regions: [
                    HairRegionCondition(
                        region: .root,
                        condition: .natural,
                        level: 6,
                        undertone: "Dourado",
                        notes: nil
                    ),
                    HairRegionCondition(
                        region: .length,
                        condition: .colored,
                        level: 7,
                        undertone: "Acobreado",
                        notes: nil
                    ),
                    HairRegionCondition(
                        region: .ends,
                        condition: .colored,
                        level: 7,
                        undertone: "Acobreado",
                        notes: "Pontas levemente ressecadas"
                    )
                ],
                photo: nil
            ),
            products: firstColoringProducts,
            mixingRatio: "1:1",
            applicationTime: 40,
            photos: [],
            notes: "Primeiro registro de teste."
        ),

        Coloring(
            id: UUID(),
            date: Date().addingTimeInterval(-30 * 24 * 60 * 60),
            hairBase: HairBase(
                regions: [
                    HairRegionCondition(
                        region: .root,
                        condition: .colored,
                        level: 7,
                        undertone: "Acobreado",
                        notes: nil
                    ),
                    HairRegionCondition(
                        region: .length,
                        condition: .colored,
                        level: 7,
                        undertone: "Acobreado",
                        notes: nil
                    ),
                    HairRegionCondition(
                        region: .ends,
                        condition: .bleached,
                        level: 8,
                        undertone: "Amarelado",
                        notes: nil
                    )
                ],
                photo: nil
            ),
            products: secondColoringProducts,
            mixingRatio: nil,
            applicationTime: 30,
            photos: [],
            notes: "Segundo registro de teste."
        )
    ]


}
