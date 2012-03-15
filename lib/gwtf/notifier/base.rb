module Gwtf
  module Notifier
    class Base
      attr_reader :item, :recipient

      def initialize(item, recipient)
        @item = item
        @recipient = recipient
      end

      def notify
        raise "Notifiers must impliment the notify method"
      end
    end
  end
end
