package require base32

set msg [gets stdin]

set mode [lindex $argv 0]
if { $mode eq "-d" } {
	set text [::base32::decode $msg]
	puts $text
} elseif { $mode eq "-e" } {
	set text [::base32::encode $msg]
	puts $text
}