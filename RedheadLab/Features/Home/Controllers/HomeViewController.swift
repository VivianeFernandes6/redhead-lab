//
//  HomeViewController.swift
//  RedheadLab
//
//  Created by Viviane Fernandes on 12/11/26.
//

import UIKit

// mantém as listas de produtos e colorações
// responsável por controlar a tela inicial e coordenar o acesso às outras telas
final class HomeViewController: UIViewController { // HomeViewController herda de UIViewController.
    // Por isso, pode utilizar funcionalidades herdadas para controlar
    // o ciclo de vida e a apresentação de telas, como viewDidLoad(),
    // present() e dismiss().
    
    // elemtntos da interface
    // private restringe o acesso às propriedades e métodos
    // ao escopo da própria declaração e às extensões da classe
    // no mesmo arquivo.
    private let titleLabel = UILabel() // nome do app
    private let saveButton = UIButton(type: .system) // guardar - com o type eu posso customizar o botão
    private let viewButton = UIButton(type: .system) //ver
    // organiza outros componentes em uma sequência, horizontal ou vertical
    // a UIStackView organiza seus elementos conforme o eixo definido, controlando também o espaçamento e o alinhamento
    private let contentStackView = UIStackView()
    // cores disponíveis mockadas
    private var colorings = ColoringMockData.colorings
    //produtos disponíveis mockados
    private var products = ColoringMockData.products
    
    // Ciclo de vida
    
    // Método do ciclo de vida de um UIViewController.
    // Chamado quando a view do controller é carregada pela primeira vez.
    
    // Sobrescreve o método viewDidLoad herdado de UIViewController.
    override func viewDidLoad() {
        
        // Chama a implementação original de viewDidLoad da classe pai.
        // Preserva o comportamento da classe pai antes de executar
        // as configurações específicas da Home.
        super.viewDidLoad()
        
        // Executa a função responsável por organizar a interface da Home.
        setupView()
    }
    
    // configurando a interface
    private func setupView() {
        // a view principal recebe a cor de fundo adaptável ao tema do sistema
        view.backgroundColor = .systemBackground
        
        // configurar os elementos
        configureElements()
        // adiciona os elementos à tela
        addElements()
        // define posições dos elementos
        setupConstraints()
    }
    
    // configurando os elementos
    private func configureElements() {
        // defino o texto do nome do app
        titleLabel.text = "Redhead Lab"
        // defino o alinhamento do texto
        titleLabel.textAlignment = .center
        //defino a fonte
        titleLabel.font = .preferredFont(forTextStyle: .largeTitle)
        // Utilizo translatesAutoresizingMaskIntoConstraints = false porque quero definir minhas próprias constraints usando Auto Layout, em vez de deixar o UIKit gerar constraints automaticamente a partir do Autoresizing Mask
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // título para o botão
        saveButton.setTitle("Guardar", for: .normal)
        // configura um evento para o botão
        // addTarget associa um objeto e uma ação a um evento do botão.
        // self indica que a própria HomeViewController receberá a ação.

        // action identifica o método que será executado por meio de #selector.

        // touchUpInside indica que a ação será disparada quando o usuário
        // tocar e soltar o botão dentro de sua área.
        saveButton.addTarget(self, action: #selector(showColoringForm), for: .touchUpInside)
        saveButton.translatesAutoresizingMaskIntoConstraints = false
        
        viewButton.setTitle("Ver", for: .normal)
        viewButton.addTarget(self, action: #selector(showColoringHistory), for: .touchUpInside)
        viewButton.translatesAutoresizingMaskIntoConstraints = false
        
        // Define a orientação da Stack View.
        // Neste caso, os elementos serão organizados verticalmente,
        // de maneira semelhante a uma VStack do SwiftUI.
        contentStackView.axis = .vertical
        // define o alinhamento dos elementos
        contentStackView.alignment = .center
        // define o espaçamento padrão
        contentStackView.spacing = 16
        // define um espaçamento específico após determinado elemento, no caso, o nome do App
        contentStackView.setCustomSpacing(40, after: titleLabel)
        contentStackView.translatesAutoresizingMaskIntoConstraints = false
    }
    
    // adicionando os elementos à tela
    private func addElements() {
        // Adiciona os três componentes à UIStackView,
        // que ficará responsável por organizá-los.
        contentStackView.addArrangedSubview(titleLabel)
        contentStackView.addArrangedSubview(saveButton)
        contentStackView.addArrangedSubview(viewButton)
        // Adiciona a contentStackView à view principal
        // da HomeViewController.
        view.addSubview(contentStackView)
        
        // Hierarquia: a view principal contém a contentStackView,
        // que contém o título e os dois botões.
    }
    
    // definindo as posições
    // aqui uso o Auto Layout
    private func setupConstraints() {
        // Ativa as constraints criadas para que o Auto Layout
        // aplique as regras de posicionamento.
        NSLayoutConstraint.activate([
            // Alinha o centro horizontal da contentStackView
            // ao centro horizontal da view principal.
            contentStackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            // Alinha o centro vertical da contentStackView
            // ao centro vertical da view principal.
            contentStackView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    // @objc permite que o método seja exposto ao Objective-C runtime.
    // Isso é necessário para que possamos referenciá-lo usando #selector
    // no addTarget() dos botões.
    @objc private func showColoringHistory() {
        // instancia a tela de histórico e passo a lista de colorações
        let historyViewController = ColoringHistoryViewController(colorings: colorings)

        // Quando uma coloração for selecionada no histórico,
        // abre os detalhes dentro da mesma pilha de navegação.
        historyViewController.onColoringSelected = { [weak self, weak historyViewController] coloring in
            guard let self, let historyViewController else {
                return
            }

            let detailViewController = ColoringDetailViewController(
                coloring: coloring,
                products: self.products
            )

            detailViewController.onColoringUpdated = { [weak self, weak historyViewController] updatedColoring in
                guard let self,
                      let coloringIndex = self.colorings.firstIndex(where: { $0.id == updatedColoring.id }) else {
                    return
                }

                self.colorings[coloringIndex] = updatedColoring
                historyViewController?.updateColoring(updatedColoring)
            }

            detailViewController.onProductCreated = { [weak self] product in
                self?.products.append(product)
            }

            historyViewController.navigationController?.pushViewController(
                detailViewController,
                animated: true
            )
        }

        // cria o controlador de navegação - UINavigationController
        // gerencia a navegação entre telas e fornece uma barra de navegação (a do histórico de colorações)
        // tem como parametro o rootViewController, que indica qual será a primeira tela dentro desse controlador
        let navigationController = UINavigationController(rootViewController: historyViewController)
        // apresentação em tela cheia
        navigationController.modalPresentationStyle = .fullScreen
        // apresenta o controlador de navegação e indica que a apresentação terá animação
        present(navigationController, animated: true) // a animação é a tela de histórico subindo de baixo pra cima
    }
    
    // para a função de guardar
    // Define o comportamento que será executado quando
    // o formulário informar que uma coloração foi salva.
    @objc private func showColoringForm() {

        let formViewController = ColoringFormViewController(products: products)

        // Define o comportamento que será executado quando
        // um novo produto for cadastrado no formulário.
        formViewController.onProductCreated = { [weak self] product in
            self?.products.append(product)
        }

        // Define o comportamento que será executado quando
        // o formulário informar que uma coloração foi salva.
        formViewController.onSave = { [weak self] coloring in
            self?.colorings.insert(coloring, at: 0)
            self?.dismiss(animated: true)
        }
        // Cria um controlador de navegação tendo o formulário
        // como sua tela raiz.
        let navigationController = UINavigationController(rootViewController: formViewController)
        // Define que a apresentação modal ocupará a tela inteira
        navigationController.modalPresentationStyle = .fullScreen
        // apresenta com animação
        present(navigationController, animated: true)
    }
}

#Preview {
    HomeViewController()
}
