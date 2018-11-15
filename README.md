# ImagePad
A simple image viewer app that downloads images from the flikr and show it in collection view.

### Notable features

1.	Integrated Flickr Photo Search API to display the photos in UICollectionView.
2.	Implemented Pagination for better performance.
3.	Implemented lazy image loading.
4.	Handling multiple download tasks effectively by:

      •	Checking if the download task for URL already exist.
      
      •	Switching between high and low task priorities depending upon whether cell corresponding to download task is visible             or not.
5.	Image caching using NSCache.
6.	Zooming image transition animation same as of iOS photo app.
7.	Using small sized image for collection view and corresponding high resolution image on full screen.
8.	Used UISearchController in the title view of Navigation Bar to search for photos.
9.	Containing an option to switch among 2, 3 or 4 number of items per row.
10. Tap animation when click on collection view cell.



