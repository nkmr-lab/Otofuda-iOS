
import Foundation

public protocol Bindable {
    associatedtype ViewModel
    associatedtype ViewModelOutput

    var viewModel: ViewModel { get }

    func bind(to viewModel: ViewModel)
    func bindOutput(_ output: ViewModelOutput)
}
