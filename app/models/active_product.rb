  # app/models/active_product.rb
  class ActiveProduct
    attr_reader :promotioncondition, :_id, :barcodeid, :category, :productname,
                :productdetail, :productcost, :productsale1, :productsale2,
                :productsale3, :productsale4, :productsale5, :productstock,
                :productminstock, :productstatus, :productmargin,
                :productmarginstep, :productmarginpercent, :__v, :userupdate,
                :onlinestatus, :productimage, :productmotherconvert,
                :productmotherid, :productunit, :lastupdatedate, :lastupdatetime,
                :stockorderprocess, :stockorderstatus, :canusepoint,
                :productpoints, :productsale6

    def initialize(attrs = {})
      @promotioncondition = attrs["promotioncondition"]
      @_id = attrs["_id"]
      @barcodeid = attrs["barcodeid"]
      @category = attrs["category"]
      @productname = attrs["productname"]
      @productdetail = attrs["productdetail"]
      @productcost = attrs["productcost"]
      @productsale1 = attrs["productsale1"]
      @productsale2 = attrs["productsale2"]
      @productsale3 = attrs["productsale3"]
      @productsale4 = attrs["productsale4"]
      @productsale5 = attrs["productsale5"]
      @productstock = attrs["productstock"]
      @productminstock = attrs["productminstock"]
      @productstatus = attrs["productstatus"]
      @productmargin = attrs["productmargin"]
      @productmarginstep = attrs["productmarginstep"]
      @productmarginpercent = attrs["productmarginpercent"]
      @__v = attrs["__v"]
      @userupdate = attrs["userupdate"]
      @onlinestatus = attrs["onlinestatus"]
      @productimage = attrs["productimage"]
      @productmotherconvert = attrs["productmotherconvert"]
      @productmotherid = attrs["productmotherid"]
      @productunit = attrs["productunit"]
      @lastupdatedate = attrs["lastupdatedate"]
      @lastupdatetime = attrs["lastupdatetime"]
      @stockorderprocess = attrs["stockorderprocess"]
      @stockorderstatus = attrs["stockorderstatus"]
      @canusepoint = attrs["canusepoint"]
      @productpoints = attrs["productpoints"]
      @productsale6 = attrs["productsale6"]
    end

    class << self
      def all
        ActiveProductClient.new.fetch_products.map { |attrs| new(attrs) }
      end

      def search(query)
        products = all
        needle = query.to_s.strip.downcase
        return products if needle.blank?

        products.select do |product|
          product.productname.to_s.downcase.include?(needle) ||
            product.barcodeid.to_s.downcase.include?(needle)
        end
      end
      
      def search_by_barcode(barcode)
        products = all
        needle = barcode.to_s.strip.downcase
        return products if needle.blank?

        products.select do |product|
          product.barcodeid.to_s.downcase.include?(needle)
        end
      end
      
      def search_by_name(name)
        products = all
        needle = name.to_s.strip.downcase
        return products if needle.blank?

        products.select do |product|
          product.productname.to_s.downcase.include?(needle)
        end
      end
      
      def none
        []
      end
    end
  end
