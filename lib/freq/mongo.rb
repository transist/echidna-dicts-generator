require 'mongo'

include Mongo

$client = MongoClient.new('localhost', 27017)