class ApplicationRecord < ActiveRecord::Base
    #self.abstract_class = true
    attr_accessible :first_name, :last_name
end
