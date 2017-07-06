require 'mechanize'
require 'nokogiri'
require 'dotenv'

Dotenv.load

class Quiz
  
  def initialize
    @parse_data = Parser.new
  end

  def run  
    parse_data.table_data
  end
   
  private 
   
  attr_reader :parse_data

  class Parser

    def initialize
      @data_html = Nokogiri::HTML(SignIn.response)
    end

    def table_data
      @result = Hash.new
      @data_html.at('table').search('tr').each do |row|
        @date = row.search('td.date').text.strip
        @table_headers ||= row.search('th.text-right').map { |h| h.text.strip.downcase!.to_sym }
        @table_cels = row.search('td.text-right').map { |c| c.text.strip }
        @values = Hash[@table_headers.zip(@table_cels.map {|i| i})]
        next if @date == ""
        @result.merge!({@date => @values})
      end
      @result
    end

    class SignIn   

      class << self 
        def response
          self.new.submit
        end  
      end  

      def initialize
        mechanize = Mechanize.new
        @password = ENV['STAQ_PASSWORD'] 
        @email    = ENV['STAQ_EMAIL']
        @target   = mechanize.get('http://staqresults.staq.com')
      end  
       
      def submit  
        login['email']    = @email
        login['password'] = @password
        login.submit.body
      end
      
      private 

      def login 
        @login ||= @target.forms.first
      end
    end  
  end 
end