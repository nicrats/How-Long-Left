//
//  ComplicationIAP.swift
//  How Long Left (iOS)
//
//  Created by Ryan Kontos on 1/3/19.
//  Copyright © 2019 Ryan Kontos. All rights reserved.
//

import Foundation
import StoreKit
import CryptoSwift

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
    
    fileprivate var productID = ""
    fileprivate var productsRequest = SKProductsRequest()
    fileprivate var iapProducts = [SKProduct]()
    
    var purchaseStatusBlock: ((IAPHandlerAlertType) -> Void)?
    
    func setPurchasedStatus(_ to: Bool) {
        
        if to == true {
            
            let ID = UIDevice().identifierForVendor!
            let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
            let salt = String((0..<6).map{ _ in letters.randomElement()! })
            let hash = "\(ID)-\(salt)".sha256()
            
            HLLDefaults.defaults.set(salt, forKey: "ComplicationSalt")
            HLLDefaults.defaults.set(hash, forKey: "ComplicationHash")
            
            
        } else {
            
            HLLDefaults.defaults.set(nil, forKey: "ComplicationSalt")
            HLLDefaults.defaults.set(nil, forKey: "ComplicationHash")
            
        }
        
        
    }
    
    func hasPurchasedComplication() -> Bool {
        
        if SchoolAnalyser.schoolModeIgnoringUserPreferences == .Magdalene {
            
            print("IAPCheck: Magalene user; Getting complication for free.")
            return true
            
        }
        
        var returnValue = false
        
        if let storedSalt = HLLDefaults.defaults.string(forKey: "ComplicationSalt"), let storedHash = HLLDefaults.defaults.string(forKey: "ComplicationHash") {
            
            let ID = UIDevice().identifierForVendor!
            let newHash = "\(ID)-\(storedSalt)".sha256()
            
            if newHash == storedHash {
                
                returnValue = true
                print("IAPCheck: Hashes did match")
                
            } else {
                
                print("IAPCheck: Hashes did not match")
                
            }
            
            
        } else {
            
            print("IAPCheck: Defaults contained nil, didn't check hashes")
            
        }
        
        return returnValue
        
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
        let productIdentifiers = NSSet(objects: "ComplicationIAP", "ConsumeTest" )
        
        
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
                print(product.localizedDescription + "\nfor just \(price1Str!)")
            }
        }
        
        
        
    }
    
    func paymentQueueRestoreCompletedTransactionsFinished(_ queue: SKPaymentQueue) {
        purchaseStatusBlock?(.restored)
    }
    
    
    // MARK:- IAP PAYMENT QUEUE
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction:AnyObject in transactions {
            if let trans = transaction as? SKPaymentTransaction {
                switch trans.transactionState {
                case .purchased:
                    print("purchased")
                    SKPaymentQueue.default().finishTransaction(transaction as! SKPaymentTransaction)
                    purchaseStatusBlock?(.purchased)
                    break
                    
                case .failed:
                    print("failed")
                    SKPaymentQueue.default().finishTransaction(transaction as! SKPaymentTransaction)
                    break
                case .restored:
                    print("restored")
                    SKPaymentQueue.default().finishTransaction(transaction as! SKPaymentTransaction)
                    break
                    
                default: break
                }}}
    }
}
