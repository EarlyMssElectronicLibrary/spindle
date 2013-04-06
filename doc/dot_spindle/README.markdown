# Dot spindle directory

Certain system specific settings can be made here.

At present the important one is the `SPINDLE_AWS_BUCKET` value which should be
set in the `init.rb` file.

To install, do the following

      $ cd ~
      $ mkdir .spindle
      $ cp ~/path/to/doc/dot_spindle/init.rb .spindle/

Edit the following line in ~/.spindle/init.rb to refer to the AWS bucket where
the image metadata should sent.

      SPINDLE_AWS_BUCKET = 'REPLACE_ME'

Thus:

      SPINDLE_AWS_BUCKET = 'real.bucket.name'

