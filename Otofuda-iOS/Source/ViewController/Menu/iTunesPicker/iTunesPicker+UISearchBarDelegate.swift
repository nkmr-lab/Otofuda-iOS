import Alamofire
import AlamofireImage
import PromiseKit
import SwiftyJSON
import UIKit

extension iTunesPickerVC: UISearchBarDelegate {
    // 検索ボタン押下時の呼び出しメソッド
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.endEditing(true)
        searchMusic(keyword: searchBar.text!,
                    attribute: selectedAttribute)
    }

    @IBAction func segmentChanged(_: Any) {
        if segumentView.selectedSegmentIndex == 0 {
            selectedAttribute = "artistTerm"
        } else {
            selectedAttribute = "songTerm"
        }

        searchMusic(keyword: searchBar.text!,
                    attribute: selectedAttribute)
    }

    func searchMusic(keyword _: String, attribute: String) {
        firstly {
            iTunesAPIModel.shared.request(keyword: searchBar.text!,
                                          attribute: attribute)
        }.then { data -> Promise<Results> in
            iTunesAPIModel.shared.mapping(jsonStr: data)
        }.done { results in
            print("done")
            print(results)
            self.results = results
            self.collectionView.reloadData()
        }.catch { error in
            print(error)
        }
    }
}
