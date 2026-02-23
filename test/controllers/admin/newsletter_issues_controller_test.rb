require "test_helper"

class Admin::NewsletterIssuesControllerTest < ActionDispatch::IntegrationTest
  setup do
    sign_in_admin
    @newsletter_issue = newsletter_issues(:issue_one)
  end

  test "redirects when not authenticated" do
    delete admin_session_path
    get admin_newsletter_issues_path
    assert_redirected_to new_admin_session_path
  end

  test "index" do
    get admin_newsletter_issues_path
    assert_response :success
  end

  test "show" do
    get admin_newsletter_issue_path(@newsletter_issue)
    assert_response :success
  end

  test "new" do
    get new_admin_newsletter_issue_path
    assert_response :success
  end

  test "create with valid params" do
    assert_difference("NewsletterIssue.count") do
      post admin_newsletter_issues_path, params: {newsletter_issue: {issue_number: 99, subject: "Test Issue"}}
    end
    assert_redirected_to admin_newsletter_issue_path(NewsletterIssue.last)
  end

  test "create with invalid params" do
    post admin_newsletter_issues_path, params: {newsletter_issue: {issue_number: nil, subject: ""}}
    assert_response :unprocessable_content
  end

  test "edit" do
    get edit_admin_newsletter_issue_path(@newsletter_issue)
    assert_response :success
  end

  test "update with valid params" do
    patch admin_newsletter_issue_path(@newsletter_issue), params: {newsletter_issue: {subject: "Updated Subject"}}
    assert_redirected_to admin_newsletter_issue_path(@newsletter_issue)
    assert_equal "Updated Subject", @newsletter_issue.reload.subject
  end

  test "update with invalid params" do
    patch admin_newsletter_issue_path(@newsletter_issue), params: {newsletter_issue: {subject: ""}}
    assert_response :unprocessable_content
  end

  test "create with nested sections and items" do
    assert_difference ["NewsletterIssue.count", "NewsletterSection.count", "NewsletterItem.count"] do
      post admin_newsletter_issues_path, params: {newsletter_issue: {
        issue_number: 100,
        subject: "Nested Test",
        newsletter_sections_attributes: {
          "0" => {
            title: "Test Section",
            position: 0,
            newsletter_items_attributes: {
              "0" => {title: "Item One", url: "https://example.com/one", position: 0}
            }
          }
        }
      }}
    end
    issue = NewsletterIssue.last
    assert_redirected_to admin_newsletter_issue_path(issue)
    assert_equal 1, issue.newsletter_sections.count
    assert_equal 1, issue.newsletter_sections.first.newsletter_items.count
  end

  test "create with nested item including article linkable" do
    article = articles(:rails_performance)
    assert_difference ["NewsletterIssue.count", "NewsletterItem.count"] do
      post admin_newsletter_issues_path, params: {newsletter_issue: {
        issue_number: 101,
        subject: "With Article",
        newsletter_sections_attributes: {
          "0" => {
            title: "Test Section",
            position: 0,
            newsletter_items_attributes: {
              "0" => {title: article.title, url: article.url, position: 0, linkable_type: "Article", linkable_id: article.id}
            }
          }
        }
      }}
    end
    item = NewsletterIssue.last.newsletter_sections.first.newsletter_items.first
    assert_equal article.id, item.linkable_id
    assert_equal "Article", item.linkable_type
  end

  test "create with nested item including ruby_gem linkable" do
    gem = ruby_gems(:rack_updated)
    assert_difference ["NewsletterIssue.count", "NewsletterItem.count"] do
      post admin_newsletter_issues_path, params: {newsletter_issue: {
        issue_number: 102,
        subject: "With Gem",
        newsletter_sections_attributes: {
          "0" => {
            title: "Test Section",
            position: 0,
            newsletter_items_attributes: {
              "0" => {title: gem.name, url: gem.project_url, position: 0, linkable_type: "RubyGem", linkable_id: gem.id}
            }
          }
        }
      }}
    end
    item = NewsletterIssue.last.newsletter_sections.first.newsletter_items.first
    assert_equal gem.id, item.linkable_id
    assert_equal "RubyGem", item.linkable_type
  end

  test "create with nested items auto-generates tracked links" do
    assert_difference ["NewsletterIssue.count", "TrackedLink.count"] do
      post admin_newsletter_issues_path, params: {newsletter_issue: {
        issue_number: 200,
        subject: "Tracked Links Test",
        newsletter_sections_attributes: {
          "0" => {
            title: "Shiny Objects",
            position: 0,
            newsletter_items_attributes: {
              "0" => {title: "Item One", url: "https://example.com/one", position: 0}
            }
          }
        }
      }}
    end
    issue = NewsletterIssue.last
    link = issue.tracked_links.first
    assert_equal "Item One", link.trackable.title
    assert_includes link.destination_url, "utm_source=rubycrow"
  end

  test "update with new items generates additional tracked links" do
    assert_difference "TrackedLink.count", 1 do
      patch admin_newsletter_issue_path(@newsletter_issue), params: {newsletter_issue: {
        newsletter_sections_attributes: {
          "0" => {
            title: "New Section",
            position: 5,
            newsletter_items_attributes: {
              "0" => {title: "New Item", url: "https://example.com/new", position: 0}
            }
          }
        }
      }}
    end
    assert_redirected_to admin_newsletter_issue_path(@newsletter_issue)
  end

  test "update adds new section" do
    assert_difference "NewsletterSection.count" do
      patch admin_newsletter_issue_path(@newsletter_issue), params: {newsletter_issue: {
        newsletter_sections_attributes: {
          "0" => {title: "Brand New Section", position: 5}
        }
      }}
    end
    assert_redirected_to admin_newsletter_issue_path(@newsletter_issue)
  end

  test "update destroys section" do
    section = newsletter_sections(:crows_pick)
    assert_difference "NewsletterSection.count", -1 do
      patch admin_newsletter_issue_path(@newsletter_issue), params: {newsletter_issue: {
        newsletter_sections_attributes: {
          "0" => {id: section.id, _destroy: "1"}
        }
      }}
    end
    assert_redirected_to admin_newsletter_issue_path(@newsletter_issue)
  end

  test "update reorders sections" do
    crows_pick = newsletter_sections(:crows_pick)
    shiny_objects = newsletter_sections(:shiny_objects)

    patch admin_newsletter_issue_path(@newsletter_issue), params: {newsletter_issue: {
      newsletter_sections_attributes: {
        "0" => {id: crows_pick.id, position: 1},
        "1" => {id: shiny_objects.id, position: 0}
      }
    }}

    assert_redirected_to admin_newsletter_issue_path(@newsletter_issue)
    assert_equal 1, crows_pick.reload.position
    assert_equal 0, shiny_objects.reload.position
  end

  test "publish enqueues SendNewsletterJob" do
    @unpublished = newsletter_issues(:issue_two)
    assert_enqueued_with(job: SendNewsletterJob, args: [{newsletter_issue_id: @unpublished.id}]) do
      post publish_admin_newsletter_issue_path(@unpublished)
    end
    assert_redirected_to admin_newsletter_issue_path(@unpublished)
    assert_equal "Newsletter is being sent to all subscribers.", flash[:notice]
  end

  test "publish redirects with alert if already published" do
    post publish_admin_newsletter_issue_path(@newsletter_issue)
    assert_redirected_to admin_newsletter_issue_path(@newsletter_issue)
    assert_equal "This issue has already been published.", flash[:alert]
  end

  test "destroy" do
    assert_difference("NewsletterIssue.count", -1) do
      delete admin_newsletter_issue_path(@newsletter_issue)
    end
    assert_redirected_to admin_newsletter_issues_path
  end
end
