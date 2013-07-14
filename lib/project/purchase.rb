class Purchase

  def initialize(product_id, shared_secret, &result)
    @result = result
    @shared_secret = shared_secret
    SKPaymentQueue.defaultQueue.addTransactionObserver(self)
    SKPaymentQueue.defaultQueue.addPayment(SKPayment.paymentWithProductIdentifier(product_id))
  end

  def finishTransaction(transaction, wasSuccessful:wasSuccessful)
    SKPaymentQueue.defaultQueue.finishTransaction(transaction)

    if wasSuccessful
      @receipt = Receipt.new(transaction.transactionReceipt, @shared_secret) do |result|
        if result.success
          
          # SAVING receipt data
          App::Persistence["#{@product_id}.receipt_data"] = transaction.transactionReceipt
          App::Persistence["#{@product_id}.receipt"] = result.object
          @result.call({success: true, transaction: transaction}.to_object)
        else
          @result.call({success: false, transaction: transaction}.to_object)
        end
      end
    else
      @result.call({success: wasSuccessful, transaction: transaction}.to_object)
    end
  end

  def completeTransaction(transaction)
    finishTransaction(transaction,wasSuccessful:true)
  end

  def restoreTransaction(transaction)
    recordTransaction(transaction.originalTransaction)
    finishTransaction(transaction,wasSuccessful:true)
  end

  def failedTransaction(transaction)
    finishTransaction(transaction, wasSuccessful:false)
  end

  def paymentQueue(queue,updatedTransactions:transactions)
    transactions.each do |transaction|
      case transaction.transactionState
        when SKPaymentTransactionStatePurchased
          completeTransaction(transaction)
        when SKPaymentTransactionStateFailed
          failedTransaction(transaction)
        when SKPaymentTransactionStateRestored
          restoreTransaction(transaction)
        else 
      end
    end
  end

end