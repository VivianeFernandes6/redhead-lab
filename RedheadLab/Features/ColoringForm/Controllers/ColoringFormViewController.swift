// Esta tela é construída programaticamente: os componentes são criados e configurados pelo código Swift, em vez de serem montados em um Storyboard.

// Importa o framework que fornece o seletor de fotos do sistema.
import PhotosUI

// Importa UIKit, que contém UIViewController, UILabel, UIButton,
// UIStackView, Auto Layout e outros componentes de interface.
import UIKit

// Este controller coordena a tela de cadastro de uma coloração:
// prepara a interface, recebe os dados e avisa a tela anterior quando o usuário salva.

// 'class' define uma classe.
// 'final' impede que outras classes herdem desta classe.
// A herança de UIViewController dá acesso ao ciclo de vida
// e aos recursos de tela do UIKit.
final class ColoringFormViewController: UIViewController {

    // Closure opcional que recebe um Coloring e não devolve valor (Void).
    // A Home atribui aqui o que deve acontecer quando o formulário for salvo.
    var onSave: ((Coloring) -> Void)?

    // Closure opcional que recebe um Product.
    // A tela que apresentou este formulário pode usá-la para ser avisada
    // quando um produto novo for cadastrado.
    var onProductCreated: ((Product) -> Void)?

    // 'private' restringe o acesso à propriedade.
    // 'let' impede substituir a referência por outra,
    // mas ainda permite configurar o objeto.
    private let scrollView = UIScrollView()

    // Stack principal: receberá as seções do formulário
    // e as organizará verticalmente.
    private let contentStackView = UIStackView()

    // Seletor que fornecerá a data escolhida pelo usuário
    // por meio da propriedade date.
    private let datePicker = UIDatePicker()

    // Campo para a proporção da mistura, por exemplo, "1:1".
    private let mixingRatioTextField = UITextField()

    // Campo para o tempo de aplicação em minutos.
    private let applicationTimeTextField = UITextField()

    // Área de texto para observações livres.
    private let notesTextView = UITextView()

    // Botão que abrirá o seletor de fotografias.
    private let photosButton = UIButton(type: .system)

    // Label que informa quantas fotografias foram selecionadas.
    private let photosCountLabel = UILabel()

    // Stack que receberá uma linha visual para cada produto
    // adicionado ao formulário.
    private let productStackView = UIStackView()

    // Array mutável que guarda as linhas de entrada de produto
    // atualmente adicionadas à interface.
    private var productRows: [ColoringProductInputView] = []

    // Lista de produtos que podem ser escolhidos.
    // Ela é recebida pelo inicializador.
    private var availableProducts: [Product]

    // Guarda os dados das fotografias selecionadas.
    // Data representa bytes, ou seja, os dados binários da imagem.
    private var photos: [Data] = []

    // Guarda os controles de cada região do cabelo:
    // raiz, comprimento e pontas.
    // Assim, conseguimos recuperar as respostas ao salvar.
    private var regionInputs: [RegionInput] = []

    // Inicializador personalizado.
    // Recebe os produtos disponíveis.
    // Se ninguém passar uma lista, usa os produtos mockados.
    init(products: [Product] = ColoringMockData.products) {

        // Copia a lista recebida para a propriedade availableProducts
        // desta instância.
        availableProducts = products

        // Chama o inicializador da classe pai UIViewController.
        // nil/nil indica que não estamos carregando a tela
        // de um arquivo XIB ou Storyboard.
        super.init(nibName: nil, bundle: nil)
    }

    // Inicializador exigido por UIViewController para criação via Storyboard/XIB.
    // Como esta tela foi projetada para ser criada pelo init acima,
    // esta forma não é suportada.
    required init?(coder: NSCoder) {

        // Interrompe a execução com uma mensagem caso alguém tente
        // criar esta tela usando NSCoder/Storyboard.
        fatalError("ColoringFormViewController does not support NSCoder initialization")
    }

    // override indica que estamos fornecendo nossa implementação
    // de um método herdado.
    //
    // viewDidLoad é chamado quando a view do controller termina
    // de ser carregada na memória.
    override func viewDidLoad() {

        // Executa primeiro a implementação de viewDidLoad da classe pai.
        super.viewDidLoad()

        // Depois da configuração herdada, chama nosso método
        // que prepara esta tela.
        setupView()
    }

    // Método privado: só é usado internamente por este controller.
    // É responsável por preparar a interface.
    private func setupView() {

        // Define o título associado a este controller.
        // Quando ele está dentro de um UINavigationController,
        // esse título aparece na barra de navegação.
        title = "Nova coloração"

        // Define o fundo da view principal.
        // .systemBackground se adapta ao modo claro/escuro do iOS.
        view.backgroundColor = .systemBackground

        // Configura o botão da esquerda na barra de navegação.
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            // Usa o item padrão Cancelar fornecido pelo iOS.
            barButtonSystemItem: .cancel,

            // Indica que o próprio ColoringFormViewController
            // receberá a ação do botão.
            target: self,

            // Indica qual método será chamado quando o botão for acionado.
            action: #selector(cancelForm)
        )

        // Configura o botão da direita na barra de navegação.
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            // Texto exibido no botão.
            title: "Salvar",

            // Estilo visual associado a uma ação de conclusão.
            style: .done,

            // Indica que o próprio ColoringFormViewController
            // receberá a ação do botão.
            target: self,

            // Ao tocar em Salvar, o UIKit chamará saveColoring().
            action: #selector(saveColoring)
        )

        // Configura propriedades individuais dos controles:
        // textos auxiliares, teclado, bordas, estilo etc.
        configureFields()

        // Configura como as stacks organizam seus componentes.
        configureStacks()

        // Monta a composição do formulário,
        // adicionando campos e seções às stacks.
        buildForm()

        // Desativa a tradução automática da autoresizing mask
        // em constraints.
        // Assim, controlaremos o posicionamento com Auto Layout.
        scrollView.translatesAutoresizingMaskIntoConstraints = false

        // Faz o mesmo para a stack principal,
        // pois também definiremos suas constraints manualmente.
        contentStackView.translatesAutoresizingMaskIntoConstraints = false

        // Coloca a stack principal dentro da área de conteúdo do scrollView.
        // addSubview adiciona uma view à hierarquia visual.
        scrollView.addSubview(contentStackView)

        // Coloca o scrollView dentro da view principal do controller.
        view.addSubview(scrollView)

        // Cria e ativa em conjunto as regras de Auto Layout.
        // Essas regras definem os limites do scrollView
        // e o tamanho rolável do conteúdo.
        NSLayoutConstraint.activate([

            // Encosta o topo do scrollView no topo da área segura.
            // Isso evita a região ocupada pela barra de navegação.
            scrollView.topAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.topAnchor
            ),

            // Alinha a borda esquerda do scrollView
            // à borda esquerda da view principal.
            scrollView.leadingAnchor.constraint(
                equalTo: view.leadingAnchor
            ),

            // Alinha a borda direita do scrollView
            // à borda direita da view principal.
            scrollView.trailingAnchor.constraint(
                equalTo: view.trailingAnchor
            ),

            // Faz o scrollView alcançar a parte inferior da view principal.
            scrollView.bottomAnchor.constraint(
                equalTo: view.bottomAnchor
            ),

            // Define o início do conteúdo rolável:
            // 20 pontos abaixo do topo da área de conteúdo do scrollView.
            contentStackView.topAnchor.constraint(
                equalTo: scrollView.contentLayoutGuide.topAnchor,
                constant: 20
            ),

            // Mantém a stack 20 pontos afastada
            // da borda esquerda visível do scrollView.
            contentStackView.leadingAnchor.constraint(
                equalTo: scrollView.frameLayoutGuide.leadingAnchor,
                constant: 20
            ),

            // Mantém 20 pontos de margem à direita.
            // O valor negativo indica afastamento para dentro.
            contentStackView.trailingAnchor.constraint(
                equalTo: scrollView.frameLayoutGuide.trailingAnchor,
                constant: -20
            ),

            // Define o final do conteúdo rolável,
            // com 24 pontos de espaço inferior.
            // Essa ligação ajuda o scrollView a calcular
            // a altura total do conteúdo.
            contentStackView.bottomAnchor.constraint(
                equalTo: scrollView.contentLayoutGuide.bottomAnchor,
                constant: -24
            )
        ])
    }

    // Configura os controles que já foram criados
    // como propriedades da classe.
    private func configureFields() {

        // Configura o seletor para escolher somente uma data,
        // sem escolher horário.
        datePicker.datePickerMode = .date

        // Solicita a apresentação compacta do seletor.
        // Normalmente aparece como um controle pequeno que abre
        // a seleção quando é tocado.
        datePicker.preferredDatePickerStyle = .compact

        // Texto de exemplo que aparece enquanto o campo está vazio.
        mixingRatioTextField.placeholder = "Ex.: 1:1"

        // Aplica uma borda arredondada padrão ao campo.
        mixingRatioTextField.borderStyle = .roundedRect

        // Desativa a correção automática,
        // que poderia alterar uma proporção digitada.
        mixingRatioTextField.autocorrectionType = .no

        // Dica exibida enquanto o campo de tempo está vazio.
        applicationTimeTextField.placeholder = "Minutos"

        // Define 30 como valor inicial do campo.
        applicationTimeTextField.text = "30"

        // Solicita um teclado numérico,
        // adequado para informar minutos.
        applicationTimeTextField.keyboardType = .numberPad

        // Aplica borda arredondada ao campo de tempo.
        applicationTimeTextField.borderStyle = .roundedRect

        // Usa uma fonte dinâmica adequada ao texto do corpo
        // e que respeita preferências de acessibilidade.
        notesTextView.font = .preferredFont(forTextStyle: .body)

        // Define a cor da borda usando a cor separadora adaptável do sistema.
        // cgColor é a representação usada pela camada visual.
        notesTextView.layer.borderColor = UIColor.separator.cgColor

        // Define a espessura da borda em 1 ponto.
        notesTextView.layer.borderWidth = 1

        // Arredonda os cantos da área de observações.
        notesTextView.layer.cornerRadius = 8

        // Cria e ativa uma constraint que fixa
        // a altura da área de observações em 110 pontos.
        notesTextView.heightAnchor.constraint(
            equalToConstant: 110
        ).isActive = true

        // Define o texto do botão no estado normal.
        photosButton.setTitle("Adicionar fotografias", for: .normal)

        // Alinha o texto do botão à esquerda,
        // em vez de centralizá-lo.
        photosButton.contentHorizontalAlignment = .leading

        // Liga o toque no botão ao método selectPhotos.
        // .touchUpInside significa que o usuário tocou
        // e soltou dentro do botão.
        photosButton.addTarget(
            self,
            action: #selector(selectPhotos),
            for: .touchUpInside
        )

        // Texto inicial mostrado antes de selecionar fotografias.
        photosCountLabel.text = "Nenhuma fotografia selecionada"

        // Usa uma cor secundária do sistema para dar menos destaque ao texto.
        photosCountLabel.textColor = .secondaryLabel

        // Usa um tamanho tipográfico apropriado para informação auxiliar.
        photosCountLabel.font = .preferredFont(forTextStyle: .footnote)

        // Faz as linhas de produtos serem organizadas uma abaixo da outra.
        productStackView.axis = .vertical

        // Mantém 10 pontos de distância entre as linhas de produto.
        productStackView.spacing = 10
    }

    // Define as regras gerais de organização das stacks principais.
    private func configureStacks() {

        // Organiza as seções do formulário de cima para baixo.
        contentStackView.axis = .vertical

        // Mantém 24 pontos entre cada seção do formulário.
        contentStackView.spacing = 24
    }

    // Monta visualmente o formulário,
    // criando pequenas stacks e adicionando cada seção à stack principal.
    private func buildForm() {

        // Cria uma stack que já recebe o datePicker
        // como elemento organizado.
        // arrangedSubviews são os elementos que a stack gerencia.
        let datePickerContainer = UIStackView(
            arrangedSubviews: [datePicker]
        )

        // Define o eixo vertical para a stack que contém o seletor.
        datePickerContainer.axis = .vertical

        // Centraliza o datePicker no eixo transversal da stack,
        // neste caso, horizontalmente.
        datePickerContainer.alignment = .center

        // Cria uma seção intitulada "Data da aplicação"
        // e adiciona essa seção à stack principal.
        contentStackView.addArrangedSubview(
            makeSection(
                title: "Data da aplicação",
                content: datePickerContainer
            )
        )

        // Cria uma stack que agrupará os controles
        // das três regiões do cabelo.
        let conditionsStack = UIStackView()

        // Organiza as regiões uma abaixo da outra.
        conditionsStack.axis = .vertical

        // Define 16 pontos de espaço entre os controles das regiões.
        conditionsStack.spacing = 16

        // Percorre as três regiões definidas no enum HairRegion:
        // raiz, comprimento e pontas.
        for region in [HairRegion.root, .length, .ends] {

            // Cria um objeto auxiliar RegionInput para a região atual.
            // Ele guarda os campos e a condição escolhida para essa região.
            let input = RegionInput(region: region)

            // Guarda esse objeto no array para recuperar os dados
            // posteriormente, quando o usuário salvar.
            regionInputs.append(input)

            // Pede ao objeto RegionInput que construa suas views
            // e adiciona o resultado à stack das regiões.
            conditionsStack.addArrangedSubview(input.makeView())
        }

        // Adiciona à stack principal a seção que contém
        // raiz, comprimento e pontas.
        contentStackView.addArrangedSubview(
            makeSection(
                title: "Condições do cabelo",
                content: conditionsStack
            )
        )

        // Cria o botão usado para adicionar mais um produto ao formulário.
        let addProductButton = UIButton(type: .system)

        // Define o texto que aparecerá no botão.
        addProductButton.setTitle("＋ Adicionar produto", for: .normal)

        // Alinha o título do botão à esquerda.
        addProductButton.contentHorizontalAlignment = .leading

        // Quando o usuário tocar no botão, chama o método addProduct().
        addProductButton.addTarget(
            self,
            action: #selector(addProduct),
            for: .touchUpInside
        )

        // Agrupa a lista de produtos já adicionados
        // e o botão para adicionar outro produto.
        let productsContent = UIStackView(
            arrangedSubviews: [productStackView, addProductButton]
        )

        // Coloca a lista de produtos acima do botão.
        productsContent.axis = .vertical

        // Define 12 pontos entre a lista e o botão.
        productsContent.spacing = 12

        // Adiciona a seção de produtos à stack principal.
        contentStackView.addArrangedSubview(
            makeSection(
                title: "Produtos utilizados",
                content: productsContent
            )
        )
        
        // Cria uma stack para agrupar os campos relacionados
        // à mistura e aplicação.
        let recipeStack = UIStackView(arrangedSubviews: [

            // Cria um conjunto formado por rótulo e campo
            // para a proporção da mistura.
            labeledField(
                "Proporção da mistura",
                field: mixingRatioTextField
            ),

            // Cria outro conjunto de rótulo e campo
            // para o tempo de aplicação.
            labeledField(
                "Tempo de aplicação (minutos)",
                field: applicationTimeTextField
            )
        ])

        // Organiza os dois campos um abaixo do outro.
        recipeStack.axis = .vertical

        // Define 14 pontos entre os campos.
        recipeStack.spacing = 14

        // Adiciona a seção de mistura e aplicação à stack principal.
        contentStackView.addArrangedSubview(
            makeSection(
                title: "Mistura e aplicação",
                content: recipeStack
            )
        )

        // Agrupa o botão de seleção de fotos
        // e o texto que mostra a quantidade selecionada.
        let photosStack = UIStackView(
            arrangedSubviews: [photosButton, photosCountLabel]
        )

        // Coloca o botão acima do contador de fotos.
        photosStack.axis = .vertical

        // Define 6 pontos entre o botão e o contador.
        photosStack.spacing = 6

        // Adiciona a seção de fotografias à stack principal.
        contentStackView.addArrangedSubview(
            makeSection(
                title: "Fotografias",
                content: photosStack
            )
        )

        // Adiciona a seção final, contendo a área de texto para observações.
        contentStackView.addArrangedSubview(
            makeSection(
                title: "Observações",
                content: notesTextView
            )
        )
    }

    // Método auxiliar que recebe um título e uma view de conteúdo,
    // monta uma seção e devolve a view pronta.
    private func makeSection(
        title: String,
        content: UIView
    ) -> UIView {

        // Cria o rótulo que identificará a seção na tela.
        let titleLabel = UILabel()

        // Usa o texto recebido no parâmetro title como conteúdo do rótulo.
        titleLabel.text = title

        // Aplica um estilo de fonte de título,
        // respeitando as configurações de acessibilidade.
        titleLabel.font = .preferredFont(forTextStyle: .headline)

        // Coloca o título e o conteúdo dentro de uma stack,
        // para que fiquem organizados juntos.
        let stack = UIStackView(
            arrangedSubviews: [titleLabel, content]
        )

        // Organiza esses elementos verticalmente.
        stack.axis = .vertical

        // Define 10 pontos entre o título e o conteúdo.
        stack.spacing = 10

        // Devolve a view montada para ser adicionada à seção.
        return stack
    }

    // Método auxiliar que cria um rótulo para um campo
    // e os agrupa verticalmente.
    //
    // field é UIView para aceitar diferentes tipos de controles.
    private func labeledField(
        _ title: String,
        field: UIView
    ) -> UIView {

        // Cria um rótulo.
        let label = UILabel()

        // Define o texto do rótulo com o título recebido.
        label.text = title

        // Usa um estilo de fonte apropriado para o rótulo de um campo.
        label.font = .preferredFont(forTextStyle: .subheadline)

        // Agrupa o rótulo e o campo em uma stack.
        let stack = UIStackView(
            arrangedSubviews: [label, field]
        )

        // Organiza esses elementos verticalmente.
        stack.axis = .vertical

        // Define o espaço entre rótulo e campo.
        stack.spacing = 6

        // Devolve a view montada.
        return stack
    }

    // Método chamado pelo botão "Adicionar produto".
    // @objc permite que o UIKit o encontre por meio de #selector.
    @objc private func addProduct() {

        // Cria um menu de ações para o usuário escolher
        // um produto ou cadastrar um novo.
        let picker = UIAlertController(
            title: "Adicionar produto",
            message: "Escolha um produto do catálogo local",
            preferredStyle: .actionSheet
        )

        // Percorre todos os produtos disponíveis
        // para criar uma opção no menu para cada um.
        for product in availableProducts {

            // Se o produto tiver tonalidade, cria um texto
            // com um separador e a tonalidade.
            // Se shade for nil, usa uma string vazia.
            let shade = product.shade.map {
                " · \($0)"
            } ?? ""

            // Adiciona uma opção ao menu.
            // Quando o usuário escolhe, a closure é executada.
            //
            // [weak self] evita que a closure mantenha
            // este controller vivo por uma referência forte.
            picker.addAction(
                UIAlertAction(
                    title: "\(product.brand) \(product.name)\(shade)",
                    style: .default
                ) { [weak self] _ in

                    // Se o controller ainda existir,
                    // adiciona uma linha visual para o produto escolhido.
                    self?.appendProduct(product)
                }
            )
        }

        // Adiciona uma opção para abrir o formulário
        // de cadastro de um produto novo.
        picker.addAction(
            UIAlertAction(
                title: "Cadastrar novo produto…",
                style: .default
            ) { [weak self] _ in

                // Agenda o trabalho na fila principal,
                // usada para atualizações da interface.
                DispatchQueue.main.async { [weak self] in

                    // Se o controller ainda existir,
                    // apresenta o formulário de novo produto.
                    self?.showNewProductForm()
                }
            }
        )

        // Adiciona a opção padrão de cancelar e fechar o menu.
        picker.addAction(
            UIAlertAction(title: "Cancelar", style: .cancel)
        )

        // No iPad, um action sheet pode aparecer como popover.
        // Esta condição verifica se essa apresentação está disponível.
        if let popover = picker.popoverPresentationController {

            // Usa o botão Salvar da barra de navegação
            // como âncora visual do popover no iPad.
            popover.barButtonItem = navigationItem.rightBarButtonItem
        }

        // Apresenta o menu.
        present(picker, animated: true)
    }

    // Cria e apresenta outra tela para cadastrar
    // um produto que ainda não existe no catálogo.
    private func showNewProductForm() {

        // Cria uma instância da tela responsável
        // pelo cadastro de um produto.
        let productViewController = NewProductViewController()

        // Define o que acontecerá quando a tela de novo produto salvar.
        // A closure recebe o produto e captura este controller fracamente.
        productViewController.onSave = { [weak self] product in

            // Tenta obter uma referência forte temporária a self.
            // Se o controller já não existir, encerra a closure com return.
            guard let self else {
                return
            }

            // Acrescenta o produto recém-cadastrado
            // à lista local deste formulário.
            self.availableProducts.append(product)

            // Avisa opcionalmente a tela que criou este formulário
            // que um produto novo foi cadastrado.
            self.onProductCreated?(product)

            // Também adiciona o produto recém-cadastrado
            // à lista de produtos desta coloração.
            self.appendProduct(product)
        }

        // Coloca a tela de novo produto dentro de um controlador
        // de navegação, que fornece a barra e gerencia a navegação.
        let navigationController = UINavigationController(
            rootViewController: productViewController
        )

        // Solicita que a apresentação modal apareça como uma folha,
        // em vez de ocupar necessariamente a tela inteira.
        navigationController.modalPresentationStyle = .pageSheet

        // Apresenta a tela de cadastro de produto.
        present(navigationController, animated: true)
    }

    // Cria uma linha visual para o produto escolhido
    // e a adiciona ao formulário.
    private func appendProduct(_ product: Product) {

        // Cria o componente de entrada que representa este produto
        // e permite preencher seus detalhes.
        let row = ColoringProductInputView(product: product)

        // Define o que fazer quando o usuário pedir para remover esta linha.
        //
        // [weak self, weak row] captura ambos por referências fracas,
        // evitando retenções desnecessárias entre os objetos envolvidos.
        row.onRemove = { [weak self, weak row] in

            // Converte as referências fracas em referências fortes temporárias.
            // Se qualquer objeto não existir mais, não continua.
            guard let self, let row else {
                return
            }

            // Remove do array a mesma instância de row.
            // === compara identidade de objetos de classe,
            // não apenas igualdade de valores.
            self.productRows.removeAll {
                $0 === row
            }

            // Remove row da lista de elementos
            // que a UIStackView organiza.
            self.productStackView.removeArrangedSubview(row)

            // Remove row também da hierarquia visual da view.
            // As duas remoções têm papéis relacionados, mas distintos.
            row.removeFromSuperview()
        }

        // Guarda a linha no array para recuperar seus dados quando salvar
        // e para poder removê-la depois.
        productRows.append(row)

        // Adiciona a linha à stack que organiza verticalmente os produtos.
        productStackView.addArrangedSubview(row)
    }

    // Método chamado pelo botão de fotografias.
    // Abre o seletor de imagens do sistema.
    @objc private func selectPhotos() {

        // Cria uma configuração para determinar
        // o que o seletor de fotos permitirá escolher.
        var configuration = PHPickerConfiguration()

        // Limita a seleção a imagens,
        // excluindo vídeos e outros tipos de mídia.
        configuration.filter = .images

        // Define limite zero.
        // No PHPicker, isso significa permitir seleção
        // sem um limite fixo de quantidade.
        configuration.selectionLimit = 0

        // Cria o seletor de fotos do iOS
        // usando a configuração acima.
        let picker = PHPickerViewController(
            configuration: configuration
        )

        // Define este controller como delegado.
        // Ele receberá a notificação quando o usuário terminar a seleção.
        picker.delegate = self

        // Apresenta o seletor de fotos.
        present(picker, animated: true)
    }

    // Atualiza o texto que informa quantas fotografias foram selecionadas.
    private func updatePhotosCount() {

        // Usa um operador ternário:
        // se photos estiver vazio, mostra a primeira mensagem;
        // caso contrário, mostra a quantidade.
        photosCountLabel.text = photos.isEmpty
            ? "Nenhuma fotografia selecionada"
            : "\(photos.count) fotografia(s) selecionada(s)"
    }
    // Método chamado quando o usuário toca no botão Salvar.
    @objc private func saveColoring() {

        // Fecha o teclado antes de validar e salvar os dados.
        view.endEditing(true)

        // Verifica se pelo menos um produto foi adicionado.
        // ! significa negação: !productRows.isEmpty significa
        // que productRows NÃO está vazio.
        guard !productRows.isEmpty else {

            // Se nenhum produto foi adicionado,
            // apresenta uma mensagem explicando o problema.
            showValidationMessage("Adicione pelo menos um produto.")

            // Interrompe a execução do método.
            return
        }

        // Percorre todas as linhas de produtos.
        //
        // compactMap executa makeColoringProduct() em cada linha
        // e mantém somente os resultados que não forem nil.
        let products = productRows.compactMap {
            $0.makeColoringProduct()
        }

        // Verifica se todos os produtos conseguiram ser convertidos.
        //
        // Se a quantidade de resultados for diferente da quantidade
        // de linhas, significa que pelo menos uma conversão falhou.
        guard products.count == productRows.count else {

            // Informa que o usuário precisa conferir
            // a quantidade preenchida para cada produto.
            showValidationMessage(
                "Confira a quantidade informada para cada produto."
            )

            // Interrompe a execução.
            return
        }

        // Tenta converter o texto do campo de tempo para Int.
        //
        // text retorna uma String opcional.
        // ?? "" fornece uma string vazia caso o texto seja nil.
        //
        // Int() tenta converter a String para um número inteiro.
        //
        // applicationTime > 0 verifica se o valor é maior que zero.
        guard let applicationTime = Int(
            applicationTimeTextField.text ?? ""
        ), applicationTime > 0 else {

            // Apresenta uma mensagem caso o tempo seja inválido.
            showValidationMessage(
                "Informe o tempo de aplicação em minutos."
            )

            // Interrompe a execução.
            return
        }

        // Cria um objeto HairBase.
        //
        // regionInputs.map percorre cada entrada de região
        // e chama makeCondition() para produzir uma HairRegionCondition.
        //
        // photo: nil significa que, neste ponto,
        // não estamos associando uma fotografia à HairBase.
        let hairBase = HairBase(
            regions: regionInputs.map {
                $0.makeCondition()
            },
            photo: nil
        )

        // Cria o objeto Coloring com todas as informações
        // preenchidas pelo usuário no formulário.
        let coloring = Coloring(

            // Gera um identificador único para esta coloração.
            id: UUID(),

            // Obtém a data selecionada no UIDatePicker.
            date: datePicker.date,

            // Associa as informações sobre a base do cabelo.
            hairBase: hairBase,

            // Associa os produtos utilizados.
            products: products,

            // Obtém o texto da proporção.
            //
            // trimmingCharacters remove espaços e quebras de linha
            // do início e do final da String.
            //
            // nilIfEmpty transforma uma String vazia em nil.
            mixingRatio: mixingRatioTextField.text?
                .trimmingCharacters(in: .whitespacesAndNewlines)
                .nilIfEmpty,

            // Guarda o tempo de aplicação convertido para Int.
            applicationTime: applicationTime,

            // Guarda os dados das fotografias selecionadas.
            photos: photos,

            // Obtém as observações.
            // Remove espaços desnecessários nas extremidades
            // e transforma texto vazio em nil.
            notes: notesTextView.text
                .trimmingCharacters(in: .whitespacesAndNewlines)
                .nilIfEmpty
        )

        // Executa a closure onSave se alguém tiver atribuído uma.
        //
        // O formulário entrega o Coloring pronto
        // à tela que o apresentou.
        onSave?(coloring)
    }

    // Método auxiliar para mostrar mensagens de validação.
    // Recebe o texto que será exibido.
    private func showValidationMessage(_ message: String) {

        // Cria um alerta modal com título e mensagem.
        let alert = UIAlertController(
            title: "Confira o formulário",
            message: message,
            preferredStyle: .alert
        )

        // Adiciona um botão OK para o usuário fechar o alerta.
        alert.addAction(
            UIAlertAction(title: "OK", style: .default)
        )

        // Apresenta o alerta.
        present(alert, animated: true)
    }

    // Método conectado ao botão Cancelar da barra de navegação.
    @objc private func cancelForm() {

        // Fecha a apresentação modal atual,
        // retornando à tela que apresentou este formulário.
        dismiss(animated: true)
    }

    // Classe auxiliar privada usada apenas dentro de ColoringFormViewController.
    //
    // Cada instância representa os campos de uma região do cabelo:
    // raiz, comprimento ou pontas.
    private final class RegionInput {

        // Guarda qual região esta instância representa.
        let region: HairRegion

        // Botão que abrirá um menu para escolher a condição do cabelo.
        private let conditionButton = UIButton(type: .system)

        // Guarda a condição atualmente escolhida.
        // Começa como natural.
        private var selectedCondition: HairCondition = .natural

        // Campo para informar a altura/nível do tom.
        private let levelTextField = UITextField()

        // Campo para informar o subtom.
        private let undertoneTextField = UITextField()

        // Campo para observações específicas desta região.
        private let notesTextField = UITextField()

        // Inicializa esta entrada recebendo a região que ela representará.
        init(region: HairRegion) {

            // self.region é a propriedade da instância.
            // region é o parâmetro recebido.
            // Atribuímos o parâmetro à propriedade.
            self.region = region
        }

        // Constrói os componentes visuais desta região
        // e devolve uma UIView que poderá ser colocada em outra stack.
        func makeView() -> UIView {

            // Cria o rótulo que identificará a região.
            let titleLabel = UILabel()

            // Usa o nome legível calculado pela propriedade regionTitle.
            titleLabel.text = regionTitle

            // Define uma fonte de subtítulo.
            titleLabel.font = .preferredFont(forTextStyle: .subheadline)

            // Define o texto inicial do botão,
            // indicando que a condição inicial é Natural.
            conditionButton.setTitle("Natural ▾", for: .normal)

            // Alinha o texto do botão à esquerda.
            conditionButton.contentHorizontalAlignment = .leading

            // Faz o menu do botão abrir diretamente
            // quando o usuário toca nele.
            conditionButton.showsMenuAsPrimaryAction = true

            // Cria uma lista de pares:
            //
            // O primeiro valor é o texto mostrado ao usuário.
            // O segundo valor é o caso do enum HairCondition
            // que será armazenado.
            let conditionOptions: [(String, HairCondition)] = [

                // Opção visível "Natural", associada ao caso .natural.
                ("Natural", .natural),

                // Opção visível "Colorido", associada ao caso .colored.
                ("Colorido", .colored),

                // Opção visível "Descolorido", associada ao caso .bleached.
                ("Descolorido", .bleached),

                // Opção visível "Virgem", associada ao caso .virgin.
                ("Virgem", .virgin),

                // Opção para qualquer outra condição.
                ("Outro", .other)
            ]

            // Cria um menu usando map.
            //
            // Para cada par de opções, produz uma UIAction
            // que será exibida no botão.
            conditionButton.menu = UIMenu(
                children: conditionOptions.map { title, condition in

                    // Cria uma ação do menu.
                    // Quando escolhida, a closure recebe o toque.
                    //
                    // [weak self] evita manter RegionInput vivo
                    // somente por causa da ação armazenada.
                    UIAction(title: title) { [weak self] _ in

                        // Se esta entrada ainda existir,
                        // atualiza a condição escolhida.
                        self?.selectedCondition = condition

                        // Atualiza o texto do botão
                        // para mostrar a opção selecionada.
                        self?.conditionButton.setTitle(
                            "\(title) ▾",
                            for: .normal
                        )
                    }
                }
            )

            // Dica exibida no campo de altura do tom.
            levelTextField.placeholder = "Altura do tom"

            // Solicita teclado numérico para a altura do tom.
            levelTextField.keyboardType = .numberPad

            // Aplica borda arredondada.
            levelTextField.borderStyle = .roundedRect

            // Dica com exemplo do tipo de informação esperado.
            undertoneTextField.placeholder = "Subtom (ex.: dourado)"

            // Aplica borda arredondada.
            undertoneTextField.borderStyle = .roundedRect

            // Dica para uma observação específica da região.
            notesTextField.placeholder = "Observação da região"

            // Aplica borda arredondada.
            notesTextField.borderStyle = .roundedRect

            // Agrupa os três campos de detalhe desta região.
            let details = UIStackView(
                arrangedSubviews: [
                    levelTextField,
                    undertoneTextField,
                    notesTextField
                ]
            )

            // Organiza os campos um abaixo do outro.
            details.axis = .vertical

            // Define 8 pontos entre os campos.
            details.spacing = 8

            // Agrupa o título da região, o botão de condição
            // e a stack de detalhes.
            let stack = UIStackView(
                arrangedSubviews: [
                    titleLabel,
                    conditionButton,
                    details
                ]
            )

            // Organiza esses elementos verticalmente.
            stack.axis = .vertical

            // Define 8 pontos entre título, botão e detalhes.
            stack.spacing = 8

            // Devolve a view montada para ser adicionada
            // à seção de condições.
            return stack
        }

        // Lê o que o usuário preencheu nesta região
        // e converte em um modelo HairRegionCondition.
        func makeCondition() -> HairRegionCondition {

            // Cria e devolve o modelo com os valores coletados.
            return HairRegionCondition(

                // Guarda a região representada por esta entrada.
                region: region,

                // Guarda a condição selecionada no menu.
                condition: selectedCondition,

                // Tenta converter a altura do tom para Int.
                // Se não for um número válido, o resultado será nil.
                level: Int(levelTextField.text ?? ""),

                // Remove espaços das extremidades
                // e transforma texto vazio em nil.
                undertone: undertoneTextField.text?
                    .trimmingCharacters(in: .whitespacesAndNewlines)
                    .nilIfEmpty,

                // Faz o mesmo tratamento para a observação da região.
                notes: notesTextField.text?
                    .trimmingCharacters(in: .whitespacesAndNewlines)
                    .nilIfEmpty
            )
        }

        // Propriedade calculada:
        // não armazena um texto fixo; calcula o título
        // conforme o valor de region.
        private var regionTitle: String {

            // Verifica qual caso do enum HairRegion
            // esta instância representa.
            switch region {

            // Se for raiz, devolve o texto "Raiz".
            case .root:
                return "Raiz"

            // Se for comprimento, devolve "Comprimento".
            case .length:
                return "Comprimento"

            // Se for pontas, devolve "Pontas".
            case .ends:
                return "Pontas"
            }
        }
    }
}

// Adiciona conformidade ao protocolo do seletor de fotos.
//
// Isso permite que este controller receba
// o resultado da seleção.
extension ColoringFormViewController: PHPickerViewControllerDelegate {

    // Método exigido pelo protocolo.
    // O sistema o chama quando o usuário termina
    // ou cancela a seleção de fotos.
    func picker(
        _ picker: PHPickerViewController,
        didFinishPicking results: [PHPickerResult]
    ) {

        // Fecha o seletor de fotos.
        picker.dismiss(animated: true)

        // Percorre os resultados, considerando apenas aqueles
        // cujo itemProvider consegue carregar uma UIImage.
        for result in results
        where result.itemProvider.canLoadObject(ofClass: UIImage.self) {

            // Solicita o carregamento da imagem.
            //
            // A operação é assíncrona: a closure pode ser executada
            // depois, por isso captura self fracamente.
            result.itemProvider.loadObject(
                ofClass: UIImage.self
            ) { [weak self] object, _ in

                // Confirma que o objeto carregado é uma UIImage
                // e tenta convertê-lo para JPEG com qualidade 0.8.
                //
                // Se qualquer etapa falhar, encerra esta execução.
                guard let image = object as? UIImage,
                      let data = image.jpegData(compressionQuality: 0.8)
                else {
                    return
                }

                // Atualizações da interface devem ocorrer na fila principal.
                // Agenda a alteração do array e do label nessa fila.
                DispatchQueue.main.async {

                    // Se o controller ainda existir,
                    // guarda os bytes da imagem no array photos.
                    self?.photos.append(data)

                    // Atualiza o texto que informa quantas fotos
                    // foram selecionadas.
                    self?.updatePhotosCount()
                }
            }
        }
    }
}

// Extensão privada de String:
// adiciona uma propriedade auxiliar disponível neste arquivo.
private extension String {

    // Propriedade calculada que devolve nil se a String estiver vazia.
    // Caso contrário, devolve a própria String.
    var nilIfEmpty: String? {

        // Operador ternário:
        // se isEmpty for true, retorna nil;
        // se for false, retorna self (a String original).
        isEmpty ? nil : self
    }
}

#Preview("Coloring Form") {
    UINavigationController(rootViewController: ColoringFormViewController())
}
