import Combine
import CombineCocoa
import FirebaseDatabase
import OtofudaExtension
import UIKit

final class CreateRoomVC: UIViewController, StoryboardLoadable {
    // MARK: - IBOutlets

    @IBOutlet private var qrView: UIImageView!
    @IBOutlet private var memberCountLabel: UILabel! {
        didSet {
            memberCountLabel.text = "1"
        }
    }

    @IBOutlet private var createButton: UIButton!

    // MARK: - Publishers

    // MARK: - Properties

    private var haveMusics: [MusicModel] = []

    private var room: Room!

    private var member: [UserModel] = []

    private var me: UserModel!

    private(set) var viewModel: CreateRoomVM

    let environment: Environment
    private(set) var handler: ((Output) -> Void)?

    private var cancellables: [AnyCancellable] = []

    init?(coder: NSCoder, input _: Input, environment: Environment) {
        self.environment = environment
        viewModel = .init(environment: environment)
        super.init(coder: coder)
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // TODO: ネットワークに繋がっているかの確認をラベルで表示
        me = UserModel(order: 0)

        let room = createRoom()
        qrView.image = room.qrImage

        observeMember()

        bind(to: viewModel)
    }

    deinit {
        FirebaseManager.shared.deleteAllValue(path: room.url())
        removeObserveMember()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: false)
    }

    override func prepare(for segue: UIStoryboardSegue, sender _: Any?) {
        let nextVC = segue.destination as! MenuVC
        room.setMember(member: member)
        nextVC.room = room
        nextVC.isHost = true
        nextVC.haveMusics = haveMusics
        nextVC.me = me
        removeObserveMember()
    }

    private func createRoom() -> Room {
        let roomID = String.getRandomStringWithLength(length: 6)
        let current_date = Date.getCurrentDate()
        room = Room(name: roomID)
        room.addMember(user: me)
        FirebaseManager.shared.post(path: room.url(), value: room.dict())
        FirebaseManager.shared.post(path: room.url() + "date", value: current_date)
        return room
    }

    private func observeMember() {
        FirebaseManager.shared.observe(path: room.url() + "member", completion: { [weak self] snapshot in
            // deinitを呼びたいので強参照させないようにしている
            guard let self = self else { return }

            guard let member = snapshot.value as? [String] else {
                return
            }

            self.member = []
            for i in 0 ..< member.count {
                let userId = member[i]
                self.member.append(UserModel(id: userId, order: i))
            }

            self.memberCountLabel.text = "\(member.count)"
        })
    }

    private func removeObserveMember() {
        FirebaseManager.shared.deleteObserve(path: room.url() + "member")
    }
}

extension CreateRoomVC: Bindable {
    typealias ViewModel = CreateRoomVM
    typealias ViewModelOutput = CreateRoomVM.Output

    func bind(to viewModel: CreateRoomVM) {
        let input = CreateRoomVM.Input(
            didTappedButton: createButton.tapPublisher
        )

        bindOutput(viewModel.transform(input: input))
    }

    func bindOutput(_ output: CreateRoomVM.Output) {
        cancellables.forEach { $0.cancel() }
        cancellables.removeAll()

        output.transition
            .sink { [weak self] transition in
                switch transition {
                case .create:
                    self?.handler?(.create)
                }
            }.store(in: &cancellables)
    }
}

extension CreateRoomVC: Injectable {
    struct Input {}

    func input(_: Input) {}
}

extension CreateRoomVC: Interactable {
    enum Output {
        case create
    }

    func output(_ handler: ((Output) -> Void)?) {
        self.handler = handler
    }
}
