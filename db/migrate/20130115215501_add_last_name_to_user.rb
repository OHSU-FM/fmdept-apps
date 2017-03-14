class AddLastNameToUser < ActiveRecord::Migration
  def change
    add_column :users, :sn, :string
    ldap = LdapQuery.new( :admin=> true )

    users = User.all
    users.each{|user|
        if user.sn.nil?
            user.ldap_verify
            user.save
        end
    }

  end
end
