require "resolv"

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
      "A" => Resolv::DNS::Resource::IN::A,
      "AAAA" => Resolv::DNS::Resource::IN::AAAA,
      "CNAME" => Resolv::DNS::Resource::IN::CNAME,
      "MX" => Resolv::DNS::Resource::IN::MX,
      "TXT" => Resolv::DNS::Resource::IN::TXT,
      "NS" => Resolv::DNS::Resource::IN::NS,
      "PTR" => Resolv::DNS::Resource::IN::PTR
    }

    dns_resolver = Resolv::DNS.new(nameserver: [ "8.8.8.8" ])

    lookup_types.each do |type, resource|
      begin
        @results[type] = dns_resolver.getresources(@domain, resource)
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
