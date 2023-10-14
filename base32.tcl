package require base32

proc split {str size} {
    set result [list]
    while {[string length $str] > 0} {
        lappend result [string range $str 0 [expr {$size - 1}]]
        set str [string range $str $size end]
    }
    return $result
}

set col 64
set dec 0
set pad 0

set mode [lindex $argv 0]

if { $mode eq "-d" } {
    set dec 1
} elseif { $mode eq "-e" } {
    set dec 0
}

set inputData ""
if {[eof stdin] == 0} {
    set inputData [read stdin]
} elseif {[llength $argv] > 1} {
    set inputFile [lindex $argv 1]

    set fd [open $inputFile r]
    set inputData [read $fd]
    close $fd
}

set inputData [string trimright $inputData "\r\n"]
set inputData [string trimright $inputData "\n"]

if { $col == 0 } {
    if { !$dec && !$pad } {
        set sEnc [::base32::encode $inputData]
        puts $sEnc
    } elseif { $dec && !$pad } {
        set decoder [::base32::decode $inputData]
        puts $decoder
    }

    if { !$dec && $pad } {
        set sEnc [::base32::encode -nopad $inputData]
        puts $sEnc
    } elseif { $dec && $pad } {
        set decoder [::base32::decode -nopad $inputData]
        puts $decoder
    }
} else {
    if { !$dec && !$pad } {
        set sEnc [::base32::encode $inputData]
        set chunks [split $sEnc $col]
        foreach chunk $chunks {
            puts $chunk
        }
    } elseif { $dec && !$pad } {
        set decoder [::base32::decode $inputData]
        puts $decoder
    }

    if { !$dec && $pad } {
        set sEnc [::base32::encode -nopad $inputData]
        set chunks [split $sEnc $col]
        foreach chunk $chunks {
            puts $chunk
        }
    } elseif { $dec && $pad } {
        set decoder [::base32::decode -nopad $inputData]
        puts $decoder
    }
}
