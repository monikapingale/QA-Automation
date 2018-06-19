require 'test_helper'

class CredentailsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @credentail = credentails(:one)
  end

  test "should get index" do
    get credentails_url
    assert_response :success
  end

  test "should get new" do
    get new_credentail_url
    assert_response :success
  end

  test "should create credentail" do
    assert_difference('Credential.count') do
      post credentails_url, params: { credentail: { hostName: @credentail.hostName, password: @credentail.password, type: @credentail.type, username: @credentail.username } }
    end

    assert_redirected_to credentail_url(Credential.last)
  end

  test "should show credentail" do
    get credentail_url(@credentail)
    assert_response :success
  end

  test "should get edit" do
    get edit_credentail_url(@credentail)
    assert_response :success
  end

  test "should update credentail" do
    patch credentail_url(@credentail), params: { credentail: { hostName: @credentail.hostName, password: @credentail.password, type: @credentail.type, username: @credentail.username } }
    assert_redirected_to credentail_url(@credentail)
  end

  test "should destroy credentail" do
    assert_difference('Credential.count', -1) do
      delete credentail_url(@credentail)
    end

    assert_redirected_to credentails_url
  end
end
