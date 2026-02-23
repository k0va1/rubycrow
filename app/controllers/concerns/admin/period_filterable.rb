module Admin
  module PeriodFilterable
    extend ActiveSupport::Concern

    PERIOD_FILTERS = {
      "last_week" => 1.week,
      "last_2_weeks" => 2.weeks,
      "last_month" => 1.month
    }.freeze
  end
end
