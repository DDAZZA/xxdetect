#!/bin/ruby
# Name: Detect Bar Chars
# Author: David Elliott
# GitHub: https://github.com/DDAZZA/xxdetect
# Description: Parses a hexdump and compares with all chars to detect bad chars

def print_help
  puts "██   ██ ██   ██ ██████  ███████ ████████ ███████  ██████ ████████"
  puts " ██ ██   ██ ██  ██   ██ ██         ██    ██      ██         ██"
  puts "  ███     ███   ██   ██ █████      ██    █████   ██         ██"
  puts " ██ ██   ██ ██  ██   ██ ██         ██    ██      ██         ██"
  puts "██   ██ ██   ██ ██████  ███████    ██    ███████  ██████    ██"
  puts "  by David Elliott                                                                                                        "
  puts
  puts "Usage:"
  puts "  #{$0} [-h] [-v] [-g OUTPUT_FILE]"
  puts "  xxd FILE.mem | #{$0} [-V] bytes"
  puts "                                                                                                                       "
  puts "Example:"
  puts "  #{$0} -g dump.mem"
  puts "  xxd dump.mem | #{$0} '\\x00'"
  puts
  puts "Options:"
  puts "  -g, --generate FILE \tGenerate a file with all bad chars"
  puts "  -o, --only          \tOnly print the next bad char"
  puts "  -V, --verbose       \tMore Verbose output (Cant be used with 'only mode')"
  puts "  -v, --version       \tPrint version"
  puts "  -h, --help          \tShow this message"
  exit
end


class Numeric
  def to_hex
    h = to_s(16).downcase
    if h.length == 2
      h
    else
      "0" + h
    end
  end
end

class String
  # colorization
  def colorize(color_code)
    "\e[#{color_code}m#{self}\e[0m"
  end

  def red
    colorize(31)
  end

  def green
    colorize(32)
  end

  def yellow
    colorize(33)
  end

  def blue
    colorize(34)
  end

  def pink
    colorize(35)
  end

  def light_blue
    colorize(36)
  end

  def bold
    "\e[1m#{self}\e[22m"
  end
end


VERSION = '0.1.1'
ALL_BAD_CHARS = "\x00\x01\x02\x03\x04\x05\x06\x07\x08\x09\x0a\x0b\x0c\x0d\x0e\x0f\x10" +
  "\x11\x12\x13\x14\x15\x16\x17\x18\x19\x1a\x1b\x1c\x1d\x1e\x1f\x20" +
  "\x21\x22\x23\x24\x25\x26\x27\x28\x29\x2a\x2b\x2c\x2d\x2e\x2f\x30" +
  "\x31\x32\x33\x34\x35\x36\x37\x38\x39\x3a\x3b\x3c\x3d\x3e\x3f\x40" +
  "\x41\x42\x43\x44\x45\x46\x47\x48\x49\x4a\x4b\x4c\x4d\x4e\x4f\x50" +
  "\x51\x52\x53\x54\x55\x56\x57\x58\x59\x5a\x5b\x5c\x5d\x5e\x5f\x60" +
  "\x61\x62\x63\x64\x65\x66\x67\x68\x69\x6a\x6b\x6c\x6d\x6e\x6f\x70" +
  "\x71\x72\x73\x74\x75\x76\x77\x78\x79\x7a\x7b\x7c\x7d\x7e\x7f\x80" +
  "\x81\x82\x83\x84\x85\x86\x87\x88\x89\x8a\x8b\x8c\x8d\x8e\x8f\x90" +
  "\x91\x92\x93\x94\x95\x96\x97\x98\x99\x9a\x9b\x9c\x9d\x9e\x9f\xa0" +
  "\xa1\xa2\xa3\xa4\xa5\xa6\xa7\xa8\xa9\xaa\xab\xac\xad\xae\xaf\xb0" +
  "\xb1\xb2\xb3\xb4\xb5\xb6\xb7\xb8\xb9\xba\xbb\xbc\xbd\xbe\xbf\xc0" +
  "\xc1\xc2\xc3\xc4\xc5\xc6\xc7\xc8\xc9\xca\xcb\xcc\xcd\xce\xcf\xd0" +
  "\xd1\xd2\xd3\xd4\xd5\xd6\xd7\xd8\xd9\xda\xdb\xdc\xdd\xde\xdf\xe0" +
  "\xe1\xe2\xe3\xe4\xe5\xe6\xe7\xe8\xe9\xea\xeb\xec\xed\xee\xef\xf0" +
  "\xf1\xf2\xf3\xf4\xf5\xf6\xf7\xf8\xf9\xfa\xfb\xfc\xfd\xfe\xff"


def generate_bad_chars(file="./test.raw")
  File.open(file, "w") do |f|
    f.write ALL_BAD_CHARS
  end
  puts "Written bytes to '#{file}'"
  exit
end

def parse_argument(args)
  arg = args.first

  if args.include?('-h') || args.include?('--help') || arg.nil?
    print_help
  end

  if arg == '-g' || arg == '--generate'
    raise "FILE argument missing" if ARGV[1].nil?
    generate_bad_chars(ARGV[1])
  end

  if args.include?('-v') || args.include?('--version')
    puts VERSION
    exit
  end

  if args.include?('-V') || args.include?('--verbose')
    $VERBOSE_MODE = true
  elsif args.include?('-o') || args.include?('--only')
    $ONLY_MODE=true
  else
    # normal output
  end

  args = args - ['-V', '--verbose', '-o', '--only']

  if args.size == 1
    eval('"%s"' % args.last)
  else
    raise 'Invalid amount of arguments'
  end
end

excluded_chars = parse_argument(ARGV)

all_bad_chars = ALL_BAD_CHARS.unpack("C*")

raise 'Missing argument' if excluded_chars.nil?
#raise 'Invalid argument' if (excluded_chars.size % 4) != 0
raise 'Missing input' if STDIN.tty?

excluded_chars = excluded_chars.unpack("C*")
remaining_chars = all_bad_chars - excluded_chars


class XxdPrintParser
  attr_reader :printer, :first_bad_char, :remaining_chars

  # Parses the below line format
  # 00000000: 4343 4300 0102 0304 0506 0708 090a 0b0c  CCC.............
  def initialize(chars)
    @remaining_chars = chars
  end

  def parse_print(line)
    return parse_payload(line) if line =~ /[a-f0-9]{4,}$/

    # TODO raise error if format doesn't match

    parta, partb = line.split(': ')
    partb, partc = partb.split('  ')

    result = parta + ": "
    result = result + parse_payload(partb.gsub(" ", ''))
    result = result + "  " + partc.to_s + "\n"
    result
  end

  private

  # @param String payload
  # @param Array<Integers> remaining_chars
  def parse_payload(payload)
    result = ''
    @first_char_match ||= false
    payload.chars.each_slice(2).map(&:join).each_with_index do |c, line_index|
      @index ||= 0

      result = result + ' ' if line_index != 0 && (line_index+1) % 2 != 0

      if @index + 1 > remaining_chars.size
        result = result + c
      else
        if c.to_i(16) == remaining_chars[@index]
          @first_char_match = true
          result = result + c.green
          @index = @index + 1 if @first_char_match == true
        elsif @first_char_match
          if @first_bad_char
            result = result + c.pink
          else
            @first_bad_char ||= remaining_chars[@index].to_hex
            result = result + c.red.bold
          end
          @index = @index + 1 if @first_char_match == true
        else # not had match yet
          result = result + c
        end
      end
    end
    result
  end
end


parser = nil
STDIN.read.split("\n").each do |line|
  parser ||= XxdPrintParser.new(remaining_chars)
  result = parser.parse_print(line)
  puts result unless $ONLY_MODE
end

next_char = "\\x#{parser.first_bad_char}" if parser.first_bad_char

puts "#{next_char}" if $ONLY_MODE && next_char

if $VERBOSE_MODE
  current_list = excluded_chars.map{ |c| "\\x#{c.to_hex}" }.join
  puts
  if next_char
    puts "Next bad char is '#{next_char.yellow.bold}'"
  else
    puts "No new bad chars found!".yellow
  end
  puts "Bad chars list is: '#{current_list}#{next_char}'"
end
