//
//   .swift
//  TVShowsTest
//
//  Created by Abel Lazaro on 08/08/23.
//

import UIKit

//MARK: - protocol
protocol DetailsViewControllerDelegate: AnyObject {
    func didUpdateData(_ newData: [TVShowsModel])
}

class DetailsViewController: UIViewController {
    
    //MRK: - properties

    @IBOutlet weak var titleNavBar: UINavigationItem!
    @IBOutlet weak var bannerShowImage: UIImageView!
    @IBOutlet weak var genreLabel: UILabel!
    @IBOutlet weak var runTimeLabel: UILabel!
    @IBOutlet weak var sumaryLabel: UILabel!
    @IBOutlet weak var imdbButton: UIButton!
    @IBOutlet weak var favoriteButton: UIBarButtonItem!
    
    var show = TVShowsModel()
    var favoritesTVShows = [TVShowsModel]()
    
    var isFavorite = false
    
    weak var delegate: DetailsViewControllerDelegate?
    
    //MARK: - cicle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setuView()
    }
    
    //MARK: - helpers
    
    private func setuView() {
        
        recoverfavorites()
        
        if show.show?.externals?.imdb == nil {
            imdbButton.isHidden = true
        }
        
        
        titleNavBar.title = show.show?.name
        
        if let imagen = show.show?.image?.medium {
            bannerShowImage.sd_setImage(with: URL(string: "\(imagen)"))
        }
        
        if show.show?.genres?.count != 0 {
            genreLabel.text = "Genre: " + (show.show?.genres![0] ?? "")
        } else {
            genreLabel.text = "Genere: N/A"
        }
        
        if show.show?.runtime != nil {
            runTimeLabel.text = "RunTime: \((show.show?.runtime) ?? 0) mins."
        } else {
            runTimeLabel.text = "RunTime: "
        }
        
        let inputString = show.show?.summary
        
        sumaryLabel.text = inputString?.replacingOccurrences(of: "<p>", with: "").replacingOccurrences(of: "</p>", with: "").replacingOccurrences(of: "<b>", with: "").replacingOccurrences(of: "</b>", with: "").replacingOccurrences(of: "<i>", with: "").replacingOccurrences(of: "</i>", with: "")
        
    }
    
    private func recoverfavorites() {
        
        if let data = UserDefaults.standard.data(forKey: "favoritesKey") {
            let decoder = JSONDecoder()
            if let decodedShows = try? decoder.decode([TVShowsModel].self, from: data) {
                favoritesTVShows = decodedShows
                print("Objetos cargados desde UserDefaults:", favoritesTVShows)
            }
        }
        let name = show.show?.name
        
        let isFound = favoritesTVShows.contains { $0.show?.name == name }
        
        if isFound {
            isFavorite = true
            favoriteButton.title = "Delete"
        } else {
            favoriteButton.title = "Favorite"
        }
        
    }
    
    //MARK: - actions
    
    @IBAction func favoriteButton(_ sender: Any) {
        
        if isFavorite {
            
            let alertController = UIAlertController(title: "Aviso", message: "Estas apunto de quitar este show como favorito, ¿Estas seguro?", preferredStyle: .alert)
            
            let aceptAction = UIAlertAction(title: "Aceptar", style: .default) { _ in
                
                let name = self.show.show?.name
                
                self.favoritesTVShows.removeAll { show in
                    return show.show?.name == name
                }
                
                let encoder = JSONEncoder()
                if let encodedData = try? encoder.encode(self.favoritesTVShows) {
                    UserDefaults.standard.set(encodedData, forKey: "favoritesKey")
                }
                
                self.delegate?.didUpdateData(self.favoritesTVShows)
                
                self.favoriteButton.title = "Favorite"
                self.isFavorite = false
                
            }
            
            
            let cancelAction = UIAlertAction(title: "Cancelar", style: .cancel) { _ in
            }
            
            alertController.addAction(aceptAction)
            alertController.addAction(cancelAction)
            
            self.present(alertController, animated: true, completion: nil)
            
        } else {
            
            let name = show.show?.name
            
            favoritesTVShows.append(show)
            
            let encoder = JSONEncoder()
            if let encodedData = try? encoder.encode(favoritesTVShows) {
                UserDefaults.standard.set(encodedData, forKey: "favoritesKey")
            }
            
            let isFound = favoritesTVShows.contains { $0.show?.name == name }
            
            if isFound {
                favoriteButton.title = "Delete"
                isFavorite = true
                delegate?.didUpdateData(favoritesTVShows)
            } else {
                SingletonFunctions.shared.showAlert(title: "Oops, algo salió mal!", message: "Hubo un problema al guardar/borrar este show de TV. ¿Quieres intentar nuevamente?", actionDone: UIAlertAction(title: "Ok", style: .default), context: self)
            }
            
        }
        
        if let tvShowsViewController = self.tabBarController?.viewControllers?[0] as? TVShowsViewController {
            tvShowsViewController.checkFavorites = true
        }
        
    }
    
    @IBAction func backButton(_ sender: Any) {
        goBack()
    }
    
    @IBAction func imdbButton(_ sender: Any) {
        
        guard (show.show?.externals?.imdb) != nil  else {
            return
        }
        
        if let url = URL(string: "https://www.imdb.com/title/\((show.show?.externals?.imdb)!)/?ref_=hm_top_tt_i_1") {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
        
    }

}
