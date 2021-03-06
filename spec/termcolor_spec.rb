# -*- coding: utf-8 -*-
require File.dirname(__FILE__) + '/spec_helper'

module TermColor
  describe TermColor do
    before do
    end

    it 'should parse 1' do
      text = TermColor.parse('aaa<red>aaaa<bold>foo</bold>bb<blue>bbbb</blue>bbb</red>ccc<on_yellow>ccccc</on_yellow>ccc')
      puts text
      text.should == "aaa\e[31maaaa\e[1mfoo\e[0m\e[31mbb\e[34mbbbb\e[0m\e[31mbbb\e[0mccc\e[43mccccc\e[0mccc"
    end

    it 'should parse 2' do
      text = TermColor.parse('aa<blue>a<foo>aaa<red>aa</red>aaaa</foo>a</blue>aaa')
      puts text
      text.should == "aa\e[34maaaa\e[31maa\e[0m\e[34maaaa\e[0ma\e[0maaa"
    end

    it 'should parse 3' do
      text = TermColor.parse('aa<blue>aaaaa&lt;aaa&quot;aaa&gt;aaa&amp;aaaaa</blue>aaa')
      puts text
      text.should == "aa\e[34maaaaa<aaa\"aaa>aaa&aaaaa\e[0maaa"
    end

    it 'should parse 4' do
      text = TermColor.parse('aa<30>bbbbbbb<32>cccc<90>ddd</90>c</32>b</30>aaa')
      puts text
      text.should == "aa\e[30mbbbbbbb\e[32mcccc\e[90mddd\e[0m\e[30m\e[32mc\e[0m\e[30mb\e[0maaa"
    end

    it 'should parse 5' do
      text = TermColor.parse('aa<f123>bbbbbbb<b321>ccccc</b321>b</f123>aaa')
      puts text
      text.should == "aa\e[38;5;67mbbbbbbb\e[48;5;137mccccc\e[0m\e[38;5;67mb\e[0maaa"
    end

    it 'should parse 6' do
      text = TermColor.parse('aa<f12>bbbbbbb<b6>ccccc</b6>b</f12>aaa')
      puts text
      text.should == "aa\e[38;5;244mbbbbbbb\e[48;5;238mccccc\e[0m\e[38;5;244mb\e[0maaa"
    end

    it 'should raise Error' do
      lambda{ TermColor.parse('aaaaa<red>aaaaa</blue>aaaaa') }.should raise_error(REXML::ParseException)
      lambda{ TermColor.parse('aaaaa<red>aaaaaaaaaa') }.should_not raise_error(REXML::ParseException)
    end

    it 'should escape text' do
      TermColor.escape('<>&"\'').should == "&lt;&gt;&amp;&quot;&apos;"
    end

    it 'should unescape text' do
      TermColor.unescape("&lt;&gt;&amp;&quot;&apos;").should == '<>&"\''
    end

    it 'should prepare parse' do
      TermColor.prepare_parse("<10>10</10>").should == '<_10>10</_10>'
      TermColor.prepare_parse("<32>10</32>").should == '<_32>10</_32>'
    end

    it 'should convert to escape sequence' do
      listener = TermColor::MyListener.new
      listener.to_esc_seq('red').should == "\e[31m"
      listener.to_esc_seq('on_red').should == "\e[41m"
      listener.to_esc_seq('foo').should == nil
      listener.to_esc_seq('0').should == "\e[0m"
      listener.to_esc_seq('31').should == "\e[31m"
      listener.to_esc_seq('031').should == "\e[031m"
      listener.to_esc_seq('_0').should == "\e[0m"
      listener.to_esc_seq('_31').should == "\e[31m"
    end

    it 'should do colorize' do
      TermColor.colorize('test', :green).should == "\e[32mtest\e[0m"
    end

    it 'should make separate tags for combined-style tag' do
      h = { "<red_on_yellow>hello, world</red_on_yellow>" =>
                   "<red><on_yellow>hello, world</on_yellow></red>",
            "<green_with_bold>hello, world</green_with_bold>" =>
                   "<green><bold>hello, world</bold></green>",
            "<blue_on_white_with_bold_and_underline>hello</blue_on_white_with_bold_and_underline>" =>
                   "<blue><on_white><bold><underline>hello</underline></bold></on_white></blue>",
            "<black_on_white>hello</black_on_white>term<green_with_bold>color</green_with_bold>" =>
                   "<black><on_white>hello</on_white></black>term<green><bold>color</bold></green>" }
      h.each_pair do |combined, separated|
        TermColor.prepare_parse(combined).should == separated
      end
    end

    it 'should do colorize using String#termcolor' do
      "<red>ruby</red>".termcolor.should == "\e[31mruby\e[0m"
      "ruby".termcolor(:red).should == "<red>ruby</red>".termcolor
      "ruby isn't ruby gem".termcolor(:red, 11..14).should == "ruby isn't <red>ruby</red> gem".termcolor
      "ruby isn't ruby gem".termcolor(:red, 'ruby').should == "<red>ruby</red> isn't <red>ruby</red> gem".termcolor
      "ruby isn't ruby gem".termcolor(:red, :ruby).should == "<red>ruby</red> isn't <red>ruby</red> gem".termcolor
      "Ruby isn't Ruby Gem".termcolor(:red, '[A-Z]+').should == "<red>R</red>uby isn't <red>R</red>uby <red>G</red>em".termcolor
    end
  end
end
