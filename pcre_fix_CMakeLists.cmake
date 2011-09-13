file(READ ${fixfile} code)
string(REPLACE "pcre.h.generic" "pcre.h.in" code "${code}")
file(WRITE ${fixfile} "${code}")

file(READ ${append_file} code)
file(APPEND ${fixfile} "${code}")