import Foundation
import RxSwift

final class PresetViewModel {
    private let useCase = PresetUseCase()

    //    func fetchPresetData() -> Single<[Preset]> {
    //        return Single.zip(useCase.fetch(),
    //                          resultSelector: { (fetchedRecipes, favoRecipeArray) -> [Preset] in
    //                            // TODO: 取得件数が増えると処理量がどんどん増えていくため、要再検討.
    //                            var recipeArray = fetchedRecipes.recipes
    //                            for_a: for (index, recipe) in recipeArray.enumerated() {
    //                                for favoRecipe in favoRecipeArray {
    //                                    if recipe.id == favoRecipe.id {
    //                                        recipeArray[index].isFavorite = favoRecipe.isFavorite
    //                                        continue for_a
    //                                    }
    //                                }
    //                            }
    //                            return recipeArray
    //                        })
    //    }
}
