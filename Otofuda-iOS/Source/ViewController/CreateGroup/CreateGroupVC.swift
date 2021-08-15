import Combine
import FirebaseDatabase
import UIKit

final class CreateGroupVC: UIViewController {

    // MARK: - IBOutlets
    @IBOutlet private var qrView: UIImageView!

    @IBOutlet private var memberCountLabel: UILabel! {
        didSet {
            memberCountLabel.text = "現在の人数　　1　　人" // TODO: Localize & 人数の部分だけ切り分け
        }
    }

    // MARK: - Properties
    private var haveMusics: [Music] = []

    private var room: Room!

    private var member: [User] = []

    private var me: User!

    private let viewModel: TopVM
    let environment: Environment
    private var handler: ((Output) -> Void)?

    private var cancellables: [AnyCancellable] = []

    // MARK: - Publishers

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

        let appDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
        let myColor: UIColor = ColorList(index: 0).uiColor
        me = User(index: 0, name: appDelegate.uuid, color: myColor)

        let room = createRoom()
        qrView.image = room.qrImage

        observeMember()
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
                let user = member[i]
                let myColor = ColorList(index: i).uiColor

                self.member.append(User(index: i, name: user, color: myColor))
            }

            self.memberCountLabel.text = "現在の人数　　\(member.count)　　人"
        })
    }

    private func removeObserveMember() {
        FirebaseManager.shared.deleteObserve(path: room.url() + "member")
    }
}

extension CreateGroupVC: StoryboardLoadable {}

extension CreateGroupVC: Injectable {
    struct Input {}

    func input(_: Input) {}
}

extension CreateGroupVC: Interactable {
    enum Output {}

    func output(_ handler: ((Output) -> Void)?) {
        self.handler = handler
    }
}
