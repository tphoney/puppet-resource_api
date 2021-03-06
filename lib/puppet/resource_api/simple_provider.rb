module Puppet::ResourceApi
  # This class provides a default implementation for set(), when your resource does not benefit from batching.
  # Instead of processing changes yourself, the `create`, `update`, and `delete` functions, are called for you,
  # with proper logging already set up.
  # Note that your type needs to use `ensure` in the conventional way to signal presence and absence of resources.
  class SimpleProvider
    def set(context, changes)
      changes.each do |name, change|
        is = change.key?(:is) ? change[:is] : (get(context) || []).find { |key| key[:id] == name }
        should = change[:should]

        is = { name: name, ensure: 'absent' } if is.nil?
        should = { name: name, ensure: 'absent' } if should.nil?

        if is[:ensure].to_s == 'absent' && should[:ensure].to_s == 'present'
          context.creating(name) do
            create(context, name, should)
          end
        elsif is[:ensure].to_s == 'present' && should[:ensure].to_s == 'present'
          context.updating(name) do
            update(context, name, should)
          end
        elsif is[:ensure].to_s == 'present' && should[:ensure].to_s == 'absent'
          context.deleting(name) do
            delete(context, name)
          end
        end
      end
    end

    def create(_context, _name, _should)
      raise "#{self.class} has not implemented `create`"
    end

    def update(_context, _name, _should)
      raise "#{self.class} has not implemented `update`"
    end

    def delete(_context, _name)
      raise "#{self.class} has not implemented `delete`"
    end
  end
end
