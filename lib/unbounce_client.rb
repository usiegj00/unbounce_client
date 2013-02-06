require 'httparty'
require 'json'

class UnbounceClient
  include HTTParty
  base_uri 'https://api.unbounce.com'
  headers('Accept' => 'application/vnd.unbounce.api.v0.1+json')

  @format

  def initialize(api_key)
    @auth = { username: api_key, password: '' }
  end

  def root
    parse get('/')
  end

  def accounts
    parse( get('/accounts') )['accounts'].collect { |account| OpenStruct.new(account) }
  end

  def sub_accounts(account_id)
    parse( get("/accounts/#{account_id}/sub_accounts") )['subAccounts'].collect { |sub_account| OpenStruct.new(sub_account) }
  end

  def sub_account(id)
    OpenStruct.new( parse( get("/sub_accounts/#{id}") ) )
  end

  def domains(id)
    parse( get("/sub_accounts/#{id}/domains") )['domains'].collect { |domain| OpenStruct.new(domain) }
  end

  def page_groups(sub_account_id)
    parse( get("/sub_accounts/#{sub_account_id}/page_groups") )['pageGroups'].collect { |page_group| OpenStruct.new(page_group) }
  end

  def pages(opts={ account_id: nil, sub_account_id: nil, page_group_id: nil })
    parent, id = opts_to_path_and_id(opts)

    parse( get("/#{parent}/#{id}/pages") )['pages'].collect { |page| OpenStruct.new(page) }
  end

  def page(id)
    OpenStruct.new( parse( get("/pages/#{id}") ) )
  end

  def leads(opts={ sub_account_id: nil, page_id: nil })
    parent, id = opts_to_path_and_id(opts)

    parse( get("/#{parent}/#{id}/leads") )['leads'].collect { |lead| OpenStruct.new(lead) }
  end

  def lead(id)
    OpenStruct.new( parse( get("/leads/#{id}") ) )
  end

  private

    def opts_to_path_and_id(opts)
      # Trim out all empty keys.
      opts = opts.keep_if { |k,v| !v.nil? }
      # Now grab the first key/value pair only.
      parent, id = [opts.keys.first, opts[opts.keys.first]]
      # Remove the trailing '_id' from the parent identifier.
      parent = parent.to_s.gsub(/_id/, '')

      ["#{parent}s", id]
    end

    def get(url)
      self.class.get(url, basic_auth: @auth)
    end

    def parse(response)
      JSON.parse(response.parsed_response)
    end

end
