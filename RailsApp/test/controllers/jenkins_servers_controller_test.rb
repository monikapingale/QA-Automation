require 'test_helper'

class JenkinsServersControllerTest < ActionDispatch::IntegrationTest
  setup do
    @jenkins_server = jenkins_servers(:one)
  end

  test "should get index" do
    get jenkins_servers_url
    assert_response :success
  end

  test "should get new" do
    get new_jenkins_server_url
    assert_response :success
  end

  test "should create jenkins_server" do
    assert_difference('JenkinsServer.count') do
      post jenkins_servers_url, params: { jenkins_server: { browser: @jenkins_server.browser, name: @jenkins_server.name, os: @jenkins_server.os, password: @jenkins_server.password, url: @jenkins_server.url, username: @jenkins_server.username } }
    end

    assert_redirected_to jenkins_server_url(JenkinsServer.last)
  end

  test "should show jenkins_server" do
    get jenkins_server_url(@jenkins_server)
    assert_response :success
  end

  test "should get edit" do
    get edit_jenkins_server_url(@jenkins_server)
    assert_response :success
  end

  test "should update jenkins_server" do
    patch jenkins_server_url(@jenkins_server), params: { jenkins_server: { browser: @jenkins_server.browser, name: @jenkins_server.name, os: @jenkins_server.os, password: @jenkins_server.password, url: @jenkins_server.url, username: @jenkins_server.username } }
    assert_redirected_to jenkins_server_url(@jenkins_server)
  end

  test "should destroy jenkins_server" do
    assert_difference('JenkinsServer.count', -1) do
      delete jenkins_server_url(@jenkins_server)
    end

    assert_redirected_to jenkins_servers_url
  end
end
