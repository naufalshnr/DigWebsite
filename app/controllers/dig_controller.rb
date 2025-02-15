require "dnsruby"

class DigController < ApplicationController
  def index
    @results = {}
    @domain = nil
    @error = nil
  end

  def lookup
    @domain = params[:domain]
    if @domain.blank?
      @error = "Domain name cannot be empty."
      @results = {}
      respond_to do |format|
        format.turbo_stream
        format.html { render :index }
      end
      return
    end

    @results = {}
    lookup_types = {
      "A" => Dnsruby::Types.A,
      "AAAA" => Dnsruby::Types.AAAA,
      "CNAME" => Dnsruby::Types.CNAME,
      "MX" => Dnsruby::Types.MX,
      "TXT" => Dnsruby::Types.TXT,
      "NS" => Dnsruby::Types.NS,
      "PTR" => Dnsruby::Types.PTR
    }

    resolver = Dnsruby::Resolver.new(nameserver: [ "8.8.8.8" ]) # Use Google's public DNS server

    lookup_types.each do |type, resource|
      begin
        @results[type] = resolver.query(@domain, resource).answer
        Rails.logger.debug "Results for #{type}: #{@results[type].inspect}"
      rescue => e
        Rails.logger.error "Error during DNS lookup for #{type}: #{e.message}"
        @results[type] = "Error during DNS lookup: #{e.message}"
      end
    end

    respond_to do |format|
      format.turbo_stream
      format.html { render :index }
    end
  end

  def clear
    Rails.logger.debug "Clearing results"
    @results = {}
    @domain = nil
    @error = nil

    respond_to do |format|
      format.turbo_stream
      format.html { render :index }
    end
  end
end
