require File.dirname(__FILE__) + '/../test_helper'
require 'reports_Controller'

# Re-raise errors caught by the controller.
class ReportsController; def rescue_action(e) raise e end; end

class ReportsControllerTest < Test::Unit::TestCase
  fixtures :organizations, :people, :visits

  def setup
    @controller = ReportsController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    login_as 'greeter'
  end

  def test_index
    get :index, :organization_key => 'sfbk'
    assert_response :success
  end

  def test_visits_report
    get :visits, :organization_key => 'sfbk',
            :report => { :after => { :year => 2007, :month => 1, :day => 1 },
                         :before => { :year => 2009, :month => 1, :day => 1 } },
            :page => 2
    assert_response :success
    assert_not_nil assigns(:report)
    assert_not_nil assigns(:visits)
    assert_equal 102, assigns(:visits).size
    assert_equal 20, assigns(:visits).to_a.size
    assert_equal 2, assigns(:visits).page
  end

  def test_visits_report_default
    get :visits, :organization_key => 'sfbk'
    assert_response :success
    assert_not_nil assigns(:report)
    assert_not_nil assigns(:visits)
  end

  def test_visits_report_csv
    get :visits, :organization_key => 'sfbk',
            :report => { :after => { :year => 2007, :month => 1, :day => 1 },
                         :before => { :year => 2009, :month => 1, :day => 1 } },
            :format => 'csv'
    assert_response :success
    assert_not_nil assigns(:visits)
    assert_equal 102, assigns(:visits).size

    output = StringIO.new
    output.binmode
    assert_nothing_raised { @response.body.call(@response, output) }
    lines = output.string.split("\n")
    assert_equal assigns(:visits).size + 1, lines.size
    assert_equal 'first_name,last_name,email,phone,postal_code,datetime,volunteer,note', lines[0]
    assert_equal "attachment; filename=\"sfbk_visits_2007-01-01_2009-01-01.csv\"", @response.headers['Content-Disposition']
  end

  def test_services_report
    get :services, :organization_key => 'sfbk',
            :report => {  :after => { :year => 2006, :month => 1, :day => 1 },
                          :before => { :year => 2009, :month => 1, :day => 1 },
                          :for_service_types => [ service_types(:membership).id, service_types(:class).id] },
            :page => 2
    assert_response :success
    assert_not_nil assigns(:report)
    assert_not_nil assigns(:services)
    assert_equal 28, assigns(:services).size
    assert_equal 8, assigns(:services).to_a.size
    assert_equal 2, assigns(:services).page
    assert_select "input[type=checkbox]", 3
    assert_select "input[type=checkbox][checked=checked]", 2
  end

  def test_services_report_default
    get :services, :organization_key => 'sfbk'
    assert_response :success
    assert_not_nil assigns(:report)
    assert_not_nil assigns(:services)
  end

  def test_services_report_csv
    get :services, :organization_key => 'sfbk',
            :report => {  :after => { :year => 2006, :month => 1, :day => 1 },
                          :before => { :year => 2009, :month => 1, :day => 1 },
                          :for_service_types => [ service_types(:membership).id, service_types(:class).id] },
            :format => 'csv'
    assert_response :success
    assert_not_nil assigns(:services)
    assert_equal 28, assigns(:services).size

    output = StringIO.new
    output.binmode
    assert_nothing_raised { @response.body.call(@response, output) }
    lines = output.string.split("\n")
    assert_equal assigns(:services).size + 1, lines.size
    assert_equal 'first_name,last_name,email,phone,postal_code,service_type,start_date,end_date,volunteered,paid,note', lines[0]
    assert_equal "attachment; filename=\"sfbk_services_2006-01-01_2009-01-01.csv\"", @response.headers['Content-Disposition']
  end

  def test_signin_report
    get :signin, :organization_key => 'sfbk', :year => 2008, :month => 2, :day => 1
    assert_response :success
    assert_not_nil assigns(:visits)
    assert_equal 3, assigns(:visits).size
    assert_equal Date.new(2008,2,1), assigns(:day)
  end

end