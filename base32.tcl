package require base32

proc split {str size} {
	set result [list]
	for {set i 0} {$i < [string length $str]} {incr i $size} {
		lappend result [string range $str $i [expr {$i + $size - 1}]]
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

if { $dec } {
	# Se estiver decodificando, remover as quebras de linha apenas do texto codificado
	set inputData [string map {\r "" \n ""} $inputData]
}

if { $col == 0 } {
	if { !$dec && !$pad } {
		set sEnc [::base32::encode $inputData]
		set chunks [split $sEnc 64]
		foreach chunk $chunks {
			puts $chunk
		}
	} elseif { $dec && !$pad } {
		set decoder [::base32::decode $inputData]
		puts $decoder
	}

	if { !$dec && $pad } {
		set sEnc [::base32::encode -nopad $inputData]
		set chunks [split $sEnc 64]
		foreach chunk $chunks {
			puts $chunk
		}
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
		set mergedData [join [split $decoder 64] ""]
		puts $mergedData
	}

	if { !$dec && $pad } {
		set sEnc [::base32::encode -nopad $inputData]
		set chunks [split $sEnc $col]
		foreach chunk $chunks {
			puts $chunk
		}
	} elseif { $dec && $pad } {
		set decoder [::base32::decode -nopad $inputData]
		set mergedData [join [split $decoder 64] ""]
		puts $mergedData
	}
}
