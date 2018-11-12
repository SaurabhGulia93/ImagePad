//
//  IPMainViewController.swift
//  ImagePad
//
//  Created by Saurabh on 11/11/18.
//  Copyright © 2018 SaurabhGulia. All rights reserved.
//

import UIKit

protocol Photo {
    var thumbnailURL: URL? {get}
    var highResPhotoURL: URL? {get}
}

protocol MainViewControllerProtocol {
    func searchPhotos(forSearchString searchString: String, pageNumber: Int, andItemsPerPage itemsPerPage: Int, completion: @escaping ([Photo]?, String?)-> Void)
}

private struct MainViewControllerConstants{
    static let optionsForItemsPerRow: [Int] = [2, 3, 4]
    static let cellPadding: CGFloat = 10.0
    static let defaultNumberOfColumns = 4
    static let cellIdentifier = "ImageCollectionViewCell"
    static let footerIdentifier = "CustomFooterView"
    static let itemsPerPage = 25
    
    struct Messages{
        static let itemsNeededAlertSheetMessage = "How many items should each row have?"
        static let searchDefaultPlaceholder = "Search"
        static let errorMsg = "No Results Found"
    }
}

class IPMainViewController: UICollectionViewController {

    fileprivate var photosDataSource: [Photo] = []
    fileprivate var delegate: MainViewControllerProtocol? = nil
    fileprivate var itemsPerRow = MainViewControllerConstants.defaultNumberOfColumns
    fileprivate let searchController = UISearchController(searchResultsController: nil)
    fileprivate var searchString: String? = nil
    fileprivate var searckTask: DispatchWorkItem? = nil
    fileprivate var isLoading: Bool = false
    fileprivate var zooimingCellIndexPath: IndexPath? = nil
    fileprivate var isFulfillingSearchConditions: Bool{
        get{
            if let searchText = searchController.searchBar.text{
                searchString = searchText
                return true
            }else{
                return false
            }
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        delegate = FlickrProvider()
        
        searchController.searchBar.delegate = self
        self.definesPresentationContext = true
        self.navigationItem.titleView = searchController.searchBar
        self.navigationItem.titleView?.tintColor = .white
        searchController.hidesNavigationBarDuringPresentation = false
    }

    @IBAction func optionsSelected(_ sender: UIBarButtonItem) {
        let alertSheet = UIAlertController(title: nil, message: MainViewControllerConstants.Messages.itemsNeededAlertSheetMessage, preferredStyle: .actionSheet)
        for item in MainViewControllerConstants.optionsForItemsPerRow{
            alertSheet.addAction(UIAlertAction(title: String(item), style: .default, handler: {[weak self] action in
                self?.itemsPerRow = Int(action.title ?? "") ?? MainViewControllerConstants.defaultNumberOfColumns
                self?.collectionView?.reloadData()
            }))
        }
        self.present(alertSheet, animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let cell = sender as? IPImageCollectionViewCell,
            let indexPath = self.collectionView?.indexPath(for: cell) {
            zooimingCellIndexPath = indexPath
            
            guard let detailViewController = segue.destination as? IPImageDetailViewController else {
                return
            }
            detailViewController.photo = photosDataSource[indexPath.item]
        }
    }
    
    fileprivate func search(forPage pageNumber: Int, completion:@escaping ([Photo])->Void){
        guard let searchString = searchString else{ return }
        delegate?.searchPhotos(forSearchString: searchString, pageNumber: pageNumber, andItemsPerPage: MainViewControllerConstants.itemsPerPage, completion: {[weak self](results, error) in
            self?.isLoading = false
            DispatchQueue.main.async {
                if error != nil {
                    self?.showError(error: error ?? MainViewControllerConstants.Messages.errorMsg)
                }
                guard let photos = results else {
                    self?.showError(error: MainViewControllerConstants.Messages.errorMsg)
                    return
                }
                completion(photos)
                self?.collectionView?.reloadData()
            }
        })
        isLoading = true
    }
    
    fileprivate func searchNextPage(){
        let currentPage = (photosDataSource.count)/MainViewControllerConstants.itemsPerPage
        search(forPage: currentPage+1, completion:{[weak self] (results) in
            self?.photosDataSource.append(contentsOf: results)
        })
    }
    
    fileprivate func showError(error: String) {
        let alert = UIAlertController(title: "Error", message: error, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Okay!", style: .default, handler: { action in
            self.searchController.searchBar.placeholder = MainViewControllerConstants.Messages.searchDefaultPlaceholder
            self.searchString = nil
        }))
        self.present(alert, animated: true, completion: nil)
    }
}

// MARK: - UICollectionViewDataSource implementation
extension IPMainViewController{
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int{
        return photosDataSource.count
    }
    
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell{
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MainViewControllerConstants.cellIdentifier, for: indexPath)
        
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
        let photo = photosDataSource[indexPath.item]
        (cell as! IPImageCollectionViewCell).fillData(photo)
        
        let currentDataSourceSize = photosDataSource.count
        if currentDataSourceSize - indexPath.row == (2 * itemsPerRow){
            searchNextPage()
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        (cell as! IPImageCollectionViewCell).reducePriorityOfDownloadtaskForCell()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.bounds.size.width, height: 55)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize.zero
    }
    
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let footerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: MainViewControllerConstants.footerIdentifier, for: indexPath) as! IPCollectionFooterView
        isLoading ? footerView.loader.startAnimating(): footerView.loader.stopAnimating()
        return footerView
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension IPMainViewController: UICollectionViewDelegateFlowLayout{
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize{
        
        let paddingPerRow = MainViewControllerConstants.cellPadding * CGFloat(itemsPerRow - 1)
        let availableSpace = self.view.frame.width - paddingPerRow
        let dimensionOfEachItem = availableSpace/CGFloat(itemsPerRow)
        
        return CGSize(width: dimensionOfEachItem, height: dimensionOfEachItem)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return MainViewControllerConstants.cellPadding
    }
}

// MARK: - UISearchBarDelegate Implementation
extension IPMainViewController: UISearchBarDelegate{
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if isFulfillingSearchConditions{
            search(forPage: 0, completion: {[weak self] results in
                self?.photosDataSource = results
            })
            self.photosDataSource.removeAll()
            self.collectionView?.reloadData()
            
            searchController.isActive = false
            searchBar.placeholder = searchString
        }
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar){
        searchBar.placeholder = MainViewControllerConstants.Messages.searchDefaultPlaceholder
    }
}

// MARK: - Zooming transition
extension IPMainViewController: ZoomingViewController{
    func zoomingImageView(for transition: ZoomTransitioningDelegate) -> UIImageView? {
        guard let zooimingCellIndexPath = zooimingCellIndexPath, let zoomingCell: IPImageCollectionViewCell = self.collectionView?.cellForItem(at: zooimingCellIndexPath) as? IPImageCollectionViewCell else{
            return nil
        }
        
        return zoomingCell.imageView
    }
}
