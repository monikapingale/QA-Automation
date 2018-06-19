class Salesforce
  def initialize
  	puts "in initialize"
  	res = SfBulk.query("Profile", "select name from Profile limit 10")
	puts res.result.records.inspect
  end
end