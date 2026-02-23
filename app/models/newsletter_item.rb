# == Schema Information
#
# Table name: newsletter_items
#
#  id                    :bigint           not null, primary key
#  description           :text
#  linkable_type         :string
#  position              :integer          default(0), not null
#  title                 :string           not null
#  url                   :string           not null
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#  linkable_id           :bigint
#  newsletter_section_id :bigint           not null
#
# Indexes
#
#  index_newsletter_items_on_linkable_type_and_linkable_id       (linkable_type,linkable_id)
#  index_newsletter_items_on_newsletter_section_id               (newsletter_section_id)
#  index_newsletter_items_on_newsletter_section_id_and_position  (newsletter_section_id,position)
#
# Foreign Keys
#
#  fk_rails_...  (newsletter_section_id => newsletter_sections.id)
#
class NewsletterItem < ApplicationRecord
  belongs_to :newsletter_section
  belongs_to :linkable, polymorphic: true, optional: true
  has_one :tracked_link, as: :trackable, dependent: :destroy

  LINKABLE_TYPES = %w[Article RubyGem GithubRepo RedditPost].freeze

  validates :title, presence: true
  validates :url, presence: true
  validates :linkable_type, inclusion: {in: LINKABLE_TYPES}, allow_nil: true

  before_validation :clear_blank_linkable

  default_scope { order(:position) }

  def first_flight?
    return false unless linkable_type == "Article" && linkable&.blog_id

    blog_id = linkable.blog_id
    current_issue = newsletter_section.newsletter_issue

    !NewsletterItem
      .joins(newsletter_section: :newsletter_issue)
      .where(linkable_type: "Article")
      .where(newsletter_issues: {sent_at: ...current_issue.created_at})
      .where.not(newsletter_sections: {newsletter_issue_id: current_issue.id})
      .where(linkable_id: Article.where(blog_id: blog_id).select(:id))
      .exists?
  end

  private

  def clear_blank_linkable
    if linkable_type.blank? || linkable_id.blank?
      self.linkable_type = nil
      self.linkable_id = nil
    end
  end
end
