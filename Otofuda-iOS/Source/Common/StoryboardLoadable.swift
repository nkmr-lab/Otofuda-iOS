
import UIKit

/// Storyboardからインスタンスを生成可能なプロトコル
public protocol StoryboardLoadable: AnyObject {
    associatedtype Input
    associatedtype Environment
    var environment: Environment { get }
    init?(coder: NSCoder, input: Input, environment: Environment)
}

public extension StoryboardLoadable where Self: UIViewController {
    /// instantiateFromStoryboardのデフォルト実装
    static func loadFromStoryboard(with input: Input, environment: Environment) -> Self {
        let className = String(describing: type(of: self)).replacingOccurrences(of: ".Type", with: "")
        let storyboardName = className.replacingOccurrences(of: "VC", with: "")
        let storyboard = UIStoryboard(name: storyboardName, bundle: Bundle.main)

        guard let viewController = storyboard.instantiateInitialViewController(creator: { coder in
            Self(coder: coder, input: input, environment: environment)
        }
        ) else {
            fatalError("Could not instantiate \(className)")
        }
        return viewController
    }
}

public extension StoryboardLoadable where Self: UIViewController, Input == Void {
    static func loadFromStoryboard(environment: Environment) -> Self {
        loadFromStoryboard(with: (), environment: environment)
    }
}
