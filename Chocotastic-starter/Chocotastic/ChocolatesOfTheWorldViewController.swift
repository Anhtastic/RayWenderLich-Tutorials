/**
 * Copyright (c) 2016 Razeware LLC
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

import UIKit
import RxSwift
import RxCocoa

class ChocolatesOfTheWorldViewController: UIViewController {
  
  @IBOutlet private var cartButton: UIBarButtonItem!
  @IBOutlet private var tableView: UITableView!
//  let europeanChocolates = Chocolate.ofEurope
  private let europeanChocolates = Observable.just(Chocolate.ofEurope)
  private let disposeBag = DisposeBag()
  
  //MARK: View Lifecycle
  
  override func viewDidLoad() {
    super.viewDidLoad()
    title = "Chocolate!!!"

//    tableView.dataSource = self
//    tableView.delegate = self
    setupCartObserver()
    setUpCellConfiguration()
    setUpCellTapHandling()
  }
  
//  override func viewWillAppear(_ animated: Bool) {
//    super.viewWillAppear(animated)
//    updateCartButton()
//  }
  
  //MARK: Rx Setup
  private func setupCartObserver() {
    //1 First, grab the shopping cart's chocolates varaible as an Observable.
    ShoppingCart.sharedCart.chocolates.asObservable().subscribe(onNext:  {
      //2 Call subscribe(onNext:) on that Observable in order to find out about changes to the Observable's value. subscribe(onNext:) accepts a closure that will be executed every time the value changes. The incoming parameter to the closure is the new value of your Observable, and you’ll keep getting these notifications until you either unsubscribe or your subscription is disposed. What you get back from this method is an Observer conforming to Disposable.
      chocolates in
      self.cartButton.title = "\(chocolates.count) 🍫"
    }).addDisposableTo(disposeBag) //3 You add the Observer from the previous step to your disposeBag to ensure that your subscription is disposed of when the subscribing object is deallocated.
  }
  
  private func setUpCellConfiguration() {
    //1 You call bindTo(_:) to associate the europeanChocolates observable with the code that should get executed for each row in the table view.
    europeanChocolates.bindTo(tableView
      .rx //2 By calling rx, you are able to access the RxCocoa extensions for whatever class you call it on – in this case, a UITableView.
      .items(cellIdentifier: ChocolateCell.Identifier, cellType: ChocolateCell.self)) {
        //3 You call the Rx method items(cellIdentifier:cellType:), passing in the cell identifier and the class of the cell type you want to use. This allows the Rx framework to call the dequeuing methods that would normally be called if your table view still had its original delegates.
        row, chocolate, cell in
        cell.configureWithChocolate(chocolate: chocolate) //4 You pass in a block to be executed for each new item. You’ll get back information about the row, the chocolate at that row, and the cell, making it super-easy to configure the cell.
      }
      .addDisposableTo(disposeBag) //5 You take the Disposable returned by bindTo(_:) and add it to the disposeBag.
  }
  
  private func setUpCellTapHandling() {
    tableView
      .rx
      .modelSelected(Chocolate.self) //1 You call the table view’s reactive extension’s modelSelected(_:) function, passing in the Chocolate model to get the proper type of item back. This returns an Observable.
      .subscribe(onNext: { //2 Taking that Observable, you call subscribe(onNext:), passing in a trailing closure of what should be done any time a model is selected (i.e., a cell is tapped).
        chocolate in
        ShoppingCart.sharedCart.chocolates.value.append(chocolate) //3 Within the trailing closure passed to subscribe(onNext:), you add the selected chocolate to the cart.
        
        if let selectedRowIndexPath = self.tableView.indexPathForSelectedRow {
          self.tableView.deselectRow(at: selectedRowIndexPath, animated: true)
        } //4 Also in the closure, you make sure that the tapped row is deselected.
      })
      .addDisposableTo(disposeBag) //5 subscribe(onNext:) returns a Disposable. You add that Disposable to the disposeBag.
  }
  
  //MARK: Imperative methods
  
//  func updateCartButton() {
//    cartButton.title = "\(ShoppingCart.sharedCart.chocolates.value.count) 🍫"
//  }
}

/*
// MARK: - Table view data source
extension ChocolatesOfTheWorldViewController: UITableViewDataSource {

  func numberOfSections(in tableView: UITableView) -> Int {
    return 1
  }
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return europeanChocolates.count
  }
  
  func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
    return false
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    guard let cell = tableView.dequeueReusableCell(withIdentifier: ChocolateCell.Identifier, for: indexPath) as? ChocolateCell else {
      //Something went wrong with the identifier.
      return UITableViewCell()
    }
    
    let chocolate = europeanChocolates[indexPath.row]
    cell.configureWithChocolate(chocolate: chocolate)
    
    return cell
  }
}

// MARK: - Table view delegate
extension ChocolatesOfTheWorldViewController: UITableViewDelegate {

  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    tableView.deselectRow(at: indexPath, animated: true)
    
    let chocolate = europeanChocolates[indexPath.row]
    ShoppingCart.sharedCart.chocolates.value.append(chocolate)
//    updateCartButton()
  }
}
*/

// MARK: - SegueHandler
extension ChocolatesOfTheWorldViewController: SegueHandler {
  
  enum SegueIdentifier: String {
    case
    GoToCart
  }
}
