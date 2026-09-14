class ApplicationMailer < ActionMailer::Base
  default from: "from@example.com"
  layout "mailer"

  # Shared with app/views/line_items/_line_item.html.erb, which order
  # confirmation/shipped emails render. Mailer jobs don't inherit the
  # customer's I18n.locale from the request that enqueued them, so this
  # currently always renders in USD regardless of the order's locale --
  # matching today's un-localized emails. Revisit once emails are localized.
  helper CurrencyHelper
end
