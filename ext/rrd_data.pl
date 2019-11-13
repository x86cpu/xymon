#!/usr/local/bin/perl
# %Z% %M% v%I% - Date: %H% - Time: %U%
# THIS IS UNDER SCCS CONTROL
#####################################################################################
# Script name:  %M%
# Location:     mon01a:/home/hobbit/server/ext/%M%
# Modified:     %H% - %U%
# Release:      %I%
# Copyright (c) RIT 2006. All rights reserved.
#####################################################################################

use strict;

# Input parameters: Hostname, testname (column), and messagefile
my $hostname=$ARGV[0];
my $testname=$ARGV[1];
my $fname=$ARGV[2];

my ( $line,$line2,@line,@lines );
my ( @loop,$key,%buffer,$tmp );

open(OUT,">>/var/log/xymon/rrd_pl.log");
print OUT localtime().": hostname=$hostname\ttestname=$testname\tfname=$fname\n";
close(OUT);

system("/bin/cp -p ${fname} /tmp/holdit");

open(IN,"$fname");
if ( $testname eq "netbytes" ) {
   while(chomp($line=<IN>)) {
      foreach $line2 ( split('\\n',$line) ) {
         @line=split(':',$line2);
         $line[1] = join(' ',split(' ',$line[1]));
         $buffer{$line[0]}=$line[1];
      }
   }
} else {
   while(chomp($line=<IN>)) {
      @line=split(':',$line);
      $line[1] = join(' ',split(' ',$line[1]));
      $buffer{$line[0]}=$line[1];
   }
}
close(IN);

if ( $testname eq "signal" ) {
   if ( defined($buffer{"DOWN"}) ) {
      @loop=split(' ',$buffer{"DOWN"});

      print "DS:power:GAUGE:600:-50:50\n";
      print "DS:snr:GAUGE:600:0:100\n";
      print "DS:corrected:DERIVE:600:0:U\n";
      print "DS:uncorrectables:DERIVE:600:0:U\n";
      foreach $key ( @loop ) {
         undef(@line);
         push(@line,$buffer{"DOWN${key}power"});
         push(@line,$buffer{"DOWN${key}snr"});
         push(@line,$buffer{"DOWN${key}corrected"});
         push(@line,$buffer{"DOWN${key}uncorrectables"});

         print "signal.DOWN${key}.rrd\n";
         $line=join(':',@line);
         print "$line\n";
      }
   }
   if ( defined($buffer{"UP"}) ) {
      @loop=split(' ',$buffer{"UP"});

      print "DS:power:GAUGE:600:0:100\n";
      foreach $key ( @loop ) {
         undef(@line);
         push(@line,$buffer{"UP${key}power"});

         print "signal.UP${key}.rrd\n";
         $line=join(':',@line);
         print "$line\n";
      }
   }

}

if ( $testname eq "speed" ) {
   if ( defined($buffer{"SPEED"}) ) {
      print "DS:download:GAUGE:900:0:U\n";
      print "DS:upload:GAUGE:900:0:U\n";
      print "DS:latency:GAUGE:900:0:U\n";
      undef(@line);
      push(@line,$buffer{"SPEEDDOWN"});
      push(@line,$buffer{"SPEEDUP"});
      push(@line,$buffer{"SPEEDPING"});

      print "speed.rrd\n";
      $line=join(':',@line);
      print "$line\n";
   }
}


if ( $testname eq "mpstat" ) {
   if ( defined($buffer{"CPUs"}) ) {

      @loop=split(' ',$buffer{"CPUs"});
      print "DS:CPU:GAUGE:600:0:32\n";

      print "DS:usr:GAUGE:600:0:100\n";
      print "DS:sys:GAUGE:600:0:100\n";
      print "DS:wt:GAUGE:600:0:100\n";
      print "DS:idl:GAUGE:600:0:100\n";

      foreach $key ( @loop ) {
         undef(@line);
         push(@line,$buffer{"${key}"});
         push(@line,$buffer{"CPU${key}usr"});
         push(@line,$buffer{"CPU${key}sys"});
         push(@line,$buffer{"CPU${key}wt"});
         push(@line,$buffer{"CPU${key}idl"});

         print "mpstat.CPU${key}.rrd\n";
         $line=join(':',@line);
         print "$line\n";
      }

   }
} elsif ( $testname eq "nsrstat" ) {
   if ( $hostname eq "rit010n20" ) {
      system("/bin/cp -p ${fname} /home/xymon/debug");
   }
   if ( defined($buffer{"DRIVEs"}) ) {
      @loop=split(' ',$buffer{"DRIVEs"});

      print "DS:sessions:GAUGE:600:0:U\n";
      print "DS:amountkb:GAUGE:600:0:U\n";
      print "DS:rs:GAUGE:600:0:U\n";
      print "DS:ws:GAUGE:600:0:U\n";
      print "DS:krs:GAUGE:600:0:U\n";
      print "DS:kws:GAUGE:600:0:U\n";
      print "DS:wait:GAUGE:600:0:U\n";
      print "DS:actv:GAUGE:600:0:U\n";
      print "DS:wsvct:GAUGE:600:0:U\n";
      print "DS:perw:GAUGE:600:0:100\n";
      print "DS:perb:GAUGE:600:0:100\n";

      foreach $key ( @loop ) {
         undef(@line);
         push(@line,$buffer{"${key}sessions"});
         push(@line,$buffer{"${key}amountkb"});
         push(@line,$buffer{"${key}rs"});
         push(@line,$buffer{"${key}ws"});
         push(@line,$buffer{"${key}krs"});
         push(@line,$buffer{"${key}kws"});
         push(@line,$buffer{"${key}wait"});
         push(@line,$buffer{"${key}actv"});
         push(@line,$buffer{"${key}wsvct"});
         push(@line,$buffer{"${key}perw"});
         push(@line,$buffer{"${key}perb"});

         $tmp = (split('/',$key))[1];
         print "nsrstat.rmt${tmp}.rrd\n";
         $line=join(':',@line);
         print "$line\n";
      }
   }

   if ( defined($buffer{"POOLs"}) ) {
      @loop=split(' ',$buffer{"POOLs"});

      print "DS:sessions:GAUGE:600:0:U\n";
      print "DS:tapes:GAUGE:600:0:U\n";

      foreach $key ( @loop ) {
         undef(@line);
         push(@line,$buffer{"${key}sessions"});
         push(@line,$buffer{"${key}tapes"});

         print "nsrpool.${key}.rrd\n";
         $line=join(':',@line);
         print "$line\n";
      }
   }
} elsif ( $testname eq "zonestat" || $testname eq "zone" ) {
   if ( defined($buffer{"ZONEs"}) ) {
      @loop=split(' ',$buffer{"ZONEs"});

      print "DS:nproc:GAUGE:600:0:U\n";
      print "DS:size:GAUGE:600:0:U\n";
      print "DS:rss:GAUGE:600:0:U\n";
      print "DS:memory:GAUGE:600:0:U\n";
      print "DS:cpu:GAUGE:600:0:U\n";

      foreach $key ( @loop ) {
         undef(@line);
         push(@line,$buffer{"${key}nproc"});
         push(@line,$buffer{"${key}size"});
         push(@line,$buffer{"${key}rss"});
         push(@line,$buffer{"${key}memory"});
         push(@line,$buffer{"${key}cpu"});

#         print "zonestat.${key}.rrd\n";
         print "${testname}.${key}.rrd\n";
         $line=join(':',@line);
         print "$line\n";
      }

   }
} elsif ( $testname eq "clawscat" ) {
   if ( defined($buffer{"MODULE"}) ) {
      $key=$buffer{"MODULE"};
      print "DS:docspermin:GAUGE:600:0:U\n";
      print "DS:secsperdoc:GAUGE:600:0:U\n";
      print "DS:totaldocs:DERIVE:600:0:U\n";
      print "DS:statusdone:GAUGE:600:0:U\n";
      print "DS:statusproc:GAUGE:600:0:U\n";
      print "DS:statusready:GAUGE:600:0:U\n";
      print "DS:statuspending:GAUGE:600:0:U\n";

      push(@line,$buffer{"${key}DocsPerMinute"});
      push(@line,$buffer{"${key}SecondsPerDoc"});
      push(@line,$buffer{"${key}TotalDocs"});
      push(@line,$buffer{"${key}StatusDone"});
      push(@line,$buffer{"${key}StatusProcessing"});
      push(@line,$buffer{"${key}StatusReady"});
      push(@line,$buffer{"${key}StatusPending"});

      print "clawscat.rrd\n";
      $line=join(':',@line);
      print "$line\n";
   }
} elsif ( $testname eq "claws" ) {
   if ( defined($buffer{"MODULE"}) ) {
      $key=$buffer{"MODULE"};
      print "DS:docspermin:GAUGE:600:0:U\n";
      print "DS:secsperdoc:GAUGE:600:0:U\n";
      print "DS:pending:GAUGE:600:0:U\n";
      print "DS:errors:GAUGE:600:0:U\n";

      push(@line,$buffer{"${key}DocsPerMinute"});
      push(@line,$buffer{"${key}SecondsPerDoc"});
      push(@line,$buffer{"${key}Pending"});
      push(@line,$buffer{"${key}Errors"});

      print "claws.rrd\n";
      $line=join(':',@line);
      print "$line\n";
   }
} elsif ( $testname eq "netbytes" ) {
   if ( defined($buffer{"INTERFACEs"}) ) {
      @loop=split(' ',$buffer{"INTERFACEs"});

      print "DS:bytesrecieved:DERIVE:600:0:U\n";
      print "DS:bytessent:DERIVE:600:0:U\n";

      foreach $key ( @loop ) {
         undef(@line);
         push(@line,$buffer{"${key}_recieved"});
         push(@line,$buffer{"${key}_sent"});

         print "netbytes.$key.rrd\n";
         $line=join(':',@line);
         print "$line\n";
      }
   }
} elsif ( $testname eq "pmdf" ) {
   if ( defined($buffer{"QUEUEs"}) ) {
      @loop=split(' ',$buffer{"QUEUEs"});

      print "DS:enqueued:GAUGE:600:0:U\n";
      print "DS:deferred:GAUGE:600:0:U\n";
      print "DS:retrying:GAUGE:600:0:U\n";
      print "DS:holding:GAUGE:600:0:U\n";

      print "DS:enqueued_5m:GAUGE:600:0:U\n";
      print "DS:enqueued_10m:GAUGE:600:0:U\n";
      print "DS:enqueued_15m:GAUGE:600:0:U\n";
      print "DS:enqueued_30m:GAUGE:600:0:U\n";
      print "DS:enqueued_60m:GAUGE:600:0:U\n";
      print "DS:enqueued_90m:GAUGE:600:0:U\n";
      print "DS:enqueued_2h:GAUGE:600:0:U\n";
      print "DS:enqueued_4h:GAUGE:600:0:U\n";
      print "DS:enqueued_8h:GAUGE:600:0:U\n";
      print "DS:enqueued_12h:GAUGE:600:0:U\n";
      print "DS:enqueued_18h:GAUGE:600:0:U\n";
      print "DS:enqueued_24h:GAUGE:600:0:U\n";
      print "DS:enqueued_36h:GAUGE:600:0:U\n";
      print "DS:enqueued_48h:GAUGE:600:0:U\n";
      print "DS:enqueued_60h:GAUGE:600:0:U\n";

      print "DS:deferred_5m:GAUGE:600:0:U\n";
      print "DS:deferred_10m:GAUGE:600:0:U\n";
      print "DS:deferred_15m:GAUGE:600:0:U\n";
      print "DS:deferred_30m:GAUGE:600:0:U\n";
      print "DS:deferred_60m:GAUGE:600:0:U\n";
      print "DS:deferred_90m:GAUGE:600:0:U\n";
      print "DS:deferred_2h:GAUGE:600:0:U\n";
      print "DS:deferred_4h:GAUGE:600:0:U\n";
      print "DS:deferred_8h:GAUGE:600:0:U\n";
      print "DS:deferred_12h:GAUGE:600:0:U\n";
      print "DS:deferred_18h:GAUGE:600:0:U\n";
      print "DS:deferred_24h:GAUGE:600:0:U\n";
      print "DS:deferred_36h:GAUGE:600:0:U\n";
      print "DS:deferred_48h:GAUGE:600:0:U\n";
      print "DS:deferred_60h:GAUGE:600:0:U\n";

      foreach $key ( @loop ) {
         undef(@line);
         push(@line,$buffer{"${key}_enqueued"});
         push(@line,$buffer{"${key}_deferred"});
         push(@line,$buffer{"${key}_retrying"});
         push(@line,$buffer{"${key}_holding"});

         push(@line,$buffer{"${key}_enqueued_5m"});
         push(@line,$buffer{"${key}_enqueued_10m"});
         push(@line,$buffer{"${key}_enqueued_15m"});
         push(@line,$buffer{"${key}_enqueued_30m"});
         push(@line,$buffer{"${key}_enqueued_60m"});
         push(@line,$buffer{"${key}_enqueued_90m"});
         push(@line,$buffer{"${key}_enqueued_2h"});
         push(@line,$buffer{"${key}_enqueued_4h"});
         push(@line,$buffer{"${key}_enqueued_8h"});
         push(@line,$buffer{"${key}_enqueued_12h"});
         push(@line,$buffer{"${key}_enqueued_18h"});
         push(@line,$buffer{"${key}_enqueued_24h"});
         push(@line,$buffer{"${key}_enqueued_36h"});
         push(@line,$buffer{"${key}_enqueued_48h"});
         push(@line,$buffer{"${key}_enqueued_60h"});

         push(@line,$buffer{"${key}_deferred_5m"});
         push(@line,$buffer{"${key}_deferred_10m"});
         push(@line,$buffer{"${key}_deferred_15m"});
         push(@line,$buffer{"${key}_deferred_30m"});
         push(@line,$buffer{"${key}_deferred_60m"});
         push(@line,$buffer{"${key}_deferred_90m"});
         push(@line,$buffer{"${key}_deferred_2h"});
         push(@line,$buffer{"${key}_deferred_4h"});
         push(@line,$buffer{"${key}_deferred_8h"});
         push(@line,$buffer{"${key}_deferred_12h"});
         push(@line,$buffer{"${key}_deferred_18h"});
         push(@line,$buffer{"${key}_deferred_24h"});
         push(@line,$buffer{"${key}_deferred_36h"});
         push(@line,$buffer{"${key}_deferred_48h"});
         push(@line,$buffer{"${key}_deferred_60h"});

         print "pmdf.$key.rrd\n";
         $line=join(':',@line);
         print "$line\n";
      }
   }
   if ( defined($buffer{"DISPs"}) ) {
      @loop=split(' ',$buffer{"DISPs"});

      print "DS:conns_cur:GAUGE:600:0:U\n";
      print "DS:conns_max:GAUGE:600:0:U\n";
      print "DS:conns_tot:DERIVE:600:0:U\n";
      print "DS:procs_cur:GAUGE:600:0:U\n";
      print "DS:procs_max:GAUGE:600:0:U\n";
      print "DS:procs_tot:DERIVE:600:0:U\n";

      foreach $key ( @loop ) {
         undef(@line);
         push(@line,$buffer{"${key}_Conns_cur"});
         push(@line,$buffer{"${key}_Conns_max"});
         push(@line,$buffer{"${key}_Conns_tot"});
         push(@line,$buffer{"${key}_Procs_cur"});
         push(@line,$buffer{"${key}_Procs_max"});
         push(@line,$buffer{"${key}_Procs_tot"});

         print "pmdfdisp.$key.rrd\n";
         $line=join(':',@line);
         print "$line\n";
      }
   }
   if ( defined($buffer{"DBs"}) ) {
      @loop=split(' ',$buffer{"DBs"});

      print "DS:cur:GAUGE:600:0:U\n";
      print "DS:max:GAUGE:600:0:U\n";

      foreach $key ( @loop ) {
         undef(@line);
         push(@line,$buffer{"${key}_cur"});
         push(@line,$buffer{"${key}_max"});

         print "pmdfdb.$key.rrd\n";
         $line=join(':',@line);
         print "$line\n";
      }
   }
} elsif ( $testname eq "mxgate" ) {
   if ( defined($buffer{"MTAs"}) ) {
      @loop=split(' ',$buffer{"MTAs"});

      print "DS:conns:GAUGE:600:0:U\n";
      print "DS:data_rate:GAUGE:600:0:U\n";
      print "DS:def_msgs:GAUGE:600:0:U\n";
      print "DS:msg_rate:GAUGE:600:0:U\n";
      print "DS:q_size:GAUGE:600:0:U\n";
      print "DS:q_msgs:GAUGE:600:0:U\n";

      foreach $key ( @loop ) {
         undef(@line);
         push(@line,$buffer{"${key}_conns"});
         push(@line,$buffer{"${key}_data_rate"});
         push(@line,$buffer{"${key}_def_msgs"});
         push(@line,$buffer{"${key}_msg_rate"});
         push(@line,$buffer{"${key}_q_size"});
         push(@line,$buffer{"${key}_q_msgs"});

         print "mxgate.$key.rrd\n";
         $line=join(':',@line);
         print "$line\n";
      }
   }
} elsif ( $testname eq "named" ) {
   if ( defined($buffer{"BINDs"}) ) {
      @loop=split(' ',$buffer{"BINDs"});

      print "DS:stats:DERIVE:600:0:U\n";

      foreach $key ( @loop ) {
         undef(@line);
         push(@line,$buffer{"${key}_stats"});

         print "bind.$key.rrd\n";
         $line=join(':',@line);
         print "$line\n";
      }
   }
} elsif ( $testname eq "exch" ) {
#      system("cp $fname /tmp/$hostname.out");
   if ( defined($buffer{"TESTs"}) ) {
      delete($buffer{"TESTs"});
      @loop=keys %buffer;

      print "DS:latency:GAUGE:600:0:U\n";

      foreach $key ( @loop ) {
         if ( $buffer{$key} eq "" ) { next };
         undef(@line);
         push(@line,$buffer{"$key"});

         print "exch.$key.rrd\n";
         $line=join(':',@line);
         print "$line\n";
      }
   }

}

exit 0;

