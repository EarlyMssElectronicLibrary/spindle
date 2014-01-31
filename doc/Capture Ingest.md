

Check file integrity
    Check for md5s.txt file
    If md5s.txt file newer than listed files:
        validate
    Else:
        check for md5s_v2.txt

    If md5s_v2.txt:
        generate md5s.txt
        validate
    Else:
        generate md5s.txt

Collect metadata


Copy files into repo with checksum

Upload metadata to KatIkon

