
public protocol Interactable {
    associatedtype Output
    var handler: ((Output) -> Void)? { get }
    func output(_ handler: ((Output) -> Void)?)
}
