require 'test_helper'

class AccmeLibTest < ActiveSupport::TestCase
  def test_if_pars_serializer_validates
    serializer = AccmeLib::Pars::Serializer.new
    serializer.activity_type = 'C'
    serializer.country = 'USA'
    serializer.add_commercial_source :commercial_supporters_source => 'Testing, Inc.',
                                     :monetary_amount_received =>0,
                                     :inkind_durable => false,
                                     :inkind_space => false,
                                     :inkind_dispose => false,
                                     :inkind_animal => false,
                                     :inkind_human => false,
                                     :inkind_other => ''
    isvalid = serializer.valid?

    errors = serializer.errors
    assert_equal true, errors.to_yaml
  end
end
