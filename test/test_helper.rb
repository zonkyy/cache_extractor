# -*- coding: utf-8 -*-
$LOAD_PATH.unshift File.dirname(__FILE__) + '/../lib'

# describe の代わりに describe_internally を使用することで
# 内部で private メソッドを自由に呼び出せる
def describe_internally(*args, &block)
  example = describe(*args, &block)
  cls = args[0]
  if cls.is_a? Class
    saved_private_instance_methods = cls.private_instance_methods
    example.before do
      cls.class_eval { public *saved_private_instance_methods }
    end
    example.after do
      cls.class_eval { private *saved_private_instance_methods }
    end
  end
end
