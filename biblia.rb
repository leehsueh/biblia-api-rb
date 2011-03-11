# Module that abstracts the Biblia web service API
######### Usage: #########
# first set API_KEY to your application's registered key before making any calls.
# if proxy setup is needed, set the PROXY_HOST and PROXY_PORT variables
##########################

require 'net/http'
require 'json'

module Biblia
	API_BASE_URL = 'http://api.biblia.com/v1/bible/'
	API_KEY = nil
    
    PROXY_HOST = nil
    PROXY_PORT = nil
	
	def Biblia.content(bible, ext, request_params)
		url_str = API_BASE_URL + 'content/' + bible + '.' + ext
		api_call(url_str, request_params)
	end
	
	def Biblia.search(bible, request_params)
		url_str = API_BASE_URL + 'search/' + bible
		api_call(url_str, request_params)
	end
	
	def Biblia.find(bible, request_params)
        if !bible
            bible = ''
        end
        if !request_params
            request_params = {}
        end
		url_str = API_BASE_URL + 'find/' + bible
		api_call(url_str, request_params)
	end
    
    def Biblia.list_bibles()
        bibles_json = find(nil, nil)
        bibles = JSON.parse(bibles_json)
        bibles['bibles']
    end
	
	def Biblia.tag_text(text, tag_format)
        request_params = {'text'=>text, 'tagFormat'=>tag_format}
		url_str = API_BASE_URL + 'tag/'
		api_call(url_str, request_params)
	end
    
    def Biblia.tag_url(url, tag_format)
        if !url['http://']
            url = 'http://' + url
        end
        request_params = {'url'=>url, 'tagFormat'=>tag_format}
		url_str = API_BASE_URL + 'tag/'
		api_call(url_str, request_params)
	end
	
	def Biblia.compare(first, second)
		request_params = {'first'=>first, 'second'=>second}
		url_str = API_BASE_URL + 'compare/'
		api_call(url_str, request_params)
	end
	
	def Biblia.image(bible)
		url_str = API_BASE_URL + 'image/' + bible
		api_call(url_str, {})
	end
	
	def Biblia.scan(text, style)
		request_params = {'text'=>text, 'style'=>style}
		url_str = API_BASE_URL + 'scan/'
		api_call(url_str, request_params)
	end
	
	def Biblia.parse(passage, style)
		request_params = {'passage'=>text, 'style'=>style}
		url_str = API_BASE_URL + 'parse/'
        api_call(url_str, request_params)
	end
    
    def Biblia.api_call(base_url_path, request_params)
        request_str = build_request_string(request_params)
        if request_str == ''
            'API key not set!'
        else
            base_url_path << '?' << request_str
            http_get_request(base_url_path)
        end
    end
	
	def Biblia.build_request_string(request_params)
		request_str = ''
        if API_KEY
            request_params.each do |key, value|
                if value != nil && value != ''
                    request_str << key << "=" << URI.escape(value, Regexp.new("[^#{URI::PATTERN::UNRESERVED}]")) << '&'
                end
            end
            request_str << 'key=' << API_KEY
        end
		request_str
	end

	def Biblia.http_get_request(url_str)
        if API_KEY
            # setup proxy if configured
            if PROXY_HOST && PROXY_PORT
                proxy = Net::HTTP::Proxy(PROXY_HOST, PROXY_PORT)
            else
                proxy = Net::HTTP
            end
            
            url = URI.parse(url_str)
            data = proxy.get(url.host, url.path + '?' + url.query)
            return data
        else
            'API key not set!'
        end
	end

	private_class_method :http_get_request
	private_class_method :build_request_string
end
