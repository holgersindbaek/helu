class Helu
  
  attr_reader :product_id

  def initialize(product_id, &result)
    @product_id = product_id
    SKPaymentQueue.defaultQueue.addTransactionObserver(self)

    # Check if product exists and if get price, title and description
    productsRequest = SKProductsRequest.alloc.initWithProductIdentifiers(NSSet.setWithObject(product_id))
    productsRequest.delegate = self
    productsRequest.start
    @product_result = result
  end

# Product variables that can be access after 

  def price
    price_locale = NSLocale.alloc.initWithLocaleIdentifier(App::Persistence["#{@product_id}.priceLocale"])
    price = App::Persistence["#{@product_id}.price"]

    formatter = NSNumberFormatter.alloc.init
    formatter.setFormatterBehavior(NSNumberFormatterBehavior10_4)
    formatter.setNumberStyle(NSNumberFormatterCurrencyStyle)
    formatter.setLocale(price_locale)

    formatter.stringFromNumber(price || 0) 
  end

  def title
    App::Persistence["#{@product_id}.localizedTitle"] || "Title is not ready"
  end

  def description
    App::Persistence["#{@product_id}.localizedDescription"] || "Description is not ready"
  end

# Private product logic

  def productsRequest(request, didReceiveResponse:response) 
    
    # This throwns an error:
    @product_result.call({success: true, response: response}.to_object) if @product_result

    # This does work
    # @product_result.call({success: true, response: response}) if @product_result

    # Save needed product info
    product = response.products.first
    App::Persistence["#{@product_id}.priceLocale"] = product.priceLocale.localeIdentifier
    App::Persistence["#{@product_id}.price"] = product.price
    App::Persistence["#{@product_id}.localizedTitle"] = product.localizedTitle
    App::Persistence["#{@product_id}.localizedDescription"] = product.localizedDescription
  end
 
  def request(request, didFailWithError:error)
    ap "didFailWithError"
    @product_result.call({success: false, error: error}) if @product_result
  end

# Purchase logic

  def purchase(&result)
    payment = SKPayment.paymentWithProductIdentifier(product_id)
    SKPaymentQueue.defaultQueue.addPayment(payment)
    @purchase_result = result
  end

# Private Purchase logic

  def finishTransaction(transaction, wasSuccessful:wasSuccessful)
    SKPaymentQueue.defaultQueue.finishTransaction(transaction)
    produt_id = transaction.payment.productIdentifier
    wasSuccessful ? @purchase_result.call({success: true, transaction: transaction}) : @purchase_result.call({success: false, transaction: transaction}) if @purchase_result
  end

  def completeTransaction(transaction)
    finishTransaction(transaction,wasSuccessful:true)
  end

  def restoreTransaction(transaction)
    recordTransaction(transaction.originalTransaction)
    finishTransaction(transaction,wasSuccessful:true)
  end

  def failedTransaction(transaction)
    produt_id = transaction.payment.productIdentifier

    if (transaction.error.code != SKErrorPaymentCancelled)
      finishTransaction(transaction, wasSuccessful:false)
    elsif transaction.error.code == SKErrorPaymentCancelled
      @purchase_result.call({success: false, transaction: transaction}) if @purchase_result
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
