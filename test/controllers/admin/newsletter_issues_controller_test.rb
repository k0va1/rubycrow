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

  test "destroy" do
    assert_difference("NewsletterIssue.count", -1) do
      delete admin_newsletter_issue_path(@newsletter_issue)
    end
    assert_redirected_to admin_newsletter_issues_path
  end
end
