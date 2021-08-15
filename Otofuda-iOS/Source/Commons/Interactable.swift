
public protocol Interactable {
    associatedtype Output
    func output(_ handler: ((Output) -> Void)?)
}
