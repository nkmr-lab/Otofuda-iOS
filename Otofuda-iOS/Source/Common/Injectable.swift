
public protocol Injectable {
    associatedtype Input
    func input(_ input: Input)
}
