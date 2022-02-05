# pluginの定数未定義を握りつぶす
class Module
  module ExtModule
    def const_missing(id)
      if self.name =~ /^ProconBypassMan::Plugin/
        parent_const = Object.const_get("#{self.name}")
        parent_const.const_set(id, Module.new)
        Object.const_get("#{self.name}::#{id}")
      else
        super
      end
    end
  end

  prepend ExtModule
end
