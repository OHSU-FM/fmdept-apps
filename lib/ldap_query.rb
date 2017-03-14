# Mixin with Devise's LdapConnect so we can send any kind of query to the LDAP server
module LdapQuery
    
    # Ldap Connection
    def self.connection
        @@connection ||= LdapQuery::Connection.new( :admin=> true )
    end

    def self.queryable? val
        # If a non ohsu email is present: abort
        # otherwise its an LDAP query
        if val =~ /\A[^@]+@[^@]+\Z/
            return false unless val.ends_with? '@ohsu.edu'
        end
        return true
    end


    class Scanner
        attr_accessor :cn, :email, :displayname, :sn, :query, :errors, :from
        attr_reader :user

        # Search LDAP server for user information and return a UserDefaultEmail instance object
        def self.search(q, opts={})

            # Filter query parameters
            q.to_s.gsub!('*','')
            scanner = self.new(q)
           
            # Scan local database first
            if opts[:only].nil? || opts[:only].to_s == 'user'
                users = self.user_search q
                if users.size != 0
                    scanner.load_user users
                    return scanner
                end
            end
            
            # Scan LDAP
            if opts[:only].nil? || opts[:only].to_s == 'ldap'
                begin
                    ldap = self.ldap_search q
                rescue
                    # An error was raised while querying the OHSU ldap server
                    scanner.errors.add :connection, 'Error contacting OHSU Authentication Server (LDAP)'
                    return scanner
                end
                scanner.load_ldap ldap
            end

            return scanner
        end

        # Search User model for matches
        def self.user_search q
            User.where("login = :val OR email = :val OR name = :val", :val=>q)
        end

        # Search Ldap for matches
        def self.ldap_search q
            ldap_result = nil
        
            # search until we find a match
            search_attrs = ['cn','displayname', 'sn']
            search_attrs = ['mail'] if q.include?('@')

            search_attrs.each do |attr|
                ldap_result = LdapQuery.connection.query(attr, q)
                # break if we found a match
                break if ldap_result
            end
            return ldap_result
        end

        def initialize query
            self.query = query
        end

        # array of errors
        def errors
            @errors ||= ErrorsHash.new
        end

        # to we have a user with this information?
        def user
            @user ||= User.find_by_email(self.email)
        end

        def as_user_attributes
            {:name=>displayname, :email=>email, :login=>cn, :sn=>sn}
        end

        # use properties to create a ude object
        def to_ude
            UserDefaultEmail.new self.as_ude_attributes
        end

        def as_ude_attributes
            {:cn=>cn, :email=>email, :displayname=>displayname}
        end

        # Init self from array of users
        def load_user users
            self.reset
            
            self.from = :db

            if users.size == 0
                self.errors.add :query, :nothing_found
                return
            end

            if users.size != 1
                self.errors.add :query, :too_many_matches
                return
            end

            @user = users.first
            self.cn = user.login
            self.displayname = user.name
            self.email = user.email
            self.sn = user.sn
        end

        # Init self from an ldap query result
        def load_ldap ldap_result
            self.reset
            self.from = :ldap

            if ldap_result.nil?
                self.errors.add(:query, 'No results were found')
                return
            end
            
            [:cn, :mail, :displayName].each do |key|
                if ldap_result[key].nil?
                    self.errors.add key, 'Search result was missing information'
                    return
                end

                if ldap_result[key].size == 0
                    self.errors.add key, 'Search result was missing data'
                    return
                end
                
                if ldap_result[key].size != 1
                    self.errors.add :query, 'There were too many matches to your search'
                    return
                end

                if ldap_result[key][0].nil?
                    self.errors.add key, 'There were no results for search'
                    return
                end
            end

            unless ldap_result[:mail].first =~ /\A[^@]+@[^@]+\Z/ 
                errors.add :email, 'An invalid email address was found in search result'
            end
             
            self.sn = ldap_result[:cn][0].to_s
            self.cn = ldap_result[:cn][0].to_s
            self.email = ldap_result[:mail][0].to_s
            self.displayname = ldap_result[:displayName][0].to_s
        end

        def reset
            @user = nil     # clear user
            @errors = ErrorsHash.new  #
            [:cn, :email, :displayname, :sn, :query, :from].each do |key|
                self.send("#{key}=",nil)
            end
        end

    end

    class ErrorsHash < Hash
        def add key, val
            unless self.has_key? key
                self[key] = []
            end
            self[key].push val
        end
    end

    class Connection < Devise::LDAP::Connection 
        # perform a direct query on ldap connection
        def query(attr, value)
            filter = Net::LDAP::Filter.eq(attr.to_s, value.to_s)
            
            ldap_entry = nil
            @ldap.search(:base=> @ldap.base,:filter => filter) {|entry| ldap_entry = entry}
            if ldap_entry
                if ldap_entry[attr]
                    DeviseLdapAuthenticatable::Logger.send("Custom Query param #{attr} has results") 
                end
            end
            return ldap_entry
        end   
    end
end
