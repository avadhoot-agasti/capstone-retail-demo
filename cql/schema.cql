CREATE KEYSPACE retail WITH replication = {
  'class': 'SimpleStrategy',
  'replication_factor': '3'
};

CREATE TABLE brand (
  brand_unique_code text,
  brandname text,
  PRIMARY KEY ((brand_unique_code))
);

CREATE TABLE region (
  region_unique_code text,
  region_name text,
  PRIMARY KEY ((region_unique_code))
);

#Product info is divided into product and product sku. The access pattern is for OLTP application
#Assumption - 
#OLTP application. Access patter is on barcode stored in product_sku. 
#But if barcode scan fails, then enable search on brand name and short title
#prices are stored at sku level. The prices at product level 
CREATE TABLE product (
  brand_unique_code text,
  short_title text,
  productid timeuuid,
  long_seo_title text,
  msrp_current_max int,
  product_sku list<timeuuid>,
  sales_price_current_max int,
  PRIMARY KEY ((brand_unique_code, short_title), productid)
) 



#Assumption - barcode is at SKU level. When billing is done, the product is searched on barcode. 
#The prices are different at SKU level
#sku_attr_val would differentiate "red" shirt with "blue" shirt. Chosen as key-value pair since properties of "camera" are different than "shirt" and Target sales both!
CREATE TABLE product_sku (
  barcode text,
  brand_unique_code text,
  long_seo_title text,
  msrp_current_int int,
  product_sku_id timeuuid,
  productid timeuuid,
  sales_price_current int,
  savings_current int,
  sku_attr_val map<text, text>,
  PRIMARY KEY ((barcode))
)

#Assumption
#store has multiple phones. 
#Direct Query on StoreID is required for OLTP app to traceback from register. Hence partition key on storeid
#zip code is kept separate from address to enable any zipcode, city, satate wide analysis
#Region is kept separate to support any customized definition of region
CREATE TABLE store (
  storeid uuid,
  address text,
  phones list<text>,
  region_unique_code text,
  store_start_time map<text, timestamp>,
  store_stop_time map<text, timestamp>,
  tax_rate int,
  zipcode text,
  PRIMARY KEY ((storeid))
);

#This register table is used to track basic register information. More denormalized tables are created later to track registers daily sales information
REATE TABLE register (
  registerid uuid,
  stroeid uuid,
  PRIMARY KEY ((registerid))
)

#This register table is used to track daily aggregate information 
#TODO - add more aggregates
CREATE TABLE register_aggregate (
  storeid uuid,
  registerid uuid,
  date timestamp,
  total_items counter,
  total_sales counter,
  PRIMARY KEY ((storeid), registerid, date)
)

#Receipt table. Always queried using registerid.
#Payment info is map to store CC, Cash info as needed 
#cashierid maps to empid
CREATE TABLE receipt (
  registerid uuid,
  receiptid timeuuid,
  cashierid uuid,
  payment_info map<text, text>,
  total_price int,
  PRIMARY KEY ((registerid), receiptid)
);

#Assumption is that employees are for a store and they are searched using storeid
CREATE TABLE employee (
  storeid uuid,
  empid uuid,
  lastnameinitials text,
  PRIMARY KEY ((storeid), empid)
)


