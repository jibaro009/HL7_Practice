#tclsh 8.6


set msg MSH|^~\\&|1|2\rPID|1|2|123^^^CDH^MRN~321^^^CDH^UMRN~456^^^MGH^MRN||TEST^CDH^L\rPV1|1|OUTPATIENT\rORC|NW|\rOBR||ORDER_NUMBER\rOBX|1|ST\rOBX|2|ST
#set msg OBX|1|ST\rOBX|2|ST

puts "msh: $msg"

set segments [split $msg \r]
set fieldChar [string index $msg 3]
set subfieldChar [string index $msg 4]
set repetitionChar [string index $msg 5]
set compChar [string index $msg 7]

puts "segment list: $segments"

if 0 {
    Debug Code
    set mshIndex [lsearch -regexp $segmentList ^MSH]
    puts $mshIndex
    set pidIndex [lsearch -regexp $segmentList ^PID]
    puts $pidIndex
    set pv1Index [lsearch -regexp $segmentList ^PV1]
    puts $pv1Index
    set orcSegment [lsearch -inline -regexp $segmentList ^ORC]
    puts $orcSegment
    set obxIndex [lsearch -regexp $segmentList ^OBX]
    puts $obxIndex
    set obxIndex2 [expr {$obxIndex + 1}]
    puts $obxIndex2

    set obrIndex [lsearch -regexp $segmentList ^OBR]
    puts $obrIndex
    
    set mshSegment [lindex $msg $mshIndex]
    set pidSegment [lindex $msg $pidIndex]
    set pv1Segment [lindex $msg $pv1Index]
    set obxSegment [lindex $msg $obxIndex]
    
    #set mshSegment [lindex [lregexp $segmentList ^MSH] 0]
    #set pidSegment [lindex [lregexp $segmentList ^PV1] 0]
    #set pv1Segment [lindex [lregexp $segmentList ^PV1] 0]
    
    puts $mshSegment
    puts $pidSegment
    puts $pv1Segment
    puts $obxSegment
}

#display segments
puts "\nDisplay segments using a foreach loop\n"
foreach segment $segmentList {
   #puts $segment
   #puts "Segment ID: [string range $segment 0 2]"
   set fields [split $segment $fieldChar]  
   #puts [lindex $fields 0]
   puts "fields: $fields"
   if {[lindex $fields 0] eq "OBX"} {
      puts "OBX Segment using split and lindex: $segment"
      puts "\nOBX fields\n"
      set index 1
      foreach field $fields {
         puts "OBX:$index $field"
         #puts $index
         #set index [expr {$index + 1}] 
         incr index
      }
   }
   
   if {[string range $segment 0 2] eq "PV1"} {
      puts "PV1 segment using string and range: $segment"
   }
   
   if {[lindex $fields 0] eq "PID"} {
       puts "PID segment $segment"
       set pid_3 [lindex $fields 3]
       puts "PID3: $pid_3"
       set pid_3_repetitions [split $pid_3 $repetitionChar]
       puts "PID:3 repetitions: $pid_3_repetitions"
       foreach pid_3_repetition $pid_3_repetitions {
          #puts $pid_3_repetition
          set pid_3_repetition_subfields [split $pid_3_repetition $subfieldChar]
          set pid_3_4 [lindex $pid_3_repetition_subfields 3]
          set pid_3_5 [lindex $pid_3_repetition_subfields 4]
          #puts $pid_3_4
          if {$pid_3_4 eq "CDH" && $pid_3_5 eq "MRN"} {
             puts "Patient CDH MRN: [lindex $pid_3_repetition_subfields 0]"
             #puts "Patient CDH repetition: $pid_3_repetition"
             set cdh_mrn_repetition $pid_3_repetition
             puts "Patient CDH repetition: $cdh_mrn_repetition"
          }
       }
       puts "New MRN: [lreplace $pid_3_repetition 0 [llength $pid_3_repetitions] $cdh_mrn_repetition]"
       set new_mrn [lreplace $pid_3_repetition 0 [llength $pid_3_repetitions] $cdh_mrn_repetition]
       #set new_pid_segment [lreplace $segment 2 2 $new_mrn]
       puts "New PID [join [lreplace $fields 3 3 $new_mrn] $fieldChar]"
       set new_pid [join [lreplace $fields 3 3 $new_mrn] $fieldChar]
   }
   
}

set new_segments [lreplace $segmentList 1 1 $new_pid]
puts "New Segments: $new_segments"
set new_msg [join $new_segments \r]
puts "\nNew HL7 MSG: $new_msg"