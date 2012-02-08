# stolen from https://gist.github.com/119874

require 'sinatra'

module Sinatra::Partials
    def partial(template, *args)
        template_array = template.to_s.split('/')
        template = template_array[0..-2].join('/') + "/_#{template_array[-1]}"
        options = args.last.is_a?(Hash) ? args.pop : {}
        options.merge!(:layout => false)
        locals = options[:locals] || {}
        if collection = options.delete(:collection) then
            collection.inject([]) do |buffer, member|
                buffer << erb(:"#{template}", options.merge(:layout =>
                false, :locals => {template_array[-1].to_sym => member}.merge(locals)))
            end.join("\n")
        else
            erb(:"#{template}", options)
        end
    end
end

helpers Sinatra::Partials