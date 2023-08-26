//
//  TVShowsViewController.swift
//  TVShowsTest
//
//  Created by Abel Lazaro on 08/08/23.
//

import UIKit
import SDWebImage

class TVShowsViewController: UIViewController {
    
    //MARK: - properties
    
    @IBOutlet weak var tableView: UITableView!
    
    var tvShows = [TVShowsModel]()
    
    var favoritesTVShows = [TVShowsModel]()
    
    var checkFavorites = false
    
    //MARK: - cicle

    override func viewDidLoad() {
        super.viewDidLoad()
        
        recoverfavorites()
        getTVShows()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if checkFavorites {
            setupData()
        }
        tableView.reloadData()
        
    }
    
    //MARK: helpers
    
    private func setupData() {
        
        if let favoritesViewController = self.tabBarController?.viewControllers?[1] as? FavoritesViewController {
            favoritesTVShows = favoritesViewController.favoritesTVShows
        }
        
    }
    
    private func recoverfavorites() {
        
        if let data = UserDefaults.standard.data(forKey: "favoritesKey") {
            let decoder = JSONDecoder()
            if let decodedShows = try? decoder.decode([TVShowsModel].self, from: data) {
                favoritesTVShows = decodedShows
                print("Objetos cargados desde UserDefaults:", favoritesTVShows)
            }
        }
        
    }
    
    private func getTVShows() {
        
        APIServicio.shared.getTvShows() { [weak self] (res, err) in
            if let err = err {
                print("Error al obtener shows de television", err)
                DispatchQueue.main.async {
                    SingletonFunctions.shared.showAlert(title: "Oops, algo salió mal!", message: "Ocurrió un error al consultar el servicio. ¿Quieres intentar nuevamente?", actionDone: UIAlertAction(title: "Aceptar", style: .default), context: self!)
                }
                return
            }
            
            guard let res = res else { return }
            
            DispatchQueue.main.async {
                self?.tvShows = res
                self?.tableView.reloadData()
                
            }
            
        }
    }
    

}

//MARK: - UITableViewDelegate, UITableViewDataSource

extension TVShowsViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tvShows.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! TVShowsTableViewCell
        
        cell.titleLabel.text = tvShows[indexPath.row].show?.name
        
        if let imagen = tvShows[indexPath.row].show?.image?.medium {
            cell.tvShowImage.sd_setImage(with: URL(string: "\(imagen)"))
        }
        
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let viewController : DetailsViewController = UIStoryboard(name: "DetailsView", bundle: nil).instantiateViewController(withIdentifier: "DetailsViewController") as! DetailsViewController
        
        viewController.show = tvShows[indexPath.row]
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
        
        var configuration = UISwipeActionsConfiguration(actions: [])
        
        let isFound = favoritesTVShows.contains { $0.show?.name == tvShows[indexPath.row].show?.name }

        if isFound {
            
            let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { (action, view, completion) in
                print("===Eliminado===")
                
                let alertController = UIAlertController(title: "Aviso", message: "Estas apunto de quitar este show como favorito, ¿Estas seguro?", preferredStyle: .alert)
                
                let aceptAction = UIAlertAction(title: "Aceptar", style: .default) { _ in
                    
                    self.favoritesTVShows.removeAll { show in
                        return show.show?.name == self.tvShows[indexPath.row].show?.name
                    }
                    
                    let encoder = JSONEncoder()
                    if let encodedData = try? encoder.encode(self.favoritesTVShows) {
                        UserDefaults.standard.set(encodedData, forKey: "favoritesKey")
                    }
                    
                    let isFound = self.favoritesTVShows.contains { $0.show?.name == self.tvShows[indexPath.row].show?.name }
                    
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
            
            configuration = UISwipeActionsConfiguration(actions: [deleteAction])
            
        } else {
            
            let favoriteAction = UIContextualAction(style: .normal, title: "Favorite") { (action, view, completion) in
                print("===AGREGADO A FAVORITOS===")
                
                self.favoritesTVShows.append(self.tvShows[indexPath.row])
                
                let encoder = JSONEncoder()
                if let encodedData = try? encoder.encode(self.favoritesTVShows) {
                    UserDefaults.standard.set(encodedData, forKey: "favoritesKey")
                }
                
                let isFound = self.favoritesTVShows.contains { $0.show?.name == self.tvShows[indexPath.row].show?.name }
                
                if !isFound {
                    SingletonFunctions.shared.showAlert(title: "Oops, algo salió mal!", message: "Hubo un problema al guardar este show de TV. ¿Quieres intentar nuevamente?", actionDone: UIAlertAction(title: "Ok", style: .default), context: self)
                }
                
                completion(true)
            }
            
            favoriteAction.image = UIImage(systemName: "star.fill")
            favoriteAction.backgroundColor = UIColor.green
            
            configuration = UISwipeActionsConfiguration(actions: [favoriteAction])
            
        }
        
        return configuration
    }
    
    
}

//MARK: - delegate

extension TVShowsViewController: DetailsViewControllerDelegate {

    func didUpdateData(_ newData: [TVShowsModel]) {
        favoritesTVShows = newData
    }

}
