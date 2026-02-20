# == Schema Information
#
# Table name: newsletter_items
#
#  id                    :bigint           not null, primary key
#  description           :text
#  position              :integer          default(0), not null
#  title                 :string           not null
#  url                   :string           not null
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#  article_id            :bigint
#  newsletter_section_id :bigint           not null
#
# Indexes
#
#  index_newsletter_items_on_article_id                          (article_id)
#  index_newsletter_items_on_newsletter_section_id               (newsletter_section_id)
#  index_newsletter_items_on_newsletter_section_id_and_position  (newsletter_section_id,position)
#
# Foreign Keys
#
#  fk_rails_...  (newsletter_section_id => newsletter_sections.id)
#
class NewsletterItem < ApplicationRecord
  belongs_to :newsletter_section
  belongs_to :article, optional: true
  has_one :tracked_link, as: :trackable, dependent: :destroy

  validates :title, presence: true
  validates :url, presence: true

  default_scope { order(:position) }
end
