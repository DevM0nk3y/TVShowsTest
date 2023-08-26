//
//  FavoritesViewController.swift
//  TVShowsTest
//
//  Created by Abel Lazaro on 08/08/23.
//

import UIKit

class FavoritesViewController: UIViewController {
    
    //MARK: - properties
    
    @IBOutlet weak var tableView: UITableView!
    
    var favoritesTVShows = [TVShowsModel]()
    
    //MARK: - cicle

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.reloadData()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        setupData()
        
        tableView.reloadData()
        
    }
    
    //MARK: - helpers
    
    private func setupData() {
        
        if let tvShowsViewController = self.tabBarController?.viewControllers?[0] as? TVShowsViewController {
            tvShowsViewController.checkFavorites = true
        }

        
        if let data = UserDefaults.standard.data(forKey: "favoritesKey") {
            let decoder = JSONDecoder()
            if let decodedShows = try? decoder.decode([TVShowsModel].self, from: data) {
                favoritesTVShows = decodedShows
                print("Objetos cargados desde UserDefaults:", favoritesTVShows)
            }
        }
        
    }
    

}

extension FavoritesViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return favoritesTVShows.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! TVShowsTableViewCell
        
        cell.titleLabel.text = favoritesTVShows[indexPath.row].show?.name
        
        if let imagen = favoritesTVShows[indexPath.row].show?.image?.medium {
            cell.tvShowImage.sd_setImage(with: URL(string: "\(imagen)"))
        }
        
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let viewController : DetailsViewController = UIStoryboard(name: "DetailsView", bundle: nil).instantiateViewController(withIdentifier: "DetailsViewController") as! DetailsViewController
        
        viewController.show = favoritesTVShows[indexPath.row]
        viewController.delegate = self
        
        viewController.providesPresentationContextTransitionStyle = true
        viewController.definesPresentationContext = true
        viewController.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
        self.present(viewController, animated: true, completion: nil)
        
        nextViewController(viewController: "DetailsViewController", storyboard: "DetailsView")
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 150
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { (action, view, completion) in
            print("===Eliminado===")
            
            let alertController = UIAlertController(title: "Aviso", message: "Estas apunto de quitar este show como favorito, ¿Estas seguro?", preferredStyle: .alert)
            
            let aceptAction = UIAlertAction(title: "Aceptar", style: .default) { _ in
                
                let name = self.favoritesTVShows[indexPath.row].show?.name
                
                self.favoritesTVShows.removeAll { show in
                    return show.show?.name == name
                }
                
                let encoder = JSONEncoder()
                if let encodedData = try? encoder.encode(self.favoritesTVShows) {
                    UserDefaults.standard.set(encodedData, forKey: "favoritesKey")
                }
                
                self.tableView.reloadData()
                
                let isFound = self.favoritesTVShows.contains { $0.show?.name == name }
                
                if isFound {
                    SingletonFunctions.shared.showAlert(title: "Oops, algo salió mal!", message: "Hubo un problema al borrar este show de TV. ¿Quieres intentar nuevamente?", actionDone: UIAlertAction(title: "Ok", style: .default), context: self)
                }
                
            }
            
            
            let cancelAction = UIAlertAction(title: "Cancelar", style: .cancel) { _ in
            }
            
            alertController.addAction(aceptAction)
            alertController.addAction(cancelAction)
            
            self.present(alertController, animated: true, completion: nil)
            
            completion(true)
        }
        
        deleteAction.image = UIImage(systemName: "trash")
        
        let configuration = UISwipeActionsConfiguration(actions: [deleteAction])
        
        return configuration
    }
    
}

extension FavoritesViewController: DetailsViewControllerDelegate {

    func didUpdateData(_ newData: [TVShowsModel]) {
        favoritesTVShows = newData
        tableView.reloadData()
    }

}
