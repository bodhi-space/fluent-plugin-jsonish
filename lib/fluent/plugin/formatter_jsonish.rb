require 'fluent/formatter'
require 'time'

module Fluent
  module TextFormatter
    class JSONishFormatter < JSONFormatter

      Plugin.register_formatter("jsonish", self)

      config_param :add_tag, :hash, :default => {}
      config_param :add_time, :hash, :default => {}

      def update_entry(tag, time, record)
        merge_hash = {}

        if @add_time.key?('key')
          if not @add_time.key?('format') or @add_time['format'] == 'iso8601(3)'
            merge_hash[@add_time['key']] = Time.at(time.to_r).iso8601(3)
          else
            merge_hash[@add_time['key']] = eval("Time.at(time.to_r).#{@add_time['format']}")
          end
        end

        if @add_tag.key?('key')
          if not @add_tag.key?('format') or @add_tag['format'] == 'to_s'
            merge_hash[@add_tag['key']] = tag.to_s
          else
            merge_hash[@add_tag['key']] = eval("tag.#{@add_tag['format']}")
          end
        end

        return tag, time, record.merge(merge_hash)
      end

      def format(tag, time, record)
        super(*update_entry(tag, time, record))
      end

      def format_without_nl(tag, time, record)
        super(*update_entry(tag, time, record))
      end

    end
  end
end
