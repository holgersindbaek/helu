class Product

  def initialize(product_id, &result)
    @result = result
    productsRequest = SKProductsRequest.alloc.initWithProductIdentifiers(NSSet.setWithObject(product_id))
    productsRequest.delegate = self
    productsRequest.start
  end

  def productsRequest(request, didReceiveResponse:response) 
    receipt_data = App::Persistence["#{@product_id}.receipt_data"]

    if receipt_data.blank?
      @result.call({success: true, response: response}.to_object)
    else
      @receipt = Receipt.new(receipt_data, @shared_secret) do |result|
        if result.success
          @result.call({success: true, response: response}.to_object)
        else

        end
      end
    end

    # Save needed product info
    product = response.products.first
    App::Persistence["#{product.productIdentifier}.priceLocale"] = product.priceLocale.localeIdentifier
    App::Persistence["#{product.productIdentifier}.price"] = product.price
    App::Persistence["#{product.productIdentifier}.localizedTitle"] = product.localizedTitle
    App::Persistence["#{product.productIdentifier}.localizedDescription"] = product.localizedDescription
  end
 
  def request(request, didFailWithError:error)
    @result.call({success: false, error: error}.to_object)
  end

end