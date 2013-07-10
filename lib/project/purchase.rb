class Purchase

  def initialize(product_id, &result)
    @result = result
    SKPaymentQueue.defaultQueue.addTransactionObserver(self)
    SKPaymentQueue.defaultQueue.addPayment(SKPayment.paymentWithProductIdentifier(product_id))
  end

  def finishTransaction(transaction, wasSuccessful:wasSuccessful)
    SKPaymentQueue.defaultQueue.finishTransaction(transaction)
    @result.call({success: wasSuccessful, transaction: transaction}.to_object)
  end

  def completeTransaction(transaction)
    finishTransaction(transaction,wasSuccessful:true)
  end

  def restoreTransaction(transaction)
    recordTransaction(transaction.originalTransaction)
    finishTransaction(transaction,wasSuccessful:true)
  end

  def failedTransaction(transaction)
    if (transaction.error.code != SKErrorPaymentCancelled)
      finishTransaction(transaction, wasSuccessful:false)
    elsif transaction.error.code == SKErrorPaymentCancelled
      @result.call({success: false, transaction: transaction}.to_object)
    else
      SKPaymentQueue.defaultQueue.finishTransaction(transaction)
    end
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