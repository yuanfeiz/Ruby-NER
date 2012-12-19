# encoding: utf-8
require 'spec_helper'

describe "XmlBuilder" do
  let(:in1) { "湖南 NN B-LOC\n毛 NR B-PER\n泽东 NR I-PER\nEOP\n本报 NR O" }
  before(:each) do
    in1.extend XmlBuilder
  end
  it "should produce the correct result" do
    in1.should respond_to(:to_xml)
    puts in1.to_xml
    in1.to_xml.should be_nil
  end
end