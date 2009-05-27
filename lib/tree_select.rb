module ActionView
  module Helpers
    module FormOptionsHelper
      def options_from_tree_collection_for_select(collection, value_method, text_method, selected = nil)
        options = recurse_options_from_tree_collection_for_select(collection, value_method, text_method)
        selected, disabled = extract_selected_and_disabled(selected)
        select_deselect = {}
        select_deselect[:selected] = extract_values_from_collection(collection, value_method, selected)
        select_deselect[:disabled] = extract_values_from_collection(collection, value_method, disabled)
        
        options_for_select(options, select_deselect)
      end

      def tree_select(object, method, collection, value_method, text_method, options = {}, html_options = {})
        InstanceTag.new(object, method, self, options.delete(:object)).to_tree_select_tag(collection, value_method, text_method, options, html_options)
      end
      
      private
      def recurse_options_from_tree_collection_for_select(collection, value_method, text_method, level = 0)
        prefix = '-' * 5 * level
        result = []
        collection.each do |element|
          result << ["#{prefix}#{element.send(text_method)}", element.send(value_method)]    
          if element.children.size > 0
            result = result + recurse_options_from_tree_collection_for_select(element.children, value_method, text_method, level + 1)
          end
        end
        
        result
      end
    end

  
    class InstanceTag
      include FormOptionsHelper
    
      def to_tree_select_tag(collection, value_method, text_method, options, html_options)
        html_options = html_options.stringify_keys
        add_default_name_and_id(html_options)
        value = value(object)
        disabled_value = options.has_key?(:disabled) ? options[:disabled] : nil
        selected_value = options.has_key?(:selected) ? options[:selected] : value
        content_tag(
          "select", add_options(options_from_tree_collection_for_select(collection, value_method, text_method, :selected => selected_value, :disabled => disabled_value), options, value), html_options
        )
      end
    end
    
    class FormBuilder
      def tree_select(method, collection, value_method, text_method, options = {}, html_options = {})
        @template.tree_select(@object_name, method, collection, value_method, text_method, objectify_options(options), @default_options.merge(html_options))
      end
    end
  end
end