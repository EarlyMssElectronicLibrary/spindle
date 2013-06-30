#!/usr/bin/env ruby

require 'getoptlong'

require_relative 'spindle_functions'

COMMAND = File.basename(__FILE__)

def usage
  "Usage: #{COMMAND} [OPTIONS] IMAGE_DIR SHOOT_LIST_DIR \"REASON\"
"
end # def usage

HELP = "
OPTIONS

      -h, --help: show help

For all images in IMAGE_DIR, locate the matching shot sequence data in
SHOOT_LIST_DIR, and apply the metadata values marked with a '>' below to each
image. REASON is required and will be added as keyword explaining why this 
change was made.

          MEGAVISION_IPTC_DATA
          Date of Origin|                    32| 
          Object Owner|                      32| 
          Lighting Setup|                  2000| ID 
          Catalog Number|                    32| 
        > Object Name|                       64| Georgian NF 7, 2r
          Copyright|                        128| 
          Day Entered|                        8| 
          Series Identifier|                 32| 
          Tile Identifier|                   32| 
          Substrate Material|                64| 
          Media|                             32| 
        > CUBE NAME|                         32| 0055_000003
          Camera Setup|                     254| 
          Instructions|                     254| 
          Page Identifier|                   32|    -   -    
          Urgency|                            1| 0
        > Keyword 1|                         32| Resolution (PPI): 719
        > Keyword 2|                         32| Position: 3
          Keyword 3|                         32| 
          Keyword 4|                         32| 
          Keyword 5|                         32| 
          Keyword 6|                         32| 
          Keyword 7|                         32| 
          Keyword 8|                         32| 
          Keyword 9|                         32| 
          Keyword 10|                        32| 
          Keyword 11|                        32| 
          Keyword 12|                        32| 

Create new md5 files for all updated files.

"

def metadata_value lines, name
  lines.grep(/#{name}/)[0].split('|')[2].strip
end

opts = GetoptLong.new(
  [ '--help', '-h', GetoptLong::NO_ARGUMENT ]
)

opts.each do |opt, arg|
  case opt
    when '--help'
      puts usage
      puts HELP
exit 0
  end
end

status = 0

image_dir = has_dir? 'IMAGE_DIR', ARGV.shift

if image_dir
  message COMMAND, "Using image directory: #{image_dir}"
else
  puts usage
  exit 1
end

shoot_list_dir = has_dir? 'SHOOT_LIST_DIR', ARGV.shift

if shoot_list_dir
  message COMMAND, "Using shoot_list directory: #{shoot_list_dir}"
else
  puts usage
  exit 1
end

reason = ARGV.shift
if reason
  message COMMAND, "Using REASON: #{reason}"
else
  error COMMAND, "No REASON supplied"
  puts usage
  exit 1
end

shot_seq_files = Dir[File.join(shoot_list_dir, '**/*.txt')]

files = Dir[File.join(image_dir, "*.dng")]

files.each do |f|
  shot_seq = File.basename(f).split(/\+/)[0]
  metadata_file = shot_seq_files.grep(/#{shot_seq}/)[0]
  metadata = File.readlines(metadata_file)
  object_name = metadata_value metadata, 'Object Name'
  source = metadata_value metadata, 'CUBE NAME'
  keywords = metadata.grep(/^Keyword/).map { |k| 
    val = k.split('|')[2].strip
    val.empty? ? nil : val
  }.compact
  keywords << "REAPPLIED metadata: #{Time.now}"
  keywords << "REAPPLIED reason: #{reason}"
  keywords << "REAPPLIED tags: Keywords ObjectName Source"
  (args ||= []) << "-m"
  args << keywords.map { |k| "-keywords=#{k}" }
  args << "-ObjectName=#{object_name}"
  args << "-Source=#{source}"
  args << f
  args.flatten!
  system('exiftool', *args)
end



exit status