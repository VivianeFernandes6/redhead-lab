//
//  HomeView.swift
//  RedheadLab
//
//  Created by Viviane Fernandes on 26/11/26.
//

import UIKit

final class HomeView: UIView {
    override init(frame: CGRect){
        super.init(frame: frame)
    }
    // minha implementação não oferece suporte à criação por Storyboard ou XIB, logo esse inicializador é obrigatório
    required init?(coder: NSCoder){
        fatalError("HomeView does not support NSCoder initialization")
    }
}
