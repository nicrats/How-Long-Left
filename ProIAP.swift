//
//  ProIAP.swift
//  How Long Left (macOS)
//
//  Created by Ryan Kontos on 6/8/19.
//  Copyright © 2019 Ryan Kontos. All rights reserved.
//

import Foundation

import Foundation
import StoreKit

enum IAPHandlerAlertType{
    case disabled
    case restored
    case purchased
    
    func message() -> String{
        switch self {
        case .disabled: return "Purchases are disabled in your device!"
        case .restored: return "You've successfully restored your purchase!"
        case .purchased: return "You've successfully bought this purchase!"
        }
    }
}


class IAPHandler: NSObject {
    
    
    static let shared = IAPHandler()
    
    static var unreachable = true
    static var delegate: IAPListener?
    
    static var recentTransaction: SKPaymentTransaction?
    
    fileprivate var productID = ""
    fileprivate var productsRequest = SKProductsRequest()
    fileprivate var iapProducts = [SKProduct]()
    
    static var proPriceString: String?
    
    var purchaseStatusBlock: ((IAPHandlerAlertType) -> Void)?
    
    func setPurchasedStatus(_ to: Bool) {
        
        HLLDefaults.appData.proUser = to
        
        
    }
    

    // MARK: - MAKE PURCHASE OF A PRODUCT
    func canMakePurchases() -> Bool {  return SKPaymentQueue.canMakePayments()  }
    
    func purchaseMyProduct(index: Int){
        if iapProducts.count == 0 { return }
        
        if self.canMakePurchases() {
            let product = iapProducts[index]
            let payment = SKPayment(product: product)
            SKPaymentQueue.default().add(self)
            SKPaymentQueue.default().add(payment)
            
            print("PRODUCT TO PURCHASE: \(product.productIdentifier)")
            productID = product.productIdentifier
        } else {
            purchaseStatusBlock?(.disabled)
        }
    }
    
    // MARK: - RESTORE PURCHASE
    func restorePurchase(){
        
        
        SKPaymentQueue.default().add(self)
        SKPaymentQueue.default().restoreCompletedTransactions()
    }
    
    
    // MARK: - FETCH AVAILABLE IAP PRODUCTS
    func fetchAvailableProducts(){
        
        // Put here your IAP Products ID's
        let productIdentifiers = NSSet(objects: "HLLMacPro")
        
        
        productsRequest = SKProductsRequest(productIdentifiers: productIdentifiers as! Set<String>)
        productsRequest.delegate = self
        productsRequest.start()
    }
}

extension IAPHandler: SKProductsRequestDelegate, SKPaymentTransactionObserver{
    // MARK: - REQUEST IAP PRODUCTS
    
    
    func productsRequest (_ request:SKProductsRequest, didReceive response:SKProductsResponse) {
        
        if (response.products.count > 0) {
            iapProducts = response.products
            for product in iapProducts{
                let numberFormatter = NumberFormatter()
                numberFormatter.formatterBehavior = .behavior10_4
                numberFormatter.numberStyle = .currency
                numberFormatter.locale = product.priceLocale
                let price1Str = numberFormatter.string(from: product.price)
                print("IAP: \(product.localizedDescription) costs \(price1Str!)")
                
                if product.productIdentifier == "HLLMacPro" {
                    
                    IAPHandler.proPriceString = price1Str
                    ProPurchaseHandler.shared.presentPromptIfNeeded()
                    
                    
                }
                
            }
        }
        
        
        
    }
    
    
    
    func paymentQueueRestoreCompletedTransactionsFinished(_ queue: SKPaymentQueue) {
        // purchaseStatusBlock?(.restored)
        //IAPHandler.delegate?.purchaseResult(was: .restored)
        // setPurchasedStatus(true)
    }
    
    func paymentQueue(_ queue: SKPaymentQueue, restoreCompletedTransactionsFailedWithError error: Error) {
        
        purchaseStatusBlock?(.disabled)
        IAPHandler.delegate?.purchaseResult(was: .failed)
        setPurchasedStatus(false)
    }
    
    // MARK:- IAP PAYMENT QUEUE
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction:AnyObject in transactions {
            if let trans = transaction as? SKPaymentTransaction {
                
                IAPHandler.recentTransaction = trans
                
                switch trans.transactionState {
                case .purchased:
                    print("purchased")
                    SKPaymentQueue.default().finishTransaction(transaction as! SKPaymentTransaction)
                    purchaseStatusBlock?(.purchased)
                    setPurchasedStatus(true)
                    IAPHandler.delegate?.purchaseResult(was: .succeeded)
                    
                    break
                    
                case .failed:
                    print("failed")
                    SKPaymentQueue.default().finishTransaction(transaction as! SKPaymentTransaction)
                    IAPHandler.delegate?.purchaseResult(was: .failed)
                    break
                    
                case .restored:
                    
                    SKPaymentQueue.default().finishTransaction(transaction as! SKPaymentTransaction)
                    IAPHandler.delegate?.purchaseResult(was: .restored)
                    break
                    
                default: break
                }}}
    }
}

protocol IAPListener {
    
    func purchaseResult(was result: IAPPurchaseState)
    
    
}

enum IAPPurchaseState {
    
    case succeeded
    case failed
    case restored
    
}
